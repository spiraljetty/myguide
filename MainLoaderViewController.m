//
//  MainLoaderViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import "MainLoaderViewController.h"
#import "YLViewController.h"
#import "AppDelegate_Pad.h"
#import "DynamicSpeech.h"

#import <AudioToolbox/AudioToolbox.h>

@interface MainLoaderViewController ()

@end

@implementation MainLoaderViewController

@synthesize currentWRViewController;
@synthesize miniDemoVC, waitSpinner, waitBlack, waitLabel, shortWaitTimer, standardPageButtonOverlay, readyForAppointmentButton, modalConfirmReadyForAppointment, revealSettings, modalEnterGoal;

static MainLoaderViewController* mViewController = NULL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
        // Custom initialization
        NSLog(@"MainLoaderViewController.initWithNibName() %S", nibNameOrNil);
        
        shouldShowReadyButton = YES;
        
        [self createNewWaitingRoomViewController];
        [self createNewButtonOverlay];
//        [self createReadyForAppointmentButton];
        [self createModalAreYouSure];
        [self createModalEnterGoal];
        
        miniDemoVC = [[MiniDemoViewController alloc] initWithNibName:nil bundle:nil];
        miniDemoVC.view.alpha = 1.0;
        miniDemoVC.view.frame = CGRectMake(200, 200, 410, 262);
        miniDemoVC.view.backgroundColor = [UIColor clearColor];
        //sandy tried moving this over to see if it shifts like other but it didn't work and crashed compiler
        [miniDemoVC.view setCenter:CGPointMake(-80.0f, 1109.0f)];
        // attempted
        //[miniDemoVC.view setCenter:CGPointMake(100.0f, 900.0f)];
        
        miniDemoVC.view.transform = rotateRight;
        
        [self.view addSubview:miniDemoVC.view];
        [self.view sendSubviewToBack:miniDemoVC.view];
        
        waitBlack = [[UIView alloc] initWithFrame:self.view.frame];
        waitBlack.backgroundColor = [UIColor blackColor];
        waitBlack.alpha = 0.0;
//        waitBlack.transform = rotateRight;
        
        waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        waitLabel.text = @"Resetting...";
        waitLabel.textAlignment = UITextAlignmentCenter;
        waitLabel.textColor = [UIColor whiteColor];
        waitLabel.font = [UIFont fontWithName:@"Avenir" size:45];
        waitLabel.backgroundColor = [UIColor clearColor];
        waitLabel.opaque = YES;
        [waitLabel sizeToFit];
        [waitLabel setCenter:CGPointMake(412.0f, 512.0f)];
        waitLabel.alpha = 0.0;
        waitLabel.transform = rotateRight;
        
        waitSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
        [waitSpinner setCenter:CGPointMake(412.0f, 712.0f)];
        [waitSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitSpinner.transform = rotateRight;
        waitSpinner.alpha = 0.0;
        
        revealSettings = [UIButton buttonWithType:UIButtonTypeCustom];
        revealSettings.frame = CGRectMake(0, 0, 35, 35);
        revealSettings.showsTouchWhenHighlighted = YES;
        [revealSettings setImage:[UIImage imageNamed:@"GreySidebar_rotated.png"] forState:UIControlStateNormal];
        [revealSettings setImage:[UIImage imageNamed:@"GreySidebar_rotated.png"] forState:UIControlStateHighlighted];
        [revealSettings setImage:[UIImage imageNamed:@"GreySidebar_rotated.png"] forState:UIControlStateSelected];
        revealSettings.backgroundColor = [UIColor clearColor];
        [revealSettings setCenter:CGPointMake(17.0f, 1005.0f)];
        [revealSettings addTarget:self action:@selector(revealSettingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        revealSettings.enabled = YES;
        revealSettings.hidden = NO;
        revealSettings.alpha = 0.0;
        [revealSettings retain];
        revealSettings.transform = rotateRight;
        [self.view addSubview:revealSettings];
        [self.view sendSubviewToBack:revealSettings];
        
        [self.view addSubview:waitBlack];
        [self.view addSubview:waitLabel];
        [self.view addSubview:waitSpinner];
        
        // Hide volume display from now on
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
        [self.view addSubview: volumeView];
        [volumeView release];

        
    }
    return self;
}

- (void)revealSettingsButtonPressed {
    NSLog(@"MainLoaderViewController.revealSettingsButtonPressed()");
    revealSettings.enabled = NO;
    [self fadeOutRevealSettingsButton];
    currentWRViewController.revealSettingsButtonPressed = YES;
    [currentWRViewController showModalUnlockSettingsView];
}

- (void)fadeInRevealSettingsButton {
    NSLog(@"MainLoaderViewController.fadeInRevealSettingsButton()");
    revealSettings.enabled = YES;
    
    [self.view bringSubviewToFront:revealSettings];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        revealSettings.alpha = 0.08;
        
    }
    [UIView commitAnimations];
}

