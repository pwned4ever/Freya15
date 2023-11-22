//
//  SettingsViewViewController.m


#import "SettingsViewController.h"
#import "fun/krw.h"
#import "ViewController.h"
/*#import "utils/utilsZS.h"
#include "cs_blob.h"
#include "file_utils.h"
#include "OffsetHolder.h"
#include <sys/sysctl.h>

#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]
//bool pressedJBbut;
*/
@interface SettingsViewController ()

@end
/*
char *sysctlWithNameS(const char *name) {
    kern_return_t kr = KERN_FAILURE;
    char *ret = NULL;
    size_t *size = NULL;
    size = (size_t *)malloc(sizeof(size_t));
    if (size == NULL) goto out;
    bzero(size, sizeof(size_t));
    if (sysctlbyname(name, NULL, size, NULL, 0) != ERR_SUCCESS) goto out;
    ret = (char *)malloc(*size);
    if (ret == NULL) goto out;
    bzero(ret, *size);
    if (sysctlbyname(name, ret, size, NULL, 0) != ERR_SUCCESS) goto out;
    kr = KERN_SUCCESS;
    out:
    if (kr == KERN_FAILURE)
    {
        free(ret);
        ret = NULL;
    }
    free(size);
    size = NULL;
    return ret;
}


NSString *getKernelBuildVersionS(void) {
    NSString *kernelBuild = nil;
    NSString *cleanString = nil;
    char *kernelVersion = NULL;
    kernelVersion = sysctlWithNameS("kern.version");
    if (kernelVersion == NULL) return nil;
    cleanString = [NSString stringWithUTF8String:kernelVersion];
    free(kernelVersion);
    kernelVersion = NULL;
    cleanString = [[cleanString componentsSeparatedByString:@"; "] objectAtIndex:1];
    cleanString = [[cleanString componentsSeparatedByString:@"-"] objectAtIndex:1];
    cleanString = [[cleanString componentsSeparatedByString:@"/"] objectAtIndex:0];
    kernelBuild = [cleanString copy];
    return kernelBuild;
}



*/
 
