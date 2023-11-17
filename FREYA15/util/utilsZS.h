//
//  utils.h
//  electra
//
//  Created by Jamie on 27/01/2018.
//  Copyright © 2018 Electra Team. All rights reserved.
//

#ifndef utils_h
#define utils_h
#import <sys/types.h>
#import <sys/stat.h>
#include <sys/wait.h>
#include <stdio.h>
#include <spawn.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <signal.h>
#import <sys/cdefs.h>



void util_debug(const char * fmt, ...) __printflike(1, 2);
void util_info(const char * fmt, ...) __printflike(1, 2);
void util_warning(const char * fmt, ...) __printflike(1, 2);
void util_error(const char * fmt, ...) __printflike(1, 2);
void util_printf(const char * fmt, ...) __printflike(1, 2);
void util_hexprint(void *data, size_t len, const char *desc);
void util_hexprint_width(void *data, size_t len, int width, const char *desc);
void util_nanosleep(uint64_t nanosecs);
void util_msleep(unsigned int ms);
_Noreturn void fail_info(const char *info);
void fail_if(bool cond, const char *fmt, ...)  __printflike(2, 3);

//void move_in_jbResources();
// don't like macro

//int util_runCommand(const char *cmd, ...);
#endif /* utils_h */
