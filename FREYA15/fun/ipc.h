//
//  ipc.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#ifndef ipc_h
#define ipc_h

#include <stdio.h>
#include <mach/mach.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif
uint64_t ipc_entry_lookup(mach_port_t port_name);

uint64_t port_name_to_ipc_port(mach_port_t port_name);

uint64_t port_name_to_kobject(mach_port_t port_name);
#ifdef __cplusplus
}
#endif

#endif /* ipc_h */
