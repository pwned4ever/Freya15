#import "trustcache.h"
#import "JBDTCPage.h"
#import "boot_info.h"
#import "kernel/krw.h"
#import "kernel/proc.h"
#import "macho.h"
#import "signatures.h"

int tcentryComparator(const void *vp1, const void *vp2) {
  trustcache_entry *tc1 = (trustcache_entry *)vp1;
  trustcache_entry *tc2 = (trustcache_entry *)vp2;
  return memcmp(tc1->hash, tc2->hash, CS_CDHASH_LEN);
}

JBDTCPage *trustCacheFindFreePage(void) {
  // Find page that has slots left
  for (JBDTCPage *page in gTCPages) {
    @autoreleasepool {
      if (page.amountOfSlotsLeft > 0) {
        NSLog(@"[jailbreakd] trustCacheFindFreePage returning page: %@", page);
        return page;
      }
    }
  }

  // No page found, allocate new one
  NSLog(@"[jailbreakd] trustCacheFindFreePage No page found, allocate new one");
  return [[JBDTCPage alloc] initAllocateAndLink];
}

BOOL isCdHashInTrustCache(NSData *cdHash) {
  kern_return_t kr;

  CFMutableDictionaryRef amfiServiceDict =
      IOServiceMatching("AppleMobileFileIntegrity");
  if (amfiServiceDict) {
    io_connect_t connect;
    io_service_t amfiService =
        IOServiceGetMatchingService(kIOMainPortDefault, amfiServiceDict);
    kr = IOServiceOpen(amfiService, mach_task_self(), 0, &connect);
    if (kr != KERN_SUCCESS) {
      NSLog(@"[jailbreakd] Failed to open amfi service %d %s", kr,
            mach_error_string(kr));
      return -2;
    }

    uint64_t includeLoadedTC = YES;
    kr = IOConnectCallMethod(
        connect, AMFI_IS_CD_HASH_IN_TRUST_CACHE, &includeLoadedTC, 1,
        CFDataGetBytePtr((__bridge CFDataRef)cdHash),
        CFDataGetLength((__bridge CFDataRef)cdHash), 0, 0, 0, 0);
    NSLog(@"[jailbreakd] Is %s in TrustCache? %s",
          cdHash.description.UTF8String, kr == 0 ? "Yes" : "No");

    IOServiceClose(connect);
    return kr == 0;
  }

  return NO;
}

BOOL trustCacheListAdd(uint64_t trustCacheKaddr) {
  NSLog(@"[jailbreakd] trustCacheListAdd: trustCacheKaddr: 0x%llx\n",
        trustCacheKaddr);
  if (!trustCacheKaddr)
    return NO;

  uint64_t pmap_image4_trust_caches = bootInfo_getSlidUInt64(@"off_trustcache");
  uint64_t curTc = kread64(pmap_image4_trust_caches);
  if (curTc == 0) {
    kwrite64(pmap_image4_trust_caches, trustCacheKaddr);
  } else {
    uint64_t prevTc = 0;
    while (curTc != 0) {
      prevTc = curTc;
      curTc = kread64(curTc);
    }
    kwrite64(prevTc, trustCacheKaddr);
  }

  return YES;
}

BOOL trustCacheListRemove(uint64_t trustCacheKaddr) {
  if (!trustCacheKaddr)
    return NO;

  uint64_t nextPtr =
      kread64(trustCacheKaddr + offsetof(trustcache_page, nextPtr));

  uint64_t pmap_image4_trust_caches = bootInfo_getSlidUInt64(@"off_trustcache");
  uint64_t curTc = kread64(pmap_image4_trust_caches);
  if (curTc == 0) {
    NSLog(@"[jailbreakd] WARNING: Tried to unlink trust cache page 0x%llX but "
           "pmap_image4_trust_caches points to 0x0",
          trustCacheKaddr);
    return NO;
  } else if (curTc == trustCacheKaddr) {
    kwrite64(pmap_image4_trust_caches, nextPtr);
  } else {
    uint64_t prevTc = 0;
    while (curTc != trustCacheKaddr) {
      if (curTc == 0) {
        NSLog(@"[jailbreakd] WARNING: Hit end of trust cache chain while "
              @"trying to "
               "unlink trust cache page 0x%llX",
              trustCacheKaddr);
        return NO;
      }
      prevTc = curTc;
      curTc = kread64(curTc);
    }
    kwrite64(prevTc, nextPtr);
  }
  return YES;
}

