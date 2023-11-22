//
//  bootstrap.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/21.
//

#import "bootstrap.h"
#import "utils.h"
#import "escalate.h"
#import "proc.h"
#import "vnode.h"
#import "boot_info.h"
#import "offsets.h"
#import "krw.h"
#import "jailbreakd.h"
#include "../ViewController.h"
#import <stdbool.h>
#import <Foundation/Foundation.h>
#import <sys/stat.h>

#import "../libs/NSData/NSData+GZip.h"//"NSData+GZip.h"
#include "../libs/NSString/NSString+SHA256.h"

void extractGz(const char *from, const char *to) {
    NSData *gz = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@(from) ofType:@"gz"]];
    NSData *extracted = [gz gunzippedData];
    int fd = open(to, O_CREAT | O_WRONLY, 0755);
    write(fd, [extracted bytes], [extracted length]);
    close(fd);
}








typedef UInt32        IOOptionBits;
#define IO_OBJECT_NULL ((io_object_t)0)
typedef mach_port_t io_object_t;
typedef io_object_t io_registry_entry_t;
extern const mach_port_t kIOMainPortDefault;
typedef char io_string_t[512];

kern_return_t
IOObjectRelease(io_object_t object );

io_registry_entry_t
IORegistryEntryFromPath(mach_port_t, const io_string_t);

CFTypeRef
IORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);

extern char **environ;

int remountPrebootPartition(bool writable) {
    if(writable) {
        launch("/sbin/mount", "-u", "-w", "/private/preboot", NULL, NULL, NULL, NULL);
    } else {
        launch("/sbin/mount", "-u", "/private/preboot", NULL, NULL, NULL, NULL, NULL);
    }
    return 0;
}

char* getBootManifestHash(void) {
    io_registry_entry_t registryEntry = IORegistryEntryFromPath(kIOMainPortDefault, "IODeviceTree:/chosen");
    if (registryEntry == IO_OBJECT_NULL) {
        return NULL;
    }
    CFDataRef bootManifestHash = IORegistryEntryCreateCFProperty(registryEntry, CFSTR("boot-manifest-hash"), kCFAllocatorDefault, kNilOptions);
    if(!bootManifestHash) {
        return NULL;
    }
    
    IOObjectRelease(registryEntry);
    
    CFIndex length = CFDataGetLength(bootManifestHash) * 2 + 1;
    char *manifestHash = (char*)calloc(length, sizeof(char));
    
    int i = 0;
    for (i = 0; i<(int)CFDataGetLength(bootManifestHash); i++) {
        sprintf(manifestHash+i*2, "%02X", CFDataGetBytePtr(bootManifestHash)[i]);
    }
    manifestHash[i*2] = 0;
    
    CFRelease(bootManifestHash);
    
    return manifestHash;
}


int UUIDPathPermissionFixup(void) {
    NSString *UUIDPath = [NSString stringWithFormat:@"%s%s", "/private/preboot/", getBootManifestHash()];
//    printf("UUIDPath: %s\n", UUIDPath.UTF8String);
    
    struct stat UUIDPathStat;
    if (stat(UUIDPath.UTF8String, &UUIDPathStat) != 0) {
      //  printf("Failed to stat %s", UUIDPath.UTF8String);
        return -1;
    }
    
    uid_t curOwnerID = UUIDPathStat.st_uid;
    gid_t curGroupID = UUIDPathStat.st_gid;
    if (curOwnerID != 0 || curGroupID != 0) {
        if (chown(UUIDPath.UTF8String, 0, 0) != 0) {
        //    printf("Failed to chown 0:0 %s", UUIDPath.UTF8String);
            return -1;
        }
    }
    
    mode_t curPermissions = UUIDPathStat.st_mode & S_IRWXU;
    if (curPermissions != 0755) {
        if (chmod(UUIDPath.UTF8String, 0755) != 0) {
          //  printf("Failed to chmod 755 %s", UUIDPath.UTF8String);
            return -1;
        }
    }
    
    return 0;
}

#include "../util/utilsZS.h"
#import <UIKit/UIKit.h>

void util_debug(const char * fmt, ...) __printflike(1, 2);
void util_info(const char * fmt, ...) __printflike(1, 2);
void util_warning(const char * fmt, ...) __printflike(1, 2);
void util_error(const char * fmt, ...) __printflike(1, 2);
void util_printf(const char * fmt, ...) __printflike(1, 2);
void util_hexprint(void *data, size_t len, const char *desc);
void util_hexprint_width(void *data, size_t len, int width, const char *desc);
void util_nanosleep(uint64_t nanosecs);
void util_msleep(unsigned int ms);
_Noreturn void fail_info(const char *info);
void fail_if(bool cond, const char *fmt, ...)  __printflike(2, 3);

void wipeSymlink(NSString *path) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&error];
    if (!error) {
        NSString *fileType = attributes[NSFileType];
        if ([fileType isEqualToString:NSFileTypeSymbolicLink]) {
            [fileManager removeItemAtPath:path error:&error];
            if (!error) {
             //   util_printf("Deleted symlink at %s\n", path.UTF8String);
            }
        } else {
            //[Logger print:[NSString stringWithFormat:@"Wanted to delete symlink at %@, but it is not a symlink", path]];
        }
    } else {
        //[Logger print:[NSString stringWithFormat:@"Wanted to delete symlink at %@, error occurred: %@, but we ignore it", path, error]];
    }
}

char* locateExistingFakeRoot(void) {
    NSString *bootManifestHash = [NSString stringWithUTF8String:getBootManifestHash()];
    if (!bootManifestHash) {
        return NULL;
    }
    
    NSString *ppPath = [NSString stringWithFormat:@"/private/preboot/%@", bootManifestHash];
    NSError *error = nil;
    NSArray<NSString *> *candidateURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ppPath error:&error];
    if (!error) {
        for (NSString *candidatePath in candidateURLs) {
            if ([candidatePath.lastPathComponent hasPrefix:@"jb-"]) {
                char *ret = malloc(1024);
                strcpy(ret, [NSString stringWithFormat:@"%@/%@", ppPath, candidatePath].UTF8String);
                
                return ret;
            }
        }
    }
    return NULL;
}

