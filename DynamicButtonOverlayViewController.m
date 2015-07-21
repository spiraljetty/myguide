//
//  DynamicButtonOverlayViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 1/17/13.
//
//

#import "DynamicButtonOverlayViewController.h"
#import "AppDelegate_Pad.h"

//#define STANDARD_FADE_DURATION = 0.3;

@interface DynamicButtonOverlayViewController ()

@end

@implementation DynamicButtonOverlayViewController


@synthesize delegate, buttonOverlayType, nextPageButton, previousPageButton, voiceAssistButton, fontsizeButton, returnToMenuButton, surveyResourceBack;
@synthesize yesButton, noButton, progressVC, readyForAppointmentButton;

static DynamicButtonOverlayViewController* mViewController;

+ (DynamicButtonOverlayViewController*) getViewController {
    return mViewController;
}


- (id)initWithButtonOverlayType:(NSString *)thisButtonOverlayType {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    buttonOverlayType = thisButtonOverlayType;
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    self.view.frame = CGRectMake(0, 0, 1024, 233);
    //self.view.transform = rotateRight;
    
    if ([thisButtonOverlayType isEqualToString:@"previousnext"]) {
        
        surveyResourceBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_back_wht_gradient_clearback5.png"]];
        surveyResourceBack.opaque = NO;
        surveyResourceBack.frame = CGRectMake(0, 0, 1024, 95);
//        surveyResourceBack.transform = rotateLeft;
        [surveyResourceBack setCenter:CGPointMake(512.0f, 115.0f)];
//        [surveyResourceBack setCenter:CGPointMake(100.0f, 90.0f)];
        surveyResourceBack.alpha = 1.0;
        
        [self.view addSubview:surveyResourceBack];
        [self.view sendSubviewToBack:surveyResourceBack];
        
        //nextPageButton - skip to next physician detail item
        nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextPageButton.frame = CGRectMake(0, 0, 150, 139);
        nextPageButton.showsTouchWhenHighlighted = YES;
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
        nextPageButton.backgroundColor = [UIColor clearColor];
       // sandy shifted [nextPageButton setCenter:CGPointMake(950.0f, 85.0f)];
        // this button is on the lower nav bar
                [nextPageButton setCenter:CGPointMake(945.0f, 80.0f)];
//        [nextPageButton setCenter:CGPointMake(385.0f, 80.0f)];
        //	[nextPageButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
        //    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
        [nextPageButton addTarget:delegate action:@selector(overlayNextPressed) forControlEvents:UIControlEventTouchUpInside];
        nextPageButton.enabled = YES;
        nextPageButton.hidden = NO;
        nextPageButton.alpha = 1.0;
        [nextPageButton retain];
//        nextPageButton.transform = rotateLeft;
        [self.view addSubview:nextPageButton];
//        [self.view sendSubviewToBack:nextPageButton];
        
        //previousPageButton - skip to previous physician detail item
        previousPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previousPageButton.frame = CGRectMake(0, 0, 150, 139);
        previousPageButton.showsTouchWhenHighlighted = YES;
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image.png"] forState:UIControlStateNormal];
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateSelected];
        previousPageButton.backgroundColor = [UIColor clearColor];
        [previousPageButton setCenter:CGPointMake(85.0f, 75.0f)];
//        [previousPageButton setCenter:CGPointMake(75.0f, 85.0f)];
//        [previousPageButton setCenter:CGPointMake(685.0f, 945.0f)];
        //	[previousPageButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
        [previousPageButton addTarget:delegate action:@selector(overlayPreviousPressed) forControlEvents:UIControlEventTouchUpInside];
        previousPageButton.enabled = YES;
        previousPageButton.hidden = NO;
        previousPageButton.alpha = 1.0;
        [previousPageButton retain];
//        previousPageButton.transform = rotateLeft;
        [self.view addSubview:previousPageButton];
//        [self.view sendSubviewToBack:previousPageButton];
        
        //returnToMenuButton
        returnToMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        returnToMenuButton.frame = CGRectMake(0, 0, 90, 85);
        returnToMenuButton.showsTouchWhenHighlighted = YES;
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml.png"] forState:UIControlStateNormal];
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateHighlighted];
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateSelected];
        returnToMenuButton.backgroundColor = [UIColor clearColor];
        [returnToMenuButton setCenter:CGPointMake(725.0f, 500.0f)];
        [returnToMenuButton addTarget:delegate action:@selector(overlayMenuPressed) forControlEvents:UIControlEventTouchUpInside];
        returnToMenuButton.enabled = NO;
        returnToMenuButton.hidden = NO;
        returnToMenuButton.alpha = 0.0;
        [returnToMenuButton retain];
