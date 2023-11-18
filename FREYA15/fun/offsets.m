//
//  offsets.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/10.
//

#include "offsets.h"
#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include <sys/utsname.h>
#include "../util/utilsZS.h"

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
uint32_t off_p_ro = 0;

//kernel func
uint64_t off_kalloc_data_external = 0;
uint64_t off_kfree_data_external = 0;
uint64_t off_add_x0_x0_0x40_ret = 0;
uint64_t off_empty_kdata_page = 0;
uint64_t off_trustcache = 0;
uint64_t off_gphysbase = 0;
uint64_t off_gphyssize = 0;
uint64_t off_pmap_enter_options_addr = 0;
uint64_t off_allproc = 0;
uint64_t off_pmap_find_phys = 0;
uint64_t off_ml_phys_read_data = 0;
uint64_t off_ml_phys_write_data = 0;
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

    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/proc_internal.h#L227
    off_p_list_le_prev = 0x8;
if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
    off_p_name = 0x389;
} else {
    off_p_name = 0x2d9;
}
    off_p_pid = 0x68;
    off_p_ucred = 0xd8;
    off_p_task = 0x10;
if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
    off_p_csflags = 0x1C;
} else {
    off_p_csflags = 0x300;/*EXPORT _cs_entitlement_flags
                           __TEXT_EXEC:__text:FFFFFFF0073F5254 _cs_entitlement_flags
                           __TEXT_EXEC:__text:FFFFFFF0073F5254                 LDR             W8, [X0,#0x290]*/ // <- ios 12
}
    off_p_uid = 0x2c;
    off_p_gid = 0x30;
    off_p_ruid = 0x34;
    off_p_rgid = 0x38;
    off_p_svuid = 0x3c;
    off_p_svgid = 0x40;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.4")) {
        off_p_textvp = 0x350;
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        off_p_textvp = 0x358;
    } else {
        off_p_textvp = 0x2a8;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        off_p_pfd = 0x100;
    } else {
        off_p_pfd = 0x100;

    }

    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ucred.h#L91
    off_u_cr_label = 0x78;
    off_u_cr_uid = 0x18;
    off_u_cr_ruid = 0x1c;
    off_u_cr_svuid = 0x20;
    off_u_cr_ngroups = 0x24;
    off_u_cr_groups = 0x28;
    off_u_cr_rgid = 0x68;
    off_u_cr_svgid = 0x6c;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/kern/task.h#L157
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        off_task_t_flags = 0x3b8;
        
    } else {
        off_task_t_flags = 0x3e8;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
        //off_task_itk_space = 0x330;
        off_task_itk_space = 0x308;
    } else {
        off_task_itk_space = 0x330;
    }
    
    off_task_map = 0x28;    //_get_task_pmap

    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/vm/vm_map.h#L471
    off_vm_map_pmap = 0x48;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/arm/pmap.h#L377
    off_pmap_ttep = 0x8;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/vnode_internal.h#L142
    off_vnode_vu_ubcinfo = 0x78;
    off_vnode_v_name = 0xb8;
    off_vnode_v_parent = 0xc0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.2")) {
//        off_vnode_v_data = 0xD8;
        off_vnode_v_data = 0xe0;

    } else {
        off_vnode_v_data = 0xe0;

    }
        
    off_fp_glob = 0x10;
    
    off_fg_data = 0x38;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ubc_internal.h#L149
    off_ubc_info_cs_blobs = 0x50;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/bsd/sys/ubc_internal.h#L102
    off_cs_blob_csb_platform_binary = 0xb8;
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/ipc/ipc_port.h#L152

    //https://github.com/0x7ff/dimentio/blob/7ffffffb4ebfcdbc46ab5e8f1becc0599a05711d/libdimentio.c#L958
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.4")) {
        off_ipc_port_ip_kobject = 0x48;
    } else {
        off_ipc_port_ip_kobject = 0x58;

    }
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8019.41.5/osfmk/ipc/ipc_space.h#L128
    off_ipc_space_is_table = 0x20;
    
    off_amfi_slot = 0x8;
    off_sandbox_slot = 0x10;
    off_p_ro = 0x20;
    
    if ([device  isEqual: @"iPhone 6S"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
           // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF007188AE8;
            off_kfree_data_external = 0xFFFFFFF007189254;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2AEC0; // AppleS5L8920XFPWM
            off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;
            off_trustcache = 0xFFFFFFF0078718C0;
            off_gphysbase = 0xFFFFFFF0070CBA30; //xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_gphyssize = 0xFFFFFFF0070CBA48; //xref pmap_attribute_cache_sync size: 0x%llx @%s:%d
            off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
            off_allproc = 0xFFFFFFF00784C100;
            off_pmap_find_phys = 0xFFFFFFF007284B58;
            off_ml_phys_read_data = 0xFFFFFFF00729510C;
            off_ml_phys_write_data = 0xFFFFFFF007295390;
            
            off_zm_fix_addr_kalloc =  0xFFFFFFF007137450;// done
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);

        }
    } else if ([device  isEqual: @"iPhone 6S Plus"]) {
        
        
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF0071D4848;//done
            off_kfree_data_external =  0xFFFFFFF0071D4EB4;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF00596A60C;//done
            off_empty_kdata_page = 0xFFFFFFF007824000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078BA570;//done
            off_gphysbase = 0xFFFFFFF00714E860;//done
            off_gphyssize = 0xFFFFFFF00714CB18;//??? FFFFFFF00714E870;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF0072CA294;//done
            off_allproc = 0xFFFFFFF00789A198;// done
            off_pmap_find_phys = 0xFFFFFFF0072D1198;//done
            off_ml_phys_read_data = 0xFFFFFFF0072E25BC;//done
            off_ml_phys_write_data = 0xFFFFFFF0072E2824;//done
            off_zm_fix_addr_kalloc =  0xFFFFFFF007137450;// done
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.7.3")) {
           // printf("[i] %s offsets selected for iOS 15.7.3\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF00719762C;//done
            off_kfree_data_external =  0xFFFFFFF007197C98;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005B3460C;//APPLEARMPE
            off_empty_kdata_page = 0xFFFFFFF0077E0000 + 0x100;//done
            off_trustcache = 0xFFFFFFF007876530;//done
            off_gphysbase = 0xFFFFFFF00714D6E8;//done
            off_gphyssize = 0xFFFFFFF0071149F8;//??? FFFFFFF00714E870;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF00728C7F4;//done
            off_allproc = 0xFFFFFFF007856188;// done
            off_pmap_find_phys = 0xFFFFFFF00729341C;//done
            off_ml_phys_read_data = 0xFFFFFFF0072A3828;//done
            off_ml_phys_write_data = 0xFFFFFFF0072A3A90;//done
            off_zm_fix_addr_kalloc =  0xFFFFFFF0070FF3D0;
            
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.3.1")) {//19D52
           // printf("[i] %s offsets selected for iOS 15.3.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF00718D748;//done
            off_kfree_data_external =  0xFFFFFFF00718DF0C;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005AD80B4;//done AppleARMPE iphone 7 and 6s the same throughtout versions ios .1 - .7
            off_empty_kdata_page = 0xFFFFFFF0077E0000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078798C0;//done
            off_gphysbase = 0xFFFFFFF0070CC0C0;//FFFFFFF00714E7C0;//done
            off_gphyssize = 0xFFFFFFF0070CC0D8;//???;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF007284A8C;// done
            off_allproc = 0xFFFFFFF007854100;//done
            off_pmap_find_phys = 0xFFFFFFF00728B380;//0xFFFFFFF00728B920;//done //FFFFFFF00717CE14
            off_ml_phys_read_data = 0xFFFFFFF00729BB60;//done
            off_ml_phys_write_data = 0xFFFFFFF00729BDE4;// done
            off_zm_fix_addr_kalloc =  0xFFFFFFF007106520;// done

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
           // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);
            /*off_kalloc_data_external = 0xFFFFFFF007188AE8;//done
            off_kfree_data_external =  0xFFFFFFF007189254;//done
            
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005AE40B4;//done
            off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078718C0;//done
            off_gphysbase = 0xFFFFFFF007103B28;
            off_gphyssize = 0xFFFFFFF007103B40;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;
            off_allproc = 0xFFFFFFF007890110;
            off_pmap_find_phys = 0xFFFFFFF0072C2154;
            off_ml_phys_read_data = 0xFFFFFFF0072D361C;
            off_ml_phys_write_data = 0xFFFFFFF0072D38A0;
            off_zm_fix_addr_kalloc =  0xFFFFFFF00713A530;
            
           */
             off_kalloc_data_external = 0xFFFFFFF007188AE8;
             off_kfree_data_external = 0xFFFFFFF007189254;
             
             off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2ADF0;//
             off_empty_kdata_page = 0xFFFFFFF0077D8000 + 0x100;//done
             off_trustcache = 0xFFFFFFF0078718C0;
             off_gphysbase = 0xFFFFFFF0070CBA30;
             off_gphyssize = 0xFFFFFFF0070CBA48;

             off_pmap_enter_options_addr = 0xFFFFFFF00727DDE8;
             
             off_allproc = 0xFFFFFFF00784C100;
             off_pmap_find_phys = 0xFFFFFFF007284B58;
             off_ml_phys_read_data = 0xFFFFFFF00729510C;
             off_ml_phys_write_data = 0xFFFFFFF007295390;
             off_zm_fix_addr_kalloc = 0xFFFFFFF0071024B8;

             
            
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0.2") || SYSTEM_VERSION_EQUAL_TO(@"15.0.1")) {
           // printf("[i] %s offsets selected for iOS 15.0.2/1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;
            off_kfree_data_external =  0xFFFFFFF0071C6638;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B88C0;
            off_gphysbase = 0xFFFFFFF007103B20;
            off_gphyssize = 0xFFFFFFF007103B30;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF007893910;
            off_pmap_find_phys = 0xFFFFFFF0072C602C;
            off_ml_phys_read_data = 0xFFFFFFF0072D6ABC;
            off_ml_phys_write_data = 0xFFFFFFF0072D6D40;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone SE"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.7.3")) {
           // printf("[i] %s offsets selected for iOS 15.7.3\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.6")) {
           // printf("[i] %s offsets selected for iOS 15.6\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.3.1")) {
           // printf("[i] %s offsets selected for iOS 15.3.1\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 7"]) {
      
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
            // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF0071D4848;//done
            off_kfree_data_external =  0xFFFFFFF0071D4EB4;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF00596A60C;//done
            off_empty_kdata_page = 0xFFFFFFF007824000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078BA570;//done
            off_gphysbase = 0xFFFFFFF00714E860;//done
            off_gphyssize = 0xFFFFFFF00714CB18;//??? FFFFFFF00714E870;//not done yet //??
            off_pmap_enter_options_addr = 0xFFFFFFF0072CA294;//done
            off_allproc = 0xFFFFFFF00789A198;// done
            
            off_pmap_find_phys = 0xFFFFFFF0072D1198;//done
            off_ml_phys_read_data = 0xFFFFFFF0072E25BC;//done
            off_ml_phys_write_data = 0xFFFFFFF0072E2824;//done
            off_zm_fix_addr_kalloc =  0xFFFFFFF007137450;// done
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.5")) {
            off_kalloc_data_external = 0xFFFFFFF0071D4040;//done by twittter guy
            off_kfree_data_external = 0xFFFFFFF0071D4BA8;//done by twittter guy
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2AEC0;//done by twittter guy
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;//done by twittter guy
            off_trustcache = 0xFFFFFFF0078B6570;//done by twittter guy
            off_gphysbase = 0xFFFFFFF00714E5C0;//done by twittter guy
            off_gphyssize = 0xFFFFFFF00714E5C8;//done by twittter guy
            off_pmap_enter_options_addr = 0xFFFFFFF0072C7BD0;//done by twittter guy
            off_allproc = 0xFFFFFFF007896198; ////done by twittter guy
            off_pmap_find_phys = 0xFFFFFFF0072CEAE4;//done by twittter guy
            off_ml_phys_read_data = 0xFFFFFFF0072DFEB4;//done by twittter guy
            off_ml_phys_write_data = 0xFFFFFFF0072E011C;////done by twittter guy
            off_zm_fix_addr_kalloc = 0xFFFFFFF0071373E0;/////done by twittter guy
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
           // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF0071C5CC8;
            off_kfree_data_external =  0xFFFFFFF0071C6434;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059260B4;
            off_empty_kdata_page = 0xFFFFFFF00781C000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B58C0;
            off_gphysbase = 0xFFFFFFF007103B28;
            off_gphyssize = 0xFFFFFFF007103B40;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;
            off_allproc = 0xFFFFFFF007890110;
            off_pmap_find_phys = 0xFFFFFFF0072C2154;
            off_ml_phys_read_data = 0xFFFFFFF0072D361C;
            off_ml_phys_write_data = 0xFFFFFFF0072D38A0;
            off_zm_fix_addr_kalloc =  0xFFFFFFF00713A530;
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0.2") || SYSTEM_VERSION_EQUAL_TO(@"15.0.1")) {
           // printf("[i] %s offsets selected for iOS 15.0.2/1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF0071C5E2C;
            off_kfree_data_external =  0xFFFFFFF0071C6638;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4;//FFFFFFF005C37428
            off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF0078B88C0;
            off_gphysbase = 0xFFFFFFF007103B20;
            off_gphyssize = 0xFFFFFFF007103B30;
            off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF007893910;
            off_pmap_find_phys = 0xFFFFFFF0072C602C;
            off_ml_phys_read_data = 0xFFFFFFF0072D6ABC;
            off_ml_phys_write_data = 0xFFFFFFF0072D6D40;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }
    } else if ([device  isEqual: @"iPhone 7 Plus"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.7.3")) {
           // printf("[i] %s offsets selected for iOS 15.7.3\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.6")) {
           // printf("[i] %s offsets selected for iOS 15.6\n", device.UTF8String);
//    { .task_threads_next = 0x388, .task_threads_prev = 0x390, .map = 0x3a0, .thread_id = 0x440, .object_size = 0x610 }, // iOS 15.4 - 15.7.2 arm64e

            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009570000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA607C;
            off_ml_phys_read_data = 0xFFFFFFF007CB9860;
            off_ml_phys_write_data = 0xFFFFFFF007CB9B58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.3.1")) {
           // printf("[i] %s offsets selected for iOS 15.3.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009570000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA607C;
            off_ml_phys_read_data = 0xFFFFFFF007CB9860;
            off_ml_phys_write_data = 0xFFFFFFF007CB9B58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.2")) {
            off_kalloc_data_external = 0xFFFFFFF0071CA924;
            off_kfree_data_external = 0xFFFFFF0071CB0E8;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C09428;
            off_empty_kdata_page = 0xFFFFFFF007824000 + 0x100;//done
            off_trustcache = 0xFFFFFFF0078BD900;
            off_gphysbase = 0xFFFFFFF0071041B8;
            off_gphyssize = 0xFFFFFFF0071041D0;

            off_pmap_enter_options_addr = 0xFFFFFFF0072C1BC0;
            
            off_allproc = 0xFFFFFFF007898120;
            off_pmap_find_phys = 0xFFFFFFF0072C8D14;
            off_ml_phys_read_data = 0xFFFFFFF00729510C;
            off_ml_phys_write_data = 0xFFFFFFF007295390;
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713E598;
            //
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
            
            // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);

            off_kalloc_data_external = 0xFFFFFFF0071C5CC8;//done me
            off_kfree_data_external = 0xFFFFFFF0071C6434;//done me
            
            off_add_x0_x0_0x40_ret = 0xFFFFFFF005C13DF0;//
            off_empty_kdata_page = 0xFFFFFFF00781C000 + 0x100;//done me
            off_trustcache = 0xFFFFFFF0078B58C0;//done me
            off_gphysbase = 0xFFFFFFF007103B28;//done me
            off_gphyssize = 0xFFFFFFF007103B40;//done me
            off_pmap_enter_options_addr = 0xFFFFFFF0072BB124;//done me
            
            off_allproc = 0xFFFFFFF007890110;//done me
            off_pmap_find_phys = 0xFFFFFFF0072C2154;//done me
            off_ml_phys_read_data = 0xFFFFFFF0072D361C;//done me
            off_ml_phys_write_data = 0xFFFFFFF0072D38A0;//done me
            off_zm_fix_addr_kalloc = 0xFFFFFFF00713A530;//done me

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
            
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone 8"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
           // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);
            /*
             off_kalloc_data_external = 0xFFFFFFF007B994E4; //done
             off_kfree_data_external = 0xFFFFFFF007B99804; //done
             off_add_x0_x0_0x40_ret = 0xFFFFFFF005C2AEC0;
             off_empty_kdata_page = 0xFFFFFFF0095BE748 + 0x100; //done
             off_trustcache = 0xFFFFFFF00979BF80; //done
             off_gphysbase = 0xFFFFFFF0077B7AE8; //xref //done
             //pmap_attribute_cache_sync size: 0x%llx @%s:%d
             off_gphyssize = 0xFFFFFFF0077B7B00; //xref //done
             //pmap_attribute_cache_sync size: 0x%llx @%s:%d
             off_pmap_enter_options_addr = 0xFFFFFFF007CA2718; //done
             off_allproc = 0xFFFFFFF0097493E0; //done
      
             off_pmap_find_phys = 0xFFFFFFF007CA9FAC; //done
             off_ml_phys_read_data = 0xFFFFFFF007CBE2B4; //done
             off_ml_phys_write_data = 0xFFFFFFF007CBE5AC; //done
      
             */
            off_kalloc_data_external = 0xFFFFFFF007CA3EDC;//
            off_kfree_data_external =  0xFFFFFFF007CA4320;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF008524900;//????;
            off_empty_kdata_page = 0xFFFFFFF00959C000 + 0x100;////0xFFFFFFF007820000 + 0x100;
            off_trustcache = 0xFFFFFFF00979BF80;//;
            off_gphysbase = 0xFFFFFFF0078803D8;//
            off_gphyssize = 0xFFFFFFF0078803F0;//
            off_pmap_enter_options_addr = 0xFFFFFFF007CA2718;//0xFFFFFFF0072BF940;
            off_allproc = 0xFFFFFFF0097493E0;//0xFFFFFFF007893910;
            off_pmap_find_phys = 0xFFFFFFF007B87A24;
            off_ml_phys_read_data = 0xFFFFFFF007CBE2B4;
            off_ml_phys_write_data = 0xFFFFFFF007CBE5AC;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EE718;
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0.2") || SYSTEM_VERSION_EQUAL_TO(@"15.0.1")) {
            //util_info("[i] %s offsets selected for iOS 15.0.2/1\n", device.UTF8String); //19A404
            off_kalloc_data_external =  0xFFFFFFF007B95664;
            off_kfree_data_external =   0xFFFFFFF007B95984;
            off_add_x0_x0_0x40_ret = 0xFFFFFFF008269688;//0xFFFFFFF0083B7848; FFFFFFF0083B7324 , FFFFFFF0083B73A8 , FFFFFFF0083B7358
            off_empty_kdata_page = 0xFFFFFFF00957C000 + 0x100;// 0xFFFFFFF009578000 + 0x100;//0xFFFFFFF00957C000 + 0x100;
            off_trustcache = 0xFFFFFFF00977AF80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;
            off_gphyssize = 0xFFFFFFF0077B3BE0;//0xFFFFFFF0077B3BE8;
            off_pmap_enter_options_addr = 0xFFFFFFF007CA3098; //failed pmap_enter, virt=%p, start_a
            off_allproc = 0xFFFFFFF009728BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA9978;
            off_ml_phys_read_data = 0xFFFFFFF007CBD860;
            off_ml_phys_write_data = 0xFFFFFFF007CBDB58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }
        
    } else if ([device  isEqual: @"iPhone 8 Plus"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.7.3")) {
           // printf("[i] %s offsets selected for iOS 15.7.3\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.6")) {
           // printf("[i] %s offsets selected for iOS 15.6\n", device.UTF8String);
//    { .task_threads_next = 0x388, .task_threads_prev = 0x390, .map = 0x3a0, .thread_id = 0x440, .object_size = 0x610 }, // iOS 15.4 - 15.7.2 arm64e

            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009570000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA607C;
            off_ml_phys_read_data = 0xFFFFFFF007CB9860;
            off_ml_phys_write_data = 0xFFFFFFF007CB9B58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.3.1")) {
           // printf("[i] %s offsets selected for iOS 15.3.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009570000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA607C;
            off_ml_phys_read_data = 0xFFFFFFF007CB9860;
            off_ml_phys_write_data = 0xFFFFFFF007CB9B58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone X"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.1")) {
           // printf("[i] %s offsets selected for iOS 15.1\n", device.UTF8String);
            off_kalloc_data_external = 0xFFFFFFF007B994E4;//done
            off_kfree_data_external = 0xFFFFFFF007B99D58;//done
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083BBD68;//0xFFFFFFF008524900;//????; FFFFFFF0083BB844//
            off_empty_kdata_page = 0xFFFFFFF009594000 + 0x100;//done
            off_trustcache = 0xFFFFFFF009797F80;//done
            off_gphysbase = 0xFFFFFFF0077B7AF0;//0xFFFFFFF0077B7AE8;
            off_gphyssize = 0xFFFFFFF0077B7B00;//0xFFFFFFF0077B7B08;?
            off_pmap_enter_options_addr = 0xFFFFFFF007CA2718;//   <- ix 15.1
            off_allproc = 0xFFFFFFF0097453E0;// <- ix 15.1
            off_pmap_find_phys = 0xFFFFFFF007CA9F54;// <- ix 15.1
            off_ml_phys_read_data = 0xFFFFFFF007CBE2B4; //done
            off_ml_phys_write_data = 0xFFFFFFF007CBE5AC;//   <- ix 15.1
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EE718;//   <- ix 15.1 & iphone 8 same?  15.1

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0.2") || SYSTEM_VERSION_EQUAL_TO(@"15.0.1")) {
           // printf("[i] %s offsets selected for iOS 15.0.2/1\n", device.UTF8String);

        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
            
            off_kalloc_data_external = 0xFFFFFFF007B91664;//
            off_kfree_data_external = 0xFFFFFFF007B91F78;//
            off_add_x0_x0_0x40_ret = 0xFFFFFFF0083B33B0;//0xFFFFFFF0083B3850;?
            off_empty_kdata_page = 0xFFFFFFF009574000;//0xFFFFFFF009574000;//;
            off_trustcache = 0xFFFFFFF009772F80;
            off_gphysbase = 0xFFFFFFF0077B3AE8;//0xFFFFFFF0070CBA30;
            off_gphyssize = 0xFFFFFFF0077B3BE8;//0xFFFFFFF0070CBA48;
            off_pmap_enter_options_addr = 0xFFFFFFF007C9F098;
            off_allproc = 0xFFFFFFF009720BA0;
            off_pmap_find_phys = 0xFFFFFFF007CA607C;
            off_ml_phys_read_data = 0xFFFFFFF007CB9860;
            off_ml_phys_write_data = 0xFFFFFFF007CB9B58;
            off_zm_fix_addr_kalloc = 0xFFFFFFF0077EA6F8;
            
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }
    } else if ([device  isEqual: @"iPhone XS"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }
    } else if ([device  isEqual: @"iPhone XS Max"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    } else if ([device  isEqual: @"iPhone XR"]) {
        if (SYSTEM_VERSION_EQUAL_TO(@"15.8")) {
           // printf("[i] %s offsets selected for iOS 15.8\n", device.UTF8String);
        } else if (SYSTEM_VERSION_EQUAL_TO(@"15.0")) {
           // printf("[i] %s offsets selected for iOS 15.0\n", device.UTF8String);
        } else {
           // printf("[-] No matching offsets.\n");
            exit(EXIT_FAILURE);
        }

    }

}

