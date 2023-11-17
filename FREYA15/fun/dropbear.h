//
//  dropbear.h
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/08/19.
//

#ifndef dropbear_h
#define dropbear_h

#include <stdio.h>
int untarDropbearBootstrap(void);
int cleanDropbearBootstrap(void);
int setupSSH(void);
int runSSH(void);

#endif /* dropbear_h */