char* generateFakeRootPath(void) {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *result = [NSMutableString stringWithCapacity:6];
    
    for (NSUInteger i = 0; i < 6; i++) {
        NSUInteger randomIndex = arc4random_uniform((uint32_t)[letters length]);
        unichar randomCharacter = [letters characterAtIndex:randomIndex];
        [result appendFormat:@"%C", randomCharacter];
    }
    
    NSString *bootManifestHash = [NSString stringWithUTF8String:getBootManifestHash()];
    if (!bootManifestHash) {
        return NULL;
    }
    
    NSString *fakeRootPath = [NSString stringWithFormat:@"/private/preboot/%@/jb-%@", bootManifestHash, result];
    return fakeRootPath.UTF8String;
}

void createSymbolicLinkAtPath_withDestinationPath(char* path, char* pathContent) {
    NSString *path_ns = [NSString stringWithUTF8String:path];
    NSString *pathContent_ns = [NSString stringWithUTF8String:pathContent];
    NSArray<NSString *> *components = [path_ns componentsSeparatedByString:@"/"];
    NSString *directoryPath = [[components subarrayWithRange:NSMakeRange(0, components.count - 1)] componentsJoinedByString:@"/"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Failed to create directory. Error: %@", error);
            return;
        }
    }
    
    NSError *error = nil;
    [fileManager createSymbolicLinkAtPath:path_ns withDestinationPath:pathContent_ns error:&error];
    if (error) {
        NSLog(@"Failed to create symbolic link. Error: %@", error);
    }
}

int untar(char* tarPath, char* target) {
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    
    NSString *tarBinary = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar"];
    chmod(tarBinary.UTF8String, 0755);
    
    pid_t pid;
    const char* args[] = {"tar", "--preserve-permissions", "-xkf", tarPath, "-C", target, NULL};
    
    int status = posix_spawn(&pid, tarBinary.UTF8String, NULL, &attr, (char **)&args, environ);
    if(status == 0) {
        rootify(pid);
        kill(pid, SIGCONT);
        
        if(waitpid(pid, &status, 0) == -1) {
            util_printf("waitpid error");
        }
        
    }
    util_printf("untar posix_spawn status: %d\n", status);
    
    return 0;
}

void patchBaseBinLaunchDaemonPlist(NSString *plistPath)
{
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (plistDict) {
        NSMutableArray *programArguments = ((NSArray *)plistDict[@"ProgramArguments"]).mutableCopy;
        if (programArguments.count >= 1) {
            NSString *pathBefore = programArguments[0];
            if (![pathBefore hasPrefix:@"/private/preboot"]) {
                programArguments[0] = prebootPath(pathBefore);
                plistDict[@"ProgramArguments"] = programArguments.copy;
                [plistDict writeToFile:plistPath atomically:YES];
            }
        }
    }
}

void patchBaseBinLaunchDaemonPlists(void)
{
    NSURL *launchDaemonURL = [NSURL fileURLWithPath:prebootPath(@"basebin/LaunchDaemons") isDirectory:YES];
    NSArray<NSURL *> *launchDaemonPlistURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:launchDaemonURL includingPropertiesForKeys:nil options:0 error:nil];
    for (NSURL *launchDaemonPlistURL in launchDaemonPlistURLs) {
        patchBaseBinLaunchDaemonPlist(launchDaemonPlistURL.path);
    }
}

int untarBinaries(void) {
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    
    NSString *tarPath = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar"];
    chmod(tarPath.UTF8String, 0755);
    char* binariesTar = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/binaries.tar"].UTF8String;
    
    pid_t pid;///private/var/jb/tar"
   // const char* args[] = {"tar", "--preserve-permissions", "-xkf", binariesTar, "-C", NSBundle.mainBundle.bundlePath.UTF8String, NULL};
    const char* args[] = {"tar", "--preserve-permissions", "-xkf", binariesTar, "-C", NSBundle.mainBundle.bundlePath.UTF8String, NULL};

    int status = posix_spawn(&pid, tarPath.UTF8String, NULL, &attr, (char **)&args, environ);
    if(status == 0) {
        rootify(pid);
        kill(pid, SIGCONT);
        
        if(waitpid(pid, &status, 0) == -1) {
            util_printf("waitpid error");
        }
        
    }
    util_printf(@"untarBinaries posix_spawn status: %d\n", status);
    
    return 0;
}

int untarBootstrap(void) {
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    
    NSString *tarPath = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar"];
    chmod(tarPath.UTF8String, 0755);
    char* binariesTar = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/bootstrap-iphoneos-arm64.tar"].UTF8String;
    
    pid_t pid;///private/var/jb/tar"
   // const char* args[] = {"tar", "--preserve-permissions", "-xkf", binariesTar, "-C", NSBundle.mainBundle.bundlePath.UTF8String, NULL};
    const char* args[] = {"tar", "--preserve-permissions", "-xkf", "/var/pwnstrap/bootstrap-iphoneos-arm64.tar", "-C", "/", NULL};

    int status = posix_spawn(&pid, tarPath.UTF8String, NULL, &attr, (char **)&args, environ);
    if(status == 0) {
        rootify(pid);
        kill(pid, SIGCONT);
        
        if(waitpid(pid, &status, 0) == -1) {
            util_printf("waitpid error");
        }
        
    }
    util_printf(@"untarBootstrao..... posix_spawn status: %d\n", status);
    
    return 0;
}


#define ldiddy "/private/var/containers/Bundle/jb_resources/bin/ldid"
#define ldiddy1 "/private/var/containers/Bundle/jb_resources/bin/ldid1"
#define signthecertp12 "/private/var/containers/Bundle/jb_resources/signcert.p12"
#define theEnts "/private/var/containers/Bundle/jb_resources/Ent.plist"
#define globalEnts "/private/var/containers/Bundle/jb_resources/global.xml"

pid_t pd;