//off_kalloc_data_external = 0xFFFFFFF0071C5E2C; // //look for string  = kfree: vm_map_remove_locked() failed for addr: %p, map: goto function and go about 4 functions up should be the fifth  with
//the start address of the function after this
/*loc_FFFFFFF007189238                    ; CODE XREF: _kfree_type_impl_external+8
__TEXT_EXEC:__text:FFFFFFF007189238                 LDR             W8, [X0,#0x2C]
__TEXT_EXEC:__text:FFFFFFF00718923C                 AND             X2, X8, #0xFFFFFF
__TEXT_EXEC:__text:FFFFFFF007189240                 ADR             X0, off_FFFFFFF0070C3828
__TEXT_EXEC:__text:FFFFFFF007189244                 NOP
 and go up 6 functions to this
 7188AE8
 __TEXT_EXEC:__text:FFFFFFF007188AE8
 __TEXT_EXEC:__text:FFFFFFF007188AE8                 EXPORT _kalloc_data_external
 __TEXT_EXEC:__text:FFFFFFF007188AE8 _kalloc_data_external
 __TEXT_EXEC:__text:FFFFFFF007188AE8                 MOV             X2, X1  ; _kalloc_data
 __TEXT_EXEC:__text:FFFFFFF007188AEC                 MOV             X1, X0
 __TEXT_EXEC:__text:FFFFFFF007188AF0                 NOP
 __TEXT_EXEC:__text:FFFFFFF007188AF4                 LDR             X8, =off_FFFFFFF0070C3390
 __TEXT_EXEC:__text:FFFFFFF007188AF8                 CMP             X0, #0x7EF
 __TEXT_EXEC:__text:FFFFFFF007188AFC                 B.HI            loc_FFFFFFF007188B10
 __TEXT_EXEC:__text:FFFFFFF007188B00                 ADD             X9, X1, #0xF
 __TEXT_EXEC:__text:FFFFFFF007188B04                 ADD             X9, X8, X9,LSR#4
 __TEXT_EXEC:__text:FFFFFFF007188B08                 LDRB            W9, [X9,#0x16]
 __TEXT_EXEC:__text:FFFFFFF007188B0C                 B               loc_FFFFFFF007188B44
 __TEXT_EXEC:__text:FFFFFFF007188B10 ; ---------------------------------------------------------------------------
 __TEXT_EXEC:__text:FFFFFFF007188B10
 __TEXT_EXEC:__text:FFFFFFF007188B10 loc_FFFFFFF007188B10                    ; CODE XREF: _kalloc_data_external+14↑j
 __TEXT_EXEC:__text:FFFFFFF007188B10                 LDR             X9, [X8,#(qword_FFFFFFF0070C3430 - 0xFFFFFFF0070C3390)]
 __TEXT_EXEC:__text:FFFFFFF007188B14                 CMP             X9, X1
 __TEXT_EXEC:__text:FFFFFFF007188B18                 B.LS            loc_FFFFFFF007188B64
 __TEXT_EXEC:__text:FFFFFFF007188B1C                 LDRB            W11, [X8,#(byte_FFFFFFF0070C3426 - 0xFFFFFFF0070C3390)]
 __TEXT_EXEC:__text:FFFFFFF007188B20                 LDR             X9, [X8] ; unk_FFFFFFF0070C3438
 __TEXT_EXEC:__text:FFFFFFF007188B24                 MOV             W10, #0x28
 __TEXT_EXEC:__text:FFFFFFF007188B28
 __TEXT_EXEC:__text:FFFFFFF007188B28 loc_FFFFFFF007188B28                    ; CODE XREF: _kalloc_data_external+54↓j
 __TEXT_EXEC:__text:FFFFFFF007188B28                 MOV             X12, X11
 __TEXT_EXEC:__text:FFFFFFF007188B2C                 UMADDL          X11, W11, W10, X9
 __TEXT_EXEC:__text:FFFFFFF007188B30                 LDR             W13, [X11,#4]
 __TEXT_EXEC:__text:FFFFFFF007188B34                 ADD             W11, W12, #1
 __TEXT_EXEC:__text:FFFFFFF007188B38                 CMP             X13, X1
 __TEXT_EXEC:__text:FFFFFFF007188B3C                 B.CC            loc_FFFFFFF007188B28
 __TEXT_EXEC:__text:FFFFFFF007188B40                 MOV             W9, W12
 __TEXT_EXEC:__text:FFFFFFF007188B44
 __TEXT_EXEC:__text:FFFFFFF007188B44 loc_FFFFFFF007188B44                    ; CODE XREF: _kalloc_data_external+24↑j
 __TEXT_EXEC:__text:FFFFFFF007188B44                 LDR             X8, [X8,#(off_FFFFFFF0070C3428 - 0xFFFFFFF0070C3390)] ; unk_FFFFFFF0070C3780
 __TEXT_EXEC:__text:FFFFFFF007188B48                 ADD             X8, X8, X9,LSL#3
 __TEXT_EXEC:__text:FFFFFFF007188B4C                 LDR             X0, [X8]
 __TEXT_EXEC:__text:FFFFFFF007188B50                 CBZ             X0, loc_FFFFFFF007188B64
 __TEXT_EXEC:__text:FFFFFFF007188B54                 NOP
 __TEXT_EXEC:__text:FFFFFFF007188B58                 LDR             X1, =0
 __TEXT_EXEC:__text:FFFFFFF007188B5C                 CBZ             X1, loc_FFFFFFF007188B78
 __TEXT_EXEC:__text:FFFFFFF007188B60                 B               sub_FFFFFFF0071DB2B0
 __TEXT_EXEC:__text:FFFFFFF007188B64 ; ---------------------------------------------------------------------------
 __TEXT_EXEC:__text:FFFFFFF007188B64
 __TEXT_EXEC:__text:FFFFFFF007188B64 loc_FFFFFFF007188B64                    ; CODE XREF: _kalloc_data_external+30↑j
 __TEXT_EXEC:__text:FFFFFFF007188B64                                         ; _kalloc_data_external+68↑j
 __TEXT_EXEC:__text:FFFFFFF007188B64                 ADR             X0, off_FFFFFFF0070C3350
 __TEXT_EXEC:__text:FFFFFFF007188B68                 NOP
 __TEXT_EXEC:__text:FFFFFFF007188B6C                 ADRP            X3, #unk_FFFFFFF0077DC420@PAGE
 __TEXT_EXEC:__text:FFFFFFF007188B70                 ADD             X3, X3, #unk_FFFFFFF0077DC420@PAGEOFF
 __TEXT_EXEC:__text:FFFFFFF007188B74                 B               sub_FFFFFFF007188794
 __TEXT_EXEC:__text:FFFFFFF007188B78 ; ---------------------------------------------------------------------------
 __TEXT_EXEC:__text:FFFFFFF007188B78
 __TEXT_EXEC:__text:FFFFFFF007188B78 loc_FFFFFFF007188B78                    ; CODE XREF: _kalloc_data_external+74↑j
 __TEXT_EXEC:__text:FFFFFFF007188B78                 LDR             X1, [X0,#8]
 __TEXT_EXEC:__text:FFFFFFF007188B7C                 B               sub_FFFFFFF0071DB2B0
 __TEXT_EXEC:__text:FFFFFFF007188B7C ; End of function _kalloc_da
 
 
// off_kfree_data_external =  0xFFFFFFF0071C6638; //look for string  = kfree: vm_map_remove_locked() failed for addr: %p, map: goto function and go about 4 functions down should be the fifth  with
//the start address of the function after this
/*loc_FFFFFFF007189238                    ; CODE XREF: _kfree_type_impl_external+8
__TEXT_EXEC:__text:FFFFFFF007189238                 LDR             W8, [X0,#0x2C]
__TEXT_EXEC:__text:FFFFFFF00718923C                 AND             X2, X8, #0xFFFFFF
__TEXT_EXEC:__text:FFFFFFF007189240                 ADR             X0, off_FFFFFFF0070C3828
__TEXT_EXEC:__text:FFFFFFF007189244                 NOP
__TEXT_EXEC:__text:FFFFFFF007189248                 MOV             X1, X9
__TEXT_EXEC:__text:FFFFFFF00718924C                 B               sub_FFFFFFF007188D60

 ; ---------------------------------------------------------------------------
 __TEXT_EXEC:__text:FFFFFFF007189250
 __TEXT_EXEC:__text:FFFFFFF007189250 locret_FFFFFFF007189250                 ; CODE XREF: _kfree_type_impl_external+C↑j
 __TEXT_EXEC:__text:FFFFFFF007189250                 RET
 __TEXT_EXEC:__text:FFFFFFF007189250 ; End of function _kfree_type_impl_external
 __TEXT_EXEC:__text:FFFFFFF007189250
 __TEXT_EXEC:__text:FFFFFFF007189254
 __TEXT_EXEC:__text:FFFFFFF007189254 ; =============== S U B R O U T I N E =======================================
 __TEXT_EXEC:__text:FFFFFFF007189254
 __TEXT_EXEC:__text:FFFFFFF007189254
 __TEXT_EXEC:__text:FFFFFFF007189254                 EXPORT _kfree_data_external
 __TEXT_EXEC:__text:FFFFFFF007189254 _kfree_data_external
 __TEXT_EXEC:__text:FFFFFFF007189254
 __TEXT_EXEC:__text:FFFFFFF007189254 var_10          = -0x10
 __TEXT_EXEC:__text:FFFFFFF007189254
 __TEXT_EXEC:__text:FFFFFFF007189254                 MOV             X2, X1  ; _kfree_data
 __TEXT_EXEC:__text:FFFFFFF007189258                 MOV             X1, X0
 __TEXT_EXEC:__text:FFFFFFF00718925C                 LSR             X8, X2, #0x21
 __TEXT_EXEC:__text:FFFFFFF007189260                 CMP             X8, #7
 __TEXT_EXEC:__text:FFFFFFF007189264                 B.CS            loc_FFFFFFF007189274
 */



 //off_add_x0_x0_0x40_ret = 0xFFFFFFF0059430B4; // in IDA string AppleARMPE goto data_xref com.apple.driver.AppleARMPlatform:__cstring:FFFFFFF005255BDD    0000000B    C    AppleARMPE
    // or look for APPLES5L8920XFPWM and find first ADD above string

