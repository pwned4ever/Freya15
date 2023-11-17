//
//  vnode.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#ifndef vnode_h
#define vnode_h

#include <stdio.h>

uint64_t findRootVnode(void);
uint64_t vnodeChown(char* filename, uid_t uid, gid_t gid);
uint64_t vnodeChmod(char* filename, mode_t mode);

#endif /* vnode_h */
