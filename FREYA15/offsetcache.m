//
//  offsetcache.m
//  kfd
//
//  Created by Mineek on 24/08/2023.
//

#import <Foundation/Foundation.h>
#import "offsetcache.h"

uint64_t getOffset(int num) {
    //printf("[!] Getting offset for %d\n", num);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"offset_%d", num];
    NSNumber *offset = [defaults objectForKey:key];
    if (offset == nil) {
        return 0;
    }
    return [offset unsignedLongLongValue];
}

uint64_t setOffset(int num, uint64_t offset) {
   // printf("[!] Saving offset 0x%llx for %d\n", offset, num);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"offset_%d", num];
    [defaults setObject:[NSNumber numberWithUnsignedLongLong:offset] forKey:key];
    [defaults synchronize];
    return offset;
}
