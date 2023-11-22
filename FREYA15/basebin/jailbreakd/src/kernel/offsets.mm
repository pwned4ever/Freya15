#include "offsets.h"
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <sys/utsname.h>

uint32_t off_p_list_le_prev = 0;
uint32_t off_p_name = 0;
uint32_t off_p_pid = 0;
uint32_t off_p_ucred = 0;
uint32_t off_p_task = 0;
uint32_t off_p_csflags = 0;
uint32_t off_p_uid = 0;
uint32_t off_p_gid = 0;
uint32_t off_p_ruid = 0;
uint32_t off_p_rgid = 0;
uint32_t off_p_svuid = 0;
uint32_t off_p_svgid = 0;
uint32_t off_p_textvp = 0;
uint32_t off_p_pfd = 0;
uint32_t off_p_flag = 0;
uint32_t off_u_cr_label = 0;
uint32_t off_u_cr_uid = 0;
uint32_t off_u_cr_ruid = 0;
uint32_t off_u_cr_svuid = 0;
uint32_t off_u_cr_ngroups = 0;
uint32_t off_u_cr_groups = 0;
uint32_t off_u_cr_rgid = 0;
uint32_t off_u_cr_svgid = 0;
uint32_t off_task_t_flags = 0;
uint32_t off_task_itk_space = 0;
uint32_t off_task_map = 0;
uint32_t off_vm_map_pmap = 0;
uint32_t off_pmap_ttep = 0;
uint32_t off_vnode_v_name = 0;
uint32_t off_vnode_v_parent = 0;
uint32_t off_vnode_v_data = 0;
uint32_t off_fp_glob = 0;
uint32_t off_fg_data = 0;
uint32_t off_vnode_vu_ubcinfo = 0;
uint32_t off_ubc_info_cs_blobs = 0;
uint32_t off_cs_blob_csb_platform_binary = 0;
uint32_t off_ipc_port_ip_kobject = 0;
uint32_t off_ipc_space_is_table = 0;
uint32_t off_amfi_slot = 0;
uint32_t off_sandbox_slot = 0;

// kernel func
uint64_t off_kalloc_data_external = 0;
uint64_t off_kfree_data_external = 0;
uint64_t off_add_x0_x0_0x40_ret = 0;
uint64_t off_empty_kdata_page = 0;
uint64_t off_trustcache = 0;
uint64_t off_gphysbase = 0;
uint64_t off_gphyssize = 0;
uint64_t off_pmap_enter_options_addr = 0;
uint64_t off_allproc = 0;
uint64_t off_zm_fix_addr_kalloc = 0;
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
char *_cur_deviceModel = NULL;
char *get_current_deviceModel(void){
    if(_cur_deviceModel)
        return _cur_deviceModel;
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    static NSDictionary* deviceNamesByCode = nil;
    if (!deviceNamesByCode) {
        deviceNamesByCode = @{ @"iPhone8,1" : @"iPhone 6S",         //
                              @"iPhone8,2" : @"iPhone 6S Plus",    //
                              @"iPhone8,4" : @"iPhone SE",         //
                              @"iPhone9,1" : @"iPhone 7",          //
                              @"iPhone9,3" : @"iPhone 7",          //
                              @"iPhone9,2" : @"iPhone 7 Plus",     //
                              @"iPhone9,4" : @"iPhone 7 Plus",     //
                              @"iPhone10,1": @"iPhone 8",          // CDMA
                              @"iPhone10,4": @"iPhone 8",          // GSM
                              @"iPhone10,2": @"iPhone 8 Plus",     // CDMA
                              @"iPhone10,5": @"iPhone 8 Plus",     // GSM
                              @"iPhone10,3": @"iPhone X",          // CDMA
                              @"iPhone10,6": @"iPhone X",          // GSM
                              @"iPhone11,2": @"iPhone XS",         //
                              @"iPhone11,4": @"iPhone XS Max",     //
                              @"iPhone11,6": @"iPhone XS Max",     // China
                              @"iPhone11,8": @"iPhone XR",         //
                              @"iPhone12,1": @"iPhone 11",         //
                              @"iPhone12,3": @"iPhone 11 Pro",     //
                              @"iPhone12,5": @"iPhone 11 Pro Max", //
                              
                              @"iPad4,1"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   : @"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   : @"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   : @"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   : @"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   : @"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
        };
    }
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    _cur_deviceModel = strdup([deviceName UTF8String]);
    return _cur_deviceModel;
}


