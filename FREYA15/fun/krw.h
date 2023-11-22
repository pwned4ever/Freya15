//
//  krw.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/10.
//

#ifndef krw_h
#define krw_h

#include "fun.h"
#include <mach/mach.h>



#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint64_t obj, func, delta;
} io_external_trap_t;

typedef mach_port_t io_connect_t;


uint64_t get_selftask(void);
uint64_t get_selfproc(void);
uint64_t get_kslide(void);
uint64_t get_kernproc(void);

void set_selftask(void);
void set_selfproc(void);
void set_kslide(void);
void set_kernproc(void);

uint64_t getting_proc_SetCRED(void);
uint64_t do_kopen(uint64_t puaf_pages, uint64_t puaf_method, uint64_t kread_method, uint64_t kwrite_method);
void do_kclose(void);
void do_kread(uint64_t kaddr, void* uaddr, uint64_t size);
void do_kwrite(void* uaddr, uint64_t kaddr, uint64_t size);
uint8_t kread8(uint64_t where);
uint32_t kread16(uint64_t where);
uint32_t kread32(uint64_t where);
uint64_t kread64(uint64_t where);
void kwrite8(uint64_t where, uint8_t what);
void kwrite16(uint64_t where, uint16_t what);
void kwrite32(uint64_t where, uint32_t what);
void kwrite64(uint64_t where, uint64_t what);
void kwritebuf(uint64_t kaddr, void* input, size_t size);
void kreadbuf(uint64_t kaddr, void* output, size_t size);

/*uint64_t zm_fix_addr_kalloc(uint64_t addr);
uint64_t init_kcall(void);
uint64_t init_kcall_allocated(void);
*/
int prepare_kcall(void);
int prepare_kcall152(uint64_t fclient, uint64_t fvtable, mach_port_t uclient);

uint64_t kcall(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6);
uint64_t kcallKRW(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6);

typedef uint64_t u64;
uint64_t kalloc(u64 kfd, size_t ksize);
uint64_t kalloc2ndx(u64 kfd, size_t ksize);
//uint64_t kalloc(u64 kfd, size_t ksize);

/*
void kfree(uint64_t kaddr, size_t ksize);

uint64_t clean_dirty_kalloc(uint64_t addr, size_t size);
 */
int kalloc_using_empty_kdata_page(void);

int term_kcall(void);


uint64_t kvtophys(uint64_t kvaddr);
uint64_t physread64(uint64_t pa);
void physwrite64(uint64_t paddr, uint64_t value);
extern uint64_t FINAL_KFD;
void dothestage2(void);
uint64_t testthekcall(void);

extern uint64_t proc_set_ucred_func;
bool shouldRestore(void);
extern bool newTFcheckMyRemover4me;

//void unset_groot(uint64_t proc_unset);
//extern uint64_t groot_ogucredof_proc;

#ifdef __cplusplus
}
#endif

#endif /* krw_h */
