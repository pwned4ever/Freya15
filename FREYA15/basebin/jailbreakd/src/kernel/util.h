#import <Foundation/Foundation.h>

typedef struct __attribute__((__packed__)) _vm_map_flags {
    unsigned int
        /* boolean_t */ wait_for_space:1,         /* Should callers wait for space? */
        /* boolean_t */ wiring_required:1,        /* All memory wired? */
        /* boolean_t */ no_zero_fill:1,           /* No zero fill absent pages */
        /* boolean_t */ mapped_in_other_pmaps:1,  /* has this submap been mapped in maps that use a different pmap */
        /* boolean_t */ switch_protect:1,         /* Protect map from write faults while switched */
        /* boolean_t */ disable_vmentry_reuse:1,  /* All vm entries should keep using newer and higher addresses in the map */
        /* boolean_t */ map_disallow_data_exec:1, /* Disallow execution from data pages on exec-permissive architectures */
        /* boolean_t */ holelistenabled:1,
        /* boolean_t */ is_nested_map:1,
        /* boolean_t */ map_disallow_new_exec:1, /* Disallow new executable code */
        /* boolean_t */ jit_entry_exists:1,
        /* boolean_t */ has_corpse_footprint:1,
        /* boolean_t */ terminated:1,
        /* boolean_t */ is_alien:1,              /* for platform simulation, i.e. PLATFORM_IOS on OSX */
        /* boolean_t */ cs_enforcement:1,        /* code-signing enforcement */
        /* boolean_t */ cs_debugged:1,           /* code-signed but debugged */
        /* boolean_t */ reserved_regions:1,      /* has reserved regions. The map size that userspace sees should ignore these. */
        /* boolean_t */ single_jit:1,            /* only allow one JIT mapping */
        /* boolean_t */ never_faults : 1,        /* only seen in KDK */
        /* reserved */ pad:13;
} vm_map_flags;

uint64_t proc_get_ucred(uint64_t proc_ptr);
void proc_set_ucred(uint64_t proc_ptr, uint64_t ucred_ptr);

void run_unsandboxed(void (^block)(void));

NSString *proc_get_path(pid_t pid);
void proc_set_svuid(uint64_t proc_ptr, uid_t svuid);
void ucred_set_svuid(uint64_t ucred_ptr, uint32_t svuid);
void ucred_set_uid(uint64_t ucred_ptr, uint32_t uid);

void proc_set_svgid(uint64_t proc_ptr, uid_t svgid);
void ucred_set_svgid(uint64_t ucred_ptr, uint32_t svgid);
void ucred_set_cr_groups(uint64_t ucred_ptr, uint32_t cr_groups);

uint32_t proc_get_p_flag(uint64_t proc_ptr);
void proc_set_p_flag(uint64_t proc_ptr, uint32_t p_flag);

int64_t proc_fix_setuid(pid_t pid);

void pmap_set_wx_allowed(uint64_t pmap_ptr, bool wx_allowed);

uint32_t proc_get_csflags(uint64_t proc);

void proc_set_csflags(uint64_t proc, uint32_t csflags);

void task_set_memory_ownership_transfer(uint64_t task_ptr, uint8_t enabled);

vm_map_flags vm_map_get_flags(uint64_t vm_map_ptr);

void vm_map_set_flags(uint64_t vm_map_ptr, vm_map_flags new_flags);

int proc_set_debugged(uint64_t proc_ptr, bool fully_debugged);

int proc_set_debugged_pid(pid_t pid, bool fully_debugged);

bool set_task_platform(pid_t pid, bool set);

void set_proc_csflags(pid_t pid);

void set_csb_platform_binary(pid_t pid);

void platformize(pid_t pid);