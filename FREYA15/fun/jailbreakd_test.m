//
//  jailbreakd_test.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/22.
//

#import <Foundation/Foundation.h>
#import "jailbreakd_test.h"
#import "utils.h"

#import "offsets.h"
#import "krw.h"
#import "./common/KernelRwWrapper.h"
#import "proc.h"
#import "jailbreakd.h"
#import "escalate.h"

#import <stdbool.h>
#import <mach/mach.h>
#import <stdlib.h>
#import <unistd.h>
#import <pthread.h>
#import <sys/stat.h>
#import <sys/mount.h>

extern char **environ;

void test_run_jailbreakd(void) {
    util_runCommand("/var/jb/basebin/jbinit", NULL, NULL);
}

void* test_run_jailbreakd_async(void* arg) {
    util_runCommand("/var/jb/basebin/jbinit", NULL, NULL);
//
//    posix_spawnattr_t attr;
//    posix_spawnattr_init(&attr);
//    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
//
//    NSString *jbinitPath = @"/var/jb/basebin/jbinit";
//
//    pid_t pid;
//    const char* args[] = {"jbinitPath", NULL};
//
//    int status = posix_spawn(&pid, jbinitPath.UTF8String, NULL, &attr, (char **)&args, environ);
//    if(status == 0) {
//        platformize(pid);
//        kill(pid, SIGCONT);
//
//        if(waitpid(pid, &status, 0) == -1) {
//            printf("waitpid error");
//        }
//
//    }
//    NSLog(@"jbinit posix_spawn status: %d", status);
    
    return NULL;
}



void test_handoffKRW_jailbreakd(void) {
    pthread_t thread;
    if (pthread_create(&thread, NULL, test_run_jailbreakd_async, NULL) != 0) {
        perror("pthread_create failed");
        return;
    }
    usleep(100000);
    pid_t jbd_pid = pid_by_name("jailbreakd");
//    set_proc_csflags(jbd_pid);
//    handoffKernRw(jbd_pid, "/var/jb/basebin/jailbreakd");
    NSLog(@"[kfund-arm64] jbd_pid: %d", jbd_pid);
//    handoffUnsafeKernRw(jbd_pid, NULL);
    handoffKernRw(jbd_pid, "/var/jb/basebin/jailbreakd");
   // usleep(1000000);
}

uint64_t test_jbd_kcall(uint64_t func, uint64_t argc, const uint64_t *argv)
{
    xpc_object_t message = xpc_dictionary_create_empty();
    xpc_dictionary_set_uint64(message, "id", JBD_MSG_KCALL);
    xpc_dictionary_set_uint64(message, "kaddr", func);

    xpc_object_t args = xpc_array_create_empty();
    for (uint64_t i = 0; i < argc; i++) {
        xpc_array_set_uint64(args, XPC_ARRAY_APPEND, argv[i]);
    }
    xpc_dictionary_set_value(message, "args", args);

    xpc_object_t reply = sendJBDMessage(message);
    if (!reply) return -1;
    return xpc_dictionary_get_uint64(reply, "ret");
}

void test_communicate_jailbreakd(void) {
    //testing 0x1 = check if kernel r/w received
    printf("krw_ready: 0x%llx", jbdKRWReady()); //should return 1
    
    //testing 0x2 = grab kernel info
    uint64_t kbase = 0;
    uint64_t kslide = 0;
    uint64_t allproc = 0;
    uint64_t kernproc = 0;
    
    jbdKernInfo(&kbase, &kslide, &allproc, &kernproc);
    printf("kbase = 0x%llx", kbase);
    printf("kslide = 0x%llx", kslide);
    printf("allproc = 0x%llx", allproc);
    printf("kernproc = 0x%llx", kernproc);
    
    //testing 0x3 = kread32
    printf("jbdKread32 ret: 0x%x", jbdKread32(kbase));
    
    //testing 0x4 = kread64
    printf("jbdKread64 ret: 0x%llx", jbdKread64(kbase));
    
    //testing 0x5 = kwrite32
    printf("jbdKwrite32 ret: 0x%llx", jbdKwrite32(off_empty_kdata_page + kslide, 0x41424344));
    printf("really off_empty_kdata_page has been written? 0x%x", kread32(off_empty_kdata_page + get_kslide()));
    
    //testing 0x6 = kwrite64
    printf("jbdKwrite64 ret: 0x%llx", jbdKwrite64(off_empty_kdata_page + kslide, 0x4141414141414141));
    printf("really off_empty_kdata_page has been written? 0x%llx", kread64(off_empty_kdata_page + get_kslide()));
    //Restore
    kwrite64(off_empty_kdata_page + get_kslide(), 0x0);
    
    //testing 0x7 = kalloc
    uint64_t allocated_kmem = jbdKalloc(0x100);
    printf("jbdKalloc ret: 0x%llx", allocated_kmem);

    //testing 0x8 = kfree
    printf("jbdKfree ret: 0x%llx", jbdKfree(allocated_kmem, 0x100));
    
    //testing 0x9 = kcall
    uint64_t proc_selfpid_kfunc = 0xFFFFFFF00758E90C + kslide;
    uint64_t kcall_ret = jbdKcall(proc_selfpid_kfunc, 1, (const uint64_t[]){1});
    printf("proc_selfpid kcall ret: %lld, jailbreakd pid: %d", kcall_ret, pid_by_name("jailbreakd"));
    
    //testing 10 = rebuild trustcache (load trustcache all from /var/jb)
    printf("jbdRebuildTrustCache ret: 0x%llx", jbdRebuildTrustCache());
    util_runCommand("/var/jb/usr/bin/id", NULL, NULL);  //check if running /var/jb binaries well.
    
    //testing 11 = load trustcache from unsigned bin (partial file)
    char* execPath = [NSString stringWithFormat:@"%@/unsigned/unsignedhelloworld", NSBundle.mainBundle.bundlePath].UTF8String;
    printf("execPath: %s", execPath);
    chmod(execPath, 0755);
    printf("jbdProcessBinary ret: 0x%llx", jbdProcessBinary(execPath));
    util_runCommand(execPath, NULL, NULL);
    
    //testing 12 = patch dyld and bind mount
    printf("jbdInitEnvironment ret: 0x%llx", jbdInitEnvironment());

    //kill
    launch("/var/jb/usr/bin/killall", "-9", "jailbreakd", NULL, NULL, NULL, NULL, NULL);
   // usleep(10000);
    launch("/var/jb/bin/launchctl", "unload", "/var/jb/basebin/LaunchDaemons/kr.h4ck.jailbreakd.plist", NULL, NULL, NULL, NULL, NULL);
}