//DATA XREF: com.apple.driver.AppleARMPlatform:__text go into function goto next "AppleARMPE" look above in the add x0, x0//
 /*
 :FFFFFFF0059430B4                 ADD             X0, X0, #unk_FFFFFFF0079E1040@PAGEOFF
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430B8                 RET
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430BC ; ---------------------------------------------------------------------------
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430BC                 STP             X29, X30, [SP,#-0x10]!
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430C0                 MOV             X29, SP
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430C4                 ADRP            X1, #aApplearmpe@PAGE ; "AppleARMPE"
 com.apple.driver.AppleARMPlatform:__text:FFFFFFF0059430C8                 ADD             X1, X1, #aApplearmpe@PAGEOFF ; "AppleARMPE"
 
  
  EXPORT AppleS5L8920XPWM_InitFunc_1
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0941C AppleS5L8920XPWM_InitFunc_1             ; DATA XREF: com.apple.driver.AppleS5L8920XPWM:__mod_init_func:FFFFFFF006DAE200↓o
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0941C
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0941C var_s0          =  0
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0941C
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0941C                 STP             X29, X30, [SP,#-0x10+var_s0]!
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C09420                 MOV             X29, SP
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C09424                 ADRP            X0, #unk_FFFFFFF007A39F40@PAGE
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C09428                 ADD             X0, X0, #unk_FFFFFFF007A39F40@PAGEOFF
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C0942C                 ADRP            X1, #aApples5l8920xf@PAGE ; "AppleS5L8920XFPWM"
  com.apple.driver.AppleS5L8920XPWM:__text:FFFFFFF005C09430                 ADD             X1, X1, #aApples5l8920xf@PAGEOFF ; "AppleS5L8920XFPWM"
  
 */
 
// off_empty_kdata_page = 0xFFFFFFF007820000 + 0x100;
 
//lookf for string COM.APPLE.KPI.BSD  follow down to
/*\\ look for the end of KLDDATA:
 //look for end of bss:FFFFFFF0
 next data stsart of function address
  _KLDDATA:__bss:FFFFFFF00781C750 ; __KLDDATA___bss ends
  __KLDDATA:__bss:FFFFFFF00781C750
  __DATA:__data:FFFFFFF007820000 ; ===========================================================================
  __DATA:__data:FFFFFFF007820000
  __DATA:__data:FFFFFFF007820000 ; Segment type: Pure data
  __DATA:__data:FFFFFFF007820000                 AREA __DATA:__data, DATA, ALIGN=4
  __DATA:__data:FFFFFFF007820000                 ;
  */

// off_trustcache = 0xFFFFFFF0078B88C0;

//trustcache same also like this
        //find data xref _pmap_set_local_signing_public_key
        // function address above _pmap_set_local_signing_public_key
// find string ATTEMPTED TO SET THE LOCAL SIGNING PUBL go into function and find
/*
__TEXT_EXEC:__text:FFFFFFF00728BCBC                 EXPORT _pmap_set_local_signing_public_key
__TEXT_EXEC:__text:FFFFFFF00728BCBC _pmap_set_local_signing_public_key
__TEXT_EXEC:__text:FFFFFFF00728BCBC
__TEXT_EXEC:__text:FFFFFFF00728BCBC var_10          = -0x10
__TEXT_EXEC:__text:FFFFFFF00728BCBC var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF00728BCBC
__TEXT_EXEC:__text:FFFFFFF00728BCBC                 SUB             SP, SP, #0x20
__TEXT_EXEC:__text:FFFFFFF00728BCC0                 STP             X29, X30, [SP,#0x10+var_s0]
__TEXT_EXEC:__text:FFFFFFF00728BCC4                 ADD             X29, SP, #0x10
__TEXT_EXEC:__text:FFFFFFF00728BCC8                 ADRP            X8, #byte_FFFFFFF0078718C8@PAGE THIS And go into this and find address of function above
 should look like this
 
 
 __bss:FFFFFFF009772F80 qword_FFFFFFF009772F80 % 8  < ----   THIS  function  with % 8           ; DATA XREF: sub_FFFFFFF007CAC944:loc_FFFFFFF007CACDA0↑o
 __bss:FFFFFFF009772F80                                         ; sub_FFFFFFF007CAC944+460↑r ...
 __bss:FFFFFFF009772F88 byte_FFFFFFF009772F88 % 1               ; DATA XREF: sub_FFFFFFF007CAE678+10↑o
 __bss:FFFFFFF009772F88                                         ; sub_FFFFFFF007CAE678+14↑o ...
 __bss:FFFFFFF009772F89 xmmword_FFFFFFF009772F89 % 0x10         ; DATA XREF: sub_FFFFFFF007CAE678+2C↑o
 __bss:FFFFFFF009772F89                                         ; sub_FFFFFFF007CAE678+30↑o ...
 __bss:FFFFFFF009772F99                 % 1
 
 
__TEXT_EXEC:__text:FFFFFFF00728BCCC                 ADD             X8, X8, #byte_FFFFFFF0078718C8@PAGEOFF
__TEXT_EXEC:__text:FFFFFFF00728BCD0                 MOV             W9, #1
__TEXT_EXEC:__text:FFFFFFF00728BCD4
__TEXT_EXEC:__text:FFFFFFF00728BCD4 loc_FFFFFFF00728BCD4                    ; CODE XREF: _pmap_set_local_signing_public_key+24↓j
__TEXT_EXEC:__text:FFFFFFF00728BCD4                 CASPA           WZR, WSP, W10, W11, [X8]
__TEXT_EXEC:__text:FFFFFFF00728BCD8                 CBNZ            W10, loc_FFFFFFF00728BD20
__TEXT_EXEC:__text:FFFFFFF00728BCDC                 CASP            W10, W11, W9, W10, [X8]
__TEXT_EXEC:__text:FFFFFFF00728BCE0                 CBNZ            W10, loc_FFFFFFF00728BCD4
__TEXT_EXEC:__text:FFFFFFF00728BCE4                 LDP             Q0, Q1, [X0]
__TEXT_EXEC:__text:FFFFFFF00728BCE8                 ADRP            X8, #xmmword_FFFFFFF0078718C9@PAGE
__TEXT_EXEC:__text:FFFFFFF00728BCEC                 ADD             X8, X8, #xmmword_FFFFFFF0078718C9@PAGEOFF
__TEXT_EXEC:__text:FFFFFFF00728BCF0                 LDR             Q2, [X0,#0x20]
__TEXT_EXEC:__text:FFFFFFF00728BCF4                 STP             Q1, Q2, [X8,#0x10]
__TEXT_EXEC:__text:FFFFFFF00728BCF8                 STR             Q0, [X8]
__TEXT_EXEC:__text:FFFFFFF00728BCFC                 LDP             Q0, Q1, [X0,#0x30]
__TEXT_EXEC:__text:FFFFFFF00728BD00                 LDR             Q2, [X0,#0x50]
__TEXT_EXEC:__text:FFFFFFF00728BD04                 LDRB            W9, [X0,#0x60]
__TEXT_EXEC:__text:FFFFFFF00728BD08                 STRB            W9, [X8,#(byte_FFFFFFF007871929 - 0xFFFFFFF0078718C9)]
__TEXT_EXEC:__text:FFFFFFF00728BD0C                 STP             Q1, Q2, [X8,#0x40]
__TEXT_EXEC:__text:FFFFFFF00728BD10                 STR             Q0, [X8,#(xmmword_FFFFFFF0078718F9 - 0xFFFFFFF0078718C9)]
__TEXT_EXEC:__text:FFFFFFF00728BD14                 LDP             X29, X30, [SP,#0x10+var_s0]
__TEXT_EXEC:__text:FFFFFFF00728BD18                 ADD             SP, SP, #0x20
__TEXT_EXEC:__text:FFFFFFF00728BD1C                 RET
__TEXT_EXEC:__text:FFFFFFF00728BD20 ; ---------------------------------------------------------------------------
__TEXT_EXEC:__text:FFFFFFF00728BD20
__TEXT_EXEC:__text:FFFFFFF00728BD20 loc_FFFFFFF00728BD20                    ; CODE XREF: _pmap_set_local_signing_public_key+1C↑j
__TEXT_EXEC:__text:FFFFFFF00728BD20                 CLREX
__TEXT_EXEC:__text:FFFFFFF00728BD24                 ADRP            X8, #aPmapC@PAGE ; "pmap.c"
__TEXT_EXEC:__text:FFFFFFF00728BD28                 ADD             X8, X8, #aPmapC@PAGEOFF ; "pmap.c"
__TEXT_EXEC:__text:FFFFFFF00728BD2C                 MOV             W9, #0x5246
__TEXT_EXEC:__text:FFFFFFF00728BD30                 STP             X8, X9, [SP,#0x10+var_10]
__TEXT_EXEC:__text:FFFFFFF00728BD34                 ADRP            X0, #aAttemptedToSet_0@PAGE ; "attempted to set the local signing publ"...
__TEXT_EXEC:__text:FFFFFFF00728BD38                 ADD             X0, X0, #aAttemptedToSet_0@PAGEOFF ; "attempted to set the local signing publ"...
__TEXT_EXEC:__text:FFFFFFF00728BD3C                 BL              _panic
__TEXT_EXEC:__text:FFFFFFF00728BD3C ; End of function _pmap_set_local_signing_public_key
__TEXT_EXEC:__text:FFFFFFF00728BD3C
__TEXT_EXEC:__text:FFFFFFF00728BD40
__TEXT_EXEC:__text:FFFFFFF00728BD40 ; =============== S U B R O U T I N E =======================================
*/
/*
 THIS ]> FFFFFFF0078BD900
 __DATA:__bss:FFFFFFF0078BD900 <---- THIS --->   qword_FFFFFFF0078BD900 % 8              ; DATA XREF: sub_FFFFFFF0072CE63C:loc_FFFFFFF0072CEAB4↑o
 __DATA:__bss:FFFFFFF0078BD900                                         ; sub_FFFFFFF0072CE63C+47C↑r ...
 __DATA:__bss:FFFFFFF0078BD908 byte_FFFFFFF0078BD908 % 1               ; DATA XREF: _pmap_set_local_signing_public_key+C↑o
 __DATA:__bss:FFFFFFF0078BD908                                         ; _pmap_set_local_signing_public_key+10↑o ...
 __DATA:__bss:FFFFFFF0078BD909 xmmword_FFFFFFF0078BD909 % 0x10         ; DATA XREF: _pmap_set_local_signing_public_key+2C↑o
 __DATA:__bss:FFFFFFF0078BD909                                         ; _pmap_set_local_signing_public_key+30↑o ...
 __DATA:__bss:FFFFFFF0078BD919                 % 1
 */






 //off_gphysbase = 0xFFFFFFF007103B20;

