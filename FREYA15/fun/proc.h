//
//  proc.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#include <stdio.h>

pid_t pid_by_name(char* nm);
uint64_t proc_by_name(char* nm);
uint64_t proc_of_pid(pid_t pid);
uint64_t proc_get_task(uint64_t proc);
uint64_t task_get_vm_map(uint64_t task);
uint64_t vm_map_get_pmap(uint64_t vm_map);
uint64_t pmap_get_ttep(uint64_t pmap);
uint64_t proc_of_pidAMFI(pid_t pid);
