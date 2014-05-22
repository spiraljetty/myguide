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
        
        showingMiniMenu = NO;
        
        [self updateAllMiniMenuLabels];
    }
    return self;
}

- (void)menuButtonPressed {
    NSLog(@"mini menu button pressed");
    if (!showingMiniMenu) {
        showingMiniMenu = YES;
        miniMenuButton.titleLabel.text = @"Dismiss";
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showMiniDemoMenu];
    } else {
        showingMiniMenu = NO;
        miniMenuButton.titleLabel.text = @"Demo Menu";
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideMiniDemoMenu];
    }
}

- (void)resetButtonPressed {
    NSLog(@"reset button pressed");
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] performAppReset];
}

- (void)updateAllMiniMenuLabels {
    demoLabel.text = demoText;
    clinicLabel.text = clinicText;
    subClinicLabel.text = subClinicText;
    visitLabel.text = visitText;
    seeingLabel.text = seeingText;
    respondentLabel.text = respondentText;
    edLabel.text = edText;
    satisfactionLabel.text = satisfactionText;
    
    NSLog(@"mini menu labels updated");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
