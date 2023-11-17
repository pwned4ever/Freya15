//
//  utils.m
//  freya

#import <Foundation/Foundation.h>
//#import <CoreFoundation/CoreFoundation.h>
#include "utilsZS.h"

void (*log_UI)(const char *text) = NULL;

static void util_vprintf(const char *fmt, va_list ap);


void util_nanosleep(uint64_t nanosecs)
{
    int ret;
    struct timespec tp;
    tp.tv_sec = nanosecs / (1000 * 1000 * 1000);
    tp.tv_nsec = nanosecs % (1000 * 1000 * 1000);
    do {
        ret = nanosleep(&tp, &tp);
    } while (ret && errno == EINTR);
}

void util_msleep(unsigned int ms)
{
    uint64_t nanosecs = ms * 1000 * 1000;
    util_nanosleep(nanosecs);
}



static void log_vprintf(int type, const char *fmt, va_list ap)
{
    char message[256];

    vsnprintf(message, sizeof(message), fmt, ap);
    switch (type) {
        case 'D': type = 'D'; break;
        case 'I': type = '+'; break;
        case 'W': type = '!'; break;
        case 'E': type = '-'; break;
    }
    fprintf(stdout, "[%c] %s\n", type, message);
    if (0) {
        CF_EXPORT void CFLog(int32_t level, CFStringRef format, ...);
        //CFLog(6, CFSTR("[%c] %s\n"), type, message);
    }
    if (log_UI) {
        char ui_text[512];
        snprintf(ui_text, sizeof(ui_text), "[%c] %s\n", type, message);
        log_UI(ui_text);
    }
}

void util_debug(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_vprintf('D', fmt, ap);
    va_end(ap);
}

void util_info(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_vprintf('I', fmt, ap);
    va_end(ap);
}

void util_warning(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_vprintf('W', fmt, ap);
    va_end(ap);
}

void util_error(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_vprintf('E', fmt, ap);
    va_end(ap);
}

static void util_vprintf(const char *fmt, va_list ap)
{
    vfprintf(stdout, fmt, ap);
    if (log_UI) {
        char ui_text[512];
        vsnprintf(ui_text, sizeof(ui_text), fmt, ap);
        log_UI(ui_text);
    }
}

void util_printf(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    util_vprintf(fmt, ap);
    va_end(ap);
}

#define PROC_PIDPATHINFO_MAXSIZE (4*MAXPATHLEN)

extern char **environ;


void util_hexprint(void *data, size_t len, const char *desc)
{
    uint8_t *ptr = (uint8_t *)data;
    size_t i;

    if (desc) {
        util_printf("%s\n", desc);
    }
    for (i = 0; i < len; i++) {
        if (i % 16 == 0) {
            util_printf("%04x: ", (uint16_t)i);
        }
        util_printf("%02x ", ptr[i]);
        if (i % 16 == 7) {
            util_printf(" ");
        }
        if (i % 16 == 15) {
            util_printf("\n");
        }
    }
    if (i % 16 != 0) {
        util_printf("\n");
    }
}

void util_hexprint_width(void *data, size_t len, int width, const char *desc)
{
    uint8_t *ptr = (uint8_t *)data;
    size_t i;

    if (desc) {
        util_printf("%s\n", desc);
    }
    for (i = 0; i < len; i += width) {
        if (i % 16 == 0) {
            util_printf("%04x: ", (uint16_t)i);
        }
        if (width == 8) {
            util_printf("%016llx ", *(uint64_t *)(ptr + i));
        }
        else if (width == 4) {
            util_printf("%08x ", *(uint32_t *)(ptr + i));
        }
        else if (width == 2) {
            util_printf("%04x ", *(uint16_t *)(ptr + i));
        }
        else {
            util_printf("%02x ", ptr[i]);
        }
        if ((i + width) % 16 == 8) {
            util_printf(" ");
        }
        if ((i + width) % 16 == 0) {
            util_printf("\n");
        }
    }
    if (i % 16 != 0) {
        util_printf("\n");
    }
}

_Noreturn static void vfail(const char *fmt, va_list ap)
{
    char text[512];
    vsnprintf(text, sizeof(text), fmt, ap);
    util_printf("[!] fail < %s >\n", text);
    util_printf("[*] endless loop\n");
    while (1) {
        util_msleep(1000);
    }
}

void fail_if(bool cond, const char *fmt, ...)
{
    if (cond) {
        va_list ap;
        va_start(ap, fmt);
        vfail(fmt, ap);
        va_end(ap);
    }
}

_Noreturn void fail_info(const char *info)
{
    util_printf("[!] fail < %s >\n", info ? info : "null");
    util_printf("[*] endless loop\n");
    exit(1);
}
