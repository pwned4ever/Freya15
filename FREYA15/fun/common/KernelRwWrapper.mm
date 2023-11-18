//
//  KernelRwWrapper.cc
//  Taurine
//
//  Created by tihmstar on 27.02.21.
//

#include "KernelRwWrapper.h"
#include "KernelRW.hpp"
#include "macros.h"
#include <sys/param.h>
#include <Foundation/Foundation.h>
#include "../ipc.h"
#include "../krw.h"
#include "../offsets.h"

#define PROC_PIDPATHINFO_SIZE  (MAXPATHLEN)
extern "C" int proc_pidpath(int pid, void * buffer, uint32_t  buffersize);

uint64_t our_proc_kAddr;
KernelRW *krw = NULL;


extern "C" void ksetOffsets(uint64_t kernBaseAddr, uint64_t kernProcAddr, uint64_t allProcAddr){
    if (krw){
        krw->setOffsets(kernBaseAddr, kernProcAddr, allProcAddr);
    }
}

extern "C" void handoffKernRw(pid_t spawnedPID, const char *processPath){
    mach_port_t spawnedTaskPort = MACH_PORT_NULL;
    mach_port_t exceptionPort = MACH_PORT_NULL;
    mach_port_t trasmissionPort = MACH_PORT_NULL;
    cleanup([&]{
        if (trasmissionPort) {
            mach_port_destroy(mach_task_self(), trasmissionPort); trasmissionPort = MACH_PORT_NULL;
        }
        if (exceptionPort) {
            mach_port_destroy(mach_task_self(), exceptionPort); exceptionPort = MACH_PORT_NULL;
        }
        if (spawnedTaskPort) {
            mach_port_destroy(mach_task_self(), spawnedTaskPort); spawnedTaskPort = MACH_PORT_NULL;
        }
    });
    kern_return_t kret = KERN_SUCCESS;
    exception_mask_t masks[EXC_TYPES_COUNT] = {};
    mach_msg_type_number_t masksCnt = 0;
    mach_port_t eports[EXC_TYPES_COUNT] = {};
    exception_behavior_t behaviors[EXC_TYPES_COUNT] = {};
    thread_state_flavor_t flavors[EXC_TYPES_COUNT] = {};
    
    if (processPath) {
        for (int i=0; i<200; i++) {
            char path[PROC_PIDPATHINFO_SIZE+1] = {};
            if (int pathLen = proc_pidpath(spawnedPID, path, sizeof(path))){
                if (strncmp(path, processPath, pathLen) == 0) {
                    //debug("Got process! '%s'",path);
                    break;
                }else{
//                    debug("Got process '%s' but need '%s', waiting...",path,processPath);
                }
            }else{
                debug("proc_pidpath failed with error=%d (%s)",errno,strerror(errno));
            }
            usleep(50);
        }
    }
    
    for (int i=0; i<200; i++) {
        if (!(kret = task_for_pid(mach_task_self(), spawnedPID, &spawnedTaskPort))) break;
        usleep(50);
    }
    retassure(!kret, "Failed to get task_for_pid(%d) with error=0x%08x",spawnedPID,kret);
    
    retassure(!(kret = task_get_exception_ports(spawnedTaskPort, EXC_BREAKPOINT, masks, &masksCnt, eports, behaviors, flavors)), "Failed to get old exception port");
    exceptionPort = eports[0];
    retassure(!(kret = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &trasmissionPort)),"Failed to alloc trasmissionPort");
    retassure(!(kret = mach_port_insert_right(mach_task_self(), trasmissionPort, trasmissionPort, MACH_MSG_TYPE_MAKE_SEND)),"Failed to insert send right to trasmissionPort");
    //find takeThread
    {
        bool haveSetPort = false;
        while (!haveSetPort) {
            thread_act_array_t threads = NULL;
            cleanup([&]{
                if (threads) {
                    _kernelrpc_mach_vm_deallocate_trap(mach_task_self(), (mach_vm_address_t)threads, PAGE_SIZE); threads = NULL;
                }
            });
            mach_msg_type_number_t threadsCount = {};
            for (int i=0; i<200; i++) {
                if (!(kret = task_threads(spawnedTaskPort, &threads, &threadsCount))) break;
                usleep(50);
            }
            retassure(!kret, "Failed to get remote thread list");
            for (int i=0; i<threadsCount; i++) {
                arm_thread_state64_t state = {};
                mach_msg_type_number_t statecnt = ARM_THREAD_STATE64_COUNT;
                retassure(!(kret = thread_get_state(threads[i], ARM_THREAD_STATE64, (thread_state_t)&state, &statecnt)), "Failed to get remote thread state");
                if (state.__x[0] == 0x4141414141414141){
                    haveSetPort = true;
                    retassure(!(kret = thread_set_exception_ports(threads[i], EXC_BREAKPOINT, trasmissionPort, EXCEPTION_DEFAULT, ARM_THREAD_STATE64)), "Failed to set exception port");
                    break;
                }
            }
            if (!haveSetPort) {
                usleep(50);
            }
        }
    }
    
    {
        uint64_t spawnedTaskAddr = port_name_to_kobject(spawnedTaskPort);//krw->getKobjAddrForPort(spawnedTaskPort);
      //  printf("spawnedTaskAddr=0x%016llx\n",spawnedTaskAddr);
        krw->setOffsets(0xfffffff007004000 + get_kslide(), get_kernproc(), kread64(off_allproc + get_kslide()));
        krw->doRemotePrimitivePatching(trasmissionPort, spawnedTaskAddr);
    }
    //printf("done kernel rw handoff\n");
}