/*
 __text:FFFFFFF008235A14 ; =============== S U B R O U T I N E =======================================
 __text:FFFFFFF008235A14
 __text:FFFFFFF008235A14
 __text:FFFFFFF008235A14 sub_FFFFFFF008235A14                    ; CODE XREF: sub_FFFFFFF007CCD4B0+D8↑p
 __text:FFFFFFF008235A14                 CMP             W2, #0
 __text:FFFFFFF008235A18                 B.EQ            loc_FFFFFFF008235A3C
 
 
 __text:FFFFFFF008235A1C                 ADRP            X2, #qword_FFFFFFF0077B7AE8@PAGE <----THIS
 __text:FFFFFFF008235A20                 ADD             X2, X2, #qword_FFFFFFF0077B7AE8@PAGEOFF
 
 
 
 __text:FFFFFFF008235A24                 LDR             X2, [X2]
 __text:FFFFFFF008235A28                 SUB             X0, X0, X2
 __text:FFFFFFF008235A2C                 ADRP            X2, #qword_FFFFFFF0077B7AF8@PAGE <----THIS for second function go into it and find start address of next function inline form here for Gphysize
 __text:FFFFFFF008235A30                 ADD             X2, X2, #qword_FFFFFFF0077B7AF8@PAGEOFF
 __text:FFFFFFF008235A34                 LDR             X2, [X2]
 __text:FFFFFFF008235A38                 ADD             X0, X0, X2
 __text:FFFFFFF008235A3C
 __text:FFFFFFF008235A3C loc_FFFFFFF008235A3C                    ; CODE XREF: sub_FFFFFFF008235A14+4↑j
 __text:FFFFFFF008235A3C                 B               sub_FFFFFFF008235804
 __text:FFFFFFF008235A3C ; End of function sub_FFFFFFF008235A14
 __text:FFFFFFF008235A3C
 __text:FFFFFFF008235A3C ; ---------------------------------------------------------------------------
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 __text:FFFFFFF008235A40                 DCQ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 */
            //look for string  = IRQ EXCEPTION TAKEN WHILE SP1 SELECTED """ and follow upward to sub_function after red and 1 functon above red
//EXPORT _gPhysBase
        /*  find function invalidate_icache64
        DATA_CONST:__const:FFFFFFF007103B20 qword_FFFFFFF007103B20 DCQ 0            ; DATA XREF: _invalidate_icache64+8↓o                                                */
 
// off_gphyssize = 0xFFFFFFF007103B30;
        //? EXPORT _gPhysSize
        //0xFFFFFFF007103C18 function after _invalidate_icache64??

// off_pmap_enter_options_addr = 0xFFFFFFF0072BF940;
        // look for string = failed pmap_enter, virt=%p, start_a -> go into function until you  see the grey string END of function and find the next functions address

// off_allproc = 0xFFFFFFF007893910;
        // look for string COM.APPLE.KAUTH.FILEOP..//
        //use flowchart find spot in pic hahahahahahahaha.
        //0xFFFFFFF007890110;// i7 . 0xFFFFFFF00784C100; //look for stackshot_in_flags string follow flow chart up

// off_pmap_find_phys = 0xFFFFFFF0072C602C;  6s 15.1 = 0xFFFFFFF007284B58;

//look for string %S: UNABLE TO ALLOCATE PTD @%S:%D and go up until you see this function with type

// looks like this

/*
 
 __text:FFFFFFF007CA607C sub_FFFFFFF007CA607C < -- THIS
 
 __text:FFFFFFF007CA607C
 __text:FFFFFFF007CA607C var_s0          =  0
 __text:FFFFFFF007CA607C
 __text:FFFFFFF007CA607C                 STP             X29, X30, [SP,#-0x10+var_s0]!
 __text:FFFFFFF007CA6080                 MOV             X29, SP
 __text:FFFFFFF007CA6084                 BL              sub_FFFFFFF007CA5ED4
 __text:FFFFFFF007CA6088                 LSR             X0, X0, #0xE
 __text:FFFFFFF007CA608C                 LDP             X29, X30, [SP+var_s0],#0x10
 __text:FFFFFFF007CA6090                 RET
 
 */
        //try looking for string =    lck_rw_unlock_shared(): lock %p held in    """" and find the address start of next function in line OR
    //string     =   pmap_attribute_cache_sync size: 0x%llx
//     %s: Attempt to wire empty/compressed PT should have compressed PTE %p 0x%llx has extra bit below it leading to this