@implementation SettingsViewController
/*
- (IBAction)tweakwantstoggle:(id)sender {
        if ([sender isOn])
        {
            
            [self.WantsTweakInj setOn:TRUE];
            [self.WantsTweakInj setHidden:NO];
            [self.WantsTweakInj setEnabled:YES];
            [self.WantsTweakInj setUserInteractionEnabled:YES];
            
            [self.WantsSubstrateInj setOn:FALSE];
            [self.WantsSubstrateInj setHidden:NO];
            [self.WantsSubstrateInj setEnabled:YES];
            [self.WantsSubstrateInj setUserInteractionEnabled:YES];

            
            checkwantstweakinj = 1;
            checkwantsSubstrateinj = 0;

            saveCustomSetting(@"TinjectOpt", 0);
        } else {
            
            [self.WantsTweakInj setOn:FALSE];
            [self.WantsTweakInj setHidden:NO];
            [self.WantsTweakInj setEnabled:YES];
            [self.WantsTweakInj setUserInteractionEnabled:YES];
            
            [self.WantsSubstrateInj setOn:TRUE];
            [self.WantsSubstrateInj setHidden:NO];
            [self.WantsSubstrateInj setEnabled:YES];
            [self.WantsSubstrateInj setUserInteractionEnabled:YES];

            checkwantstweakinj = 0;
            checkwantsSubstrateinj = 1;
            saveCustomSetting(@"TinjectOpt", 1);
        }
}
- (IBAction)substratewantstoggle:(id)sender {

    if ([sender isOn])
    {
        [self.WantsTweakInj setOn:FALSE];
        [self.WantsTweakInj setHidden:NO];
        [self.WantsTweakInj setEnabled:YES];
        [self.WantsTweakInj setUserInteractionEnabled:YES];
        
        [self.WantsSubstrateInj setOn:TRUE];
        [self.WantsSubstrateInj setHidden:NO];
        [self.WantsSubstrateInj setEnabled:YES];
        [self.WantsSubstrateInj setUserInteractionEnabled:YES];

        checkwantsSubstrateinj = 1;
        checkwantstweakinj = 0;

        saveCustomSetting(@"StrateOpt", 0);
    } else {
        [self.WantsTweakInj setOn:TRUE];
        [self.WantsTweakInj setHidden:NO];
        [self.WantsTweakInj setEnabled:YES];
        [self.WantsTweakInj setUserInteractionEnabled:YES];
        
        [self.WantsSubstrateInj setOn:FALSE];
        [self.WantsSubstrateInj setHidden:NO];
        [self.WantsSubstrateInj setEnabled:YES];
        [self.WantsSubstrateInj setUserInteractionEnabled:YES];

        checkwantstweakinj = 1;
        checkwantsSubstrateinj = 0;

        saveCustomSetting(@"StrateOpt", 1);
    }
}

- (IBAction)setthenoncewith:(id)sender {
    [self.noncesettertxtfeild setValue:@"0x1111111111111111" forKey:@"Nonce"];
}

- (IBAction)jbbutton:(id)sender {
    
}
char *sysctlWithNameSet(const char *name) {
    kern_return_t kr = KERN_FAILURE;
    char *ret = NULL;
    size_t *size = NULL;
    size = (size_t *)malloc(sizeof(size_t));
    if (size == NULL) goto out;
    bzero(size, sizeof(size_t));
    if (sysctlbyname(name, NULL, size, NULL, 0) != ERR_SUCCESS) goto out;
    ret = (char *)malloc(*size);
    if (ret == NULL) goto out;
    bzero(ret, *size);
    if (sysctlbyname(name, ret, size, NULL, 0) != ERR_SUCCESS) goto out;
    kr = KERN_SUCCESS;
    out:
    if (kr == KERN_FAILURE)
    {
        free(ret);
        ret = NULL;
    }
    free(size);
    size = NULL;
    return ret;
}

bool machineNameContainsSet(const char *string) {
    char *machineName = sysctlWithNameSet("hw.machine");
    if (machineName == NULL) return false;
    bool ret = strstr(machineName, string) != NULL;
    free(machineName);
    machineName = NULL;
    return ret;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

/*
    int checkuncovermarker = (file_exists("/.installed_unc0ver"));
    int checkcheckRa1nmarker = (file_exists("/.bootstrapped"));
    int checkth0rmarkerFinal = (file_exists("/.freya_installed"));
    int checkelectra = (file_exists("/.bootstrapped_electra"));

    int checkchimeramarker = (file_exists("/.procursus_strapped"));
    int checkJBRemoverMarker = (file_exists("/var/mobile/Media/.bootstrapped_Th0r_remover"));

    int checku0slide = (file_exists("/var/tmp/slide.txt"));
    int checkcylog = (file_exists("/var/tmp/cydia.log"));
    int checkrcd = (file_exists("/etc/rc.d/substrate"));
    
    int checksuckmydTmpRun = (file_exists("/var/tmp/suckmyd.pid"));
    int checkjbdrRun = (file_exists("/var/run/jailbreakd.pid"));
    printf("jbd Run marker exists?: %d\n", checkjbdrRun);

    int checkpspawnhook = (file_exists("/var/run/pspawn_hook.ts"));
    int checkTweakinj = (!(file_exists("/usr/libexec/substrated")));
    int checksubsinj = (file_exists("/usr/libexec/substrated"));
    printf("checksubsinj: %d\n", checksubsinj);
    printf("checkTweakinj: %d\n", checkTweakinj);
    printf("checku0slide: %d\n", checku0slide);
    
    printf("Uncover marker exists?: %d\n", checkuncovermarker);
    printf("checkcylog marker exists?: %d\n", checkcylog);
    printf("checkrcd marker exists?: %d\n", checkrcd);
    */
    
    back4romset = 1;
 /*   CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.freyasbackgroundview.bounds;
    
    //gradient.colors = @[(id)[[UIColor colorWithRed:0.26 green:0.81 blue:0.64 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.09 green:0.35 blue:0.62 alpha:1.0] CGColor]];
    gradient.colors = @[(id)[[UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.29 green:0.05 blue:0.22 alpha:1.0] CGColor]];
    [self.freyasbackgroundview.layer insertSublayer:gradient atIndex:0];
    [self.freyasbackgroundview.layer insertSublayer:gradient atIndex:0];
    */
    

    //0 = Cydia//1
