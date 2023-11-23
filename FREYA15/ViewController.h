//
//  ViewController.h
//  FREYA15
//
//  Created by Marcel  on 2023-11-06.
//

#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/stat.h>
#include <stdio.h>
#include <stdbool.h>

#include <stddef.h>
#include <stdint.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


#define showMSG(msg, wait, destructive) showAlert(@"freya", msg, wait, destructive)
#define showPopup(msg, wait, destructive) showThePopup(@"", msg, wait, destructive)
#define __FILENAME__ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)
#define _assert(test, message, fatal) do \
if (!(test)) { \
int saved_errno = errno; \
LOG("__assert(%d:%s)@%s:%u[%s]", saved_errno, #test, __FILENAME__, __LINE__, __FUNCTION__); \
} \
while (false)


@interface ViewController : UIViewController <AVAudioPlayerDelegate> {
//@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, AVAudioPlayerDelegate> {
    SystemSoundID PlaySoundID1;
    AVAudioPlayer *audioPlayer1;
}

@property (readonly) ViewController *sharedController;
+ (ViewController*)sharedController;

- (IBAction)touchLtweaks:(id)sender;
- (IBAction)tocuhrestoreFS:(id)sender;
@property (strong, nonatomic) IBOutlet UIStackView *stackviewtextviewonly;

@property (strong, nonatomic) IBOutlet UIView *textviewStackViewView;
@property (strong, nonatomic) IBOutlet UIButton *stopbtnMusic;
@property (weak, nonatomic) IBOutlet UITextView *tvViewLog;
@property (weak, nonatomic) IBOutlet UILabel *lblfreyaTitle;
@property (strong, nonatomic) IBOutlet UISwitch *restoreFSSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *fixfsswitch;
@property (strong, nonatomic) IBOutlet UILabel *devicelbl;
@property (strong, nonatomic) IBOutlet UILabel *versionlbl;
@property (strong, nonatomic) IBOutlet UIView *freyabackgroundview;

@property (strong, nonatomic) IBOutlet UISwitch *loadTweakSwitch;

@property (weak, nonatomic) IBOutlet UIButton *btnJb;

@end

void sploitR(char *msg);

static inline void showAlertWithCancel(NSString *title, NSString *message, Boolean wait, Boolean destructive, NSString *cancel) {
    dispatch_semaphore_t semaphore;
    if (wait)
    semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"Okay" style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (wait)
            dispatch_semaphore_signal(semaphore);
        }];
        [alertController addAction:OK];
        [alertController setPreferredAction:OK];
        if (cancel) {
            UIAlertAction *abort = [UIAlertAction actionWithTitle:cancel style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (wait)
                dispatch_semaphore_signal(semaphore);
            }];
            [alertController addAction:abort];
            [alertController setPreferredAction:abort];
        }
        [controller presentViewController:alertController animated:YES completion:nil];
    });
    if (wait)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

static inline void showAlertPopup(NSString *title, NSString *message, Boolean wait, Boolean destructive, NSString *cancel) {
    dispatch_semaphore_t semaphore;
    if (wait)
    semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller presentViewController:alertController animated:YES completion:nil];
    });
    if (wait)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}



static inline void showAlert(NSString *title, NSString *message, Boolean wait, Boolean destructive) {

    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        [controller dismissViewControllerAnimated:false completion:nil];
    });
    
    showAlertWithCancel(title, message, wait, destructive, nil);
}



static inline void showThePopup(NSString *title, NSString *message, Boolean wait, Boolean destructive) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *controller = [ViewController sharedController];
        [controller dismissViewControllerAnimated:false completion:nil];
    });
    
    showAlertPopup(title, message, wait, destructive, nil);
}
bool runcheckjbstate(void);


extern int back4romset;
extern bool pressedJBbut;

extern bool JUSTremovecheck;

BOOL shouldLoadTweaks(void);
BOOL shouldRestoreFS(void);
void removethejb(void);

void saveCustomSetting(NSString *setting, int settingResult);

static inline void disableRootFS(void) {
    ViewController *controller = [ViewController sharedController];
    [[controller restoreFSSwitch] setOn:false];
    saveCustomSetting(@"RestoreFS", 1);
}