/*
 STP             X9, X22, [SP,#0x80+var_80]
__TEXT_EXEC:__text:FFFFFFF0072C8B98                 ADRP            X0, #aSAttemptToWire_0@PAGE ; "%s: Attempt to wire empty/compressed PT"...
__TEXT_EXEC:__text:FFFFFFF0072C8B9C                 ADD             X0, X0, #aSAttemptToWire_0@PAGEOFF ; "%s: Attempt to wire empty/compressed PT"...
__TEXT_EXEC:__text:FFFFFFF0072C8BA0                 BL              _panic
__TEXT_EXEC:__text:FFFFFFF0072C8BA4
__TEXT_EXEC:__text:FFFFFFF0072C8BA4 loc_FFFFFFF0072C8BA4                    ; CODE XREF: sub_FFFFFFF0072C8774+210↑j
__TEXT_EXEC:__text:FFFFFFF0072C8BA4                 LDR             X8, [X22]
__TEXT_EXEC:__text:FFFFFFF0072C8BA8                 AND             X9, X8, #0x3FFFFFFFFFFFFFFF
__TEXT_EXEC:__text:FFFFFFF0072C8BAC                 MOV             W11, #0x1FA1
__TEXT_EXEC:__text:FFFFFFF0072C8BB0                 ADRP            X10, #aPmapC@PAGE ; "pmap.c"
__TEXT_EXEC:__text:FFFFFFF0072C8BB4                 ADD             X10, X10, #aPmapC@PAGEOFF ; "pmap.c"
__TEXT_EXEC:__text:FFFFFFF0072C8BB8                 STP             X10, X11, [SP,#0x80+var_68]
__TEXT_EXEC:__text:FFFFFFF0072C8BBC                 STP             X8, X9, [SP,#0x80+var_78]
__TEXT_EXEC:__text:FFFFFFF0072C8BC0                 STR             X22, [SP,#0x80+var_80]
__TEXT_EXEC:__text:FFFFFFF0072C8BC4                 ADRP            X0, #aCompressedPteP@PAGE ; "compressed PTE %p 0x%llx has extra bits"...
__TEXT_EXEC:__text:FFFFFFF0072C8BC8                 ADD             X0, X0, #aCompressedPteP@PAGEOFF ; "compressed PTE %p 0x%llx has extra bits"...
__TEXT_EXEC:__text:FFFFFFF0072C8BCC                 BL              _panic
__TEXT_EXEC:__text:FFFFFFF0072C8BCC ; End of function sub_FFFFFFF0072C8774
__TEXT_EXEC:__text:FFFFFFF0072C8BCC
__TEXT_EXEC:__text:FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 ; =============== S U B R O U T I N E =======================================
__TEXT_EXEC:__text:FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 ; Attributes: bp-based frame
__TEXT_EXEC:__text:FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 sub_FFFFFFF0072C8BD0                    ; CODE XREF: sub_FFFFFFF00718FF54+64↑p
__TEXT_EXEC:__text:FFFFFFF0072C8BD0                                         ; sub_FFFFFFF007190F8C:loc_FFFFFFF007192CA4↑p ...
__TEXT_EXEC:__text:FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 var_40          = -0x40
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 var_30          = -0x30
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 var_20          = -0x20
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 var_10          = -0x10
__TEXT_EXEC:__text:FFFFFFF0072C8BD0 var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8BD0                 SUB             SP, SP, #0x50
__TEXT_EXEC:__text:FFFFFFF0072C8BD4                 STP             X22, X21, [SP,#0x40+var_20]
__TEXT_EXEC:__text:FFFFFFF0072C8BD8                 STP             X20, X19, [SP,#0x40+var_10]
__TEXT_EXEC:__text:FFFFFFF0072C8BDC                 STP             X29, X30, [SP,#0x40+var_s0]
__TEXT_EXEC:__text:FFFFFFF0072C8BE0                 ADD             X29, SP, #0x40
__TEXT_EXEC:__text:FFFFFFF0072C8BE4                 MOV             X20, X1
__TEXT_EXEC:__text:FFFFFFF0072C8BE8                 MOV             X19, X0
__TEXT_EXEC:__text:FFFFFFF0072C8BEC                 ADRP            X22, #_kernel_pmap@PAGE
__TEXT_EXEC:__text:FFFFFFF0072C8BF0                 LDR             X8, [X22,#_kernel_pmap@PAGEOFF]
__TEXT_EXEC:__text:FFFFFFF0072C8BF4                 CMP             X8, X0
__TEXT_EXEC:__text:FFFFFFF0072C8BF8                 B.EQ            loc_FFFFFFF0072C8C28
__TEXT_EXEC:__text:FFFFFFF0072C8BFC                 MRS             X8, #0, c13, c0, #4
__TEXT_EXEC:__text:FFFFFFF0072C8C00                 LDR             X8, [X8,#0x3C8]
__TEXT_EXEC:__text:FFFFFFF0072C8C04                 CBZ             X8, loc_FFFFFFF0072C8C38
__TEXT_EXEC:__text:FFFFFFF0072C8C08                 LDR             X8, [X8,#0x48]
__TEXT_EXEC:__text:FFFFFFF0072C8C0C                 CMP             X8, X19
__TEXT_EXEC:__text:FFFFFFF0072C8C10                 B.NE            loc_FFFFFFF0072C8C38
__TEXT_EXEC:__text:FFFFFFF0072C8C14                 MOV             X0, X20
__TEXT_EXEC:__text:FFFFFFF0072C8C18                 BL              sub_FFFFFFF00718CA80
__TEXT_EXEC:__text:FFFFFFF0072C8C1C                 MOV             X21, X0
__TEXT_EXEC:__text:FFFFFFF0072C8C20                 CBNZ            X0, loc_FFFFFFF0072C8CB8
__TEXT_EXEC:__text:FFFFFFF0072C8C24                 B               loc_FFFFFFF0072C8C38
__TEXT_EXEC:__text:FFFFFFF0072C8C28 ; ---------------------------------------------------------------------------
__TEXT_EXEC:__text:FFFFFFF0072C8C28
__TEXT_EXEC:__text:FFFFFFF0072C8C28 loc_FFFFFFF0072C8C28                    ; CODE XREF: sub_FFFFFFF0072C8BD0+28↑j
__TEXT_EXEC:__text:FFFFFFF0072C8C28                 MOV             X0, X20
__TEXT_EXEC:__text:FFFFFFF0072C8C2C                 BL              sub_FFFFFFF00718CA50
__TEXT_EXEC:__text:FFFFFFF0072C8C30                 MOV             X21, X0
__TEXT_EXEC:__text:FFFFFFF0072C8C34                 CBNZ            X0, loc_FFFFFFF0072C8CB8
__TEXT_EXEC:__text:FFFFFFF0072C8C38
__TEXT_EXEC:__text:FFFFFFF0072C8C38 loc_FFFFFFF0072C8C38                    ; CODE XREF: sub_FFFFFFF0072C8BD0+34↑j
__TEXT_EXEC:__text:FFFFFFF0072C8C38                                         ; sub_FFFFFFF0072C8BD0+40↑j ...
__TEXT_EXEC:__text:FFFFFFF0072C8C38                 ADRP            X8, #dword_FFFFFFF00782A5A8@PAGE
__TEXT_EXEC:__text:FFFFFFF0072C8C3C                 LDR             W8, [X8,#dword_FFFFFFF00782A5A8@PAGEOFF]
__TEXT_EXEC:__text:FFFFFFF0072C8C40                 CBZ             W8, loc_FFFFFFF0072C8CD0
__TEXT_EXEC:__text:FFFFFFF0072C8C44                 LDR             X8, [X22,#_kernel_pmap@PAGEOFF]
__TEXT_EXEC:__text:FFFFFFF0072C8C48                 CMP             X8, X19
__TEXT_EXEC:__text:FFFFFFF0072C8C4C                 B.EQ            loc_FFFFFFF0072C8C6C
__TEXT_EXEC:__text:FFFFFFF0072C8C50                 MRS             X8, #0, c13, c0, #4
__TEXT_EXEC:__text:FFFFFFF0072C8C54                 LDR             W9, [X8,#0x190]
__TEXT_EXEC:__text:FFFFFFF0072C8C58                 ADDS            W9, W9, #1
__TEXT_EXEC:__text:FFFFFFF0072C8C5C                 B.CS            loc_FFFFFFF0072C8CEC
__TEXT_EXEC:__text:FFFFFFF0072C8C60                 STR             W9, [X8,#0x190]
__TEXT_EXEC:__text:FFFFFFF0072C8C64                 ADD             X0, X19, #0x28
__TEXT_EXEC:__text:FFFFFFF0072C8C68                 BL              _lck_rw_lock_shared
__TEXT_EXEC:__text:FFFFFFF0072C8C6C
__TEXT_EXEC:__text:FFFFFFF0072C8C6C loc_FFFFFFF0072C8C6C                    ; CODE XREF: sub_FFFFFFF0072C8BD0+7C↑j
__TEXT_EXEC:__text:FFFFFFF0072C8C6C                 MOV             X0, X19
__TEXT_EXEC:__text:FFFFFFF0072C8C70                 MOV             X1, X20
__TEXT_EXEC:__text:FFFFFFF0072C8C74                 BL              sub_FFFFFFF0072C3CE4
__TEXT_EXEC:__text:FFFFFFF0072C8C78                 MOV             X21, X0
__TEXT_EXEC:__text:FFFFFFF0072C8C7C                 LDR             X8, [X22,#_kernel_pmap@PAGEOFF]
__TEXT_EXEC:__text:FFFFFFF0072C8C80                 CMP             X8, X19
__TEXT_EXEC:__text:FFFFFFF0072C8C84                 B.EQ            loc_FFFFFFF0072C8CB8
__TEXT_EXEC:__text:FFFFFFF0072C8C88                 ADD             X19, X19, #0x28
__TEXT_EXEC:__text:FFFFFFF0072C8C8C                 MOV             X0, X19
__TEXT_EXEC:__text:FFFFFFF0072C8C90                 BL              _lck_rw_done
__TEXT_EXEC:__text:FFFFFFF0072C8C94                 CMP             W0, #1
__TEXT_EXEC:__text:FFFFFFF0072C8C98                 B.NE            loc_FFFFFFF0072C8CF4
__TEXT_EXEC:__text:FFFFFFF0072C8C9C                 MRS             X0, #0, c13, c0, #4
__TEXT_EXEC:__text:FFFFFFF0072C8CA0                 LDR             W8, [X0,#0x190]
__TEXT_EXEC:__text:FFFFFFF0072C8CA4                 CBZ             W8, loc_FFFFFFF0072C8CF0
__TEXT_EXEC:__text:FFFFFFF0072C8CA8                 SUBS            W8, W8, #1
__TEXT_EXEC:__text:FFFFFFF0072C8CAC                 STR             W8, [X0,#0x190]
__TEXT_EXEC:__text:FFFFFFF0072C8CB0                 B.NE            loc_FFFFFFF0072C8CB8
__TEXT_EXEC:__text:FFFFFFF0072C8CB4                 BL              sub_FFFFFFF0072DA544
__TEXT_EXEC:__text:FFFFFFF0072C8CB8
__TEXT_EXEC:__text:FFFFFFF0072C8CB8 loc_FFFFFFF0072C8CB8                    ; CODE XREF: sub_FFFFFFF0072C8BD0+50↑j
__TEXT_EXEC:__text:FFFFFFF0072C8CB8                                         ; sub_FFFFFFF0072C8BD0+64↑j ...
__TEXT_EXEC:__text:FFFFFFF0072C8CB8                 MOV             X0, X21
__TEXT_EXEC:__text:FFFFFFF0072C8CBC                 LDP             X29, X30, [SP,#0x40+var_s0]
__TEXT_EXEC:__text:FFFFFFF0072C8CC0                 LDP             X20, X19, [SP,#0x40+var_10]
__TEXT_EXEC:__text:FFFFFFF0072C8CC4                 LDP             X22, X21, [SP,#0x40+var_20]
__TEXT_EXEC:__text:FFFFFFF0072C8CC8                 ADD             SP, SP, #0x50
__TEXT_EXEC:__text:FFFFFFF0072C8CCC                 RET
__TEXT_EXEC:__text:FFFFFFF0072C8CD0 ; ---------------------------------------------------------------------------
__TEXT_EXEC:__text:FFFFFFF0072C8CD0
__TEXT_EXEC:__text:FFFFFFF0072C8CD0 loc_FFFFFFF0072C8CD0                    ; CODE XREF: sub_FFFFFFF0072C8BD0+70↑j
__TEXT_EXEC:__text:FFFFFFF0072C8CD0                 MOV             X0, X19
__TEXT_EXEC:__text:FFFFFFF0072C8CD4                 MOV             X1, X20
__TEXT_EXEC:__text:FFFFFFF0072C8CD8                 LDP             X29, X30, [SP,#0x40+var_s0]
__TEXT_EXEC:__text:FFFFFFF0072C8CDC                 LDP             X20, X19, [SP,#0x40+var_10]
__TEXT_EXEC:__text:FFFFFFF0072C8CE0                 LDP             X22, X21, [SP,#0x40+var_20]
__TEXT_EXEC:__text:FFFFFFF0072C8CE4                 ADD             SP, SP, #0x50
__TEXT_EXEC:__text:FFFFFFF0072C8CE8                 B               sub_FFFFFFF0072C3CE4
__TEXT_EXEC:__text:FFFFFFF0072C8CEC ; ---------------------------------------------------------------------------
__TEXT_EXEC:__text:FFFFFFF0072C8CEC
__TEXT_EXEC:__text:FFFFFFF0072C8CEC loc_FFFFFFF0072C8CEC                    ; CODE XREF: sub_FFFFFFF0072C8BD0+8C↑j
__TEXT_EXEC:__text:FFFFFFF0072C8CEC                 BL              sub_FFFFFFF0078105A8
__TEXT_EXEC:__text:FFFFFFF0072C8CF0
__TEXT_EXEC:__text:FFFFFFF0072C8CF0 loc_FFFFFFF0072C8CF0                    ; CODE XREF: sub_FFFFFFF0072C8BD0+D4↑j
__TEXT_EXEC:__text:FFFFFFF0072C8CF0                 BL              sub_FFFFFFF0078105D0
__TEXT_EXEC:__text:FFFFFFF0072C8CF4
__TEXT_EXEC:__text:FFFFFFF0072C8CF4 loc_FFFFFFF0072C8CF4                    ; CODE XREF: sub_FFFFFFF0072C8BD0+C8↑j
__TEXT_EXEC:__text:FFFFFFF0072C8CF4                 MOV             W8, #0x839
__TEXT_EXEC:__text:FFFFFFF0072C8CF8                 ADRP            X9, #aLockRwC@PAGE ; "lock_rw.c"
__TEXT_EXEC:__text:FFFFFFF0072C8CFC                 ADD             X9, X9, #aLockRwC@PAGEOFF ; "lock_rw.c"
__TEXT_EXEC:__text:FFFFFFF0072C8D00                 STP             X9, X8, [SP,#0x40+var_30]
__TEXT_EXEC:__text:FFFFFFF0072C8D04                 STP             X19, X0, [SP,#0x40+var_40]
__TEXT_EXEC:__text:FFFFFFF0072C8D08                 ADRP            X0, #aLckRwUnlockSha@PAGE ; "lck_rw_unlock_shared(): lock %p held in"...
__TEXT_EXEC:__text:FFFFFFF0072C8D0C                 ADD             X0, X0, #aLckRwUnlockSha@PAGEOFF ; "lck_rw_unlock_shared(): lock %p held in"...
__TEXT_EXEC:__text:FFFFFFF0072C8D10                 BL              _panic
__TEXT_EXEC:__text:FFFFFFF0072C8D10 ; End of function sub_FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8D10
__TEXT_EXEC:__text:FFFFFFF0072C8D14         <------------     THIS
__TEXT_EXEC:__text:FFFFFFF0072C8D14 ; =============== S U B R O U T I N E =======================================
__TEXT_EXEC:__text:FFFFFFF0072C8D14 <------------     THIS
__TEXT_EXEC:__text:FFFFFFF0072C8D14 ; Attributes: bp-based frame
__TEXT_EXEC:__text:FFFFFFF0072C8D14 <------------     THIS
__TEXT_EXEC:__text:FFFFFFF0072C8D14                 EXPORT _pmap_find_phys <------------     THIS
__TEXT_EXEC:__text:FFFFFFF0072C8D14 _pmap_find_phys
__TEXT_EXEC:__text:FFFFFFF0072C8D14
__TEXT_EXEC:__text:FFFFFFF0072C8D14 var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF0072C8D14 <------------     THIS
__TEXT_EXEC:__text:FFFFFFF0072C8D14                 STP             X29, X30, [SP,#-0x10+var_s0]!
__TEXT_EXEC:__text:FFFFFFF0072C8D18                 MOV             X29, SP
__TEXT_EXEC:__text:FFFFFFF0072C8D1C                 BL              sub_FFFFFFF0072C8BD0
__TEXT_EXEC:__text:FFFFFFF0072C8D20                 LSR             X0, X0, #0xE
__TEXT_EXEC:__text:FFFFFFF0072C8D24                 LDP             X29, X30, [SP+var_s0],#0x10
__TEXT_EXEC:__text:FFFFFFF0072C8D28                 RET
__TEXT_EXEC:__text:FFFFFFF0072C8D28 ; End of function _pmap_find_phys
__TEXT_EXEC:__text:FFFFFFF0072C8D28
__TEXT_EXEC:__text:FFFFFFF0072C8D2C
__TEXT_EXEC:__text:FFFFFFF0072C8D2C ; =============== S U B R O U T I N E =======================================
__TEXT_EXEC:__text:FFFFFFF0072C8D2C
__TEXT_EXEC:__text:FFFFFFF0072C8D2C ; Attributes: bp-based frame
__TEXT_EXEC:__text:FFFFFFF0072C8D2C
__TEXT_EXEC:__text:FFFFFFF0072C8D2C sub_FFFFFFF0072C8D2C                    ; CODE XREF: sub_FFFFFFF0072D7B00+1548↓p
__TEXT_EXEC:__text:FFFFFFF0072C8D2C                                         ; sub_FFFFFFF0072D7B00+1780↓p
__TEXT_EXEC:__text:FFFFFFF0072C8D2C
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_80          = -0x80
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_78          = -0x78
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_70          = -0x70
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_60          = -0x60
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_50          = -0x50
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_40          = -0x40
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_30          = -0x30
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_20          = -0x20
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_10          = -0x10
__TEXT_EXEC:__text:FFFFFFF0072C8D2C var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF0072C8D2C
 */




