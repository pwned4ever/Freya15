//
//  KernelRwWrapper.h
//  Taurine
//
//  Created by tihmstar on 27.02.21.
//

#ifndef KernelRwWrapper_h
#define KernelRwWrapper_h

#include <stdint.h>
#include <stdbool.h>
#include <mach/mach.h>
#include <unistd.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
extern uint64_t our_proc_kAddr;

bool isKernRwReady(void);

void initKernRw(uint64_t taskSelfAddr, uint64_t (*kread64)(uint64_t addr), void (*kwrite64)(uint64_t where, uint64_t what));

void terminateKernRw(void);

void handoffKernRw(pid_t spawnedPID, const char *processPath);

void handoffUnsafeKernRw(pid_t spawnedPID, const char *processPath);

void ksetOffsets(uint64_t kernBaseAddr, uint64_t kernProcAddr, uint64_t allProcAddr);


#ifdef __cplusplus
}
#endif

#endif /* KernelRwWrapper_h */
