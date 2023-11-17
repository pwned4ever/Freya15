//
//  ViewController.h
//  FREYA15
//
//  Created by Marcel Cianchino on 2023-11-06.
//

#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/stat.h>
#include <stdio.h>
#include <stdbool.h>

#include <stddef.h>
#include <stdint.h>

#define showMSG(msg, wait, destructive) showAlert(@"freya", msg, wait, destructive)
#define showPopup(msg, wait, destructive) showThePopup(@"", msg, wait, destructive)
#define __FILENAME__ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)
#define _assert(test, message, fatal) do \
if (!(test)) { \
int saved_errno = errno; \
LOG("__assert(%d:%s)@%s:%u[%s]", saved_errno, #test, __FILENAME__, __LINE__, __FUNCTION__); \
} \
while (false)


@interface ViewController : UIViewController
@property (readonly) ViewController *sharedController;
+ (ViewController*)sharedController;

@property (weak, nonatomic) IBOutlet UITextView *tvViewLog;
@property (weak, nonatomic) IBOutlet UILabel *lblfreyaTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnJb;

@end

void sploitR(char *msg);
