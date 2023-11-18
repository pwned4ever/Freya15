//
//  dropbear.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#import <Foundation/Foundation.h>
#import <spawn.h>
#import <sys/stat.h>
#import "dropbear.h"
#import "escalate.h"
#import "sandbox.h"
#import "fun.h"
#import "utils.h"
#import "trustcache.h"

#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]
#define removeFile(file) if (fileExists(file)) {\
                            [[NSFileManager defaultManager]  removeItemAtPath:@file error:&error]; \
                            if (error) { \
                                printf("[-] Error: removing file %s (%s)\n", file, [[error localizedDescription] UTF8String]); \
                                error = NULL; \
                            }\
                         }
#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:&error]; \
                                   if (error) { \
                                       printf("[-] Error copying item %s to path %s (%s)\n", copyFrom, copyTo, [[error localizedDescription] UTF8String]); \
                                       error = NULL; \
                                   }

extern char **environ;


int untarDropbearBootstrap(void) {
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    
    NSString *tarPath = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/tar"];
    chmod(tarPath.UTF8String, 0755);
    char* iosbinpackPath = [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/iosbinpack/iosbinpack.tar"].UTF8String;
    
    pid_t pid;
    const char* args[] = {"tar.bin", "--preserve-permissions", "-xkf", iosbinpackPath, "-C", "/var/containers/Bundle/", NULL};
    
    int status = posix_spawn(&pid, tarPath.UTF8String, NULL, &attr, (char **)&args, environ);
    if(status == 0) {
        rootify(pid);
        kill(pid, SIGCONT);
        
        if(waitpid(pid, &status, 0) == -1) {
          //  printf("waitpid error\n");
        }
        
    }
    NSLog(@"untarBootstrap posix_spawn status: %d\n", status);
    
    return 0;
}

int setupSSH(void) {
    //----- setup SSH -----//
    NSError *error = NULL;
    
    mkdir("/var/dropbear", 0777);
    removeFile("/var/profile");
    removeFile("/var/motd");
    chmod("/var/profile", 0777);
    chmod("/var/motd", 0777); //this can be read-only but just in case
    copyFile("/var/containers/Bundle/iosbinpack64/etc/profile", "/var/profile");
    copyFile("/var/containers/Bundle/iosbinpack64/etc/motd", "/var/motd");
    
    return 0;
}

int runSSH(void) {
    
    //2.bootstrap
    cleanDropbearBootstrap();
    untarDropbearBootstrap();
    
    //3.setup dropbear
    setupSSH();
    
    //4. run SSH
    launch("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "-SEGV", "dropbear", NULL, NULL, NULL, NULL, NULL);
    //usleep(10000);
    launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "--shell", "/var/containers/Bundle/iosbinpack64/bin/bash", "-E", "-p", "2222", "-a", NULL);
    
    return 0;
}

int cleanDropbearBootstrap(void) {
    remove("/var/containers/Bundle/._iosbinpack64");
    remove("/var/mobile/.bash_history");
    remove("/var/root/.bash_history");
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/containers/Bundle/iosbinpack64" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/profile" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/motd" error:nil];
    
    return 0;
}
