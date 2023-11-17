//
//  jailbreakd_test.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/22.
//

#import <stdio.h>
#import <stdbool.h>
#import <mach/mach.h>

//
//  jailbreakd_test.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/22.
//
void test_run_jailbreakd(void);
void* test_run_jailbreakd_async(void* arg);
void test_handoffKRW_jailbreakd(void);
void test_communicate_jailbreakd(void);