/*
 text:FFFFFFF007CA98E8                 ADD             X0, X0, #aSFailedPmapEnt_0@PAGEOFF ; "%s: failed pmap_enter_addr, pmap=%p, va"...
 __text:FFFFFFF007CA98EC                 STR             X8, [SP,#0x90+var_90]
 __text:FFFFFFF007CA98F0                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA98F0 ; End of function sub_FFFFFFF007CA9828
 __text:FFFFFFF007CA98F0
 __text:FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4 ; =============== S U B R O U T I N E =======================================
 __text:FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4 ; Attributes: bp-based frame
 __text:FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4 sub_FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4 var_s0          =  0
 __text:FFFFFFF007CA98F4
 __text:FFFFFFF007CA98F4                 STP             X29, X30, [SP,#-0x10+var_s0]!
 __text:FFFFFFF007CA98F8                 MOV             X29, SP
 __text:FFFFFFF007CA98FC                 MOV             W8, W0
 __text:FFFFFFF007CA9900                 LSL             X0, X8, #0xE
 __text:FFFFFFF007CA9904                 ADRP            X8, #qword_FFFFFFF0077B3628@PAGE
 __text:FFFFFFF007CA9908                 LDR             X8, [X8,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA990C                 ADRP            X9, #qword_FFFFFFF0077B3630@PAGE
 __text:FFFFFFF007CA9910                 LDR             X9, [X9,#qword_FFFFFFF0077B3630@PAGEOFF]
 __text:FFFFFFF007CA9914                 SUBS            X8, X0, X8
 __text:FFFFFFF007CA9918                 CCMP            X9, X0, #0, CS
 __text:FFFFFFF007CA991C                 B.HI            loc_FFFFFFF007CA9934
 __text:FFFFFFF007CA9920                 BL              sub_FFFFFFF007CB4F08
 __text:FFFFFFF007CA9924                 CBZ             X0, loc_FFFFFFF007CA995C
 __text:FFFFFFF007CA9928                 LDR             W0, [X0,#0x10]
 __text:FFFFFFF007CA992C                 LDP             X29, X30, [SP+var_s0],#0x10
 __text:FFFFFFF007CA9930                 RET
 __text:FFFFFFF007CA9934 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9934
 __text:FFFFFFF007CA9934 loc_FFFFFFF007CA9934                    ; CODE XREF: sub_FFFFFFF007CA98F4+28↑j
 __text:FFFFFFF007CA9934                 LSR             X8, X8, #0xE
 __text:FFFFFFF007CA9938                 ADRP            X9, #qword_FFFFFFF0077B3668@PAGE
 __text:FFFFFFF007CA993C                 LDR             X9, [X9,#qword_FFFFFFF0077B3668@PAGEOFF]
 __text:FFFFFFF007CA9940                 LDRH            W8, [X9,W8,UXTW#1]
 __text:FFFFFFF007CA9944                 AND             W9, W8, #0x3F
 __text:FFFFFFF007CA9948                 TST             W8, #0x3F
 __text:FFFFFFF007CA994C                 MOV             W8, #2
 __text:FFFFFFF007CA9950                 CSEL            W0, W8, W9, EQ
 __text:FFFFFFF007CA9954                 LDP             X29, X30, [SP+var_s0],#0x10
 __text:FFFFFFF007CA9958                 RET
 __text:FFFFFFF007CA995C ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA995C
 __text:FFFFFFF007CA995C loc_FFFFFFF007CA995C                    ; CODE XREF: sub_FFFFFFF007CA98F4+30↑j
 __text:FFFFFFF007CA995C                 MOV             W0, #7
 __text:FFFFFFF007CA9960                 LDP             X29, X30, [SP+var_s0],#0x10
 __text:FFFFFFF007CA9964                 RET
 __text:FFFFFFF007CA9964 ; End of function sub_FFFFFFF007CA98F4
 __text:FFFFFFF007CA9964
 __text:FFFFFFF007CA9968
 __text:FFFFFFF007CA9968 ; =============== S U B R O U T I N E =======================================
 __text:FFFFFFF007CA9968
 __text:FFFFFFF007CA9968 ; Attributes: thunk
 __text:FFFFFFF007CA9968
 __text:FFFFFFF007CA9968 sub_FFFFFFF007CA9968
 __text:FFFFFFF007CA9968                 B               sub_FFFFFFF007CA3098
 __text:FFFFFFF007CA9968 ; End of function sub_FFFFFFF007CA9968
 __text:FFFFFFF007CA9968
 __text:FFFFFFF007CA996C
 __text:FFFFFFF007CA996C ; =============== S U B R O U T I N E =======================================
 __text:FFFFFFF007CA996C
 __text:FFFFFFF007CA996C
 __text:FFFFFFF007CA996C sub_FFFFFFF007CA996C
 __text:FFFFFFF007CA996C                 MOV             W8, W2
 __text:FFFFFFF007CA9970                 LSL             X2, X8, #0xE
 __text:FFFFFFF007CA9974                 B               sub_FFFFFFF007CA3098
 __text:FFFFFFF007CA9974 ; End of function sub_FFFFFFF007CA996C
 __text:FFFFFFF007CA9974
 __text:FFFFFFF007CA9978
 __text:FFFFFFF007CA9978 ; =============== S U B R O U T I N E =======================================
 __text:FFFFFFF007CA9978
 __text:FFFFFFF007CA9978 ; Attributes: bp-based frame
 __text:FFFFFFF007CA9978                                                                        <--- THIS
 __text:FFFFFFF007CA9978 sub_FFFFFFF007CA9978                    ; CODE XREF: sub_FFFFFFF007C32C54+130↑p
 __text:FFFFFFF007CA9978                                         ; sub_FFFFFFF007C32C54+3F0↑p ...
 __text:FFFFFFF007CA9978
 __text:FFFFFFF007CA9978 var_80          = -0x80
 __text:FFFFFFF007CA9978 var_78          = -0x78
 __text:FFFFFFF007CA9978 var_70          = -0x70
 __text:FFFFFFF007CA9978 var_68          = -0x68
 __text:FFFFFFF007CA9978 var_60          = -0x60
 __text:FFFFFFF007CA9978 var_50          = -0x50
 __text:FFFFFFF007CA9978 var_40          = -0x40
 __text:FFFFFFF007CA9978 var_30          = -0x30
 __text:FFFFFFF007CA9978 var_20          = -0x20
 __text:FFFFFFF007CA9978 var_10          = -0x10
 __text:FFFFFFF007CA9978 var_s0          =  0
 __text:FFFFFFF007CA9978
 __text:FFFFFFF007CA9978                 SUB             SP, SP, #0x90
 __text:FFFFFFF007CA997C                 STP             X28, X27, [SP,#0x80+var_50]
 __text:FFFFFFF007CA9980                 STP             X26, X25, [SP,#0x80+var_40]
 __text:FFFFFFF007CA9984                 STP             X24, X23, [SP,#0x80+var_30]
 __text:FFFFFFF007CA9988                 STP             X22, X21, [SP,#0x80+var_20]
 __text:FFFFFFF007CA998C                 STP             X20, X19, [SP,#0x80+var_10]
 __text:FFFFFFF007CA9990                 STP             X29, X30, [SP,#0x80+var_s0]
 __text:FFFFFFF007CA9994                 ADD             X29, SP, #0x80
 __text:FFFFFFF007CA9998                 MRS             X19, #0, c13, c0, #4
 __text:FFFFFFF007CA999C                 LDR             W8, [X19,#0x150]
 __text:FFFFFFF007CA99A0                 ADDS            W8, W8, #1
 __text:FFFFFFF007CA99A4                 B.CS            loc_FFFFFFF007CA9CD8
 __text:FFFFFFF007CA99A8                 MOV             X22, X2
 __text:FFFFFFF007CA99AC                 MOV             X23, X1
 __text:FFFFFFF007CA99B0                 MOV             X21, X0
 __text:FFFFFFF007CA99B4                 STR             W8, [X19,#0x150]
 __text:FFFFFFF007CA99B8                 ADD             X20, X0, #0x28
 __text:FFFFFFF007CA99BC                 MOV             X0, X20
 __text:FFFFFFF007CA99C0                 BL              sub_FFFFFFF007BA77B0
 __text:FFFFFFF007CA99C4                 LDR             X8, [X21,#0x10]
 __text:FFFFFFF007CA99C8                 CMP             X8, X23
 __text:FFFFFFF007CA99CC                 B.HI            loc_FFFFFFF007CA9A54
 __text:FFFFFFF007CA99D0                 LDR             X8, [X21,#0x18]
 __text:FFFFFFF007CA99D4                 CMP             X8, X23
 __text:FFFFFFF007CA99D8                 B.LS            loc_FFFFFFF007CA9A54
 __text:FFFFFFF007CA99DC                 LDR             X8, [X21]
 __text:FFFFFFF007CA99E0                 UBFX            X9, X23, #0x24, #3
 __text:FFFFFFF007CA99E4                 LDR             X8, [X8,X9,LSL#3]
 __text:FFFFFFF007CA99E8                 MVN             W9, W8
 __text:FFFFFFF007CA99EC                 TST             X9, #3
 __text:FFFFFFF007CA99F0                 B.NE            loc_FFFFFFF007CA9A54
 __text:FFFFFFF007CA99F4                 AND             X0, X8, #0xFFFFFFFFF000
 __text:FFFFFFF007CA99F8                 BL              sub_FFFFFFF007CB9D70
 __text:FFFFFFF007CA99FC                 UBFX            X8, X23, #0x19, #0xB
 __text:FFFFFFF007CA9A00                 LDR             X8, [X0,X8,LSL#3]
 __text:FFFFFFF007CA9A04                 MVN             W9, W8
 __text:FFFFFFF007CA9A08                 TST             X9, #3
 __text:FFFFFFF007CA9A0C                 B.NE            loc_FFFFFFF007CA9A54
 __text:FFFFFFF007CA9A10                 AND             X0, X8, #0xFFFFFFFFF000
 __text:FFFFFFF007CA9A14                 BL              sub_FFFFFFF007CB9D70
 __text:FFFFFFF007CA9A18                 CBZ             X0, loc_FFFFFFF007CA9A54
 __text:FFFFFFF007CA9A1C                 UBFX            X8, X23, #0xE, #0xB
 __text:FFFFFFF007CA9A20                 ADD             X23, X0, X8,LSL#3
 __text:FFFFFFF007CA9A24                 LDR             X8, [X23]
 __text:FFFFFFF007CA9A28                 AND             X27, X8, #0xFFFFFFFFF000
 __text:FFFFFFF007CA9A2C                 ADRP            X26, #qword_FFFFFFF0077B3628@PAGE
 __text:FFFFFFF007CA9A30                 LDR             X9, [X26,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA9A34                 ADRP            X11, #qword_FFFFFFF0077B3630@PAGE
 __text:FFFFFFF007CA9A38                 LDR             X10, [X11,#qword_FFFFFFF0077B3630@PAGEOFF]
 __text:FFFFFFF007CA9A3C                 CMP             X27, X9
 __text:FFFFFFF007CA9A40                 CCMP            X10, X27, #0, CS
 __text:FFFFFFF007CA9A44                 B.HI            loc_FFFFFFF007CA9AA4
 __text:FFFFFFF007CA9A48
 __text:FFFFFFF007CA9A48 loc_FFFFFFF007CA9A48                    ; CODE XREF: sub_FFFFFFF007CA9978+174↓j
 __text:FFFFFFF007CA9A48                 MOV             X25, X27
 __text:FFFFFFF007CA9A4C                 CBNZ            X8, loc_FFFFFFF007CA9B80
 __text:FFFFFFF007CA9A50                 B               loc_FFFFFFF007CA9B98
 __text:FFFFFFF007CA9A54 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9A54
 __text:FFFFFFF007CA9A54 loc_FFFFFFF007CA9A54                    ; CODE XREF: sub_FFFFFFF007CA9978+54↑j
 __text:FFFFFFF007CA9A54                                         ; sub_FFFFFFF007CA9978+60↑j ...
 __text:FFFFFFF007CA9A54                 CBNZ            W22, loc_FFFFFFF007CA9D1C
 __text:FFFFFFF007CA9A58
 __text:FFFFFFF007CA9A58 loc_FFFFFFF007CA9A58                    ; CODE XREF: sub_FFFFFFF007CA9978+22C↓j
 __text:FFFFFFF007CA9A58                                         ; sub_FFFFFFF007CA9978+238↓j ...
 __text:FFFFFFF007CA9A58                 MOV             X0, X20
 __text:FFFFFFF007CA9A5C                 BL              sub_FFFFFFF007BA846C
 __text:FFFFFFF007CA9A60                 CMP             W0, #2
 __text:FFFFFFF007CA9A64                 B.NE            loc_FFFFFFF007CA9CFC
 __text:FFFFFFF007CA9A68                 LDR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9A6C                 CBZ             W8, loc_FFFFFFF007CA9CD4
 __text:FFFFFFF007CA9A70                 SUBS            W8, W8, #1
 __text:FFFFFFF007CA9A74                 STR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9A78                 B.NE            loc_FFFFFFF007CA9A84
 __text:FFFFFFF007CA9A7C                 MOV             X0, X19
 __text:FFFFFFF007CA9A80                 BL              sub_FFFFFFF007CBE2F8
 __text:FFFFFFF007CA9A84
 __text:FFFFFFF007CA9A84 loc_FFFFFFF007CA9A84                    ; CODE XREF: sub_FFFFFFF007CA9978+100↑j
 __text:FFFFFFF007CA9A84                 LDP             X29, X30, [SP,#0x80+var_s0]
 __text:FFFFFFF007CA9A88                 LDP             X20, X19, [SP,#0x80+var_10]
 __text:FFFFFFF007CA9A8C                 LDP             X22, X21, [SP,#0x80+var_20]
 __text:FFFFFFF007CA9A90                 LDP             X24, X23, [SP,#0x80+var_30]
 __text:FFFFFFF007CA9A94                 LDP             X26, X25, [SP,#0x80+var_40]
 __text:FFFFFFF007CA9A98                 LDP             X28, X27, [SP,#0x80+var_50]
 __text:FFFFFFF007CA9A9C                 ADD             SP, SP, #0x90
 __text:FFFFFFF007CA9AA0                 RET
 __text:FFFFFFF007CA9AA4 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9AA4
 __text:FFFFFFF007CA9AA4 loc_FFFFFFF007CA9AA4                    ; CODE XREF: sub_FFFFFFF007CA9978+CC↑j
 __text:FFFFFFF007CA9AA4                 ADRP            X28, #qword_FFFFFFF0077B3670@PAGE
 __text:FFFFFFF007CA9AA8                 MOV             W24, #0x20000000
 __text:FFFFFFF007CA9AAC
 __text:FFFFFFF007CA9AAC loc_FFFFFFF007CA9AAC                    ; CODE XREF: sub_FFFFFFF007CA9978+1D0↓j
 __text:FFFFFFF007CA9AAC                 LDR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9AB0                 ADDS            W8, W8, #1
 __text:FFFFFFF007CA9AB4                 B.CS            loc_FFFFFFF007CA9CD8
 __text:FFFFFFF007CA9AB8                 SUB             X9, X27, X9
 __text:FFFFFFF007CA9ABC                 LSR             X9, X9, #0xE
 __text:FFFFFFF007CA9AC0                 LDR             X10, [X28,#qword_FFFFFFF0077B3670@PAGEOFF]
 __text:FFFFFFF007CA9AC4                 ADD             X9, X10, W9,UXTW#3
 __text:FFFFFFF007CA9AC8                 ADD             X0, X9, #4
 __text:FFFFFFF007CA9ACC                 STR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9AD0                 LDXR            WZR, W8, [X0]
 __text:FFFFFFF007CA9AD4                 TBNZ            W8, #0x1D, loc_FFFFFFF007CA9B50
 __text:FFFFFFF007CA9AD8                 LDSETA          W24, W8, [X0]
 __text:FFFFFFF007CA9ADC                 TBNZ            W8, #0x1D, loc_FFFFFFF007CA9B54
 __text:FFFFFFF007CA9AE0
 __text:FFFFFFF007CA9AE0 loc_FFFFFFF007CA9AE0                    ; CODE XREF: sub_FFFFFFF007CA9978+1FC↓j
 __text:FFFFFFF007CA9AE0                 LDR             X8, [X23]
 __text:FFFFFFF007CA9AE4                 AND             X25, X8, #0xFFFFFFFFF000
 __text:FFFFFFF007CA9AE8                 CMP             X27, X25
 __text:FFFFFFF007CA9AEC                 B.EQ            loc_FFFFFFF007CA9A48
 __text:FFFFFFF007CA9AF0                 LDR             X8, [X26,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA9AF4                 SUB             X8, X27, X8
 __text:FFFFFFF007CA9AF8                 LSR             X8, X8, #0xE
 __text:FFFFFFF007CA9AFC                 LDR             X9, [X28,#qword_FFFFFFF0077B3670@PAGEOFF]
 __text:FFFFFFF007CA9B00                 ADD             X8, X9, W8,UXTW#3
 __text:FFFFFFF007CA9B04                 ADD             X8, X8, #4
 __text:FFFFFFF007CA9B08                 LDCLRL          W24, W8, [X8]
 __text:FFFFFFF007CA9B0C                 LDR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9B10                 CBZ             W8, loc_FFFFFFF007CA9CD4
 __text:FFFFFFF007CA9B14                 SUBS            W8, W8, #1
 __text:FFFFFFF007CA9B18                 STR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9B1C                 B.NE            loc_FFFFFFF007CA9B30
 __text:FFFFFFF007CA9B20                 MOV             X0, X19
 __text:FFFFFFF007CA9B24                 MOV             X27, X11
 __text:FFFFFFF007CA9B28                 BL              sub_FFFFFFF007CBE2F8
 __text:FFFFFFF007CA9B2C                 MOV             X11, X27
 __text:FFFFFFF007CA9B30
 __text:FFFFFFF007CA9B30 loc_FFFFFFF007CA9B30                    ; CODE XREF: sub_FFFFFFF007CA9978+1A4↑j
 __text:FFFFFFF007CA9B30                 LDR             X9, [X26,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA9B34                 CMP             X25, X9
 __text:FFFFFFF007CA9B38                 B.CC            loc_FFFFFFF007CA9B78
 __text:FFFFFFF007CA9B3C                 LDR             X8, [X11,#qword_FFFFFFF0077B3630@PAGEOFF]
 __text:FFFFFFF007CA9B40                 MOV             X27, X25
 __text:FFFFFFF007CA9B44                 CMP             X8, X25
 __text:FFFFFFF007CA9B48                 B.HI            loc_FFFFFFF007CA9AAC
 __text:FFFFFFF007CA9B4C                 B               loc_FFFFFFF007CA9B78
 __text:FFFFFFF007CA9B50 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9B50
 __text:FFFFFFF007CA9B50 loc_FFFFFFF007CA9B50                    ; CODE XREF: sub_FFFFFFF007CA9978+15C↑j
 __text:FFFFFFF007CA9B50                 WFE
 __text:FFFFFFF007CA9B54
 __text:FFFFFFF007CA9B54 loc_FFFFFFF007CA9B54                    ; CODE XREF: sub_FFFFFFF007CA9978+164↑j
 __text:FFFFFFF007CA9B54                 MOV             W1, #0x1D
 __text:FFFFFFF007CA9B58                 MOV             X2, #0
 __text:FFFFFFF007CA9B5C                 ADRP            X3, #sub_FFFFFFF007B9AA30@PAGE
 __text:FFFFFFF007CA9B60                 ADD             X3, X3, #sub_FFFFFFF007B9AA30@PAGEOFF
 __text:FFFFFFF007CA9B64                 MOV             W4, #0
 __text:FFFFFFF007CA9B68                 MOV             X25, X11
 __text:FFFFFFF007CA9B6C                 BL              sub_FFFFFFF007B9A844
 __text:FFFFFFF007CA9B70                 MOV             X11, X25
 __text:FFFFFFF007CA9B74                 B               loc_FFFFFFF007CA9AE0
 __text:FFFFFFF007CA9B78 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9B78
 __text:FFFFFFF007CA9B78 loc_FFFFFFF007CA9B78                    ; CODE XREF: sub_FFFFFFF007CA9978+1C0↑j
 __text:FFFFFFF007CA9B78                                         ; sub_FFFFFFF007CA9978+1D4↑j
 __text:FFFFFFF007CA9B78                 LDR             X8, [X23]
 __text:FFFFFFF007CA9B7C                 CBZ             X8, loc_FFFFFFF007CA9B98
 __text:FFFFFFF007CA9B80
 __text:FFFFFFF007CA9B80 loc_FFFFFFF007CA9B80                    ; CODE XREF: sub_FFFFFFF007CA9978+D4↑j
 __text:FFFFFFF007CA9B80                 AND             X9, X8, #0x8000000000000003
 __text:FFFFFFF007CA9B84                 MOV             X10, #0x8000000000000000
 __text:FFFFFFF007CA9B88                 CMP             X9, X10
 __text:FFFFFFF007CA9B8C                 B.NE            loc_FFFFFFF007CA9BF0
 __text:FFFFFFF007CA9B90                 TST             X8, #0x3FFFFFFFFFFFFFFF
 __text:FFFFFFF007CA9B94                 B.NE            loc_FFFFFFF007CA9D74
 __text:FFFFFFF007CA9B98
 __text:FFFFFFF007CA9B98 loc_FFFFFFF007CA9B98                    ; CODE XREF: sub_FFFFFFF007CA9978+D8↑j
 __text:FFFFFFF007CA9B98                                         ; sub_FFFFFFF007CA9978+204↑j
 __text:FFFFFFF007CA9B98                 CBNZ            W22, loc_FFFFFFF007CA9D44
 __text:FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9B9C loc_FFFFFFF007CA9B9C                    ; CODE XREF: sub_FFFFFFF007CA9978+280↓j
 __text:FFFFFFF007CA9B9C                                         ; sub_FFFFFFF007CA9978+2A0↓j ...
 __text:FFFFFFF007CA9B9C                 LDR             X8, [X26,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA9BA0                 SUBS            X8, X25, X8
 __text:FFFFFFF007CA9BA4                 B.CC            loc_FFFFFFF007CA9A58
 __text:FFFFFFF007CA9BA8                 LDR             X9, [X11,#qword_FFFFFFF0077B3630@PAGEOFF]
 __text:FFFFFFF007CA9BAC                 CMP             X9, X25
 __text:FFFFFFF007CA9BB0                 B.LS            loc_FFFFFFF007CA9A58
 __text:FFFFFFF007CA9BB4                 LSR             X8, X8, #0xE
 __text:FFFFFFF007CA9BB8                 ADRP            X9, #qword_FFFFFFF0077B3670@PAGE
 __text:FFFFFFF007CA9BBC                 LDR             X9, [X9,#qword_FFFFFFF0077B3670@PAGEOFF]
 __text:FFFFFFF007CA9BC0                 ADD             X8, X9, W8,UXTW#3
 __text:FFFFFFF007CA9BC4                 ADD             X8, X8, #4
 __text:FFFFFFF007CA9BC8                 MOV             W9, #0x20000000
 __text:FFFFFFF007CA9BCC                 LDCLRL          W9, W8, [X8]
 __text:FFFFFFF007CA9BD0                 LDR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9BD4                 CBZ             W8, loc_FFFFFFF007CA9CD4
 __text:FFFFFFF007CA9BD8                 SUBS            W8, W8, #1
 __text:FFFFFFF007CA9BDC                 STR             W8, [X19,#0x150]
 __text:FFFFFFF007CA9BE0                 B.NE            loc_FFFFFFF007CA9BEC
 __text:FFFFFFF007CA9BE4                 MOV             X0, X19
 __text:FFFFFFF007CA9BE8                 BL              sub_FFFFFFF007CBE2F8
 __text:FFFFFFF007CA9BEC
 __text:FFFFFFF007CA9BEC loc_FFFFFFF007CA9BEC                    ; CODE XREF: sub_FFFFFFF007CA9978+268↑j
 __text:FFFFFFF007CA9BEC                 B               loc_FFFFFFF007CA9A58
 __text:FFFFFFF007CA9BF0 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9BF0
 __text:FFFFFFF007CA9BF0 loc_FFFFFFF007CA9BF0                    ; CODE XREF: sub_FFFFFFF007CA9978+214↑j
 __text:FFFFFFF007CA9BF0                 UBFX            X9, X8, #0x3A, #1
 __text:FFFFFFF007CA9BF4                 CMP             W9, W22
 __text:FFFFFFF007CA9BF8                 B.EQ            loc_FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9BFC                 CMP             W22, #0
 __text:FFFFFFF007CA9C00                 CSET            W9, NE
 __text:FFFFFFF007CA9C04                 BFI             X8, X9, #0x3A, #1
 __text:FFFFFFF007CA9C08                 STR             X8, [X23]
 __text:FFFFFFF007CA9C0C                 ADRP            X24, #off_FFFFFFF0077B3600@PAGE
 __text:FFFFFFF007CA9C10                 LDR             X8, [X24,#off_FFFFFFF0077B3600@PAGEOFF]
 __text:FFFFFFF007CA9C14                 CMP             X8, X21
 __text:FFFFFFF007CA9C18                 B.EQ            loc_FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9C1C                 MOV             X27, X11
 __text:FFFFFFF007CA9C20                 MOV             X0, X23
 __text:FFFFFFF007CA9C24                 BL              sub_FFFFFFF007CBA11C
 __text:FFFFFFF007CA9C28                 LDR             X8, [X26,#qword_FFFFFFF0077B3628@PAGEOFF]
 __text:FFFFFFF007CA9C2C                 SUB             X8, X0, X8
 __text:FFFFFFF007CA9C30                 LSR             X8, X8, #0xE
 __text:FFFFFFF007CA9C34                 ADRP            X9, #qword_FFFFFFF0077B3670@PAGE
 __text:FFFFFFF007CA9C38                 LDR             X9, [X9,#qword_FFFFFFF0077B3670@PAGEOFF]
 __text:FFFFFFF007CA9C3C                 LDR             X8, [X9,W8,UXTW#3]
 __text:FFFFFFF007CA9C40                 MOV             X9, #0xFFFFFFFFFFFFFFFC
 __text:FFFFFFF007CA9C44                 MOVK            X9, #0x83FF,LSL#48
 __text:FFFFFFF007CA9C48                 AND             X8, X8, X9
 __text:FFFFFFF007CA9C4C                 MOV             X9, #0x20
 __text:FFFFFFF007CA9C50                 MOVK            X9, #0x7C00,LSL#48
 __text:FFFFFFF007CA9C54                 LDR             X8, [X8,X9]
 __text:FFFFFFF007CA9C58                 ADD             X8, X8, #2
 __text:FFFFFFF007CA9C5C                 CBZ             W22, loc_FFFFFFF007CA9C94
 __text:FFFFFFF007CA9C60                 MOV             W9, #1
 __text:FFFFFFF007CA9C64                 LDADDH          W9, W8, [X8]
 __text:FFFFFFF007CA9C68                 LDR             X8, [X24,#off_FFFFFFF0077B3600@PAGEOFF]
 __text:FFFFFFF007CA9C6C                 CMP             X8, X21
 __text:FFFFFFF007CA9C70                 MOV             X11, X27
 __text:FFFFFFF007CA9C74                 B.EQ            loc_FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9C78                 ADRP            X8, #dword_FFFFFFF0077ADEF8@PAGE
 __text:FFFFFFF007CA9C7C                 LDR             W2, [X8,#dword_FFFFFFF0077ADEF8@PAGEOFF]
 __text:FFFFFFF007CA9C80                 LDR             X1, [X21,#0x20]
 __text:FFFFFFF007CA9C84                 MOV             X0, X19
 __text:FFFFFFF007CA9C88                 MOV             W3, #0x4000
 __text:FFFFFFF007CA9C8C                 BL              sub_FFFFFFF007B9810C
 __text:FFFFFFF007CA9C90                 B               loc_FFFFFFF007CA9CCC
 __text:FFFFFFF007CA9C94 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9C94
 __text:FFFFFFF007CA9C94 loc_FFFFFFF007CA9C94                    ; CODE XREF: sub_FFFFFFF007CA9978+2E4↑j
 __text:FFFFFFF007CA9C94                 MOV             W9, #0xFFFFFFFF
 __text:FFFFFFF007CA9C98                 LDADDH          W9, W8, [X8]
 __text:FFFFFFF007CA9C9C                 TST             W8, #0xFFFF
 __text:FFFFFFF007CA9CA0                 B.EQ            loc_FFFFFFF007CA9CDC
 __text:FFFFFFF007CA9CA4                 LDR             X8, [X24,#off_FFFFFFF0077B3600@PAGEOFF]
 __text:FFFFFFF007CA9CA8                 CMP             X8, X21
 __text:FFFFFFF007CA9CAC                 MOV             X11, X27
 __text:FFFFFFF007CA9CB0                 B.EQ            loc_FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9CB4                 ADRP            X8, #dword_FFFFFFF0077ADEF8@PAGE
 __text:FFFFFFF007CA9CB8                 LDR             W2, [X8,#dword_FFFFFFF0077ADEF8@PAGEOFF]
 __text:FFFFFFF007CA9CBC                 LDR             X1, [X21,#0x20]
 __text:FFFFFFF007CA9CC0                 MOV             X0, X19
 __text:FFFFFFF007CA9CC4                 MOV             W3, #0x4000
 __text:FFFFFFF007CA9CC8                 BL              sub_FFFFFFF007B98F94
 __text:FFFFFFF007CA9CCC
 __text:FFFFFFF007CA9CCC loc_FFFFFFF007CA9CCC                    ; CODE XREF: sub_FFFFFFF007CA9978+318↑j
 __text:FFFFFFF007CA9CCC                 MOV             X11, X27
 __text:FFFFFFF007CA9CD0                 B               loc_FFFFFFF007CA9B9C
 __text:FFFFFFF007CA9CD4 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9CD4
 __text:FFFFFFF007CA9CD4 loc_FFFFFFF007CA9CD4                    ; CODE XREF: sub_FFFFFFF007CA9978+F4↑j
 __text:FFFFFFF007CA9CD4                                         ; sub_FFFFFFF007CA9978+198↑j ...
 __text:FFFFFFF007CA9CD4                 BL              sub_FFFFFFF00824E368
 __text:FFFFFFF007CA9CD8 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9CD8
 __text:FFFFFFF007CA9CD8 loc_FFFFFFF007CA9CD8                    ; CODE XREF: sub_FFFFFFF007CA9978+2C↑j
 __text:FFFFFFF007CA9CD8                                         ; sub_FFFFFFF007CA9978+13C↑j
 __text:FFFFFFF007CA9CD8                 BL              sub_FFFFFFF00824E340
 __text:FFFFFFF007CA9CDC ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9CDC
 __text:FFFFFFF007CA9CDC loc_FFFFFFF007CA9CDC                    ; CODE XREF: sub_FFFFFFF007CA9978+328↑j
 __text:FFFFFFF007CA9CDC                 MOV             W8, #0x356
 __text:FFFFFFF007CA9CE0                 ADRP            X9, #aPmapC@PAGE ; "pmap.c"
 __text:FFFFFFF007CA9CE4                 ADD             X9, X9, #aPmapC@PAGEOFF ; "pmap.c"
 __text:FFFFFFF007CA9CE8                 STP             X9, X8, [SP,#0x80+var_70]
 __text:FFFFFFF007CA9CEC                 STP             X21, X23, [SP,#0x80+var_80]
 __text:FFFFFFF007CA9CF0                 ADRP            X0, #aPmapPPtePWired@PAGE ; "pmap %p (pte %p): wired count underflow"...
 __text:FFFFFFF007CA9CF4                 ADD             X0, X0, #aPmapPPtePWired@PAGEOFF ; "pmap %p (pte %p): wired count underflow"...
 __text:FFFFFFF007CA9CF8                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA9CFC ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9CFC
 __text:FFFFFFF007CA9CFC loc_FFFFFFF007CA9CFC                    ; CODE XREF: sub_FFFFFFF007CA9978+EC↑j
 __text:FFFFFFF007CA9CFC                 MOV             W8, #0x852
 __text:FFFFFFF007CA9D00                 ADRP            X9, #aLockRwC@PAGE ; "lock_rw.c"
 __text:FFFFFFF007CA9D04                 ADD             X9, X9, #aLockRwC@PAGEOFF ; "lock_rw.c"
 __text:FFFFFFF007CA9D08                 STP             X9, X8, [SP,#0x80+var_70]
 __text:FFFFFFF007CA9D0C                 STP             X20, X0, [SP,#0x80+var_80]
 __text:FFFFFFF007CA9D10                 ADRP            X0, #aLckRwUnlockExc@PAGE ; "lck_rw_unlock_exclusive(): lock %p held"...
 __text:FFFFFFF007CA9D14                 ADD             X0, X0, #aLckRwUnlockExc@PAGEOFF ; "lck_rw_unlock_exclusive(): lock %p held"...
 __text:FFFFFFF007CA9D18                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA9D1C ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9D1C
 __text:FFFFFFF007CA9D1C loc_FFFFFFF007CA9D1C                    ; CODE XREF: sub_FFFFFFF007CA9978:loc_FFFFFFF007CA9A54↑j
 __text:FFFFFFF007CA9D1C                 MOV             W8, #0x1E86
 __text:FFFFFFF007CA9D20                 ADRP            X9, #aPmapC@PAGE ; "pmap.c"
 __text:FFFFFFF007CA9D24                 ADD             X9, X9, #aPmapC@PAGEOFF ; "pmap.c"
 __text:FFFFFFF007CA9D28                 ADRP            X10, #aPmapChangeWiri@PAGE ; "pmap_change_wiring_internal"
 __text:FFFFFFF007CA9D2C                 ADD             X10, X10, #aPmapChangeWiri@PAGEOFF ; "pmap_change_wiring_internal"
 __text:FFFFFFF007CA9D30                 STP             X9, X8, [SP,#0x80+var_70]
 __text:FFFFFFF007CA9D34                 STP             X10, X21, [SP,#0x80+var_80]
 __text:FFFFFFF007CA9D38                 ADRP            X0, #aSAttemptToWire@PAGE ; "%s: Attempt to wire nonexistent PTE for"...
 __text:FFFFFFF007CA9D3C                 ADD             X0, X0, #aSAttemptToWire@PAGEOFF ; "%s: Attempt to wire nonexistent PTE for"...
 __text:FFFFFFF007CA9D40                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA9D44 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9D44
 __text:FFFFFFF007CA9D44 loc_FFFFFFF007CA9D44                    ; CODE XREF: sub_FFFFFFF007CA9978:loc_FFFFFFF007CA9B98↑j
 __text:FFFFFFF007CA9D44                 LDR             X8, [X23]
 __text:FFFFFFF007CA9D48                 ADRP            X9, #aPmapC@PAGE ; "pmap.c"
 __text:FFFFFFF007CA9D4C                 ADD             X9, X9, #aPmapC@PAGEOFF ; "pmap.c"
 __text:FFFFFFF007CA9D50                 MOV             W10, #0x1EA4
 __text:FFFFFFF007CA9D54                 STP             X9, X10, [SP,#0x80+var_60]
 __text:FFFFFFF007CA9D58                 ADRP            X9, #aPmapChangeWiri@PAGE ; "pmap_change_wiring_internal"
 __text:FFFFFFF007CA9D5C                 ADD             X9, X9, #aPmapChangeWiri@PAGEOFF ; "pmap_change_wiring_internal"
 __text:FFFFFFF007CA9D60                 STP             X8, X21, [SP,#0x80+var_70]
 __text:FFFFFFF007CA9D64                 STP             X9, X23, [SP,#0x80+var_80]
 __text:FFFFFFF007CA9D68                 ADRP            X0, #aSAttemptToWire_0@PAGE ; "%s: Attempt to wire empty/compressed PT"...
 __text:FFFFFFF007CA9D6C                 ADD             X0, X0, #aSAttemptToWire_0@PAGEOFF ; "%s: Attempt to wire empty/compressed PT"...
 __text:FFFFFFF007CA9D70                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA9D74 ; ---------------------------------------------------------------------------
 __text:FFFFFFF007CA9D74
 __text:FFFFFFF007CA9D74 loc_FFFFFFF007CA9D74                    ; CODE XREF: sub_FFFFFFF007CA9978+21C↑j
 __text:FFFFFFF007CA9D74                 LDR             X8, [X23]
 __text:FFFFFFF007CA9D78                 AND             X9, X8, #0x3FFFFFFFFFFFFFFF
 __text:FFFFFFF007CA9D7C                 MOV             W11, #0x1E9E
 __text:FFFFFFF007CA9D80                 ADRP            X10, #aPmapC@PAGE ; "pmap.c"
 __text:FFFFFFF007CA9D84                 ADD             X10, X10, #aPmapC@PAGEOFF ; "pmap.c"
 __text:FFFFFFF007CA9D88                 STP             X10, X11, [SP,#0x80+var_68]
 __text:FFFFFFF007CA9D8C                 STP             X8, X9, [SP,#0x80+var_78]
 __text:FFFFFFF007CA9D90                 STR             X23, [SP,#0x80+var_80]
 __text:FFFFFFF007CA9D94                 ADRP            X0, #aCompressedPteP@PAGE ; "compressed PTE %p 0x%llx has extra bits"...
 __text:FFFFFFF007CA9D98                 ADD             X0, X0, #aCompressedPteP@PAGEOFF ; "compressed PTE %p 0x%llx has extra bits"...
 __text:FFFFFFF007CA9D9C                 BL              sub_FFFFFFF00956753C
 __text:FFFFFFF007CA9D9C ; End of function sub_FFFFFFF007CA9978
 */



