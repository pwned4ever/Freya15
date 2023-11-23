//
//  ViewController.m
//  FREYA15
//
//  Created by Marcel  on 2023-11-06.
//

#import "ViewController.h"
#import "SettingsViewController.h"
#import "mycommon.h"
#import "offsets.h"
#import <time.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#import "fun/krw.h"
#import "cs_blob.h"
#import "fun/fun.h"
#import "fun/common/KernelRwWrapper.h"

extern void (*log_UI)(const char *text);
void log_toView(const char *text);
bool JUSTremovecheck;
//bool newTFcheckMyRemover4me;
bool restore_fs = false;

int back4romset;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]

#define pwned4ever_URL "https://www.dropbox.com/s/stnh0out4tkoces/Th0r.ipa"
#define pwned4ever_TEAM_TWITTER_HANDLE "shogunpwnd"
#define K_ENABLE_TWEAKS "enableTweaks"


int setplaymusic = 0;
int theViewLoaded = 0;
float theprogressis = 0.000000000;
struct timeval tv1, tv2;
mach_port_t statusphier = MACH_PORT_NULL;


char *_cur_deviceModelVC = NULL;
char *get_current_deviceModelVC(void){
    if(_cur_deviceModelVC)
        return _cur_deviceModelVC;
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
                               @"iPad7,11"   : @"iPad 7 WiFi",          // 7th Generation iPad (iPad Air) - Wifi
                               @"iPad7,12"   : @"iPad 7 Cellular",          // 7th Generation iPad (iPad Air) - Wifi
                               @"iPad4,1"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                               @"iPad4,2"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                               @"iPad4,4"   : @"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                               @"iPad4,5"   : @"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                               @"iPad5,3"   : @"iPad Air 2 WiFi",          // 2nd Generation iPad (iPad Air 2) - Wifi
                               @"iPad5,4"   : @"iPad Air 2 Cellular",          // 2nd Generation iPad (iPad Air 2) - Cellular
                               @"iPad4,7"   : @"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                               @"iPad5,1"   : @"iPad Mini 4 WiFi",         // (4th Generation iPad Mini - Cellular)
                               @"iPad5,2"   : @"iPad Mini 4 Cellular",         // (4th Generation iPad Mini - Wifi)
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
    _cur_deviceModelVC = strdup([deviceName UTF8String]);
    return _cur_deviceModelVC;
}
char *_cur_deviceversionVC = NULL;
char *get_current_deviceversionVC(void){
    if(_cur_deviceversionVC)
        return _cur_deviceversionVC;
    struct utsname systemVersion;
    uname(&systemVersion);
    
    NSString* vcode = [NSString stringWithCString: systemVersion.version
                                         encoding:NSUTF8StringEncoding];

    _cur_deviceversionVC = strdup([vcode UTF8String]);
    return _cur_deviceversionVC;
    
}


@interface ViewController ()

@end

@implementation ViewController


+ (instancetype)currentViewController {
    return currentViewController;
}
- (IBAction)tocuhrestoreFS:(id)sender {
}

- (IBAction)touchLtweaks:(id)sender {
}

ViewController *sharedController = nil;
static ViewController *currentViewController;

double uptime(void){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return -1.0;
    }
    time_t bsec = boottime.tv_sec, csec = time(NULL);
    
    return difftime(csec, bsec);
}

- (IBAction)stopbtnMusic:(id)sender {
    NSString *music=[[NSBundle mainBundle]pathForResource:@"Big-Pun-So-Hard" ofType:@"mp3"];
    audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
    audioPlayer1.delegate=self;
    [audioPlayer1 stop];
}
- (IBAction)startmusic:(id)sender {
    NSString *music=[[NSBundle mainBundle]pathForResource:@"Big-Pun-So-Hard" ofType:@"mp3"];
    audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
    audioPlayer1.delegate=self;
    audioPlayer1.volume=1;
    audioPlayer1.numberOfLoops=-1;
    [audioPlayer1 play];
}


NSString *freyaversion = @"1.8⚡️";
char *freyaversionnew = "1.0⚡️";

char *freyaupdateDate = "9:00AM 07/01/23";
char *freyaurlDownload = "github.com/pwned4ever/Th0r_Freya/tree/main/Releases/Freya.ipa";//github.com/pwned4ever/Th0r_Freya/blob/main/Releases/Freya.ipa";// "mega.nz/file/BhNxBSgJ#gNcngNQBtXS0Ipa5ivX09-jtIr7BckUhrA7YMkSFaNM"//

