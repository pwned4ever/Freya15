//
//  ViewController.m
//  FREYA15
//
//  Created by Marcel Cianchino on 2023-11-06.
//

#import "ViewController.h"
#import "offsets.h"
#import <time.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#import "fun/krw.h"
#import "fun/fun.h"
#import "fun/common/KernelRwWrapper.h"

extern void (*log_UI)(const char *text);
void log_toView(const char *text);

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


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
        deviceNamesByCode = @{@"i386"      : @"Simulator",
                              @"x86_64"    : @"Simulator",
                              @"iPod1,1"   : @"iPod Touch",        // (Original)
                              @"iPod2,1"   : @"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   : @"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   : @"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   : @"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" : @"iPhone",            // (Original)
                              @"iPhone1,2" : @"iPhone",            // (3G)
                              @"iPhone2,1" : @"iPhone",            // (3GS)
                              @"iPad1,1"   : @"iPad",              // (Original)
                              @"iPad2,1"   : @"iPad 2",            //
                              @"iPad3,1"   : @"iPad",              // (3rd Generation)
                              @"iPhone3,1" : @"iPhone 4",          // (GSM)
                              @"iPhone3,3" : @"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" : @"iPhone 4S",         //
                              @"iPhone5,1" : @"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" : @"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   : @"iPad",              // (4th Generation)
                              @"iPad2,5"   : @"iPad Mini",         // (Original)
                              @"iPhone5,3" : @"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" : @"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" : @"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" : @"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" : @"iPhone 6 Plus",     //
                              @"iPhone7,2" : @"iPhone 6",          //
                              @"iPhone8,1" : @"iPhone 6S",         //
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
ViewController *sharedController = nil;
static ViewController *currentViewController;

-(void)sploitthat{
    //runOnMainQueueWithoutDeadlocking(^{
        //self->_thebuttonsJBbackground.backgroundColor = [UIColor greenColor]; //CGRectMake(10, 100, self.view.frame.size.width-20, 30);
        self->_btnJb.backgroundColor = [UIColor blackColor]; //CGRectMake(10, 100, self.view.frame.size.width-20, 30);
        [self->_btnJb setTitleColor:[UIColor redColor] forState: (normal)];
       // self.tvViewLog.progressTintColor = [UIColor blueColor];text
    [[sharedController tvViewLog] insertText:[NSString stringWithUTF8String:"yumyum"]];

        [self.btnJb setTitle:[NSString stringWithFormat:@"exploiting"] forState:UIControlStateNormal];
    
//});
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    currentViewController = self;
    sharedController = self;
    
    
    
    
    self.tvViewLog.text = @"";
    self.tvViewLog.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    self.tvViewLog.layer.borderColor = UIColor.greenColor.CGColor;

    [self.btnJb setEnabled:TRUE];
    self.btnJb.layer.cornerRadius = 15;
    self.btnJb.backgroundColor = UIColor.blueColor;
    log_UI = log_toView;
    
        
        _offsets_init();


    
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

void sploitR(char *msg){ [[ViewController currentViewController] sploitthat]; }
