//
//  trustcache.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#import "trustcache.h"
#import "krw.h"
#import "offsets.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


BOOL trustCacheListAdd(uint64_t trustCacheKaddr)
{
    if (!trustCacheKaddr) return NO;

    uint64_t pmap_image4_trust_caches = off_trustcache + get_kslide();
    uint64_t curTc = kread64(pmap_image4_trust_caches);
    if(curTc == 0) {
        kwrite64(pmap_image4_trust_caches, trustCacheKaddr);
    }
    else {
        uint64_t prevTc = 0;
        while (curTc != 0)
        {
            prevTc = curTc;
            curTc = kread64(curTc);
        }
        kwrite64(prevTc, trustCacheKaddr);
    }

    return YES;
}

BOOL trustCacheListRemove(uint64_t trustCacheKaddr)
{
    if (!trustCacheKaddr) return NO;

    uint64_t nextPtr = kread64(trustCacheKaddr + offsetof(trustcache_page, nextPtr));

    uint64_t pmap_image4_trust_caches = off_trustcache + get_kslide();
    uint64_t curTc = kread64(pmap_image4_trust_caches);
    if (curTc == 0) {
        printf("WARNING: Tried to unlink trust cache page 0x%llX but pmap_image4_trust_caches points to 0x0\n", trustCacheKaddr);
        return NO;
    }
    else if (curTc == trustCacheKaddr) {
        kwrite64(pmap_image4_trust_caches, nextPtr);
    }
    else {
        uint64_t prevTc = 0;
        while (curTc != trustCacheKaddr)
        {
            if (curTc == 0) {
                printf("WARNING: Hit end of trust cache chain while trying to unlink trust cache page 0x%llX\n", trustCacheKaddr);
                return NO;
            }
            prevTc = curTc;
            curTc = kread64(curTc);
        }
        kwrite64(prevTc, nextPtr);
    }
    return YES;
}


uint64_t staticTrustCacheUploadFile(trustcache_file *fileToUpload, size_t fileSize, size_t *outMapSize)
{
    if (fileSize < sizeof(trustcache_file)) {
        printf("attempted to load a trustcache file that's too small.\n");
        return 0;
    }

    size_t expectedSize = sizeof(trustcache_file) + fileToUpload->length * sizeof(trustcache_entry);
    if (expectedSize != fileSize) {
        printf("attempted to load a trustcache file with an invalid size (0x%zX vs 0x%zX)\n", expectedSize, fileSize);
        return 0;
    }

    uint64_t mapSize = sizeof(trustcache_page) + fileSize;
    uint64_t mapKaddr;
//    uint64_t mapKaddr = kalloc(mapSize);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        mapKaddr = kalloc(FINAL_KFD, mapSize);

        //mapKaddr = kalloc2ndx(FINAL_KFD, mapSize);
    } else {
        mapKaddr = kalloc(FINAL_KFD, mapSize);
    }
    //kalloc2ndx(FINAL_KFD, mapSize);
    if (!mapKaddr) {
        printf("failed to allocate memory for trust cache file with size %zX\n", fileSize);
        return 0;
    }

    if (outMapSize) *outMapSize = mapSize;

    uint64_t mapSelfPtrPtr = mapKaddr + offsetof(trustcache_page, selfPtr);
    uint64_t mapSelfPtr = mapKaddr + offsetof(trustcache_page, file);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        
       // uint64_t v = (uint64_t)(mapSelfPtr);
        //do_kwrite((proc_ro) + 0x1CULL, &v, 4);
        kwrite64(mapSelfPtrPtr, mapSelfPtr);
        //do_kwrite(mapSelfPtrPtr, &v, 8);
        //do_kwrite(mapSelfPtrPtr, &v, 8);
        kwritebuf(mapSelfPtr, fileToUpload, fileSize);
    } else {
        kwrite64(mapSelfPtrPtr, mapSelfPtr);
        kwritebuf(mapSelfPtr, fileToUpload, fileSize);

    }
    trustCacheListAdd(mapKaddr);
    return mapKaddr;
}

uint64_t staticTrustCacheUploadFileAtPath(NSString *filePath, size_t *outMapSize)
{
    if (!filePath) return 0;
    NSData *tcData = [NSData dataWithContentsOfFile:filePath];
    if (!tcData) return 0;
    return staticTrustCacheUploadFile((trustcache_file *)tcData.bytes, tcData.length, outMapSize);
}

int loadTrustCacheBinaries(void) {
    printf("binaries.tc ret: 0x%llx\n", staticTrustCacheUploadFileAtPath([NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/binaries.tc"], NULL));
    
    return 0;
}

int loadTrustCacheBinpack(void) {
    printf("iosbinpack.tc ret: 0x%llx\n", staticTrustCacheUploadFileAtPath([NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/iosbinpack.tc"], NULL));
    printf("tar.tc ret: 0x%llx\n", staticTrustCacheUploadFileAtPath([NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar.tc"], NULL));
    
    return 0;
}