- (void)shareTh0r {
    struct utsname u = { 0 };
    uname(&u);
    int theups = uptime();
    int therealups = ((theups / 60) / 60) / 24;
    NSString *device = [NSString stringWithUTF8String: get_current_deviceModelVC()];
    //NSString *version = [NSString stringWithUTF8String: get_current_deviceversion()];

    [NSString stringWithUTF8String:u.machine];//𝓢Ⓗ⒜𝕽ᴱ F𝕽ᴱy⒜
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *activityViewController;
            if (therealups == 1) {
                activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Freya %@, to jailbreak my %@ iOS %@, uptime:%d day.\nUpdated %s. By:@%@ 🍻.\nDownload @ %s" ), freyaversion, [NSString stringWithUTF8String: get_current_deviceModelVC()], [[UIDevice currentDevice] systemVersion], therealups, freyaupdateDate, @pwned4ever_TEAM_TWITTER_HANDLE, freyaurlDownload]] applicationActivities:nil];
            } else {
                activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Freya %@, to jailbreak my %@ iOS %@, uptime:%d days.\nUpdated %s. By:@%@ 🍻.\nDownload @ %s" ), freyaversion, [NSString stringWithUTF8String: get_current_deviceModelVC()], [[UIDevice currentDevice] systemVersion], therealups, freyaupdateDate, @pwned4ever_TEAM_TWITTER_HANDLE, freyaurlDownload]] applicationActivities:nil];
            }
            activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
            if ([activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
                activityViewController.popoverPresentationController.sourceView = self.btnJb; }
            [self presentViewController:activityViewController animated:YES completion:nil];
            [self.btnJb setEnabled:YES];
            [self.btnJb setHidden:NO]; });
     
    });
}
int wantstoviewlog;
bool wantsmusic;
int justinstalledcydia = 0;


- (void)wannaplaymusic {
    //dispatch_async(dispatch_get_main_queue(), ^{ });
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Play Music"
                                       message:@"Would you like music to play while you wait?."
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
      //  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        //   handler:^(UIAlertAction * action) {}];
         
            
            NSString *music=[[NSBundle mainBundle]pathForResource:@"Big-Pun-So-Hard" ofType:@"mp3"];
            self->audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music]error:NULL];
            self->audioPlayer1.delegate=self;
            self->audioPlayer1.volume=1;
            self->audioPlayer1.numberOfLoops=-1;
            setplaymusic = 1;
            [self->audioPlayer1 play];
            // }
        }];
        UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"No, quiet please" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alert addAction:OK];
        [alert addAction:Cancel];
        [alert setPreferredAction:Cancel];
        [self presentViewController:alert animated:YES completion:nil];
    });
    
    

    
    
    
}

-(void)jbremoving{
    dispatch_async(dispatch_get_main_queue(), ^{
        //self->_thebuttonsJBbackground.backgroundColor = [UIColor blackColor]; //CGRectMake(10, 100, self.view.frame.size.width-20, 30);
        [self->_btnJb setTitleColor:[UIColor blueColor] forState: (normal)];
        [self->_btnJb setTitle:@"Cleaning files..." forState: normal];
        
    });
}


- (void)restoredFSprompt {
    //dispatch_async(dispatch_get_main_queue(), ^{ });
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Jailbreak Removed"
                                       message:@"I will reboot for you after you close this prompt"
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *OK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                
          //  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            //   handler:^(UIAlertAction * action) {}];
             
                
                printf("deleted jailbreak...\n");
                sleep(3);
                reboot(0);
                // }
            }];

        
        [alert addAction:OK];
        [self presentViewController:alert animated:YES completion:nil];
    });
    
    

    
    
    
}








