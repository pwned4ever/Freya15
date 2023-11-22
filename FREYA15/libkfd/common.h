/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

#ifndef common_h
#define common_h

#include <errno.h>
#include <mach/mach.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/sysctl.h>
#include <unistd.h>

#define pages(number_of_pages) ((number_of_pages) * (16384ull))

#define min(a, b) (((a) < (b)) ? (a) : (b))
#define max(a, b) (((a) > (b)) ? (a) : (b))

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;
typedef intptr_t isize;

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef uintptr_t usize;

/*
 * Helper print macros.
 */


//        print_success("%llus %llums %lluus", sec, msec, usec);    \


//                print("[0x%04llx]:", u64_offset * sizeof(u64));           \
//            print("%016llx", u64_base[u64_offset]);                        \
print("\n");                                               \
print("\n");                                                   \
print(" ");                                                \

/*
 * Helper assert macros.
 */

#if CONFIG_ASSERT

/*
 print_failure("assertion failed: (%s)", #condition);        \
 print_failure("file: %s, line: %d", __FILE__, __LINE__);    \
 print_failure("... sleep(1) before exit(1) ...");          \

 */
#define assert(condition)                                               \
    do {                                                                \
        if (!(condition)) {                                             \
            sleep(1);                                                  \
            exit(1);                                                    \
        }                                                               \
    } while (0)

#else /* CONFIG_ASSERT */

#define assert(condition)

#endif /* CONFIG_ASSERT */
//print_failure("error: %s", message);    \

#define assert_false(message)                   \
    do {                                        \
        assert(false);                          \
    } while (0)
//            print_failure("bsd error: kret = %d, errno = %d (%s)", kret, errno, strerror(errno));    \

#define assert_bsd(statement)                                                                        \
    do {                                                                                             \
        kern_return_t kret = (statement);                                                            \
        if (kret != KERN_SUCCESS) {                                                                  \
            assert(kret == KERN_SUCCESS);                                                            \
        }                                                                                            \
    } while (0)
//            print_failure("mach error: kret = %d (%s)", kret, mach_error_string(kret));    \

#define assert_mach(statement)                                                             \
    do {                                                                                   \
        kern_return_t kret = (statement);                                                  \
        if (kret != KERN_SUCCESS) {                                                        \
            assert(kret == KERN_SUCCESS);                                                  \
        }                                                                                  \
    } while (0)

/*
 * Helper timer macros.
 */

//        print_timer(&tv_diff);                      \

#if CONFIG_TIMER

#define timer_start()                                 \
    struct timeval tv_start;                          \
    do {                                              \
        assert_bsd(gettimeofday(&tv_start, NULL));    \
    } while (0)

#define timer_end()                                 \
    do {                                            \
        struct timeval tv_end, tv_diff;             \
        assert_bsd(gettimeofday(&tv_end, NULL));    \
        timersub(&tv_end, &tv_start, &tv_diff);     \
    } while (0)

#else /* CONFIG_TIMER */

#define timer_start()
#define timer_end()

#endif /* CONFIG_TIMER */

/*
 * Helper allocation macros.
 */

#define malloc_bzero(size)               \
    ({                                   \
        void* pointer = malloc(size);    \
        assert(pointer != NULL);         \
        bzero(pointer, size);            \
        pointer;                         \
    })

#define bzero_free(pointer, size)    \
    do {                             \
        bzero(pointer, size);        \
        free(pointer);               \
        pointer = NULL;              \
    } while (0)

#endif /* common_h */