extern "C" void handoffUnsafeKernRw(pid_t spawnedPID, const char *processPath){
    if (!krw){
        debug("Not using fallback kernel r/w. Not handing off");
        return;
    }
    try {
       // debug("handoffKernRw");

        mach_port_t spawnedTaskPort = MACH_PORT_NULL;
        mach_port_t exceptionPort = MACH_PORT_NULL;
        mach_port_t trasmissionPort = MACH_PORT_NULL;
        cleanup([&]{
            if (trasmissionPort) {
                mach_port_destroy(mach_task_self(), trasmissionPort); trasmissionPort = MACH_PORT_NULL;
            }
            if (exceptionPort) {
                mach_port_destroy(mach_task_self(), exceptionPort); exceptionPort = MACH_PORT_NULL;
            }
            if (spawnedTaskPort) {
                mach_port_destroy(mach_task_self(), spawnedTaskPort); spawnedTaskPort = MACH_PORT_NULL;
            }
        });
        kern_return_t kret = KERN_SUCCESS;
        exception_mask_t masks[EXC_TYPES_COUNT] = {};
        mach_msg_type_number_t masksCnt = 0;
        mach_port_t eports[EXC_TYPES_COUNT] = {};
        exception_behavior_t behaviors[EXC_TYPES_COUNT] = {};
        thread_state_flavor_t flavors[EXC_TYPES_COUNT] = {};
        
        if (processPath) {
            for (int i=0; i<200; i++) {
                char path[PROC_PIDPATHINFO_SIZE+1] = {};
                if (int pathLen = proc_pidpath(spawnedPID, path, sizeof(path))){
                    if (strncmp(path, processPath, pathLen) == 0) {
               //         debug("Got process! '%s'",path);
                        break;
                    }else{
             //           debug("Got process '%s' but need '%s', waiting...",path,processPath);
                    }
                }else{
                    debug("proc_pidpath failed with error=%d (%s)",errno,strerror(errno));
                }
                usleep(50);
            }
        }
        
        for (int i=0; i<200; i++) {
            if (!(kret = task_for_pid(mach_task_self(), spawnedPID, &spawnedTaskPort))) break;
            usleep(50);
        }
        retassure(!kret, "Failed to get task_for_pid(%d) with error=0x%08x",spawnedPID,kret);
        debug("got task_for_pid");

        
        retassure(!(kret = task_get_exception_ports(spawnedTaskPort, EXC_BREAKPOINT, masks, &masksCnt, eports, behaviors, flavors)), "Failed to get old exception port");
        exceptionPort = eports[0];
        
        retassure(!(kret = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &trasmissionPort)),"Failed to alloc trasmissionPort");
        retassure(!(kret = mach_port_insert_right(mach_task_self(), trasmissionPort, trasmissionPort, MACH_MSG_TYPE_MAKE_SEND)),"Failed to insert send right to trasmissionPort");

        //find takeThread
        {
            bool haveSetPort = false;
            while (!haveSetPort) {
                thread_act_array_t threads = NULL;
                cleanup([&]{
                    if (threads) {
                        _kernelrpc_mach_vm_deallocate_trap(mach_task_self(), (mach_vm_address_t)threads, PAGE_SIZE); threads = NULL;
                    }
                });
                mach_msg_type_number_t threadsCount = {};
                for (int i=0; i<200; i++) {
                    if (!(kret = task_threads(spawnedTaskPort, &threads, &threadsCount))) break;
                    usleep(50);
                }
                retassure(!kret, "Failed to get remote thread list");

                for (int i=0; i<threadsCount; i++) {
                    arm_thread_state64_t state = {};
                    mach_msg_type_number_t statecnt = ARM_THREAD_STATE64_COUNT;
                    retassure(!(kret = thread_get_state(threads[i], ARM_THREAD_STATE64, (thread_state_t)&state, &statecnt)), "Failed to get remote thread state");
                    if (state.__x[0] == 0x4141414141414141){
                        haveSetPort = true;
                        retassure(!(kret = thread_set_exception_ports(threads[i], EXC_BREAKPOINT, trasmissionPort, EXCEPTION_DEFAULT, ARM_THREAD_STATE64)), "Failed to set exception port");
                        break;
                    }
                }
                if (!haveSetPort) {
                    usleep(50);
                }
            }
        }
        
        {
            uint64_t spawnedTaskAddr = port_name_to_kobject(spawnedTaskPort);//krw->getKobjAddrForPort(spawnedTaskPort);
          //  debug("spawnedTaskAddr=0x%016llx",spawnedTaskAddr);
            krw->setOffsets(0xfffffff007004000 + get_kslide(), get_kernproc(), kread64(off_allproc + get_kslide()));
            krw->doRemotePrimitivePatching(trasmissionPort, spawnedTaskAddr);
        }
        //debug("done kernel rw handoff");
    } catch (tihmstar::exception ex){
#if DEBUG
        ex.dump();
#endif
    }
}

extern "C"
bool isKernRwReady(void){
    return krw != NULL;
}

extern "C"
void initKernRw(uint64_t taskSelfAddr, uint64_t (*kread64)(uint64_t addr), void (*kwrite64)(uint64_t where, uint64_t what)){
    
    KernelRW *newKrw = new KernelRW;
    
    auto p = newKrw->getPrimitivepatches(kread64, taskSelfAddr);

    kwrite64(p.where, p.what);

    krw = newKrw;
    
    //printf("new Krw\n");
}

extern "C"
void terminateKernRw(void){
    if (krw){
        delete krw;
        krw = NULL;
    }
    krw = NULL;
}