uint64_t staticTrustCacheUploadFile(trustcache_file *fileToUpload,
                                    size_t fileSize, size_t *outMapSize) {
  if (fileSize < sizeof(trustcache_file)) {
    NSLog(@"[jailbreakd] attempted to load a trustcache file that's too "
          @"small.\n");
    return 0;
  }

  size_t expectedSize =
      sizeof(trustcache_file) + fileToUpload->length * sizeof(trustcache_entry);
  if (expectedSize != fileSize) {
    NSLog(@"[jailbreakd] attempted to load a trustcache file with an invalid "
          @"size (0x%zX vs 0x%zX)\n",
          expectedSize, fileSize);
    return 0;
  }

  uint64_t mapSize = sizeof(trustcache_page) + fileSize;

  uint64_t mapKaddr = kalloc(mapSize);
  if (!mapKaddr) {
    NSLog(@"[jailbreakd] failed to allocate memory for trust cache file with "
          @"size %zX\n",
          fileSize);
    return 0;
  }

  if (outMapSize)
    *outMapSize = mapSize;

  uint64_t mapSelfPtrPtr = mapKaddr + offsetof(trustcache_page, selfPtr);
  uint64_t mapSelfPtr = mapKaddr + offsetof(trustcache_page, file);

  kwrite64(mapSelfPtrPtr, mapSelfPtr);

  kwritebuf(mapSelfPtr, fileToUpload, fileSize);

  trustCacheListAdd(mapKaddr);
  return mapKaddr;
}

void dynamicTrustCacheUploadCDHashesFromArray(NSArray *cdHashArray) {
  __block JBDTCPage *mappedInPage = nil;
  for (NSData *cdHash in cdHashArray) {
    @autoreleasepool {
      if (!mappedInPage || mappedInPage.amountOfSlotsLeft == 0) {
        // If there is still a page mapped, map it out now
        if (mappedInPage) {
          NSLog(@"[jailbreakd] there is still a page mapped, map it out now");
          [mappedInPage sort];
        }
        mappedInPage = trustCacheFindFreePage();
        NSLog(@"[jailbreakd] mappedInPage self: %@, kaddr: 0x%llx\n",
              mappedInPage, mappedInPage.kaddr);
      }

      trustcache_entry entry;
      memcpy(&entry.hash, cdHash.bytes, CS_CDHASH_LEN);
      entry.hash_type = 0x2;
      entry.flags = 0x0;
      NSLog(@"[jailbreakd] [dynamicTrustCacheUploadCDHashesFromArray] "
            @"uploading %s",
            cdHash.description.UTF8String);
      [mappedInPage addEntry:entry];
    }
  }

  if (mappedInPage) {
    [mappedInPage sort];
  }
  [mappedInPage updateTCPage];
}

int processBinary(NSString *binaryPath) {
  if (!binaryPath)
    return 0;
  if (![[NSFileManager defaultManager] fileExistsAtPath:binaryPath])
    return 0;

  int ret = 0;

  uint64_t selfproc = proc_of_pid(getpid());

  FILE *machoFile = fopen(binaryPath.fileSystemRepresentation, "rb");
  if (!machoFile)
    return 1;

  if (machoFile) {
    int fd = fileno(machoFile);

    bool isMacho = NO;
    bool isLibrary = NO;
    machoGetInfo(machoFile, &isMacho, &isLibrary);

    if (isMacho) {
      int64_t bestArchCandidate = machoFindBestArch(machoFile);
      if (bestArchCandidate >= 0) {
        uint32_t bestArch = bestArchCandidate;
        NSMutableArray *nonTrustCachedCDHashes = [NSMutableArray new];

        void (^tcCheckBlock)(NSString *) = ^(NSString *dependencyPath) {
          if (dependencyPath) {
            NSURL *dependencyURL = [NSURL fileURLWithPath:dependencyPath];
            NSData *cdHash = nil;
            BOOL isAdhocSigned = NO;
            evaluateSignature(dependencyURL, &cdHash, &isAdhocSigned);
            if (isAdhocSigned) {
              if (!isCdHashInTrustCache(cdHash)) {
                [nonTrustCachedCDHashes addObject:cdHash];
              }
            }
          }
        };

        tcCheckBlock(binaryPath);

        machoEnumerateDependencies(machoFile, bestArch, binaryPath,
                                   tcCheckBlock);

        dynamicTrustCacheUploadCDHashesFromArray(nonTrustCachedCDHashes);
      } else {
        ret = 3;
      }
    } else {
      ret = 2;
    }
    fclose(machoFile);
  } else {
    ret = 1;
  }

  return ret;
}