void copy_tar(void) {

    
    NSString *tarBinary = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar.gz"];
    
    
    extractGz(tarBinary.UTF8String, "/private/var/jb/tar");
    chmod(tarBinary.UTF8String, 0755);

    //trustbin("/private/var/containers/Bundle/jb_resources/tar");
   // posix_spawn(&pd, ldiddy, NULL, NULL, (char **)&(const char*[]){ ldiddy, NULL, NULL }, NULL);
   // waitpid(pd, NULL, 0);
   // posix_spawn(&pd, ldiddy, NULL, NULL, (char **)&(const char*[]){ ldiddy, "-S/private/var/containers/Bundle/jb_resources/global.xml", "-M", "-K/private/var/containers/Bundle/jb_resources/signcert.p12", "/private/var/containers/Bundle/jb_resources/tar", NULL }, NULL);
   // waitpid(pd, NULL, 0);
   // posix_spawn(&pd, ldiddy, NULL, NULL, (char **)&(const char*[]){ ldiddy, "-S"&&globalEnts, "-M", "-K"&&signthecertp12, NULL }, NULL);
    //waitpid(pd, NULL, 0);
   // inject_trusts(1, (const char **)&(const char*[]){tar});
}

/*void dothetar(void){
    pid_t pd;
    extractGz("zuesstrap.tar", "/private/var/containers/Bundle/jb_resources/zuesstrap.tar");

    posix_spawn(&pd, tar, NULL, NULL, (char **)&(const char*[]){ tar, "--preserve-permissions", "-xvkf", "/private/var/containers/Bundle/jb_resources/zuesstrap.tar", "-C", "/private/var/containers/Bundle/jb_resources/", NULL }, NULL);
    waitpid(pd, NULL, 0);

    unlink("/private/var/containers/Bundle/jb_resources/zuesstrap.tar");

    unlink("/private/var/containers/Bundle/jb_resources/usr/libexec/cydia/move.sh");

}
*/


int extractBootstrap(void) {
    char* jbPath = "/var/jb";
    NSString *jbPath_ns = [NSString stringWithUTF8String:jbPath];
    remountPrebootPartition(true);
    
    while(access([NSString stringWithFormat:@"/private/preboot/%s", getBootManifestHash()].UTF8String, R_OK | W_OK) != 0) {;};
    
    if(UUIDPathPermissionFixup() != 0) {
        return -1;
    }
    wipeSymlink(jbPath_ns);
    if(access(jbPath, F_OK) == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:jbPath_ns error:nil];
    }
    
    char* fakeRootPath = locateExistingFakeRoot();
//    printf("fakeRootPath: %s\n", fakeRootPath);
    
    if(fakeRootPath == NULL) {
        fakeRootPath = generateFakeRootPath();
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithUTF8String:fakeRootPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    bool bootstrapNeedsExtract = false;
    NSString* procursusPath = [NSString stringWithFormat:@"%s%s", fakeRootPath, "/procursus"];
    NSString* installedPath = [NSString stringWithFormat:@"%@%s", procursusPath, "/.installed_Freya15"];
    NSString* prereleasePath = [NSString stringWithFormat:@"%@%s", procursusPath, "/.used_kfund_prerelease"];
    
    if(access(procursusPath.UTF8String, F_OK) == 0) {
        if(access(installedPath.UTF8String, F_OK) != 0) {
            util_printf("Wiping existing bootstrap because installed file not found");
            [[NSFileManager defaultManager] removeItemAtPath:procursusPath error:nil];
        }
        if(access(prereleasePath.UTF8String, F_OK) == 0) {
            util_printf("Wiping existing bootstrap because pre release");
            [[NSFileManager defaultManager] removeItemAtPath:procursusPath error:nil];
        }
    }
    
    if(access(procursusPath.UTF8String, F_OK) != 0) {
        [[NSFileManager defaultManager] createDirectoryAtPath:procursusPath withIntermediateDirectories:YES attributes:nil error:nil];
        bootstrapNeedsExtract = true;
    }
    
    // Update basebin (should be done every rejailbreak)
    NSString *basebinPath = [NSString stringWithFormat:@"%@/basebin", procursusPath];
    if(access(basebinPath.UTF8String, F_OK) == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:basebinPath error:nil];
    }
    util_printf("mkdir ret: %d\n", mkdir(basebinPath.UTF8String, 0755));
    
