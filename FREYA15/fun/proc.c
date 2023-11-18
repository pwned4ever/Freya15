//
//  proc.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#include "proc.h"
#include "krw.h"
#include "offsets.h"

uint64_t proc_of_pidAMFI(pid_t pid) {
    uint64_t proc = get_kernproc();
    
    while (true) {
        
        if(kread32(proc + off_p_pid) == pid) {
            uint64_t pidptr = proc + off_p_pid;
            uint32_t pid2 = kread32(pidptr);
            char name[32];

            do_kread(proc + off_p_name, &name, 32);//0x381
            
            if (strncmp(name, "amfid", sizeof(name)) == 0) {
                util_printf("FOUND: pid %d, name %s\n", pid, name);
                util_printf("GOT IT\n");
                return proc;

            } else {
                while (true) {
                    
                    proc = kread64(proc + off_p_list_le_prev);
                    if(!proc) {
                        return -1;
                    }
                    do_kread(proc + off_p_name, &name, 32);//0x381
                    util_printf("FOUND: pid %d, name %s\n", pid, name);

                    if (strncmp(name, "amfid", sizeof(name)) == 0) {
                        util_printf("FOUND: pid %d, name %s\n", pid, name);
                        util_printf("GOT IT\n");
                        return proc;
                        
                    }
                }
                
            }

            //return proc;
        }
        proc = kread64(proc + off_p_list_le_prev);
        if(!proc) {
            return -1;
        }
    }
    
    return 0;

}
uint64_t proc_of_pid(pid_t pid) {
    uint64_t proc = get_kernproc();
    
    while (true) {
        if(kread32(proc + off_p_pid) == pid) {
            uint64_t pidptr = proc + off_p_pid;
            uint32_t pid2 = kread32(pidptr);
            char name[32];

            do_kread(proc + off_p_name, &name, 32);//0x381
            if(pid2 == pid) {
                util_printf("FOUND: pid %d, name %s\n", pid, name);
                util_printf("GOT IT\n");
                return proc;
            }

            //return proc;
        }
        proc = kread64(proc + off_p_list_le_prev);
        if(!proc) {
            return -1;
        }
    }
    
    return 0;
}

uint64_t proc_by_name(char* nm) {
    uint64_t proc = get_kernproc();
    
    while (true) {
        uint64_t nameptr = proc + off_p_name;
        char name[32];
        do_kread(nameptr, &name, 32);
//        printf("[i] pid: %d, process name: %s\n", kread32(proc + off_p_pid), name);
        if(strcmp(name, nm) == 0) {
            return proc;
        }
        proc = kread64(proc + off_p_list_le_prev);
        if(!proc) {
            return -1;
        }
    }
    
    return 0;
}

pid_t pid_by_name(char* nm) {
    uint64_t proc = proc_by_name(nm);
    if(proc == -1) return -1;
    return kread32(proc + off_p_pid);
}

uint64_t proc_get_task(uint64_t proc) {
    return kread64(proc + off_p_task);
}

uint64_t task_get_vm_map(uint64_t task) {
    return kread64(task + off_task_map);
}

uint64_t vm_map_get_pmap(uint64_t vm_map) {
    return kread64(vm_map + off_vm_map_pmap);
}

uint64_t pmap_get_ttep(uint64_t pmap) {
    return kread64(pmap + off_pmap_ttep);
}
