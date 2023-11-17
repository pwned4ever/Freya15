//
//  escalate.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#include <stdio.h>
#include <stdbool.h>
#include <spawn.h>

#define TF_PLATFORM (0x00000400)
#define CS_PLATFORM_BINARY (0x04000000)
#define CS_INSTALLER (0x00000008)
#define CS_GET_TASK_ALLOW (0x00000004)
#define CS_RESTRICT (0x00000800)
#define CS_HARD (0x00000100)
#define CS_KILL (0x00000200)
#define CS_DEBUGGED                    0x10000000  /* process is currently or has previously been debugged and allowed to run with invalid pages */

uint64_t borrow_entitlements(pid_t to_pid, pid_t from_pid);
void unborrow_entitlements(pid_t to_pid, uint64_t to_amfi);
uint64_t borrow_ucreds(pid_t to_pid, pid_t from_pid);
void unborrow_ucreds(pid_t to_pid, uint64_t to_ucred);

bool rootify(pid_t pid);

uint64_t run_borrow_entitlements(pid_t to_pid, char* from_path);
void kill_unborrow_entitlements(pid_t to_pid, uint64_t to_amfi, pid_t kill_pid);

bool set_task_platform(pid_t pid, bool set);
void set_proc_csflags(pid_t pid);
uint64_t get_cs_blob(pid_t pid);
void set_csb_platform_binary(pid_t pid);
void platformize(pid_t pid);
void newplatformize(pid_t pid);