//    let untarRet = untar(tarPath: basebinTarPath, target: procursusPath)
//    if untarRet != 0 {
//        throw BootstrapError.custom(String(format:"Failed to untar Basebin: \(String(describing: untarRet))"))
//    }
    createSymbolicLinkAtPath_withDestinationPath(jbPath, procursusPath.UTF8String);
    
   // [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%s", procursusPath, "/.installed_kfund"] error:nil];
 
   // NSString *boottarPath = [NSString stringWithFormat:@"%@", NSBundle.mainBundle.bundlePath, "tar"];
    NSString *boottarPathextract = [NSString stringWithFormat:@"%@%s", NSBundle.mainBundle.bundlePath, "/iosbinpack/tar"];

    extractGz("tar", boottarPathextract.UTF8String);
    extractGz("tar", procursusPath.UTF8String);

    
    if(bootstrapNeedsExtract) {
        NSString *bootstrapPath = [NSString stringWithFormat:@"%@%s", NSBundle.mainBundle.bundlePath, "/iosbinpack/bootstrap-iphoneos-arm64.tar"];
        mkdir("/var/pwnstrap", 0755);
        
        extractGz("/iosbinpack/bootstrap-iphoneos-arm64.tar", "/var/pwnstrap/bootstrap-iphoneos-arm64.tar");
//        NSString *bootstrapPath = [NSString stringWithFormat:@"%@%s", NSBundle.mainBundle.bundlePath, "/iosbinpack/bootstrap-iphoneos-arm64.tar.gz"];
        untarBootstrap();
        //untar(bootstrapPath.UTF8String, NSBundle.mainBundle.bundlePath.UTF8String);
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/pwnstrap" error:nil];

        [@"" writeToFile:installedPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    // Create basebin symlinks if they don't exist
//    if !fileOrSymlinkExists(atPath: "/var/jb/usr/bin/opainject") {
//        try createSymbolicLink(atPath: "/var/jb/usr/bin/opainject", withDestinationPath: procursusPath + "/basebin/opainject")
//    }
//    if !fileOrSymlinkExists(atPath: "/var/jb/usr/bin/jbctl") {
//        try createSymbolicLink(atPath: "/var/jb/usr/bin/jbctl", withDestinationPath: procursusPath + "/basebin/jbctl")
//    }
//    if !fileOrSymlinkExists(atPath: "/var/jb/usr/lib/libjailbreak.dylib") {
//        try createSymbolicLink(atPath: "/var/jb/usr/lib/libjailbreak.dylib", withDestinationPath: procursusPath + "/basebin/libjailbreak.dylib")
//    }
//    if !fileOrSymlinkExists(atPath: "/var/jb/usr/lib/libfilecom.dylib") {
//        try createSymbolicLink(atPath: "/var/jb/usr/lib/libfilecom.dylib", withDestinationPath: procursusPath + "/basebin/libfilecom.dylib")
//    }
    
    //extractGz("/iosbinpack/bootstrap-iphoneos-arm64.tar", bootstrapPath.UTF8String);

//    0.untar
    untarBinaries();
//    usleep(1500000);

    //1. Copy kr.h4ck.jailbreak.plist to LaunchDaemons
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/LaunchDaemons" error:nil];
    mkdir("/var/jb/basebin/LaunchDaemons", 0755);
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/LaunchDaemons/kr.h4ck.jailbreakd.plist" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/kr.h4ck.jailbreakd.plist", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/LaunchDaemons/kr.h4ck.jailbreakd.plist" error:nil];
    chown("/var/jb/basebin/LaunchDaemons/kr.h4ck.jailbreakd.plist", 0, 0);
    //2. Copy jailbreakd to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/jailbreakd" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/jailbreakd", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/jailbreakd" error:nil];
    chown("/var/jb/basebin/jailbreakd", 0, 0);
    chmod("/var/jb/basebin/jailbreakd", 0755);
    //3. Copy jbinit to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/jbinit" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/jbinit", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/jbinit" error:nil];
    chown("/var/jb/basebin/jbinit", 0, 0);
    chmod("/var/jb/basebin/jbinit", 0755);
    //4. Copy launchdhook.dylib to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/launchdhook.dylib" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/launchdhook.dylib", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/launchdhook.dylib" error:nil];
    chown("/var/jb/basebin/launchdhook.dylib", 0, 0);
    chmod("/var/jb/basebin/launchdhook.dylib", 0755);
    //5. Copy opainject to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/opainject" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/opainject", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/opainject" error:nil];
    chown("/var/jb/basebin/opainject", 0, 0);
    chmod("/var/jb/basebin/opainject", 0755);
    //6. Copy fallback(CydiaSubstrate) to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/fallback" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/fallback", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/fallback" error:nil];
    chown("/var/jb/basebin/fallback", 0, 0);
    chmod("/var/jb/basebin/fallback", 0755);
    chown("/var/jb/basebin/fallback/CydiaSubstrate.framework", 0, 0);
    chmod("/var/jb/basebin/fallback/CydiaSubstrate.framework", 0755);
    chown("/var/jb/basebin/fallback/CydiaSubstrate.framework/CydiaSubstrate", 0, 0);
    chmod("/var/jb/basebin/fallback/CydiaSubstrate.framework/CydiaSubstrate", 0644);
    //7. Copy systemhook.dylib to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/systemhook.dylib" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/systemhook.dylib", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/systemhook.dylib" error:nil];
    chown("/var/jb/basebin/systemhook.dylib", 0, 0);
    chmod("/var/jb/basebin/systemhook.dylib", 0755);
    //8. Copy rootlesshooks.dylib to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/rootlesshooks.dylib" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/rootlesshooks.dylib", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/systemhook.dylib" error:nil];
    chown("/var/jb/basebin/rootlesshooks.dylib", 0, 0);
    chmod("/var/jb/basebin/rootlesshooks.dylib", 0755);
    //9. Copy jbctl to basebin
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb/basebin/jbctl" error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/binaries/jbctl", NSBundle.mainBundle.bundlePath] toPath:@"/var/jb/basebin/jbctl" error:nil];
    chown("/var/jb/basebin/jbctl", 0, 0);
    chmod("/var/jb/basebin/jbctl", 0755);
    //10. Copy default.sources
    NSString *default_sources_path = [NSString stringWithFormat:@"%@/binaries/default.sources", NSBundle.mainBundle.resourcePath];
    [[NSFileManager defaultManager] copyItemAtPath:default_sources_path toPath:@"/var/jb/etc/apt/sources.list.d/default.sources" error:nil];
    chmod("/var/jb/etc/apt/sources.list.d/default.sources", 0644);
    chown("/var/jb/etc/apt/sources.list.d/default.sources", 0, 0);
    //Final. Remove
    util_printf("binaries access ret: %d\n", access([NSString stringWithFormat:@"%@/binaries", NSBundle.mainBundle.bundlePath].UTF8String, F_OK));
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/binaries", NSBundle.mainBundle.bundlePath] error:nil];
    util_printf("binaries access ret2: %d\n", access([NSString stringWithFormat:@"%@/binaries", NSBundle.mainBundle.bundlePath].UTF8String, F_OK));
    
    // Create preferences directory if it does not exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:@"/var/jb/var/mobile/Library/Preferences"]) {
        NSDictionary *attributes = @{NSFilePosixPermissions: @(0755), NSFileOwnerAccountID: @(501), NSFileGroupOwnerAccountID: @(501)};
        
        [fileManager createDirectoryAtPath:@"/var/jb/var/mobile/Library/Preferences" withIntermediateDirectories:YES attributes:attributes error:nil];
    }
    

    // Write boot info from cache to disk
    NSMutableDictionary *cachedBootInfo = [NSMutableDictionary dictionary];
    NSString *bootInfoPath = @"/var/jb/basebin/boot_info.plist";
    BOOL success = [cachedBootInfo writeToFile:bootInfoPath atomically:YES];
    if (!success) {
        util_printf("[-] Failed create boot_info.plist.\n");
        return -1;
    }
    
    //Save some boot_info
    bootInfo_setObject(@"off_kalloc_data_external", @(off_kalloc_data_external));
    bootInfo_setObject(@"off_kfree_data_external", @(off_kfree_data_external));
    bootInfo_setObject(@"off_add_x0_x0_0x40_ret", @(off_add_x0_x0_0x40_ret));
    bootInfo_setObject(@"off_empty_kdata_page", @(off_empty_kdata_page));
    bootInfo_setObject(@"off_trustcache", @(off_trustcache));
    bootInfo_setObject(@"off_gphysbase", @(off_gphysbase));
    bootInfo_setObject(@"off_gphyssize", @(off_gphyssize));
    bootInfo_setObject(@"off_pmap_enter_options_addr", @(off_pmap_enter_options_addr));
    bootInfo_setObject(@"off_allproc", @(off_allproc));
    NSDictionary *tmp_kfd_arm64 = [NSDictionary dictionaryWithContentsOfFile:@"/tmp/kfd-arm64.plist"];
    bootInfo_setObject(@"kcall_fake_vtable_allocations", @([tmp_kfd_arm64[@"kcall_fake_vtable_allocations"] unsignedLongLongValue]));
    bootInfo_setObject(@"kcall_fake_client_allocations", @([tmp_kfd_arm64[@"kcall_fake_client_allocations"] unsignedLongLongValue]));
    bootInfo_setObject(@"kernelslide", @(get_kslide()));
    
    return 0;
}

