//
//  utils.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#ifndef utils_h
#define utils_h

#include <stdio.h>
#include <spawn.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <stdlib.h>

int runCommandv(const char *cmd, int argc, const char * const* argv, void (^unrestrict)(pid_t));
int util_runCommand(const char *cmd, ...);
int launch(char *binary, char *arg1, char *arg2, char *arg3, char *arg4, char *arg5, char *arg6, char**env);
int launchAsPlatform(char *binary, char *arg1, char *arg2, char *arg3, char *arg4, char *arg5, char *arg6, char* arg7, char**env);
void HexDump(uint64_t addr, size_t size);

#endif /* utils_h */
