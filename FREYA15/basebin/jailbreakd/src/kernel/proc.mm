#import "proc.h"
#import "krw.h"
#import "offsets.h"

uint64_t proc_of_pid(pid_t pid) {
  uint64_t proc = get_kernproc();

  while (true) {
    if (kread32(proc + off_p_pid) == pid) {
      return proc;
    }
    proc = kread64(proc + off_p_list_le_prev);
    if (!proc) {
      return -1;
    }
  }

  return 0;
}

uint64_t proc_by_name(char *nm) {
  uint64_t proc = get_kernproc();

  while (true) {
    uint64_t nameptr = proc + off_p_name;
    char name[32];
    kreadbuf(nameptr, &name, 32);
    //        printf("[i] pid: %d, process name: %s\n", kread32(proc +
    //        off_p_pid), name);
    if (strcmp(name, nm) == 0) {
      return proc;
    }
    proc = kread64(proc + off_p_list_le_prev);
    if (!proc) {
      return -1;
    }
  }

  return 0;
}

pid_t pid_by_name(char *nm) {
  uint64_t proc = proc_by_name(nm);
  if (proc == -1)
    return -1;
  return kread32(proc + off_p_pid);
}

uint64_t proc_get_task(uint64_t proc) { return kread64(proc + off_p_task); }

uint64_t task_get_vm_map(uint64_t task) { return kread64(task + off_task_map); }

uint64_t vm_map_get_pmap(uint64_t vm_map) {
  return kread64(vm_map + off_vm_map_pmap);
}

uint64_t pmap_get_ttep(uint64_t pmap) { return kread64(pmap + off_pmap_ttep); }