- (void)fadeOutRevealSettingsButton {
    NSLog(@"MainLoaderViewController.fadeOutRevealSettingsButton()");
    revealSettings.enabled = NO;
    
//    [self.view bringSubviewToFront:revealSettings];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        revealSettings.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)fadeInReadyForAppointmentButton {
    NSLog(@"fadeInReadyForAppointmentButton...");
    [self.view bringSubviewToFront:readyForAppointmentButton];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        readyForAppointmentButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)fadeOutReadyForAppointmentButton {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        readyForAppointmentButton.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)createReadyForAppointmentButton {
    NSLog(@"createReadyForAppointmentButton...");
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    readyForAppointmentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	readyForAppointmentButton.frame = CGRectMake(0, 0, 150, 44);
	readyForAppointmentButton.showsTouchWhenHighlighted = YES;
//	readyForAppointmentButton.backgroundColor = [UIColor clearColor];
    readyForAppointmentButton.titleLabel.text = @"Ready for Appointment";
    readyForAppointmentButton.titleLabel.textColor = [UIColor blackColor];
	[readyForAppointmentButton setCenter:CGPointMake(725.0f, 500.0f)];
	[readyForAppointmentButton addTarget:self action:@selector(showModalAreYouSureView) forControlEvents:UIControlEventTouchUpInside];
	readyForAppointmentButton.enabled = YES;
	readyForAppointmentButton.hidden = NO;
    readyForAppointmentButton.alpha = 0.0;
	[readyForAppointmentButton retain];
    readyForAppointmentButton.transform = rotateRight;
    
    [self.view addSubview:readyForAppointmentButton];
}

- (void)readyForAppointmentButtonPressed:(id)sender {
    NSLog(@"Ready for appointment pressed...");
    [self hideReadyForAppointmentButton];
    [currentWRViewController readyForAppointment];
}

- (void)createModalAreYouSure {
    UIStoryboard *yesNoStoryboard = [UIStoryboard storyboardWithName:@"survey_yes_no_template" bundle:[NSBundle mainBundle]];
    
    //    wantExtraInfo = [[SwitchedImageViewController alloc] init];
    modalConfirmReadyForAppointment = [yesNoStoryboard instantiateViewControllerWithIdentifier:@"0"];
    [modalConfirmReadyForAppointment retain];
    
    modalConfirmReadyForAppointment.currentSurveyPageType = kYesNo;
    modalConfirmReadyForAppointment.surveyPageIndex = 0;
    modalConfirmReadyForAppointment.delegate = self;
    modalConfirmReadyForAppointment.isSurveyPage = YES;
    
    modalConfirmReadyForAppointment.newYesNoText = [NSString stringWithFormat:@"Are you sure you are ready for your appointment?  Pressing Yes will lock the waiting room guide until you are finished with your appointment."];
    modalConfirmReadyForAppointment.extraYesText = @"Yes, I am ready for my appointment.";
    modalConfirmReadyForAppointment.extraNoText = @"No, I would like to continue using this waiting room guide.";
    
    modalConfirmReadyForAppointment.view.frame = CGRectMake(0, 0, 1024, 800);
    modalConfirmReadyForAppointment.view.alpha = 0.0;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [modalConfirmReadyForAppointment.view setCenter:CGPointMake(400.0f, 512.0f)];
    modalConfirmReadyForAppointment.view.transform = rotateRight;
    [self.view addSubview:modalConfirmReadyForAppointment.view];
}