bool needsFinalizeBootstrap(void) {
    if(access("/var/jb/prep_bootstrap.sh", F_OK) == 0) {
        return true;
    }
    return false;
}

int finalizeBootstrap(void) {
    //1. run /var/jb/prep_bootstrap.sh
    util_runCommand("/var/jb/bin/sh", "/var/jb/prep_bootstrap.sh", NULL);
    
    //2. install libkrw0-kfund.deb (libjbdrw)
    util_runCommand("/var/jb/usr/bin/dpkg", "-i", [NSString stringWithFormat:@"%@/debs/libkrw0-kfund.deb", NSBundle.mainBundle.bundlePath].UTF8String, NULL);
    
    //3. Install package manager(sileo or zebra)
    util_runCommand("/var/jb/usr/bin/dpkg", "-i", [NSString stringWithFormat:@"%@/debs/sileo.deb", NSBundle.mainBundle.bundlePath].UTF8String, NULL);
    util_runCommand("/var/jb/usr/bin/uicache", "-p", "/var/jb/Applications/Sileo.app", NULL);
    
    util_runCommand("/var/jb/usr/bin/dpkg", "-i", [NSString stringWithFormat:@"%@/debs/zebra.deb", NSBundle.mainBundle.bundlePath].UTF8String, NULL);
    util_runCommand("/var/jb/usr/bin/uicache", "-p", "/var/jb/Applications/Zebra.app", NULL);
    
    //4. Install NewTerm3
    util_runCommand("/var/jb/usr/bin/dpkg", "-i", [NSString stringWithFormat:@"%@/debs/newterm3.deb", NSBundle.mainBundle.bundlePath].UTF8String, NULL);
    util_runCommand("/var/jb/usr/bin/uicache", "-p", "/var/jb/Applications/NewTerm.app", NULL);
    
    //5. Install Tweak Injector (Ellekit)
    util_runCommand("/var/jb/usr/bin/dpkg", "-i", [NSString stringWithFormat:@"%@/debs/ellekit_noautoload.deb", NSBundle.mainBundle.bundlePath].UTF8String, NULL);
    
    
    return 0;
}


int startJBEnvironment(void) {
    setenv("PATH", "/sbin:/bin:/usr/sbin:/usr/bin:/var/jb/sbin:/var/jb/bin:/var/jb/usr/sbin:/var/jb/usr/bin", 1);
    setenv("TERM", "xterm-256color", 1);
  /*
    char* fakeRootPath = locateExistingFakeRoot();
//    printf("fakeRootPath: %s\n", fakeRootPath);
    
    if(fakeRootPath == NULL) {
        fakeRootPath = generateFakeRootPath();
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithUTF8String:fakeRootPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
   // bool bootstrapNeedsExtract = false;
    NSString* procursusPath = [NSString stringWithFormat:@"%s%s", fakeRootPath, "/procursus"];
    NSString* installedPath = [NSString stringWithFormat:@"%@%s", procursusPath, "/.installed_kfund"];
    NSString* prereleasePath = [NSString stringWithFormat:@"%@%s", procursusPath, "/.used_kfund_prerelease"];
    
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%s", procursusPath, "/.installed_kfund"] error:nil];
*/
    
    util_printf("Extracting bootstrap...\n");
    extractBootstrap();
    patchBaseBinLaunchDaemonPlists();
    util_printf("Starting jailbreakd...\n");
    startJailbreakd();
    util_printf("Rebuilding trustcache...\n");
    util_printf("jbdRebuildTrustCache ret: %lld\n", jbdRebuildTrustCache());
    
    if (needsFinalizeBootstrap()) {
        util_printf("Status: Finalizing Bootstrap...\n");
        finalizeBootstrap();
    }
  //  finalizeBootstrap();

    util_printf("Status: Initializing Environment...\n");
    util_printf("jbdInitEnvironment ret: %lld\n", jbdInitEnvironment());
    
    util_printf("Status: Initializing System Hook...\n");
    platformize(1);    //orginally implemented from launchdhook
    util_runCommand("/var/jb/basebin/opainject", "1", "/var/jb/basebin/launchdhook.dylib", NULL);
    
    util_printf("Status: Starting Launch Daemons...\n");
    util_runCommand("/var/jb/usr/bin/launchctl", "bootstrap", "system", "/var/jb/Library/LaunchDaemons", NULL);
    
    //Kill cfprefsd to inject rootlesshooks.dylib
    util_runCommand("/var/jb/usr/bin/killall", "-9", "cfprefsd", NULL);
    
    //Anything else... to inject tweaks
    util_runCommand("/var/jb/usr/bin/killall", "-9", "chronod", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "mediaserverd", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "securityd", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "runningboardd", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "installd", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "profiled", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "assertiond", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "quicklookd", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "InCallService", NULL);
    util_runCommand("/var/jb/usr/bin/killall", "-9", "SharingViewService", NULL);
    
    //Refreshing uicache
    util_runCommand("/var/jb/usr/bin/killall", "-9", "iconservicesagent", NULL);
    util_runCommand("/var/jb/usr/bin/uicache", "-a", NULL);
    [@"Unleashed the sword" writeToFile:@"/tmp/.jailbroken_freya" atomically:YES encoding:NSUTF8StringEncoding error:nil];


    return 0;
}