//        returnToMenuButton.transform = rotateLeft;
        
        [self.view addSubview:returnToMenuButton];
//        [self.view sendSubviewToBack:returnToMenuButton];
        
        //voiceAssistButton - turn voice assist on and off
        // sandy - removed from storyboards because it was not needed currently
        voiceAssistButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceAssistButton.frame = CGRectMake(0, 0, 80, 80);
        voiceAssistButton.showsTouchWhenHighlighted = YES;
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_on.png"] forState:UIControlStateNormal];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
        voiceAssistButton.backgroundColor = [UIColor clearColor];
        [voiceAssistButton setCenter:CGPointMake(250.0f, 120.0f)];
        [voiceAssistButton addTarget:delegate action:@selector(overlayVoicePressed) forControlEvents:UIControlEventTouchUpInside];
        voiceAssistButton.enabled = YES;
        voiceAssistButton.hidden = NO;
//        if (tbvc.speakItemsAloud) {
//            voiceAssistButton.selected = NO;
//        } else {
//            voiceAssistButton.selected = YES;
//        }
        voiceAssistButton.alpha = 1.0;
        [voiceAssistButton retain];
//        voiceAssistButton.transform = rotateLeft;
        
        [self.view addSubview:voiceAssistButton];
        
        //fontsizeButton - cycle through font size options
        fontsizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fontsizeButton.frame = CGRectMake(0, 0, 80, 80);
        fontsizeButton.showsTouchWhenHighlighted = YES;
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image.png"] forState:UIControlStateNormal];
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateSelected];
        fontsizeButton.backgroundColor = [UIColor clearColor];
        [fontsizeButton setCenter:CGPointMake(350.0f, 120.0f)];
        [fontsizeButton addTarget:delegate action:@selector(overlayFontsizePressed) forControlEvents:UIControlEventTouchUpInside];
        fontsizeButton.enabled = YES;
        fontsizeButton.hidden = NO;
        fontsizeButton.alpha = 1.0;
        [fontsizeButton retain];
