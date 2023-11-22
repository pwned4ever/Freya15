//
//  fun.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/10.
//

#import <Foundation/Foundation.h>
#import <spawn.h>
#import <unistd.h>
#import <sys/stat.h>
#import <stdio.h>
#import <pthread.h>
#import "krw.h"
#import "offsets.h"
#import "sandbox.h"
#import "trustcache.h"
#import "escalate.h"
#import "utils.h"
#import "fun.h"
//#import "proc.h"
//#import "vnode.h"
#import "dropbear.h"
#import "./common/KernelRwWrapper.h"
#import "bootstrap.h"
//#import "boot_info.h"
#import "jailbreakd_test.h"
#import "helpers.h"
#import "../ViewController.h"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

int do_fun(void) {
  //  dispatch_sync( dispatch_get_main_queue(), ^{
       // printf("Patchaway\n");
    util_info("Patching");
        uint64_t kslide = get_kslide();
        uint64_t kbase = 0xfffffff007004000 + kslide;
    
        //_offsets_init();
        //initKernRw(get_selftask(), kread64, kwrite64);
        
        //printf("isKernRwReady: %d\n", );
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
            dothestage2();
          //  newplatformize(getpid());

               //printf("[i] Still root? uid: %d, gid: %d\n", getuid(), getgid());
            prepare_kcall();
            //newplatformize(getpid());
            platformize(getpid());
            uint64_t sb = unsandbox(getpid());
            loadTrustCacheBinpack();
            loadTrustCacheBinaries();
            term_kcall();
            cleanDropbearBootstrap();
            startJBEnvironment();   //oobPCI.swift -> case "startEnvironment":
            sandbox(getpid(), sb);
            /*    */
        } else {
            if (newTFcheckMyRemover4me == true) {
                util_info("getting root");

              //  printf("Deleting jailbreak\n");
                rootify(getpid());//);
                
                util_info("[i] uid: %d, gid: %d\n", getuid(), getgid());
                prepare_kcall();
                platformize(getpid());
                util_info("platformize");

                unsandbox(getpid());
                util_info("remounting");

                remountPrebootPartition(true);
                char* fakeRootPath = locateExistingFakeRoot();
                //printf("fakeRootPath: %s\n", fakeRootPath);
                util_info("fakeRootPath: %s", fakeRootPath);

                [[NSFileManager defaultManager] removeItemAtPath:@"/var/jb" error:nil];
                NSString *path = [NSString stringWithUTF8String:fakeRootPath];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                do_kclose();
                util_info("Removed Jailbreak");
                //printf("deleted jailbreak...\n");
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:1 forKey:@"LoadTweaks"];
                [defaults setInteger:0 forKey:@"resttoreRootFS"];
                [defaults synchronize];
                JUSTremovecheck = false;

                saveCustomSetting(@"resttoreRootFS", 9);

                showMSG(NSLocalizedString(@"RootFS Restored! We are going to reboot your device.", nil), 1, 1);
                dispatch_sync(
                dispatch_get_main_queue(), ^{
                    UIApplication *app = [UIApplication sharedApplication];
                    [app performSelector:@selector(suspend)];
                    [NSThread sleepForTimeInterval:1.0];
                    reboot(0);
                      
                });

               // sleep(3);
                //reboot(0);
            } else {
                
                util_info("getting root");

              //  printf("Deleting jailbreak\n");
                rootify(getpid());//);
                
                util_info("[i] uid: %d, gid: %d\n", getuid(), getgid());
                util_info("Kcall prep");
                prepare_kcall(); //must be used?? or else dies trying to unsandbox anything
                util_info("platformize");
                platformize(getpid());
                util_info("unsanbox #2");
                uint64_t sb = unsandbox(getpid());
                util_info("Loading TC");
                loadTrustCacheBinpack();
                loadTrustCacheBinaries();
                util_info("Term Kcall");
                term_kcall();
                
                cleanDropbearBootstrap();
                util_info("starting daemons");

                startJBEnvironment();   //oobPCI.swift -> case "startEnvironment":
                util_info("sandbox 2");
                sandbox(getpid(), sb);
            }
        }
        do_kclose();
        util_info("restart backboard");
    
      //  printf("Status: Done, sbreloading now...");
        restartBackboard();
       
    
    return 0;
        
}