- (void)createModalEnterGoal {
    UIStoryboard *enterGoalStoryboard = [UIStoryboard storyboardWithName:@"survey_enter_goal_template" bundle:[NSBundle mainBundle]];
    
    //    wantExtraInfo = [[SwitchedImageViewController alloc] init];
    
//    modalEnterGoal = [[SLViewController alloc] initWithNibName:@"SLViewController" bundle:nil];
    
    modalEnterGoal = [enterGoalStoryboard instantiateViewControllerWithIdentifier:@"0"];
    [modalEnterGoal retain];
    
    modalEnterGoal.currentSurveyPageType = kEnterGoal;
    modalEnterGoal.surveyPageIndex = 0;
    modalEnterGoal.delegate = self;
    modalEnterGoal.isSurveyPage = YES;
    
    modalEnterGoal.currentPromptLabel = [NSString stringWithFormat:@"Please enter your goal for today's visit.  Tap the Done button when you are finished."];
    
    modalEnterGoal.view.frame = CGRectMake(0, 0, 1024, 800);
    modalEnterGoal.view.alpha = 0.0;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [modalEnterGoal.view setCenter:CGPointMake(400.0f, 512.0f)];
    modalEnterGoal.view.transform = rotateRight;
    [self.view addSubview:modalEnterGoal.view];
    
}

- (void)showModalEnterGoalView {
    NSLog(@"showModalEnterGoalView...");
    [self.view bringSubviewToFront:modalEnterGoal.view];
        
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        modalEnterGoal.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    [modalEnterGoal.enterGoalTextField becomeFirstResponder];
}

- (void)hideModalEnterGoalView {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        modalEnterGoal.view.alpha = 0.0;
        
    }
    [UIView commitAnimations];
    
    [self performSelector:@selector(finishHideModalEnterGoalView:) withObject:self afterDelay:0.5];
    
//    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(finishHideModalConfirmReady:) userInfo:nil repeats:NO] retain];
//	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishHideModalEnterGoalView:(id)sender {
    
    [self.view sendSubviewToBack:modalEnterGoal.view];
    
}

- (void)modalYesPressedInSender:(UIViewController *)senderVC {
    [DynamicSpeech stopSpeaking];
    [self hideModalConfirmReady];
    [self readyForAppointmentButtonPressed:self];
}

- (void)modalNoPressedInSender:(UIViewController *)senderVC {
    [self hideModalConfirmReady];
}

- (void)showModalAreYouSureView {
    [self.view bringSubviewToFront:modalConfirmReadyForAppointment.view];
    
    //    [wantExtraInfo release];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        modalConfirmReadyForAppointment.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)hideModalConfirmReady {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        modalConfirmReadyForAppointment.view.alpha = 0.0;
        
    }
    [UIView commitAnimations];
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(finishHideModalConfirmReady:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishHideModalConfirmReady:(NSTimer*)theTimer {
    
    [self.view sendSubviewToBack:modalConfirmReadyForAppointment.view];
    
    [theTimer release];
	theTimer = nil;
    
}

- (void)hideReadyForAppointmentButton {
    shouldShowReadyButton = NO;
    [self.view sendSubviewToBack:readyForAppointmentButton];
    readyForAppointmentButton.alpha = 0.0;
    readyForAppointmentButton.enabled = NO;
    readyForAppointmentButton.hidden = YES;
}

- (void)unhideReadyForAppointmentButton {
    shouldShowReadyButton = YES;
    [self.view bringSubviewToFront:readyForAppointmentButton];
    readyForAppointmentButton.alpha = 0.0;
    readyForAppointmentButton.enabled = YES;
    readyForAppointmentButton.hidden = NO;
}

- (void)createNewWaitingRoomViewController {
    NSLog(@"MainLoaderViewController.createNewWaitingRoomViewController()");

    currentWRViewController = [[WRViewController alloc] initWithNibName:nil bundle:nil];
//    currentWRViewController.view.frame = CGRectMake(0, 0, 1024, 768);
    [self.view addSubview:currentWRViewController.view];
}

- (void)createNewButtonOverlay {
    NSLog(@"MainLoaderViewController.createNewButtonOverlay()");

    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    standardPageButtonOverlay = [[DynamicButtonOverlayViewController alloc] initWithButtonOverlayType:@"previousnext"];
    
//    standardPageButtonOverlay.view.frame = CGRectMake(0, 0, 1024, 233);
    //    standardPageButtonOverlay.view.backgroundColor = [UIColor redColor];
    
    standardPageButtonOverlay.view.alpha = 0.0;
//    standardPageButtonOverlay.view.transform = rotateLeft;
    [standardPageButtonOverlay.view setCenter:CGPointMake(722.0f, 512.0f)];
    [self.view addSubview:standardPageButtonOverlay.view];
}

- (void)showCurrentButtonOverlay {
    
    NSLog(@"MainLoaderViewController.showCurrentButtonOverlay()");
    
//    standardPageButtonOverlay.view.alpha = 0.0;
    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    [self.view bringSubviewToFront:readyForAppointmentButton];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        standardPageButtonOverlay.view.alpha = 1.0;
        if (shouldShowReadyButton) {
            readyForAppointmentButton.alpha = 1.0;
        }
    }
    [UIView commitAnimations];
}