//        fontsizeButton.transform = rotateLeft;
        
        [self.view addSubview:fontsizeButton];
        
        //ready for the appointment button - indicate ready to go to the appointment
        readyForAppointmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        readyForAppointmentButton.frame = CGRectMake(0, 0, 151, 93);
        readyForAppointmentButton.showsTouchWhenHighlighted = YES;
        [readyForAppointmentButton setImage:[UIImage imageNamed:@"ready_for_appointment_button.png"] forState:UIControlStateNormal];
        [readyForAppointmentButton setImage:[UIImage imageNamed:@"ready_for_appointment_button_pressed.png"] forState:UIControlStateHighlighted];
        [readyForAppointmentButton setImage:[UIImage imageNamed:@"ready_for_appointment_button_pressed.png"] forState:UIControlStateSelected];
        readyForAppointmentButton.backgroundColor = [UIColor clearColor];
        [readyForAppointmentButton setCenter:CGPointMake(475.0f, 120.0f)];
        [readyForAppointmentButton addTarget:self action:@selector(readyForAppointmentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        readyForAppointmentButton.enabled = YES;
        readyForAppointmentButton.hidden = NO;
        readyForAppointmentButton.alpha = 1.0;
        [readyForAppointmentButton retain];
        //        fontsizeButton.transform = rotateLeft;
        
        [self.view addSubview:readyForAppointmentButton];
        
        UIStoryboard *progressStoryboard = [UIStoryboard storyboardWithName:@"ProgressStoryboard_new" bundle:[NSBundle mainBundle]];
        progressVC = [progressStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [progressVC retain];
        progressVC.view.frame = CGRectMake(0, 0, 50, 320);
        progressVC.view.alpha = 1.0;
        float angle =  270 * M_PI  / 180;
        progressVC.view.backgroundColor = [UIColor clearColor];
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        // original [progressVC.view setCenter:CGPointMake(631.0f, 310.0f)];
        // sandy - shifted -50,-50
        [progressVC.view setCenter:CGPointMake(581.0f, 240.0f)];
//        progressVC.view.transform = rotateRight;
        [self.view addSubview:progressVC.view];
        
        NSLog(@"Finished creating dynamic button overlay with type: %@",thisButtonOverlayType);
        
    } else if ([thisButtonOverlayType isEqualToString:@"yesno"]) {
        
        //yesButton - yes to voice assist
        yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        yesButton.frame = CGRectMake(0, 0, 208, 139);
        yesButton.showsTouchWhenHighlighted = YES;
        [yesButton setImage:[UIImage imageNamed:@"yes_button_image.png"] forState:UIControlStateNormal];
        [yesButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateHighlighted];
        [yesButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateSelected];
        yesButton.backgroundColor = [UIColor clearColor];
        [yesButton setCenter:CGPointMake(580.0f, 760.0f)];
        [yesButton addTarget:delegate action:@selector(overlayYesPressed) forControlEvents:UIControlEventTouchUpInside];
        yesButton.enabled = YES;
        yesButton.hidden = NO;
        yesButton.alpha = 1.0;
        [yesButton retain];
//        yesButton.transform = rotateLeft;
        
        [self.view addSubview:yesButton];
//        [self.view sendSubviewToBack:yesButton];
        
        //noButton - no to voice assist
        noButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noButton.frame = CGRectMake(0, 0, 208, 139);
        noButton.showsTouchWhenHighlighted = YES;
        [noButton setImage:[UIImage imageNamed:@"no_button_image.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"no_button_image_pressed2.png"] forState:UIControlStateHighlighted];
        [noButton setImage:[UIImage imageNamed:@"no_button_image_pressed2.png"] forState:UIControlStateSelected];
        noButton.backgroundColor = [UIColor clearColor];
        [noButton setCenter:CGPointMake(580.0f, 264.0f)];
        [noButton addTarget:delegate action:@selector(overlayNoPressed) forControlEvents:UIControlEventTouchUpInside];
        noButton.enabled = YES;
        noButton.hidden = NO;
        noButton.alpha = 1.0;
        [noButton retain];
//        noButton.transform = rotateLeft;
        
        [self.view addSubview:noButton];
//        [self.view sendSubviewToBack:noButton];
        
        NSLog(@"Finished creating dynamic button overlay with type: %@",thisButtonOverlayType);
        
    } else {
        surveyResourceBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_back_wht_gradient_clearback4.png"]];
        surveyResourceBack.opaque = NO;
        surveyResourceBack.frame = CGRectMake(0, 0, 768, 1024);
        surveyResourceBack.alpha = 1.0;
        
        [self.view addSubview:surveyResourceBack];
//        [self.view sendSubviewToBack:surveyResourceBack];
        
        //nextPageButton - skip to next physician detail item
        nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextPageButton.frame = CGRectMake(0, 0, 150, 139);
        nextPageButton.showsTouchWhenHighlighted = YES;
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [nextPageButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
        nextPageButton.backgroundColor = [UIColor clearColor];
        [nextPageButton setCenter:CGPointMake(685.0f, 80.0f)];
        //	[nextPageButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
        //    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
        [nextPageButton addTarget:delegate action:@selector(overlayNextPressed) forControlEvents:UIControlEventTouchUpInside];
        nextPageButton.enabled = YES;
        nextPageButton.hidden = NO;
        nextPageButton.alpha = 1.0;
        [nextPageButton retain];
//        nextPageButton.transform = rotateLeft;
        [self.view addSubview:nextPageButton];
//        [self.view sendSubviewToBack:nextPageButton];
        
        //previousPageButton - skip to previous physician detail item
        previousPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previousPageButton.frame = CGRectMake(0, 0, 150, 139);
        previousPageButton.showsTouchWhenHighlighted = YES;
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image.png"] forState:UIControlStateNormal];
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [previousPageButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateSelected];
        previousPageButton.backgroundColor = [UIColor clearColor];
        [previousPageButton setCenter:CGPointMake(685.0f, 945.0f)];
        //	[previousPageButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
        [previousPageButton addTarget:delegate action:@selector(overlayPreviousPressed) forControlEvents:UIControlEventTouchUpInside];
        previousPageButton.enabled = NO;
        previousPageButton.hidden = NO;
        previousPageButton.alpha = 1.0;
        [previousPageButton retain];
        //previousPageButton.transform = rotateLeft;
        [self.view addSubview:previousPageButton];
//        [self.view sendSubviewToBack:previousPageButton];
        
        //returnToMenuButton
        returnToMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        returnToMenuButton.frame = CGRectMake(0, 0, 90, 85);
        returnToMenuButton.showsTouchWhenHighlighted = YES;
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml.png"] forState:UIControlStateNormal];
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateHighlighted];
        [returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateSelected];
        returnToMenuButton.backgroundColor = [UIColor clearColor];
        [returnToMenuButton setCenter:CGPointMake(725.0f, 500.0f)];
        [returnToMenuButton addTarget:delegate action:@selector(overlayMenuPressed) forControlEvents:UIControlEventTouchUpInside];
        returnToMenuButton.enabled = YES;
        returnToMenuButton.hidden = NO;
        returnToMenuButton.alpha = 1.0;
        [returnToMenuButton retain];
//        returnToMenuButton.transform = rotateLeft;
        
        [self.view addSubview:returnToMenuButton];
//        [self.view sendSubviewToBack:returnToMenuButton];
        
        //voiceAssistButton - turn voice assist on and off
        voiceAssistButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceAssistButton.frame = CGRectMake(0, 0, 80, 80);
        voiceAssistButton.showsTouchWhenHighlighted = YES;
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_on.png"] forState:UIControlStateNormal];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
        voiceAssistButton.backgroundColor = [UIColor clearColor];
        [voiceAssistButton setCenter:CGPointMake(725.0f, 770.0f)];
        [voiceAssistButton addTarget:delegate action:@selector(overlayVoicePressed) forControlEvents:UIControlEventTouchUpInside];
        voiceAssistButton.enabled = YES;
        voiceAssistButton.hidden = NO;
        //        if (tbvc.speakItemsAloud) {
        //            voiceAssistButton.selected = NO;
        //        } else {
        //            voiceAssistButton.selected = YES;
        //        }
        voiceAssistButton.alpha = 1.0;
        [voiceAssistButton retain];
//        voiceAssistButton.transform = rotateLeft;
        
        [self.view addSubview:voiceAssistButton];
        
        //fontsizeButton - cycle through font size options
        fontsizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fontsizeButton.frame = CGRectMake(0, 0, 80, 80);
        fontsizeButton.showsTouchWhenHighlighted = YES;
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image.png"] forState:UIControlStateNormal];
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateSelected];
        fontsizeButton.backgroundColor = [UIColor clearColor];
        [fontsizeButton setCenter:CGPointMake(725.0f, 670.0f)];
        [fontsizeButton addTarget:delegate action:@selector(overlayFontsizePressed) forControlEvents:UIControlEventTouchUpInside];
        fontsizeButton.enabled = YES;
        fontsizeButton.hidden = NO;
        fontsizeButton.alpha = 1.0;
        [fontsizeButton retain];
//        fontsizeButton.transform = rotateLeft;
        
        [self.view addSubview:fontsizeButton];
        
//        [self.view bringSubviewToFront:fontsizeButton];
//        [self.view bringSubviewToFront:returnToMenuButton];
//        [self.view bringSubviewToFront:voiceAssistButton];
        
        NSLog(@"Finished creating dynamic button overlay with type: %@",@"Other");
    }
    
    return self;
}

- (void)activateDelegateOverlayPreviousPressed {
    [delegate overlayPreviousPressed];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] decrementProgressBar];
}

- (void)activateDelegateOverlayNextPressed {
    [delegate overlayNextPressed];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
}

- (void)readyForAppointmentButtonPressed {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showModalAreYouSureView];
}

- (void)fadeThisObjectIn:(id)thisObject {
    [self fadeThisView:thisObject toAlpha:1.0 afterSeconds:0.3];
}

- (void)fadeThisObjectOut:(id)thisObject {
    [self fadeThisView:thisObject toAlpha:0.0 afterSeconds:0.3];
}

- (void)fadeThisView:(UIView *)thisView toAlpha:(CGFloat)newAlpha afterSeconds:(double)fadeSeconds {
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:fadeSeconds];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        thisView.alpha = newAlpha;
		
	}
	[UIView commitAnimations];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    mViewController = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