void restorewithnojbfound(void) {
  /*  struct passwd *const root_pw = getpwnam("root");

    int const rootfd = open("/", O_RDONLY);_assert(rootfd > 0, localize(@"Unable to open RootFS."), true);const char **snapshots = snapshot_list(rootfd);
    _assert(snapshots != NULL, localize(@"Unable to get snapshots for RootFS."), true);
    _assert(*snapshots != NULL, localize(@"Found no snapshot for RootFS."), true);
    char *snapshot = strdup(*snapshots);util_info("%s", snapshot);_assert(snapshot != NULL, localize(@"Unable to find original snapshot for RootFS."), true);
    char *systemSnapshot = copySystemSnapshot();_assert(systemSnapshot != NULL, localize(@"Unable to copy system snapshot."), true);
    _assert(fs_snapshot_rename(rootfd, snapshot, systemSnapshot, 0) == ERR_SUCCESS, localize(@"Unable to rename original snapshot."), true);
    free(snapshot);snapshot = NULL;snapshot = strdup(systemSnapshot);_assert(snapshot != NULL, localize(@"Unable to duplicate string."), true);
    free(systemSnapshot);systemSnapshot = NULL;
    
    char *const systemSnapshotMountPoint = "/var/rootfsmnt"; //freya removing
    if (is_mountpoint(systemSnapshotMountPoint)) {
        _assert(unmount(systemSnapshotMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount old RootFS mount point."), true);}
    _assert(clean_file(systemSnapshotMountPoint), localize(@"Unable to clean old snapshot mount point."), true);
    _assert(ensure_directory(systemSnapshotMountPoint, root_pw->pw_uid, 0755), localize(@"Unable to create snapshot mount point."), true);
    _assert(fs_snapshot_mount(rootfd, systemSnapshotMountPoint, snapshot, 0) == ERR_SUCCESS, localize(@"Unable to mount original snapshot."), true);
    const char *systemSnapshotLaunchdPath = [@(systemSnapshotMountPoint) stringByAppendingPathComponent:@"sbin/launchd"].UTF8String;
    _assert(waitFF(systemSnapshotLaunchdPath) == ERR_SUCCESS, localize(@"Unable to verify mounted snapshot."), true);
    //_assert(execCmd("/usr/bin/rsync", "-vaxcH", "--progress", "--delete", [@(systemSnapshotMountPoint) stringByAppendingPathComponent:@"Applications/."].UTF8String, "/Applications", NULL) == 0, localize(@"Unable to sync /Applications."), true);
    _assert(unmount(systemSnapshotMountPoint, MNT_FORCE) == ERR_SUCCESS, localize(@"Unable to unmount original snapshot mount point."), true);
    close(rootfd);
    ourprogressMeter();free(snapshot);snapshot = NULL;free(snapshots);snapshots = NULL;
    ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();

    _assert(clean_file("/usr/bin/find"), localize(@"Unable to clean find binary."), true);
    util_info("Successfully reverted back RootFS remount. Cleaning up...");
    NSArray *const cleanUpFileList = @[@"/var/cache",
                                       @"/var/freya",
                                       @"/var/lib",
                                       @"/var/stash",
                                       @"/var/db/stash",
                                       @"/var/mobile/Library/Cydia",
                                       @"/var/mobile/Library/Caches/com.saurik.Cydia",
                                       @"/etc/apt/sources.list.d",
                                       @"/etc/apt/sources.list",
                                       @"/private/etc/apt",
                                       @"/private/etc/alternatives",
                                       @"/private/etc/default",
                                       @"/private/etc/dpkg",
                                       @"/private/etc/dropbear",
                                       @"/private/etc/localtime",
                                       @"/private/etc/motd",
                                       @"/private/etc/pam.d",
                                       @"/private/etc/profile",
                                       @"/private/etc/pkcs11",
                                       @"/private/etc/profile.d",
                                       @"/private/etc/profile.ro",
                                       @"/private/etc/rc.d",
                                       @"/private/etc/resolv.conf",
                                       @"/private/etc/ssh",
                                       @"/private/etc/ssl",
                                       @"/private/etc/sudo_logsrvd.conf",
                                       @"/private/etc/sudo.conf",
                                       @"/private/etc/sudo_logsrvd.conf",
                                       @"/private/etc/sudoers",
                                       @"/private/etc/sudoers.d",
                                       @"/private/etc/sudoers.dist",
                                       @"/private/etc/wgetrc",
                                       @"/private/etc/symlibs.dylib",
                                       @"/private/etc/zshrc",
                                       @"/private/etc/zprofile",
                                       @"/private/private",
                                       @"/private/jb",
                                       @"/private/var/containers/Bundle/dylibs",
                                       @"/private/var/containers/Bundle/iosbinpack64",
                                       @"/private/var/containers/Bundle/tweaksupport",
                                       @"/private/var/log/suckmyd-stderr.log",
                                       @"/private/var/log/suckmyd-stdout.log",
                                       @"/private/var/log/jailbreakd-stderr.log",
                                       @"/private/var/log/jailbreakd-stdout.log",
                                       @"/Library/dpkg",
                                       @"/private/var/backups",
                                       @"/private/var/empty",
                                       @"/private/var/bin",
                                       @"/private/var/cache",
                                       @"/private/var/cercube_stashed",
                                       @"/private/var/db/stash",
                                       @"/private/var/db/sudo",
                                       @"/private/var/dropbear",
                                       @"/private/var/Ext3nder-Installer",
                                       @"/private/var/lib",
                                       @"/var/lib",
                                       @"/private/var/LIB",
                                       @"/private/var/local",
                                       @"/private/var/log/apt",
                                       @"/private/var/log/dpkg",
                                       @"/private/var/log/testbin.log",
                                       @"/private/var/lock",
                                       @"/private/var/mobile/Library/Activator",
                                       @"/private/var/mobile/Library/Preferences/ws.hbang.Terminal.plist",
                                       @"/private/var/mobile/Library/SplashBoard/Snapshots/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Application\ Support/Activator",
                                       @"/private/var/mobile/Library/Application\ Support/Flex3",
                                       @"/private/var/mobile/Library/Saved\ Application\ State/ws.hbang.Terminal.savedState",
                                       @"/private/var/mobile/Library/Saved\ Application\ State/org.coolstar.SileoStore.savedState",
                                       @"/private/var/mobile/Library/Saved\ Application\ State/com.saurik.Cydia.savedState",
                                       @"/private/var/mobile/Library/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Cr4shed",
                                       @"/private/var/mobile/Library/CT4",
                                       @"/private/var/mobile/Library/CT3",
                                       @"/private/var/mobile/Library/Cydia",
                                       @"/private/var/mobile/Library/Flex3",
                                       @"/private/var/mobile/Library/Filza",
                                       @"/private/var/mobile/Library/Fingal",
                                       @"/private/var/mobile/Library/iWidgets",
                                       @"/private/var/mobile/Library/LockHTML",
                                       @"/private/var/mobile/Library/Logs/Cydia",
                                       @"/private/var/mobile/Library/Notchification",
                                       @"/private/var/mobile/Library/unlimapps_tweaks_resources",
                                       @"/private/var/mobile/Library/Sileo",
                                       @"/private/var/mobile/Library/SBHTML",
                                       @"/private/var/mobile/Library/Toonsy",
                                       @"/private/var/mobile/Library/Widgets",
                                       @"/private/var/mobile/Library/Caches/libactivator.plist",
                                       @"/private/var/mobile/Library/Caches/com.johncoates.Flex",
                                       @"/private/var/mobile/Library/Caches/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Caches/AmyCache",
                                       @"/private/var/mobile/Library/Caches/org.coolstar.SileoStore",
                                       @"/private/var/mobile/Library/Caches/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Caches/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Caches/com.tigisoftware.Filza",
                                       @"/private/var/mobile/Library/Caches/Snapshots/com.saurik.Cydia",
                                       @"/private/var/mobile/Library/Caches/Snapshots/com.tigisoft.Filza",
                                       @"/private/var/mobile/Library/Caches/Snapshots/com.johncoates.Flex",
                                       @"/private/var/mobile/Library/Caches/Snapshots/org.coolstar.SafeMode",
                                       @"/private/var/mobile/Library/Caches/Snapshots/ws.hbang.Terminal",
                                       @"/private/var/mobile/Library/Caches/Snapshots/org.coolstar.Sileo",
                                       @"/private/var/mobile/Library/Preferences/com.saurik.Cydia.plist",
                                       @"/private/var/mobile/Library/libactivator.plist",
                                       @"/private/var/motd",
                                       @"/private/var/profile",
                                       @"/private/var/run/pspawn_hook.ts",
                                       @"/private/var/run/utmp",
                                       @"/private/var/run/sudo",
                                       @"/private/var/sbin",
                                       @"/private/var/spool",
                                       @"/private/var/tmp/cydia.log",
                                       @"/private/var/tweak",
                                       @"/private/var/unlimapps_tweak_resources",
                                       @"/.freya_installed",
                                       @"/.freya_bootstrap"];
    for (id file in cleanUpFileList) { clean_file([file UTF8String]); }
    ourprogressMeter();
    [[NSFileManager defaultManager] removeItemAtPath:@"/etc/apt/sources.list.d" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/etc/profile" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/usr/bin/rsync" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/bin/rm" error:nil];
    _assert(mod_plist_file(@"/var/mobile/Library/Preferences/com.apple.springboard.plist", ^(id plist) {
        plist[@"SBShowNonDefaultSystemApps"] = @NO;
    }), localize(@"Unable to update SpringBoard preferences."), true);// Disallow SpringBoard to show non-default system apps.
    util_info("Successfully disallowed SpringBoard to show non-default system apps.");
    disableRootFS();
    char *targettype = sysctlWithName("hw.targettype");
    _assert(targettype != NULL, localize(@"Unable to get hardware targettype."), true);
    NSString *const jetsamFile = [NSString stringWithFormat:@"/System/Library/LaunchDaemons/com.apple.jetsamproperties.%s.plist", targettype];
    free(targettype);targettype = NULL;
    _assert(mod_plist_file(jetsamFile, ^(id plist) {
        plist[@"Version4"][@"System"][@"Override"][@"Global"][@"UserHighWaterMark"] = nil;
    }), localize(@"Unable to update Jetsam plist to restore memory limit."), true);
    spotless();ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();
    ourprogressMeter();util_info("Rebooting...");
    showMSG(NSLocalizedString(@"RootFS Restored! We are going to reboot your device.", nil), 1, 1);
    dispatch_sync( dispatch_get_main_queue(), ^{UIApplication *app = [UIApplication sharedApplication];[app performSelector:@selector(suspend)];[NSThread sleepForTimeInterval:1.0];reboot(RB_QUICK); });
*/
    
}


