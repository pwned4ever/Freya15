//
//  bootstrap.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/21.
//

#ifndef bootstrap_h
#define bootstrap_h

#include <stdio.h>

#include <stdint.h>
#import <sys/cdefs.h>

void patchBaseBinLaunchDaemonPlists(void);
int extractBootstrap(void);
int startJBEnvironment(void);

#endif /* bootstrap_h */