-(void)sploitthat{
    //runOnMainQueueWithoutDeadlocking(^{
        //self->_thebuttonsJBbackground.backgroundColor = [UIColor greenColor]; //CGRectMake(10, 100, self.view.frame.size.width-20, 30);
        self->_btnJb.backgroundColor = [UIColor blackColor]; //CGRectMake(10, 100, self.view.frame.size.width-20, 30);
        [self->_btnJb setTitleColor:[UIColor redColor] forState: (normal)];
       // self.tvViewLog.progressTintColor = [UIColor blueColor];text
//    [[sharedController tvViewLog] insertText:[NSString stringWithUTF8String:"yumyum"]];

        [self.btnJb setTitle:[NSString stringWithFormat:@"exploiting"] forState:UIControlStateNormal];
    
//});
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    currentViewController = self;
    sharedController = self;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.freyabackgroundview.bounds;

       //gradient.colors = @[(id)[[UIColor colorWithRed:0.26 green:0.81 blue:0.64 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:1.0] CGColor]];
    gradient.colors = @[(id)[
                            [UIColor colorWithRed:0.09 green:0.22 blue:0.55 alpha:1.0] CGColor],
                        (id)[
                            [UIColor colorWithRed:0.29 green:0.55 blue:0.22 alpha:1.0] CGColor]];
    [self.freyabackgroundview.layer insertSublayer:gradient atIndex:0];
//    [self.freyabackgroundview.layer insertSublayer:gradient atIndex:0];
       
    
    /*    CAGradientLayer *gradienttextview = [CAGradientLayer layer];

//    gradienttextview.frame = self.tvViewLog.bounds;
   gradienttextview.frame = self.tvViewLog.bounds;

       //gradient.colors = @[(id)[[UIColor colorWithRed:0.26 green:0.81 blue:0.64 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:1.0] CGColor]];
    gradienttextview.colors = @[(id)[
                            [UIColor colorWithRed:0.29 green:0.22 blue:0.55 alpha:1.0] CGColor],
                        (id)[
                            [UIColor colorWithRed:0.29 green:0.25 blue:0.22 alpha:1.0] CGColor]];
    
    //[self.tvViewLog.layer insertSublayer:gradienttextview atIndex:0];
    [self.tvViewLog.layer insertSublayer:gradienttextview atIndex:0];// insertSublayer:gradienttextview atIndex:0];
    // [self.tvViewLog.backgroundColor initWithCGColor: CFBridgingRetain(gradienttextview)];// insertSublayer:gradienttextview atIndex:0];
//stackviewtextviewonly; *textviewStackViewView
       
*/
       //0 = Cydia//1
   //    [_Cydia_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
       //0 = MS//1 = MS2//2 = VS//3 = SP//4 = TW
      // UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
      // UIColor *grey = [UIColor colorWithRed:0.30 green:0.00 blue:0.30 alpha:0.5];;
//       double whatsmykoreNUMBER = kCFCoreFoundationVersionNumber;

    
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:1 forKey:@"LoadTweaks"];
    [defaults setInteger:0 forKey:@"RestoreFS"];
    [defaults synchronize];
    
    NSString *device = [NSString stringWithUTF8String: get_current_deviceModelVC()];


    self.tvViewLog.text = @"";
    self.tvViewLog.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    self.tvViewLog.layer.borderColor = UIColor.greenColor.CGColor;

    [self.btnJb setEnabled:TRUE];
   // self.btnJb.layer.cornerRadius = 15;
   // self.btnJb.backgroundColor = UIColor.blueColor;
   // self.btnJb.backgroundColor = UIColor.blackColor;
    [self.btnJb setTitleColor:UIColor.greenColor forState:normal];// = UIColor.blackColor;
    sys_init();
    const char *yourdevice = device.UTF8String;//print_devicemodel();
    const char *yourversion = print_deviceversion();

    [self.devicelbl setText:@(yourdevice)];
    [self.versionlbl setText:@(yourversion)];

    log_UI = log_toView;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

       print_os_details();

       // print_deviceversion();
        _offsets_init();
   });
   

        
    if (isJailbroken()) {
       // dispatch_async(dispatch_get_main_queue(), ^{
        [self.btnJb setTitle:@"Jailbroken" forState:normal];
        [self.btnJb setAlpha:0.60];
        [self.btnJb setEnabled:false];
        //self.btnJb.backgroundColor = UIColor.blackColor;
        [self.btnJb setTitleColor:UIColor.redColor forState:UIControlStateDisabled];// = UIColor.blackColor;
        goto theend;
        // [[self btnJb] setEnabled:false];

        //});
    }
    if (shouldRestoreFS()) {
        JUSTremovecheck = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.btnJb setTitle:@"Remove Freya" forState:normal];

        });
    } else {

        
    }
theend:
    if (back4romset == 1) {
        back4romset = 2; }
    [self wannaplaymusic];

    // Do any additional setup after loading the view.
}
+ (ViewController *)sharedController {
    return sharedController;
}
uint64_t puaf_pages = 0x760;
uint64_t puaf_method = 1;
uint64_t kread_method = 2;
uint64_t kwrite_method = 2;

void runOnMainQueueWithoutDeadlocking(void (^block)(void)) {
    if ([NSThread isMainThread]) {
       // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block();
    }
    else { dispatch_sync(dispatch_get_main_queue(), block); }
}




bool pressedJBbut;