//off_ml_phys_read_data = 0xFFFFFFF0072D6ABC;
        // 15.0.2/0.1 ... 0xFFFFFFF0072D6B70;       //0xFFFFFFF0072D6B70

// off_ml_phys_write_data = 0xFFFFFFF0072D6D40;
        // look for string =     Invalid size %d for ml_phys_write_data find function below and B sub_FFFFFFF is the address in that function 15.0.2/0.1 0xFFFFFFF0072D6D40;

//0xFFFFFFF0072D6D40
        //off_zm_fix_addr_kalloc = 0xFFFFFFF00713A510;


/* off_p_textvp

EXPORT _cs_entitlements_blob_get
__TEXT_EXEC:__text:FFFFFFF0073F52E8 _cs_entitlements_blob_get               ; CODE XREF: sub_FFFFFFF007422398+718↓p
__TEXT_EXEC:__text:FFFFFFF0073F52E8                                         ; IOUserClient::copyClientEntitlement(task *,char const*)+64↓p
__TEXT_EXEC:__text:FFFFFFF0073F52E8
__TEXT_EXEC:__text:FFFFFFF0073F52E8 var_10          = -0x10
__TEXT_EXEC:__text:FFFFFFF0073F52E8 var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF0073F52E8
__TEXT_EXEC:__text:FFFFFFF0073F52E8                 STP             X20, X19, [SP,#-0x10+var_10]!
__TEXT_EXEC:__text:FFFFFFF0073F52EC                 STP             X29, X30, [SP,#0x10+var_s0]
__TEXT_EXEC:__text:FFFFFFF0073F52F0                 ADD             X29, SP, #0x10
__TEXT_EXEC:__text:FFFFFFF0073F52F4                 MOV             X19, X2
__TEXT_EXEC:__text:FFFFFFF0073F52F8                 MOV             X20, X1
__TEXT_EXEC:__text:FFFFFFF0073F52FC                 STR             XZR, [X20]
__TEXT_EXEC:__text:FFFFFFF0073F5300                 STR             XZR, [X19]
__TEXT_EXEC:__text:FFFFFFF0073F5304                 LDRB            W8, [X0,#0x293]
__TEXT_EXEC:__text:FFFFFFF0073F5308                 TBNZ            W8, #5, loc_FFFFFFF0073F5314
__TEXT_EXEC:__text:FFFFFFF0073F530C                 MOV             W0, #0
__TEXT_EXEC:__text:FFFFFFF0073F5310                 B               loc_FFFFFFF0073F5348
__TEXT_EXEC:__text:FFFFFFF0073F5314 ; ---------------------------------------------------------------------------
__TEXT_EXEC:__text:FFFFFFF0073F5314
__TEXT_EXEC:__text:FFFFFFF0073F5314 loc_FFFFFFF0073F5314                    ; CODE XREF: _cs_entitlements_blob_get+20↑j
__TEXT_EXEC:__text:FFFFFFF0073F5314                 LDR             X8, [X0,#0x230]
__TEXT_EXEC:__text:FFFFFFF0073F5318                 CBZ             X8, loc_FFFFFFF0073F5344
__TEXT_EXEC:__text:FFFFFFF0073F531C                 LDR             X2, [X0,#0x238]
__TEXT_EXEC:__text:FFFFFFF0073F5320                 MOV             W1, #0xFFFFFFFF
__TEXT_EXEC:__text:FFFFFFF0073F5324                 MOV             X0, X8




EXPORT _proc_getexecutablevnode
__TEXT_EXEC:__text:FFFFFFF00758F018 _proc_getexecutablevnode
__TEXT_EXEC:__text:FFFFFFF00758F018
__TEXT_EXEC:__text:FFFFFFF00758F018 var_10          = -0x10
__TEXT_EXEC:__text:FFFFFFF00758F018 var_s0          =  0
__TEXT_EXEC:__text:FFFFFFF00758F018
__TEXT_EXEC:__text:FFFFFFF00758F018                 STP             X20, X19, [SP,#-0x10+var_10]!
__TEXT_EXEC:__text:FFFFFFF00758F01C                 STP             X29, X30, [SP,#0x10+var_s0]
__TEXT_EXEC:__text:FFFFFFF00758F020                 ADD             X29, SP, #0x10
__TEXT_EXEC:__text:FFFFFFF00758F024                 LDR             X19, [X0,#0x2A8] <- this

EXPORT _proc_getcdhash
__TEXT_EXEC:__text:FFFFFFF00758EFFC _proc_getcdhash
__TEXT_EXEC:__text:FFFFFFF00758EFFC                 MOV             X2, X1
__TEXT_EXEC:__text:FFFFFFF00758F000                 LDR             X8, [X0,#0x2A8] <- this ?
*/