void _offsets_init(void) {
    NSString *device = [NSString stringWithUTF8String: get_current_deviceModel()];
    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/proc_internal.h#L227
    off_p_list_le_prev = 0x8;
    off_p_name = 0x2d9;
    off_p_pid = 0x68;
    off_p_ucred = 0xd8;
    off_p_task = 0x10;
    off_p_csflags = 0x300;
    off_p_uid = 0x2c;
    off_p_gid = 0x30;
    off_p_ruid = 0x34;
    off_p_rgid = 0x38;
    off_p_svuid = 0x3c;
    off_p_svgid = 0x40;
    off_p_textvp = 0x2a8;
    off_p_pfd = 0x100;
    off_p_flag = 0x1bc;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ucred.h#L91
    off_u_cr_label = 0x78;
    off_u_cr_uid = 0x18;
    off_u_cr_ruid = 0x1c;
    off_u_cr_svuid = 0x20;
    off_u_cr_ngroups = 0x24;
    off_u_cr_groups = 0x28;
    off_u_cr_rgid = 0x68;
    off_u_cr_svgid = 0x6c;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/kern/task.h#L157
    off_task_t_flags = 0x3e8;
    off_task_itk_space = 0x330;
    off_task_map = 0x28; //_get_task_pmap

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/vm/vm_map.h#L471
    off_vm_map_pmap = 0x48;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/arm/pmap.h#L377
    off_pmap_ttep = 0x8;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/vnode_internal.h#L142
    off_vnode_vu_ubcinfo = 0x78;
    off_vnode_v_name = 0xb8;
    off_vnode_v_parent = 0xc0;
    off_vnode_v_data = 0xe0;

    off_fp_glob = 0x10;

    off_fg_data = 0x38;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ubc_internal.h#L149
    off_ubc_info_cs_blobs = 0x50;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ubc_internal.h#L102
    off_cs_blob_csb_platform_binary = 0xb8;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/ipc/ipc_port.h#L152
    // https://github.com/0x7ff/dimentio/blob/7ffffffb4ebfcdbc46ab5e8f1becc0599a05711d/libdimentio.c#L958
    off_ipc_port_ip_kobject = 0x58;

    // https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/ipc/ipc_space.h#L128
    off_ipc_space_is_table = 0x20;

    off_amfi_slot = 0x8;
    off_sandbox_slot = 0x10;

    if ([device  isEqual: @"iPad 7 WiFi"] || [device  isEqual: @"iPad 7 Cellular"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {

            off_kalloc_data_external = 0xFFFFFFF0071C5CC8;//done me
            off_kfree_data_external = 0xFFFFFFF0071C6434;//done me
            
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059260B4;//0xFFFFFFF005C13DF0;//
            off_empty_kdata_page = 0xFFFFFFF00781C000 + 0x100;//done me
            off_trustcache = 0xFFFFFFF0078B58C0;//done me
            off_gphysbase = 0xFFFFFFF007103B28;//done me
            off_gphyssize = 0xFFFFFFF007103B40;//done me
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;//done me
            
            off_allproc = 0xFFFFFFF007890110;//done me
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A530;//done me
            
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);

        }

    } else if ([device  isEqual: @"iPad Air 2 WiFi"] || [device  isEqual: @"iPad Air 2 Cellular"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xfffffff00716Cf84;
            off_kfree_data_external = 0xFFFFFFF00716d6fC;

            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C3ADF0; // AppleS5L8920XFPWM
            off_empty_kdata_page = 0xFFFFFFF0077C4000 + 0x100;
            off_trustcache = 0xFFFFFFF00785D8C0;
            off_gphysbase = 0xFFFFFFF0070C5A30; //xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_gphyssize = 0xFFFFFFF0070C5A48; //i think this is wrong//xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_pmap_enter_options_addr = 0xFFFFFFF007263AFC;
            off_allproc = 0xFFFFFFF007838110;//
            off_zm_fix_addr_kalloc =  0xFFFFFFF0070E4528;// done

        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);

        }

    } else if ([device  isEqual: @"iPhone 6S"]) {

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF007188AE8;
            off_kfree_data_external = 0xFFFFFFF007189254;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2AEC0; // AppleS5L8920XFPWM
            off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;
            off_trustcache = 0xFFFFFFF0078718C0;
            off_gphysbase = 0xFFFFFFF0070CBA30; //xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_gphyssize = 0xFFFFFFF0070CBA48; //xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
            off_allproc = 0xFFFFFFF00784C100;
            off_zm_fix_addr_kalloc =  0xFFFFFFF007137450;// done
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;
            off_kfree_data_external =  0xFFFFFFF0071C6638;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B88C0;
            off_gphysbase = 0xFFFFFFF007103B20;
            off_gphyssize = 0xFFFFFFF007103B30;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF007893910;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 6S Plus"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF007188AE8;
            off_kfree_data_external = 0xFFFFFFF007189254;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2ADF0;//
            off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078718C0;
            off_gphysbase = 0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
            off_allproc = 0xFFFFFFF00784C100;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0071024B8;
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;
            off_kfree_data_external =  0xFFFFFFF0071C6638;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B88C0;
            off_gphysbase = 0xFFFFFFF007103B20;
            off_gphyssize = 0xFFFFFFF007103B30;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF007893910;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;

        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone SE"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF007188AE8;//done
            off_kfree_data_external =  0xFFFFFFF007189254;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C8ADF0;//done
            off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078718C0;//done
            off_gphysbase = 0xFFFFFFF0070CBA30;//done
            off_gphyssize = 0xFFFFFFF0070CBA48;//???;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
            off_allproc = 0xFFFFFFF00784C100;// done
            off_zm_fix_addr_kalloc =  0xFFFFFFF0071024B8;// done
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF007188C4C;//done
            off_kfree_data_external =  0xFFFFFFF007189884;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005CA5DF0;//done
            off_empty_kdata_page = 0xFFFFFFF0077E0000 + 0x100;//done
            off_trustcache = 0xFFFFFFF007878880;//done
            off_gphysbase = 0xFFFFFFF0070CBA28;//done
            off_gphyssize = 0xFFFFFFF0070CBA38;//???;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF0072825F4;//done
            off_allproc = 0xFFFFFFF007853900;// done
            off_zm_fix_addr_kalloc =  0xFFFFFFF007102498;// done
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 7"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF0071C5CC8;
            off_kfree_data_external =  0xFFFFFFF0071C6434;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059260B4;
            off_empty_kdata_page = 0xFFFFFFF00781C000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B58C0;
            off_gphysbase = 0xFFFFFFF007103B28;
            off_gphyssize = 0xFFFFFFF007103B40;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;
            off_allproc = 0xFFFFFFF007890110;
            off_zm_fix_addr_kalloc =  0xFFFFFFF00713A530;
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;
            off_kfree_data_external =  0xFFFFFFF0071C6638;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;//FFFFFFF005C37428
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B88C0;
            off_gphysbase = 0xFFFFFFF007103B20;
            off_gphyssize = 0xFFFFFFF007103B30;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF007893910;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }
    } else if ([device  isEqual: @"iPhone 7 Plus"]) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            
            off_kalloc_data_external = 0xFFFFFFF0071C5CC8;//done me
            off_kfree_data_external = 0xFFFFFFF0071C6434;//done me
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059260B4;//0xFFFFFFF005C13DF0;//
            off_empty_kdata_page = 0xFFFFFFF00781C000 + 0x100;//done me
            off_trustcache = 0xFFFFFFF0078B58C0;//done me
            off_gphysbase = 0xFFFFFFF007103B28;//done me
            off_gphyssize = 0xFFFFFFF007103B40;//done me
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;//done me
            off_allproc = 0xFFFFFFF007890110;//done me
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A530;//done me
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;    //0xFFFFFFF0071C5E2C
            off_kfree_data_external =  0xFFFFFFF0071C6638;    //0xFFFFFFF0071C6638
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;//
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;//0xFFFFFFF007820000
            off_trustcache = 0xFFFFFFF0078B88C0;              //0xFFFFFFF0078B88C0
            off_gphysbase = 0xFFFFFFF007103B20;               //0xFFFFFFF007103B20
            off_gphyssize = 0xFFFFFFF007103C18;               //0xFFFFFFF007103C18
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940; //0xFFFFFFF0072BF940
            off_allproc = 0xFFFFFFF007893910;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 8"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF007CA3EDC;//
            off_kfree_data_external =  0xFFFFFFF007CA4320;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF008524900;//????;
            off_empty_kdata_page = 0xFFFFFFF00959C000 + 0x100;////0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF00979BF80;//;
            off_gphysbase = 0xFFFFFFF0078803D8;//
            off_gphyssize = 0xFFFFFFF0078803F0;//
            off_pmap_enter_options_addr = 0xFFFFFFF007CA2718;//0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF0097493E0;//0xFFFFFFF007893910;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EE718;
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external =  0xFFFFFFF007B95664;
            off_kfree_data_external =   0xFFFFFFF007B95984;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF008269688;//0xFFFFFFF0083B7848; FFFFFFF0083B7324 , FFFFFFF0083B73A8 , FFFFFFF0083B7358
            off_empty_kdata_page = 0xFFFFFFF00957C000 + 0x100;// 0xFFFFFFF009578000 + 0x100;//0xFFFFFFF00957C000 + 0x100;
            off_trustcache = 0xFFFFFFF00977AF80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;
            off_gphyssize = 0xFFFFFFF0077B3BE0;//0xFFFFFFF0077B3BE8;
            off_pmap_enter_options_addr = 0xFFFFFFF007CA3098; //failed pmap_enter, virt=%p, start_a
            off_allproc = 0xFFFFFFF009728BA0;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;
        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 8 Plus"]) {
        
    } else if ([device  isEqual: @"iPhone X"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.1")) {
            off_kalloc_data_external = 0xFFFFFFF007B994E4;//done
            off_kfree_data_external = 0xFFFFFFF007B99D58;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083BBD68;//0xFFFFFFF008524900;//????; FFFFFFF0083BB844//
            off_empty_kdata_page = 0xFFFFFFF009594000 + 0x100;//done
            off_trustcache = 0xFFFFFFF009797F80;//done
            off_gphysbase = 0xFFFFFFF0077B7AF0;//0xFFFFFFF0077B7AE8;
            off_gphyssize = 0xFFFFFFF0077B7B00;//0xFFFFFFF0077B7B08;?
            off_pmap_enter_options_addr = 0xFFFFFFF007CA2718;//   <- ix 15.1
            off_allproc = 0xFFFFFFF0097453E0;// <- ix 15.1
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EE718;//   <- ix 15.1 & iphone 8 same?  15.1
            
        } else if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"15.0.2")) {
            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009574000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;

        } else {
            NSLog(@"[jailbreakd] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else {
        NSLog(@"[jailbreakd] No matching offsets.\n");
        exit(EXIT_FAILURE);
    }
}
/*
    off_kalloc_data_external = 0xFFFFFFF007188AE8;
    off_kfree_data_external = 0xFFFFFFF007189254;
    off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2AEC0;
    off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;
    off_trustcache = 0xFFFFFFF0078718C0;
    off_gphysbase = 0xFFFFFFF0070CBA30; // xref pmap_attribute_cache_sync size:
                                        // 0x%llx @%s:%d
    off_gphyssize = 0xFFFFFFF0070CBA48; // xref pmap_attribute_cache_sync size:
                                        // 0x%llx @%s:%d
    off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
    off_allproc = 0xFFFFFFF00784C100;
*/