- (IBAction)pressedJBbtn:(id)sender {
    
    
   // NSString *enjoyStr = @"jailbroken";
     /*  if ([[[self.btnJb titleLabel] text] isEqualToString:enjoyStr]) {
           return;
       }*/

   // self.btnJb.backgroundColor = UIColor.lightGrayColor;
    //uint64_t kfd
    //runOnMainQueueWithoutDeadlocking(^{
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //dispatch_async(dispatch_get_main_queue(), ^{
       // dispatch_sync( dispatch_get_main_queue(), ^{
//               [self.btnJb setTitle:@"gR00tLA$$" forState:UIControlStateDisabled];
            
    
    pressedJBbut = TRUE;
    [[sharedController btnJb] setEnabled:TRUE];
    [sharedController btnJb].backgroundColor = UIColor.systemGreenColor;
        //});
   // });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // sys_init();
         //print_os_details();
        FINAL_KFD = do_kopen(puaf_pages, puaf_method, kread_method, kwrite_method);
        initKernRw(get_selftask(), kread64, kwrite64);
        isKernRwReady();
        if (shouldRestoreFS()) { restore_fs = true; } else { restore_fs = false; }

        do_fun();
         dispatch_sync( dispatch_get_main_queue(), ^{
            [self.btnJb setTitle:@"gR00tLA$$" forState:UIControlStateDisabled];

             [[sharedController btnJb] setEnabled:FALSE];
             [sharedController btnJb].backgroundColor = UIColor.systemBlueColor;
             

         });

     });
    //dispatch_async(dispatch_get_main_queue(), ^{
        
    //});


           
       
    
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{

   /* dispatch_async(dispatch_get_main_queue(), ^{
        [ViewController.sharedController.btnJb setTitle:@"running..." forState: normal];
        [ViewController.sharedController.tvViewLog setText:@"running..."];
    });
    */
    

    //sploitR("kk");;
}
#define CS_OPS_STATUS       0   /* return status */
#define CS_DYLD_PLATFORM 0x2000000 /* dyld used to load this is a platform binary */
#define CS_PLATFORM_BINARY 0x4000000 /* this is a platform binary */

bool isJailbroken(void) {
    uint32_t flags;
    csops(getpid(), CS_OPS_STATUS, &flags, 0);
    if ((flags & CS_PLATFORM_BINARY)) {
//        alertController = [UIAlertController alertControllerWithTitle:localize(@"Notice") message:localize(@"The system boot nonce will be set the next time you enable your jailbreak") preferredStyle:UIAlertControllerStyleAlert];
    } else {
  //      alertController = [UIAlertController alertControllerWithTitle:localize(@"Notice") message:localize(@"The system boot nonce will be set once you enable the jailbreak") preferredStyle:UIAlertControllerStyleAlert];
    }
    if (flags & CS_PLATFORM_BINARY) {
        return true;

    } else {
        
        return false;
    }
}


- (IBAction)restoreSwitch:(id)sender {
}
@end

void log_toView(const char *text) {
//®    runOnMainQueueWithoutDeadlocking(^{
dispatch_sync( dispatch_get_main_queue(), ^{
        //self.tvViewLog.text = @"";
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[sharedController tvViewLog] insertText:[NSString stringWithUTF8String:text]];
        //[[sharedController tvViewLog] insertText:[NSString stringWithUTF8String:text]];
        [[sharedController tvViewLog] scrollRangeToVisible:NSMakeRange([sharedController tvViewLog].text.length, 1)];
        
        
    });
}

bool runcheckjbstate(void) {
    if (isJailbroken()) {
        return true;
    } else {
        return false;
    }
}



void saveCustomSetting(NSString *setting, int settingResult)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:settingResult forKey:setting];
    
}

BOOL shouldLoadTweaks(void)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"LoadTweaks"] == 0)
    {
        return true;
    } else {
        return false;
    }
}


BOOL shouldRestoreFS(void)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"resttoreRootFS"] == 1)
    {
     //   [ViewController.sharedController.btnJb setTitle:@"Remove Freya?" forState:UIControlStateNormal];
        newTFcheckMyRemover4me = TRUE;
        
        [ViewController.sharedController.loadTweakSwitch setHidden:TRUE];
//        [self.loadtweaklbl setHidden:FALSE];
        [ViewController.sharedController.restoreFSSwitch setHidden:FALSE];

        return true;
    } else {
        newTFcheckMyRemover4me = false;

        return false;
    }
}



void sploitR(char *msg)    { [[ViewController currentViewController] sploitthat]; }
void removethejb() { [[ViewController currentViewController] jbremoving]; }