- (void)hideCurrentButtonOverlay {
    NSLog(@"MainLoaderViewController.hideCurrentButtonOverlay()");

    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        standardPageButtonOverlay.view.alpha = 0.0;
        readyForAppointmentButton.alpha = 0.0;
        
    }
    [UIView commitAnimations];
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(finishHideButtonOverlay:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishHideButtonOverlay:(NSTimer*)theTimer {
    NSLog(@"MainLoaderViewController.finishHideButtonOverlay()");
    [self.view sendSubviewToBack:standardPageButtonOverlay.view];
    
    [theTimer release];
	theTimer = nil;
    
}

- (void)showNextButton {
    NSLog(@"MainLoaderViewController.showNextButton()");
    @try {
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            standardPageButtonOverlay.nextPageButton.alpha = 1.0;
            
        }
        [UIView commitAnimations];
    }
    @catch(NSException *ne){
        NSLog(@"MainLoaderViewController.showNextButton() ERROR");
    }
}

- (void)hideNextButton {
    NSLog(@"MainLoaderViewController()hideNextButton()");
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        standardPageButtonOverlay.nextPageButton.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)showPreviousButton {
    NSLog(@"MainLoaderViewController.showPreviousButton()");
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        standardPageButtonOverlay.previousPageButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)hidePreviousButton {
    NSLog(@"MainLoaderViewController.hidePreviousButton()");
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        standardPageButtonOverlay.previousPageButton.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

#pragma mark DynamicButtonOverlayDelegate Methods

- (void)setActiveViewControllerTo:(UIViewController *)thisVC {
    if (activeViewController) {
        activeViewController = nil;
    }
    activeViewController = thisVC;
}

- (void)overlayNextPressed {
    NSLog(@"MainLoaderViewController.overlayNextPressed()");
    [activeViewController goForward];
}

- (void)overlayPreviousPressed {
    NSLog(@"MainLoaderViewController.overlayPreviousPressed()");
    [activeViewController goBackward];
}

- (void)overlayMenuPressed {
    NSLog(@"MainLoaderViewController.overlayMenuPressed()");
//    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] returnToMenu];
}

- (void)overlayFontsizePressed {
    NSLog(@"MainLoaderViewController.overlayFontsizePressed()");
    [currentWRViewController fontsizeButtonPressed:self];
}

- (void)overlayVoicePressed {
    NSLog(@"MainLoaderViewController.overlayVoicePressed()");
    [currentWRViewController voiceassistButtonPressed:self];
}

- (void)createNewWaitingRoomViewControllerAfterDelay:(NSTimer*)theTimer {
    
    currentWRViewController = [[WRViewController alloc] initWithNibName:nil bundle:nil];
    currentWRViewController.view.alpha = 0.0;
    [self.view addSubview:currentWRViewController.view];
    
    [self unhideReadyForAppointmentButton];
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideWaitScreen:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)destroyCurrentWaitingRoomViewController:(NSTimer*)theTimer {
    [currentWRViewController release];
    currentWRViewController = nil;
    NSLog(@"currentWRViewController destroyed...");
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(createNewWaitingRoomViewControllerAfterDelay:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)performAppReset {
    NSLog(@"MainLoaderViewcontroller.performAppReset() Resetting app...");
    
    [currentWRViewController.mainTTSPlayer stopPlayer];
    [miniDemoVC menuButtonPressed];
    [self showWaitScreen];
    [self fadeOutWRVC];
    
    
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(destroyCurrentWaitingRoomViewController:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)fadeInMiniDemoMenu {
    NSLog(@"MainLoaderViewController.fadeInMiniDemoMenu()");
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showMiniDemoMenu]; //rjl 6/26/14
//    [miniDemoVC menuButtonPressed];  //rjl 6/29/14 Adding this causes demo button to do 3-way cycle
    [self.view bringSubviewToFront:miniDemoVC.view];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        miniDemoVC.view.alpha = 1.0;
        currentWRViewController.settingsVC.soundViewController.updateSelectSoundsSwitch.alpha = 1.0;
        currentWRViewController.settingsVC.soundViewController.updateSoundsLabel.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)fadeOutMiniDemoMenu {
    NSLog(@"MainLoaderViewController.fadeOutMiniDemoMenu()");

    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        miniDemoVC.view.alpha = 0.0;
        currentWRViewController.settingsVC.soundViewController.updateSelectSoundsSwitch.alpha = 0.0;
        currentWRViewController.settingsVC.soundViewController.updateSoundsLabel.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)showMiniDemoMenu {
    NSLog(@"MainLoaderViewController.showMiniDemoMenu()");

    CGRect miniFrame = miniDemoVC.view.frame;
//    miniDemoVC.view.frame = [[UIScreen mainScreen] applicationFrame]; //rjl
//    miniFrame.origin.x = [[UIScreen mainScreen] applicationFrame].origin.x+miniDemoVC.view.frame.size.width - 300;
//    miniFrame.origin.y = [[UIScreen mainScreen] applicationFrame].origin.y+miniDemoVC.view.frame.size.height+300; //300;
//    miniFrame.origin.x = [[UIScreen mainScreen] applicationFrame].origin.x+200;
//    miniFrame.origin.y = [[UIScreen mainScreen] applicationFrame].origin.y+miniDemoVC.view.frame.size.height+150; //300;
//    miniFrame.origin.x = miniFrame.origin.x + miniDemoVC.view.frame.size.width - 50;
//    miniFrame.origin.y = miniFrame.origin.y - miniDemoVC.view.frame.size.height + 130;
    //sandy
    miniFrame.origin.x = miniFrame.origin.x + miniDemoVC.view.frame.size.width - 50; //rjl miniFrame.origin.x + miniDemoVC.view.frame.size.width - 50;
    miniFrame.origin.y = miniFrame.origin.y - miniDemoVC.view.frame.size.height + 130; //rjl miniFrame.origin.y - miniDemoVC.view.frame.size.height + 130;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        miniDemoVC.view.frame = miniFrame;
        miniDemoVC.view.backgroundColor = [UIColor whiteColor];
    }
    [UIView commitAnimations];
}

- (void)hideMiniDemoMenu {
    NSLog(@"MainLoaderViewController.hideMiniDemoMenu()");

    CGRect miniFrame = miniDemoVC.view.frame;
    //miniFrame.origin.x = miniFrame.origin.x - miniDemoVC.view.frame.size.width + 50;
    //miniFrame.origin.y = miniFrame.origin.y + miniDemoVC.view.frame.size.height - 130;
    //sandy
    miniFrame.origin.x = miniFrame.origin.x - miniDemoVC.view.frame.size.width + 50;
    miniFrame.origin.y = miniFrame.origin.y + miniDemoVC.view.frame.size.height - 130;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        miniDemoVC.view.frame = miniFrame;
        miniDemoVC.view.backgroundColor = [UIColor clearColor];
    }
    [UIView commitAnimations];
}

