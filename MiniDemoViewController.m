//
//  MiniDemoViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 12/8/12.
//
//

#import "MiniDemoViewController.h"

#import "AppDelegate_Pad.h"

@interface MiniDemoViewController ()

@end

@implementation MiniDemoViewController

@synthesize demoText, clinicText, subClinicText, visitText, seeingText, respondentText, edText, satisfactionText, showingMiniMenu;
@synthesize demoLabel, clinicLabel, subClinicLabel, visitLabel, seeingLabel, respondentLabel, edLabel, satisfactionLabel;
@synthesize miniMenuButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"MiniDemoViewController.initWithNibName()");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        demoText = @"Default";
        clinicText = @"Default";
        subClinicText = @"Default";
        visitText = @"Default";
        seeingText = @"Default";
        respondentText = @"Default";
        edText = @"Default";
        satisfactionText = @"Default";
        
        //original setting - enables demo menu in all screens
        showingMiniMenu = NO;
        // sandy
        //toggle this off and it removes it from the system -argh
        //showingMiniMenu = YES;
        
        [self updateAllMiniMenuLabels];
    }
    return self;
}

- (void)menuButtonPressed {
    NSLog(@"MiniDemoViewController.menuButtonPressed()");
    if (!showingMiniMenu) {
        showingMiniMenu = YES;
        miniMenuButton.titleLabel.text = @"Dismiss";
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showMiniDemoMenu];
    } else {
        showingMiniMenu = NO;
        // sandy truncated label miniMenuButton.titleLabel.text = @"Demo Menu";
        miniMenuButton.titleLabel.text = @"Demo";
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideMiniDemoMenu];
    }
}

- (void)resetButtonPressed {
    NSLog(@"MiniDemoViewController.resetButtonPressed()");
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] performAppReset];
}

- (void)updateAllMiniMenuLabels {
    NSLog(@"MiniDemoViewController.updateAllMiniMenuLabels()");
    demoLabel.text = demoText;
    clinicLabel.text = clinicText;
    subClinicLabel.text = subClinicText;
    visitLabel.text = visitText;
    seeingLabel.text = seeingText;
    respondentLabel.text = respondentText;
    edLabel.text = edText;
    satisfactionLabel.text = satisfactionText;
 }

- (void)viewDidLoad
{
     NSLog(@"MiniDemoViewControler.viewDidLoad()");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
