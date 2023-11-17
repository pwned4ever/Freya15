//
//  boot_info.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/21.
//

#ifndef boot_info_h
#define boot_info_h

#import <Foundation/Foundation.h>

NSString *prebootPath(NSString *path);

__kindof NSObject *bootInfo_getObject(NSString *name);
void bootInfo_setObject(NSString *name, __kindof NSObject *object);

uint64_t bootInfo_getUInt64(NSString *name);
uint64_t bootInfo_getSlidUInt64(NSString *name);
NSData *bootInfo_getData(NSString *name);
NSArray *bootInfo_getArray(NSString *name);


#endif /* boot_info_h */
