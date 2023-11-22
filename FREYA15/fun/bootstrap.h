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
#include <stdbool.h>

void extractGz(const char *from, const char *to);

void patchBaseBinLaunchDaemonPlists(void);
int extractBootstrap(void);
int startJBEnvironment(void);
void restoreRootFS(void);

int remountPrebootPartition(bool writable);
char* locateExistingFakeRoot(void);



#endif /* bootstrap_h */