void restoreRootFS(void) {
     restorewithnojbfound();
//    printf("should print this out sooo. restored rootfs\n");
}


void restoreFSOLDStyle(void) {
    if (shouldRestore) {
        restoreRootFS();
        
    }

 /*   int checkbash = (file_exists("/bin/bash"));
    int checkuicache = (file_exists("/usr/bin/uicache"));
    int checkelectra = (file_exists("/.bootstrapped_electra"));
    printf("checkuicache marker exists?: %d\n", checkuicache);
    printf("checkbash marker exists?: %d\n", checkbash);
    printf("electra exist = %d\n", checkelectra);
    ourprogressMeter();
    removethejb();
    pid_t pd;
    if (checkbash ==1 ) {
        extractFile(get_bootstrap_file(@"aJBDofSorts.tar.gz"), @"/");
        if (doweneedamfidPatch == 1) { util_info("Amfid done fucked up already!"); } else {
            if (patchtheSIGNSofCOde()){ util_info("Amfid bombed for restore process!"); } else{
                util_info("Failure to bomb Amfid");} } mkdir("/freya", 0777);
        _assert(clean_file("/bin/rm"), localize(@"Unable to clean uicache bin/rm binary."), true);
        _assert(clean_file("/usr/bin/find"), localize(@"Unable to clean uicache usr/bin/ binary."), true);
        _assert(clean_file("/usr/bin/uicache"), localize(@"Unable to clean  usr/bin/find binary."), true);
        extractFile(get_bootstrap_file(@"restoretools.tar"), @"/");
        extractFile(get_bootstrap_file(@"snappy.tar"), @"/freya");
        NSString *snapdddd = get_bootstrap_file(@"snappy.tar");
        posix_spawn(&pd, "/freya/tar", NULL, NULL, (char **)&(const char*[]){ "/freya/tar", "--preserve-permissions", "-xvpf", [snapdddd UTF8String], "-C", "/freya/", NULL}, NULL);waitpid(pd, NULL, 0);
        removingElectraiOS();uicaching("uicache");trust_file(@"/usr/bin/uicache");
        _assert(clean_file("/usr/lib/libjailbreak.dylib"), localize(@"Unable to clean old libjailbreak dylib."), true);
        _assert(execCmd("/usr/bin/uicache", NULL) >= 0, localize(@"Unable to refresh icon cache."), true);
        _assert(clean_file("/bin/rm"), localize(@"Unable to clean uicache bin/rm binary."), true);
        _assert(clean_file("/usr/bin/find"), localize(@"Unable to clean uicache usr/bin/ binary."), true);
        _assert(clean_file("/usr/bin/uicache"), localize(@"Unable to clean  usr/bin/find binary."), true);
        ourprogressMeter(); }
    [[NSFileManager defaultManager] removeItemAtPath:@"/etc/apt/sources.list.d" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/etc/profile" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/usr/bin/rsync" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/bin/rm" error:nil];
    _assert(mod_plist_file(@"/var/mobile/Library/Preferences/com.apple.springboard.plist", ^(id plist) {
        plist[@"SBShowNonDefaultSystemApps"] = @NO;
    }), localize(@"Unable to update SpringBoard preferences."), true);// Disallow SpringBoard to show non-default system apps.
    util_info("Successfully disallowed SpringBoard to show non-default system apps.");
    disableRootFS();
    char *targettype = sysctlWithName("hw.targettype");
    _assert(targettype != NULL, localize(@"Unable to get hardware targettype."), true);
    NSString *const jetsamFile = [NSString stringWithFormat:@"/System/Library/LaunchDaemons/com.apple.jetsamproperties.%s.plist", targettype];
    free(targettype);
    targettype = NULL;
    _assert(mod_plist_file(jetsamFile, ^(id plist) {
        plist[@"Version4"][@"System"][@"Override"][@"Global"][@"UserHighWaterMark"] = nil;
    }), localize(@"Unable to update Jetsam plist to restore memory limit."), true);
    spotless();
    ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();
    util_info("Rebooting...");
    if (kCFCoreFoundationVersionNumber < 1452.23 ) {//ios 11.3 = 1452.23
        showMSG(NSLocalizedString(@"Jailbreak Files manually removed. We are going to reboot your device.", nil), 1, 1);
        dispatch_sync( dispatch_get_main_queue(), ^{ UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)]; [NSThread sleepForTimeInterval:1.0]; reboot(RB_QUICK); });}
    chmod("/freya/snappy", 04755);
    int rvchecsnap1 = posix_spawn(&pd, "/freya/snappy", NULL, NULL, (char **)&(const char*[]){ "/freya/snappy", "-f", "/", "-r",  "orig-fs", "-x", NULL}, NULL);waitpid(pd, NULL, 0);
    printf("[*] Trying snappy result = %d \n" , rvchecsnap1);
    ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();ourprogressMeter();
    showMSG(NSLocalizedString(@"RootFS Restored! We are going to reboot your device.", nil), 1, 1);
    dispatch_sync( dispatch_get_main_queue(), ^{ UIApplication *app = [UIApplication sharedApplication];[app performSelector:@selector(suspend)];[NSThread sleepForTimeInterval:1.0];reboot(RB_QUICK); });
  */
    
}

