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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


int do_fun(void) {
  //  dispatch_sync( dispatch_get_main_queue(), ^{
       // printf("Patchaway\n");
//        uint64_t kslide = get_kslide();
//        uint64_t kbase = 0xfffffff007004000 + kslide;
      /*  printf("[i] Kernel base: 0x%llx\n", kbase);
        printf("[i] Kernel slide: 0x%llx\n", kslide);
        printf("[i] Kernel base kread64 ret: 0x%llx\n", kread64(kbase));*/
    
        //_offsets_init();
        //initKernRw(get_selftask(), kread64, kwrite64);
        
        //printf("isKernRwReady: %d\n", );
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
            dothestage2();
          //  newplatformize(getpid());

               //printf("[i] Still root? uid: %d, gid: %d\n", getuid(), getgid());
            prepare_kcall();
            newplatformize(getpid());
            //platformize(getpid());
            //uint64_t sb = unsandbox(getpid());
            loadTrustCacheBinpack();
            loadTrustCacheBinaries();
            term_kcall();
            cleanDropbearBootstrap();
            startJBEnvironment();   //oobPCI.swift -> case "startEnvironment":
            //sandbox(getpid(), sb);
            /*    */
        } else {
            //printf("[i] rootify ret: %d\n",
                   rootify(getpid());
            util_info("[i] uid: %d, gid: %d\n", getuid(), getgid());
            prepare_kcall(); //must be used?? or else dies trying to unsandbox anything
            platformize(getpid());
            uint64_t sb = unsandbox(getpid());
            loadTrustCacheBinpack();
            loadTrustCacheBinaries();
            term_kcall();
            cleanDropbearBootstrap();
            startJBEnvironment();   //oobPCI.swift -> case "startEnvironment":
            sandbox(getpid(), sb);
        }
        do_kclose();
      //  printf("Status: Done, sbreloading now...");
        restartBackboard();
       
    
    return 0;
        
}