//    [_Cydia_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    //0 = MS//1 = MS2//2 = VS//3 = SP//4 = TW
     NSString *minKernelBuildVersion = nil;
     NSString *maxKernelBuildVersion = nil;

    UIColor *white = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];;
    UIColor *grey = [UIColor colorWithRed:0.30 green:0.00 blue:0.30 alpha:0.5];;
    double whatsmykoreNUMBER = kCFCoreFoundationVersionNumber;
   // printf("whatsmykoreNUMBER: %f\n", whatsmykoreNUMBER);
  
    //self.SPuppet_Outlet.hidden =true;

        minKernelBuildVersion = @"4397.0.0.2.4~1";
        maxKernelBuildVersion = @"4903.240.8~8";
                //            maxKernelBuildVersion = @"4903.232.2~1";// <- ios 12.1.1/2?  -- -- @"4903.240.8~8";
        
      /*      self.MS1_OUTLET.hidden = YES;
            _MS1_OUTLET.userInteractionEnabled = FALSE;
            _MS1_OUTLET.enabled = false;
            _MS1_OUTLET.backgroundColor = grey;
            self.VS_Outlet.hidden = YES;
            _VS_Outlet.userInteractionEnabled = FALSE;
            _VS_Outlet.enabled = false;
            _VS_Outlet.backgroundColor = grey;
            self.MS2_Outlet.hidden = YES;
            _MS2_Outlet.userInteractionEnabled = FALSE;
            _MS2_Outlet.enabled = false;
            _MS2_Outlet.backgroundColor = grey;
            self.SP_Outlet.hidden = NO;
            _SP_Outlet.userInteractionEnabled = TRUE;
            _SP_Outlet.enabled = true;
            _SP_Outlet.backgroundColor = grey;
            _TWOutlet.userInteractionEnabled = TRUE;
            _TWOutlet.enabled = true;
            _TWOutlet.backgroundColor = grey;
            self.CicutaOutlet.hidden = YES;
            _CicutaOutlet.userInteractionEnabled = FALSE;
            _CicutaOutlet.enabled = false;

    
    if (getExploitType() == 0)
    {
        [_MS1_OUTLET sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 1)
    {
        [_MS2_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 2)
    {
        [_VS_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 3)
    {
        [_SP_Outlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (getExploitType() == 4)
    {
        [_TWOutlet sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [self.freyashotbackgroud setHidden:YES];
*/
    
    if (back4romset == 2) {
       /* _MS1_OUTLET.hidden = true;
        _MS2_Outlet.hidden = true;
        _VS_Outlet.hidden = true;
        _SP_Outlet.hidden = true;
        _TWOutlet.hidden = true;
        _SPuppet_Outlet.hidden = true;
        _CicutaOutlet.hidden = true;
*/
        
        [_loadtweaklbl setHidden:YES];
        [_restorefslbl setHidden:YES];
        [self.TweaksEnabled setHidden:YES];
        [_restoreFS setHidden:YES];
        [_TweaksEnabled setHidden:TRUE];
        //[ViewController.sharedController. setHidden:YES];
      //  [ViewController.sharedController.TweaksEnabled setHidden:YES];
//        [self.freyashotbackgroud setHidden:NO];

        goto end1;

    }
    
    if (pressedJBbut) {
        back4romset = 2;
   //     printf("[*****] yep we hid the settings stuff [*****]\n");
        [_loadtweaklbl setHidden:YES];
        [_restorefslbl setHidden:YES];
        [self.TweaksEnabled setHidden:YES];
        [_restoreFS setHidden:YES];
        [_TweaksEnabled setHidden:TRUE];
/*
        _VS_Outlet.userInteractionEnabled = false;
        _VS_Outlet.enabled = false;
        _VS_Outlet.backgroundColor = grey;
        _VS_Outlet.hidden = true;
        [ViewController.sharedController.fixfsswitch setHidden:YES];
        [ViewController.sharedController.forceuisswizitch setHidden:YES];
        [ViewController.sharedController.restoreFSSwitch setHidden:YES];
        [ViewController.sharedController.loadTweakSwitch setHidden:YES];
        [self.freyashotbackgroud setHidden:NO];
*/
    
        goto end1;
    }
  
    if (runcheckjbstate()) {
        back4romset = 2;
   //     printf("[*****] yep we hid the settings stuff [*****]\n");
        [_loadtweaklbl setHidden:YES];
        [_EX_output_kfdSmith setHidden:YES];
        [_restorefslbl setHidden:YES];
        [self.TweaksEnabled setHidden:YES];
        [_restoreFS setHidden:YES];
        [_TweaksEnabled setHidden:TRUE];

        goto end1;
    }
    
    if (shouldLoadTweaks()) {
        [_TweaksEnabled setOn:true];
        [self.TweaksEnabled setOn:TRUE];
        [self.TweaksEnabled setEnabled:TRUE];
        [self.TweaksEnabled setHidden:FALSE];
        [self.loadtweaklbl setHidden:FALSE];
        [self.TweaksEnabled setUserInteractionEnabled:YES];

    } else {
        [_loadtweaklbl setHidden:YES];
        [_restorefslbl setHidden:YES];
        [self.TweaksEnabled setHidden:YES];
        [_restoreFS setHidden:YES];
        [_TweaksEnabled setHidden:TRUE];
    }
        if (shouldRestoreFS()) {
            JUSTremovecheck = true;
            [ViewController.sharedController.btnJb setTitle:@"Remove Freya?" forState:UIControlStateNormal];

            [_restoreFS setOn:true];
            [self.TweaksEnabled setHidden:FALSE];
            [self.loadtweaklbl setHidden:FALSE];
            [self.restoreFS setHidden:FALSE];
            [self.restorefslbl setHidden:FALSE];
            [self.TweaksEnabled setUserInteractionEnabled:YES];

        }
        else {
            [ViewController.sharedController.btnJb setTitle:@"gR00tLA$$" forState:UIControlStateNormal];

            [_TweaksEnabled setOn:true];
            [self.TweaksEnabled setHidden:FALSE];
            [self.loadtweaklbl setHidden:FALSE];
            [self.restoreFS setHidden:FALSE];
            [self.restorefslbl setHidden:FALSE];
            [self.TweaksEnabled setUserInteractionEnabled:YES];

            JUSTremovecheck = false;
            [_restoreFS setOn:false];
            
            
        }
    
    /*if (checkth0rmarkerFinal == 1) {
        if (checkfsfixswitch == 1) {
            [self.fixfsswitch setOn:TRUE];
            [self.fixfsswitch setHidden:NO];
            [self.fixfsswitch setEnabled:YES];
            [self.fixfsswitch setUserInteractionEnabled:YES]; }
        else {
            
            if (checksubsinj == 1) {
                _substratelabel.hidden = false;
                [self.WantsSubstrateInj setOn:YES];
                
                [self.WantsSubstrateInj setEnabled:NO];
                self.WantsSubstrateInj.hidden = false;
                
                _tinjectorlabel.hidden = true;
                [_WantsTweakInj setOn:NO];
                [_WantsTweakInj setEnabled:NO];
                _WantsTweakInj.hidden = true;

            } else {
                
                _substratelabel.hidden = true;
                [_WantsSubstrateInj setOn:NO];
                [_WantsSubstrateInj setEnabled:NO];
                _WantsSubstrateInj.hidden = true;
                
                _tinjectorlabel.hidden = false;
                [_WantsTweakInj setOn:YES];
                [_WantsTweakInj setEnabled:NO];
                _WantsTweakInj.hidden = false;

            }
            [self.fixfsswitch setOn:FALSE];
            [self.fixfsswitch setHidden:NO];
            [self.fixfsswitch setEnabled:YES];
            [self.fixfsswitch setUserInteractionEnabled:YES];
            [self.restoreFSSwitch setOn:FALSE];
            [self.restoreFSSwitch setHidden:NO];
            [self.restoreFSSwitch setEnabled:YES];
            [self.restoreFSSwitch setUserInteractionEnabled:YES];
            [self.restoreFSSwitch setHidden:NO];
            //[self.loadTweaksSwitch setOn:TRUE];
            //[self.loadTweaksSwitch setEnabled:TRUE];
            [self.loadTweaksSwitch setHidden:FALSE];
            [self.loadTweaksSwitch setUserInteractionEnabled:YES];
            [self.setnoncebtn setUserInteractionEnabled:YES];

            [ViewController.sharedController.restoreFSSwitch setEnabled:YES];
            [ViewController.sharedController.restoreFSSwitch setOn:YES];
            [ViewController.sharedController.restoreFSSwitch setHidden:NO];
            [ViewController.sharedController.restoreFSSwitch setUserInteractionEnabled:YES]; } }

    else {
        */
        
    /*    [self.WantsSubstrateInj setHidden:NO];
        [self.WantsTweakInj setHidden:NO];

        [self.setnoncebtn setHidden:TRUE];
        [self.fixfsswitch setHidden:TRUE];
        [self.ReinstallcydiaLabel setHidden:TRUE];
        [self.forceuicacheswitch setHidden:TRUE];
        [self.ForceuicacheLabel setHidden:TRUE];
        
        
     */
        if (shouldRestoreFS()) {
            JUSTremovecheck = true;
            [_restoreFS setOn:true]; }
         else {
            JUSTremovecheck = false;
            [_restoreFS setOn:false]; }
    //}
       
        

end1:
    {}
 //   printf("end of life !\n");
}

- (IBAction)credtitsbtnPressed:(id)sender {
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Credits To"
                                   message:@"YcS_dev, Lars F, Ellie, Wh1te4ever, xina, mineek and Linus H. \nThank you! for using Freya to jailbreak your device!."
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];
     
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)tweaksswitchpressed:(id)sender {
    if ([sender isOn])
    {
        saveCustomSetting(@"LoadTweaks", 0);
    } else {
        saveCustomSetting(@"LoadTweaks", 1);
    }

}

- (IBAction)restorefsswtichedpressed:(id)sender {
    if ([sender isOn])
    {
        [ViewController.sharedController.btnJb setTitle:@"Remove Freya?" forState:UIControlStateNormal];
        newTFcheckMyRemover4me = true;

        saveCustomSetting(@"resttoreRootFS", 1);
    } else {
        [ViewController.sharedController.btnJb setTitle:@"gR00tLA$$" forState:UIControlStateNormal];
        newTFcheckMyRemover4me = false;

        saveCustomSetting(@"resttoreRootFS", 9);
    }


}


- (IBAction)fuck:(id)sender {
}

@end