- (void)fadeOutWRVC {
    NSLog(@"MainLoaderViewController.fadeOutWRVC()");

    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        currentWRViewController.view.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)showWaitScreen {
    NSLog(@"MainLoaderViewController.showWaitScreen()");

    [self.view bringSubviewToFront:waitBlack];
    [self.view bringSubviewToFront:waitLabel];
    [self.view bringSubviewToFront:waitSpinner];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        waitBlack.alpha = 0.7;
        waitLabel.alpha = 1.0;
        waitSpinner.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    [waitSpinner startAnimating];
}

- (void)hideWaitScreen:(NSTimer*)theTimer {
    NSLog(@"MainLoaderViewController.hideWaitScreen()");

    [[AppDelegate_Pad sharedAppDelegate] startReachabilityNotifier];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        waitBlack.alpha = 0.0;
        waitLabel.alpha = 0.0;
        waitSpinner.alpha = 0.0;
        currentWRViewController.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(sendWaitScreenToBack:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)sendWaitScreenToBack:(NSTimer*)theTimer {
    [self.view sendSubviewToBack:waitSpinner];
    [self.view sendSubviewToBack:waitBlack];
    [self.view sendSubviewToBack:waitLabel];
    [waitSpinner stopAnimating];
}

+ (MainLoaderViewController*) getViewController{
    return mViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mViewController = self;
	// Do any additional setup after loading the view.
    NSLog(@"MainLoaderViewController.viewDidLoad()");
    [readyForAppointmentButton setTitle:@"Ready for Appointment" forState:UIControlStateNormal];
    readyForAppointmentButton.titleLabel.text = @"Ready for Appointment";
    [readyForAppointmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)dealloc {
    [currentWRViewController release];
    [miniDemoVC release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