/* off_task_t_flags
EXPORT _proc_is64bit_data
__TEXT_EXEC:__text:FFFFFFF00758EFC4 _proc_is64bit_data
__TEXT_EXEC:__text:FFFFFFF00758EFC4                 LDR             X8, [X0,#0x10]
__TEXT_EXEC:__text:FFFFFFF00758EFC8                 LDR             W8, [X8,#0x3E8] <- this??
__TEXT_EXEC:__text:FFFFFFF00758EFCC                 UBFX            W0, W8, #1, #1
*/

// off_ubc_info_cs_blobs = 0x78;


/*
 EXPORT _cs_entitlements_blob_get
 __TEXT_EXEC:__text:FFFFFFF0073F52E8 _cs_entitlements_blob_get               ; CODE XREF: sub_FFFFFFF007422398+718↓p
 __TEXT_EXEC:__text:FFFFFFF0073F52E8                                         ; IOUserClient::copyClientEntitlement(task *,char const*)+64↓p
 __TEXT_EXEC:__text:FFFFFFF0073F52E8
 __TEXT_EXEC:__text:FFFFFFF0073F52E8 var_10          = -0x10
 __TEXT_EXEC:__text:FFFFFFF0073F52E8 var_s0          =  0
 __TEXT_EXEC:__text:FFFFFFF0073F52E8
 __TEXT_EXEC:__text:FFFFFFF0073F52E8                 STP             X20, X19, [SP,#-0x10+var_10]!
 __TEXT_EXEC:__text:FFFFFFF0073F52EC                 STP             X29, X30, [SP,#0x10+var_s0]
 __TEXT_EXEC:__text:FFFFFFF0073F52F0                 ADD             X29, SP, #0x10
 __TEXT_EXEC:__text:FFFFFFF0073F52F4                 MOV             X19, X2
 __TEXT_EXEC:__text:FFFFFFF0073F52F8                 MOV             X20, X1
 __TEXT_EXEC:__text:FFFFFFF0073F52FC                 STR             XZR, [X20]
 __TEXT_EXEC:__text:FFFFFFF0073F5300                 STR             XZR, [X19]
 __TEXT_EXEC:__text:FFFFFFF0073F5304                 LDRB            W8, [X0,#0x293]
 __TEXT_EXEC:__text:FFFFFFF0073F5308                 TBNZ            W8, #5, loc_FFFFFFF0073F5314
 __TEXT_EXEC:__text:FFFFFFF0073F530C                 MOV             W0, #0
 __TEXT_EXEC:__text:FFFFFFF0073F5310                 B               loc_FFFFFFF0073F5348
 __TEXT_EXEC:__text:FFFFFFF0073F5314 ; ---------------------------------------------------------------------------
 __TEXT_EXEC:__text:FFFFFFF0073F5314
 __TEXT_EXEC:__text:FFFFFFF0073F5314 loc_FFFFFFF0073F5314                    ; CODE XREF: _cs_entitlements_blob_get+20↑j
 __TEXT_EXEC:__text:FFFFFFF0073F5314                 LDR             X8, [X0,#0x230]
 __TEXT_EXEC:__text:FFFFFFF0073F5318                 CBZ             X8, loc_FFFFFFF0073F5344
 __TEXT_EXEC:__text:FFFFFFF0073F531C                 LDR             X2, [X0,#0x238]
 __TEXT_EXEC:__text:FFFFFFF0073F5320                 MOV             W1, #0xFFFFFFFF
 __TEXT_EXEC:__text:FFFFFFF0073F5324                 MOV             X0, X8
 */
// off_p_pfd = 0x108;//0x100 //0xd8
// off_ipc_port_ip_kobject = 0x48;
//itk_space =0x308
//off_p_textvp = 0x198;//0x2a8, 0x28C