void fileEnumerateTrustCacheEntries(
    NSURL *fileURL, void (^enumerateBlock)(trustcache_entry entry)) {
  NSData *cdHash = nil;
  BOOL adhocSigned = NO;
  int evalRet = evaluateSignature(fileURL, &cdHash, &adhocSigned);
  if (evalRet == 0) {
    NSLog(@"[jailbreakd] %s cdHash: %s, adhocSigned: %d",
          fileURL.path.UTF8String, cdHash.description.UTF8String, adhocSigned);
    if (adhocSigned) {
      if ([cdHash length] == CS_CDHASH_LEN) {
        trustcache_entry entry;
        memcpy(&entry.hash, [cdHash bytes], CS_CDHASH_LEN);
        entry.hash_type = 0x2;
        entry.flags = 0x0;
        enumerateBlock(entry);
      }
    }
  } else if (evalRet != 4) {
    NSLog(@"[jailbreakd] evaluateSignature failed with error %d", evalRet);
  }
}

void dynamicTrustCacheUploadDirectory(NSString *directoryPath) {
  NSString *basebinPath = [[prebootPath(@"basebin")
      stringByResolvingSymlinksInPath] stringByStandardizingPath];
  NSString *resolvedPath = [[directoryPath stringByResolvingSymlinksInPath]
      stringByStandardizingPath];
  NSDirectoryEnumerator<NSURL *> *directoryEnumerator =
      [[NSFileManager defaultManager]
                     enumeratorAtURL:[NSURL fileURLWithPath:resolvedPath
                                                isDirectory:YES]
          includingPropertiesForKeys:@[ NSURLIsSymbolicLinkKey ]
                             options:0
                        errorHandler:nil];
  __block JBDTCPage *mappedInPage = nil;
  for (NSURL *enumURL in directoryEnumerator) {
    @autoreleasepool {
      NSNumber *isSymlink;
      [enumURL getResourceValue:&isSymlink
                         forKey:NSURLIsSymbolicLinkKey
                          error:nil];
      if (isSymlink && ![isSymlink boolValue]) {
        // never inject basebin binaries here
        if ([[[enumURL.path stringByResolvingSymlinksInPath]
                stringByStandardizingPath] hasPrefix:basebinPath])
          continue;
        fileEnumerateTrustCacheEntries(enumURL, ^(trustcache_entry entry) {
          if (!mappedInPage || mappedInPage.amountOfSlotsLeft == 0) {
            // If there is still a page mapped, map it out now
            if (mappedInPage) {
              [mappedInPage sort];
            }
            NSLog(@"[jailbreakd] mapping in a new tc page");
            mappedInPage = trustCacheFindFreePage();
          }

          // [mappedInPage updateTCPage];
          NSLog(@"[jailbreakd] [dynamicTrustCacheUploadDirectory %s] Uploading "
                @"cdhash of %s",
                directoryPath.UTF8String, enumURL.path.UTF8String);
          [mappedInPage addEntry:entry];
        });
      }
    }
  }

  if (mappedInPage) {
    [mappedInPage sort];
  }
  [mappedInPage updateTCPage];
}

void rebuildDynamicTrustCache(void) {
  // nuke existing
  for (JBDTCPage *page in [gTCPages reverseObjectEnumerator]) {
    @autoreleasepool {
      [page unlinkAndFree];
    }
  }

  NSLog(@"[jailbreakd] Triggering initial trustcache upload...");
  dynamicTrustCacheUploadDirectory(prebootPath(nil));
  NSLog(@"[jailbreakd] Initial TrustCache upload done!");
}

uint64_t staticTrustCacheUploadCDHashesFromArray(NSArray *cdHashArray,
                                                 size_t *outMapSize) {
  size_t fileSize =
      sizeof(trustcache_file) + cdHashArray.count * sizeof(trustcache_entry);
  trustcache_file *fileToUpload = (trustcache_file *)malloc(fileSize);

  uuid_generate(fileToUpload->uuid);
  fileToUpload->version = 1;
  fileToUpload->length = cdHashArray.count;

  [cdHashArray
      enumerateObjectsUsingBlock:^(NSData *cdHash, NSUInteger idx, BOOL *stop) {
        if (![cdHash isKindOfClass:[NSData class]])
          return;
        if (cdHash.length != CS_CDHASH_LEN)
          return;

        memcpy(&fileToUpload->entries[idx].hash, cdHash.bytes, cdHash.length);
        fileToUpload->entries[idx].hash_type = 0x2;
        fileToUpload->entries[idx].flags = 0x0;
      }];

  qsort(fileToUpload->entries, cdHashArray.count, sizeof(trustcache_entry),
        tcentryComparator);

  uint64_t mapKaddr =
      staticTrustCacheUploadFile(fileToUpload, fileSize, outMapSize);
  free(fileToUpload);
  return mapKaddr;
}