void remountFS(bool shouldRestore) {
    
    if (shouldRestore) {
        //return true;
        restoreRootFS();
        
    } else {

        remountPrebootPartition(true);
       // return false;
    }
    
}
        /*    int root_fs = open("/", O_RDONLY);
            _assert(root_fs > 0, @"Error Opening The Root Filesystem!", true);
            const char **snapshots = snapshot_list(root_fs);
            const char *origfs = "orig-fs";
            bool isOriginalFS = false;
            const char *root_disk = "/dev/disk0s1s1";
            if (snapshots == NULL) {
                util_info("No System Snapshot Found! Don't worry, I'll Make One!");//Clear Dev Flags
                uint64_t devVnode = vnodeForPath(root_disk);
                _assert(ISADDR(devVnode), @"Failed to clear dev vnode's si_flags.", true);
                uint64_t v_specinfo = ReadKernel64(devVnode + koffset(KSTRUCT_OFFSET_VNODE_VU_SPECINFO));
                _assert(ISADDR(v_specinfo), @"Failed to clear dev vnode's si_flags.", true);
                WriteKernel32(v_specinfo + koffset(KSTRUCT_OFFSET_SPECINFO_SI_FLAGS), 0);
                uint32_t si_flags = ReadKernel32(v_specinfo + koffset(KSTRUCT_OFFSET_SPECINFO_SI_FLAGS));
                _assert(si_flags == 0, @"Failed to clear dev vnode's si_flags.", true);
                _assert(_vnode_put(devVnode) == ERR_SUCCESS, @"Failed to clear dev vnode's si_flags.", true);
                preMountFS(root_disk, root_fs, snapshots, origfs);//Pre-Mount
                close(root_fs); }
            list_all_snapshots(snapshots, origfs, isOriginalFS);
            uint64_t rootfs_vnode = vnodeForPath("/");
            LOG("rootfs_vnode = " ADDR, rootfs_vnode);
            _assert(ISADDR(rootfs_vnode), @"Failed to mount", true);
            uint64_t v_mount = ReadKernel64(rootfs_vnode + koffset(KSTRUCT_OFFSET_VNODE_V_MOUNT));
            LOG("v_mount = " ADDR, v_mount);
            _assert(ISADDR(v_mount), @"Failed to mount", true);
            uint32_t v_flag = ReadKernel32(v_mount + koffset(KSTRUCT_OFFSET_MOUNT_MNT_FLAG));
            if ((v_flag & (MNT_RDONLY | MNT_NOSUID))) {
                v_flag = v_flag & ~(MNT_RDONLY | MNT_NOSUID);
                WriteKernel32(v_mount + koffset(KSTRUCT_OFFSET_MOUNT_MNT_FLAG), v_flag & ~MNT_ROOTFS);
                _assert(execCmd("/sbin/mount", "-u", root_disk, NULL) == ERR_SUCCESS, @"Failed to mount", true);
                WriteKernel32(v_mount + koffset(KSTRUCT_OFFSET_MOUNT_MNT_FLAG), v_flag); }
            _assert(_vnode_put(rootfs_vnode) == ERR_SUCCESS, @"Failed to mount", true);
            _assert(execCmd("/sbin/mount", NULL) == ERR_SUCCESS, @"Failed to mount", true);
            
         */
        

