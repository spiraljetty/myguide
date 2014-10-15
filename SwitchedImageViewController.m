/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "SwitchedImageViewController.h"
#import "RootViewController_Pad.h"
#import "AppDelegate_Pad.h"
#import "DynamicModuleViewController_Pad.h"
#import "PhysicianViewController_Pad.h"
#import "DynamicSurveyViewController_Pad.h"
#import "SLGlowingTextField.h"
#import "DynamicContent.h"
#import "DynamicModuleViewController_Pad.h"
#import "WRViewController.h"

@implementation SwitchedImageViewController

@synthesize currentSatisfactionLabel, currentReplayButton, moviePlayerController, currentPromptLabel, hideNextButton, hidePreviousButton, module1Badge, module2Badge;

@synthesize imageDirectory, rotationView, currentPromptString;
@synthesize stronglyDisagreeButton, disagreeButton, agreeButton, stronglyAgreeButton, neutralButton, doesNotApplyButton;
@synthesize satisfactionRating;

@synthesize currentSurveyPageType, newDisagreeButton, newAgreeButton, newAgreeDisagreeLabel, newAgreeDisagreeText, newNoButton, newYesButton, newYesNoLabel, newYesNoText, provider1ImageButton, provider1TextButton, provider2ImageButton, provider2TextButton, provider3ImageButton, provider3TextButton, provider4ImageButton, provider4TextButton, provider5ImageButton, provider5TextButton, providerTestLabel, providerTestText, subclinic1TextButton, subclinic2TextButton, subclinic3TextButton, subclinic4TextButton, subclinic5TextButton, subclinicTestLabel, subclinicTestText, helpfulRating, goal1TextButton, goal2TextButton, goal3TextButton, goal4TextButton, goal5TextButton, goalChooseLabel, goalChooseText, goalRating, goalRateLabel, goalRateText, okButton, currentSatisfactionString;
@synthesize goal10Text, goal10TextButton, goal9Text,goal9TextButton,goal8Text,goal8TextButton,goal7Text,goal7TextButton,goal6Text,goal6TextButton,goalsSelected;
@synthesize provider1ImageThumb, provider2ImageThumb, provider3ImageThumb, provider4ImageThumb;
@synthesize delegate, surveyPageIndex, isSurveyPage;
@synthesize provider1Text, provider2Text, provider3Text, provider4Text, subclinic1Text, subclinic2Text, subclinic3Text, subclinic4Text, goal1Text, goal2Text, goal3Text, goal4Text, goal5Text, helpfulLabel, helpfulText, extraNoLabel, extraNoText, extraYesLabel, extraYesText;
@synthesize module1Button, module2Button, module3Button, module4Button, chooseModuleLabel, chooseModuleText, extraModule1Label, extraModule1Text, extraModule2Label, extraModule2Text, enterGoalTextField, userEnteredGoalText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"In SwitchedImageViewController initWithNibName...");
        surveyPageIndex = -1;
        
        goalsSelected = -1;
        
        isSurveyPage = YES;
        hidePreviousButton = NO;
        hideNextButton = NO;
        
        userEnteredGoalText = @"";
    }
    return self;
}

-(id)initWithImageDirecotry:(NSString *)directoryName
{
    
    self = [self init];
    
    if (self) {
        
        if (directoryName != nil) {
            
            self.imageDirectory = directoryName;
            
        }else
        {
            NSLog(@"Error: Directory Name must not be nil.");
        }
        
    }
    
    return self;
}

- (void)uniqueRotationViewSetup {
    rotationView = [[RVRotationView alloc] initWithFrame:self.view.bounds];
    
    rotationView.delegate = self;
    
    [rotationView loadAnimationFromDirectory:self.imageDirectory];
    
    self.view = rotationView;
    
    //[rotationView displayImageWithPosition:0];
    
    
    rotateLeftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rotateLeftButton addTarget:self action:@selector(pressedRotateLeftButton) forControlEvents:UIControlEventTouchUpInside];
    [rotateLeftButton setTitle:@"<<" forState:UIControlStateNormal];
    rotateLeftButton.frame = CGRectMake(5, 5, 50, 40);
    [self.view addSubview:rotateLeftButton];
    
    startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton addTarget:self action:@selector(pressedStartButton) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"Play" forState:UIControlStateNormal];
    startButton.frame = CGRectMake(60, 5, 50, 40);
    [self.view addSubview:startButton];
    
    stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopButton addTarget:self action:@selector(pressedEndButton) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    stopButton.frame = CGRectMake(115, 5, 50, 40);
    [self.view addSubview:stopButton];
    
    rotateRightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rotateRightButton addTarget:self action:@selector(pressedRotateRightButton) forControlEvents:UIControlEventTouchUpInside];
    [rotateRightButton setTitle:@">>" forState:UIControlStateNormal];
    rotateRightButton.frame = CGRectMake(170, 5, 50, 40);
    [self.view addSubview:rotateRightButton];
    
    UILabel *decLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 5, 60, 13)];
    decLabel.textAlignment = UITextAlignmentCenter;
    decLabel.textColor = [UIColor lightGrayColor];
    decLabel.backgroundColor = [UIColor clearColor];
    decLabel.text = @"Decelerate";
    decLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:decLabel];
    [decLabel release];
    
    
    
    UISwitch *decelerationSwith = [[UISwitch alloc] initWithFrame:CGRectMake(220, 18, 76, 40)];
    [decelerationSwith addTarget:self action:@selector(decelerationSwitchChanges:) forControlEvents:UIControlEventValueChanged];
    decelerationSwith.on = YES;
    [self.view addSubview:decelerationSwith];
    [decelerationSwith release];
    
    rotationSpeedSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 50, 230, 30)];
    [rotationSpeedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    rotationSpeedSlider.minimumValue = 1;
    rotationSpeedSlider.maximumValue = 20;
    rotationSpeedSlider.value = 10;
    [self.view addSubview:rotationSpeedSlider];
    [rotationSpeedSlider release];
}

-(void)reloadImages
{
    
    
    
}

- (void)showModule1Badge {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        module1Badge.alpha = 1.0;
        
        
    }
    [UIView commitAnimations];
}

- (void)showModule2Badge {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        module2Badge.alpha = 1.0;
        
        
    }
    [UIView commitAnimations];
}

-(void)decelerationSwitchChanges:(id)sender
{
    
    NSLog(@"switch changes to %i", ((UISwitch *)sender).on);
    
    rotationView.decelerateAnimation = ((UISwitch *)sender).on;
}

-(void)pressedStartButton
{
    NSLog(@"Pressed Start");
    
    [rotationView startRotationAnimationWithDirection:RVRotationViewDirectionRight];
}

-(void)pressedEndButton
{
    NSLog(@"Pressed End");
    
    [rotationView stopRotationAnimation];
}

-(void)pressedRotateLeftButton
{
    NSLog(@"Pressed Rotate Left");
    
    [rotationView rotateLeft];
    
    if (rotationView.isAnimating) {
        rotationView.animationDirection = RVRotationViewDirectionLeft;
        
    }
}

-(void)pressedRotateRightButton
{
    NSLog(@"Pressed Rotate Right");
    
    [rotationView rotateRight];
    
    if (rotationView.isAnimating) {
        rotationView.animationDirection = RVRotationViewDirectionRight;
    }
}

-(void)sliderValueChanged:(id)sender
{
    NSLog(@"Slider Value %i",(int)((UISlider *)sender).value);
    
    rotationView.animationSpeed = (int)((UISlider *)sender).value;
}

-(void)rotationViewDidStartDedemocelerating:(RVRotationView *)rotationView
{
    NSLog(@"Rotation View did start decelerating");
}

-(void)rotationViewDidStopDecelerating:(RVRotationView *)rotationView
{
    NSLog(@"Rotation View did stop decelerating");
}

-(void)rotationViewDidStartAnimating:(RVRotationView *)rotationView
{
    NSLog(@"Rotation View did start animating");
}

-(void)rotationViewDidStopAnimating:(RVRotationView *)rotationView
{
    NSLog(@"Rotation View did stop animating");
}


- (void) switchChanged: (UISwitch *) aSwitch
{
    iv.alpha = aSwitch.isOn ? 1.0f : 0.5f;
}

-(void)segmentedControlIndexChanged:(UISegmentedControl *)aControl {
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:aControl.selectedSegmentIndex];
        
        [self segmentedControlPressedWithIndex:aControl.selectedSegmentIndex];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:aControl.selectedSegmentIndex];
        
        DynamicSurveyViewController_Pad *currentDelegate = delegate;
        [currentDelegate overlayNextPressed];
    }
    
}

-(void)stronglyDisagreeFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.stronglyDisagreeFaceButtonPressed() Strongly disagree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 0;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
    
}

-(void)disagreeFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.disagreeFaceButtonPressed() Disagree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 1;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)agreeFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.agreeFaceButtonPressed() Agree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 3;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)stronglyAgreeFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.stronglyAgreeFaceButtonPressed() Strongly agree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 4;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)neutralFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.neutralFaceButtonPressed() Neutral pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 2;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}
//removed from surveys in build 2.0.0
-(void)doesNotApplyFaceButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.doesNotApplyFaceButtonPressed() Does not apply pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 5;
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}


- (void)faceButtonPressed:(id)sender {
    
    NSLog(@"SwitchedImageViewController.faceButtonPressed() Face button pressed...");
    
    UIButton *resultButton = (UIButton *)sender;
    //    NSLog(@" The button's title is %@." resultButton.currentTitle);
    
    int segmentedControlEquivalentIndexSelected;
    
    if ([sender isEqual:stronglyDisagreeButton]) {
        NSLog(@"Strongly disagree pressed...");
        stronglyDisagreeButton.alpha = 1.0;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
        segmentedControlEquivalentIndexSelected = 0;
    } else if (sender == disagreeButton) {
        segmentedControlEquivalentIndexSelected = 1;
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 1.0;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (sender == neutralButton) {
        segmentedControlEquivalentIndexSelected = 2;
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 1.0;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (sender == agreeButton) {
        segmentedControlEquivalentIndexSelected = 3;
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 1.0;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (sender == stronglyAgreeButton) {
        segmentedControlEquivalentIndexSelected = 4;
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 1.0;
        doesNotApplyButton.alpha = 0.7;
    } else {
        segmentedControlEquivalentIndexSelected = 5;
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 1.0;
    }
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] satisfactionSurveyInProgress]) {
        // Store rating to db for satisfaction question
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    } else {
        /* sandy 7-16 make template conditional hack */
        int currentpageVCIndex = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] vcIndex];
        
        NSLog(@"SwitchedImageViewController.faceButtonPressed() uses storyboard survey_NEW_painscale_template or noprompt if subsequent session vcIndex = %d",currentpageVCIndex);
        UIStoryboard *painScaleStoryboard = NULL;
        if( currentpageVCIndex== 11)
          painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_template" bundle:[NSBundle mainBundle]];
       else
            painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_noprompt_template" bundle:[NSBundle mainBundle]];
//        UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_template" bundle:[NSBundle mainBundle]];
        SwitchedImageViewController *tempSurveyPage = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        
        
        // Store rating for dynamic survey item
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:segmentedControlEquivalentIndexSelected];
    }
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    [currentDelegate overlayNextPressed];
    
    //    satisfactionRating.selectedSegmentIndex = segmentedControlEquivalentIndexSelected;
}

- (void)segmentedControlPressedWithIndex:(int)segmentedControlIndex {
    //This is called for the post-treatment satisfaction survey
    NSLog(@"SwitchedImageViewController.segmentedControlPressedWithIndex() index: %d", segmentedControlIndex);
    if (segmentedControlIndex == 0) {
        stronglyDisagreeButton.alpha = 1.0;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (segmentedControlIndex == 1) {
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 1.0;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (segmentedControlIndex == 2) {
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 1.0;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (segmentedControlIndex == 3) {
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 1.0;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 0.7;
    } else if (segmentedControlIndex == 4) {
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 1.0;
        doesNotApplyButton.alpha = 0.7;
    } else {
        stronglyDisagreeButton.alpha = 0.7;
        disagreeButton.alpha = 0.7;
        neutralButton.alpha = 0.7;
        agreeButton.alpha = 0.7;
        stronglyAgreeButton.alpha = 0.7;
        doesNotApplyButton.alpha = 1.0;
    }
    
    int currentVCIndex = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] vcIndex];
    
    UISegmentedControl *currentlyActiveSegmentedControl = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] currentActiveSegmentedControlForIndex:currentVCIndex];
    
    currentlyActiveSegmentedControl.selectedSegmentIndex = segmentedControlIndex;
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    if (rootViewController != NULL)
        [rootViewController showNextSurveyPage];
   // [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] regress:self];
    
}



-(void)pressedSatisfactionReplayButton:(id)sender {
    NSLog(@"Pressed replay button");
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] replayCurrentSatisfactionSound];
}

- (void)updateSatisfactionPromptLabelWithString:(NSString*)newText {
    
    currentPromptLabel.text = newText;
    
}

-(IBAction)playMovie:(id)sender
{
	UIButton *playButton = (UIButton *) sender;
	
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"what_is_tbi" ofType:@"mp4"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackComplete:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	[moviePlayerController.view setFrame:CGRectMake(playButton.frame.origin.x,
													playButton.frame.origin.y,
													playButton.frame.size.width,
													playButton.frame.size.height)];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //    moviePlayerController.view.transform = rotateRight;
    
	[self.view addSubview:moviePlayerController.view];
    //moviePlayerController.fullscreen = YES;
	
	//moviePlayerController.scalingMode = MPMovieScalingModeFill;
	
    [moviePlayerController play];
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:YES];
}

-(IBAction)playSecondMovie:(id)sender
{
	UIButton *playButton = (UIButton *) sender;
	
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"mTBI" ofType:@"mp4"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackComplete:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	[moviePlayerController.view setFrame:CGRectMake(playButton.frame.origin.x,
													playButton.frame.origin.y,
													playButton.frame.size.width,
													playButton.frame.size.height)];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //    moviePlayerController.view.transform = rotateRight;
    
	[self.view addSubview:moviePlayerController.view];
    //moviePlayerController.fullscreen = YES;
	
	//moviePlayerController.scalingMode = MPMovieScalingModeFill;
	
    [moviePlayerController play];
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:YES];
}

-(IBAction)playThirdMovie:(id)sender
{
	UIButton *playButton = (UIButton *) sender;
	
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"anatomy_brain" ofType:@"mp4"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackComplete:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	[moviePlayerController.view setFrame:CGRectMake(playButton.frame.origin.x,
													playButton.frame.origin.y,
													playButton.frame.size.width,
													playButton.frame.size.height)];
    
    
    //    moviePlayerController.view.transform = rotateRight;
    
	[self.view addSubview:moviePlayerController.view];
    //moviePlayerController.fullscreen = YES;
	
	//moviePlayerController.scalingMode = MPMovieScalingModeFill;
	
    [moviePlayerController play];
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:YES];
}

-(IBAction)playFourthMovie:(id)sender
{
	UIButton *playButton = (UIButton *) sender;
	
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"lobe_functions" ofType:@"mp4"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackComplete:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	[moviePlayerController.view setFrame:CGRectMake(playButton.frame.origin.x,
													playButton.frame.origin.y,
													playButton.frame.size.width,
													playButton.frame.size.height)];
    
    
    //    moviePlayerController.view.transform = rotateRight;
    
	[self.view addSubview:moviePlayerController.view];
    //moviePlayerController.fullscreen = YES;
	
	//moviePlayerController.scalingMode = MPMovieScalingModeFill;
	
    [moviePlayerController play];
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:YES];
}

-(IBAction)stopMovie:(id)sender
{
    NSLog(@"SwitchedImageViewController.stopMovie()");
    [moviePlayerController stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayerController];
    @try {
//       [moviePlayerController.view removeFromSuperview]; //rjl 6/29/14 this line caused flaky crash
    }
    @catch(NSException *ne){
        NSLog(@"SwitchedImageViewController.stopMovie() ERROR");
    }
    @finally {
        NSLog(@"SwitchedImageViewController.stopMovie() try/catch/finally");
    }
    //    [moviePlayerController release];
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:NO];
    
}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModule] setPlayingMovie:NO];
    
    MPMoviePlayerController *thisMoviePlayerController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:thisMoviePlayerController];
	
    [thisMoviePlayerController.view removeFromSuperview];
    [thisMoviePlayerController release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // NSLog(@"SwitchedImageViewController.viewDidLoad()");
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    iv.alpha = 0.5f;
    
    if (isSurveyPage) {
        
        if (currentReplayButton) {
            currentReplayButton.alpha = 0.0;
        }
        
        switch (currentSurveyPageType) {
            case kOk:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for ok survey page with index=%d...", surveyPageIndex);
                currentPromptLabel.text = currentPromptString;
                break;
            case kAgreementPainScale:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for agreement-painscale survey page with index=%d...", surveyPageIndex);
                NSLog(@"SwitchedImageViewController.viewDidLoad() sandy Verify that this is new_painscale_template and set fontsize here");
                currentPromptLabel.text = currentPromptString;
                currentSatisfactionLabel.text = currentSatisfactionString;
                break;
            case kAgreeDisagree:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for agree-disagree survey page with index=%d...", surveyPageIndex);
                //    IBOutlet UIButton *newDisagreeButton;
                //    IBOutlet UIButton *newAgreeButton;
                
                currentPromptLabel.text = currentPromptString;
                newAgreeDisagreeLabel.text = newAgreeDisagreeText;
                
                //    IBOutlet NSString *newAgreeDisagreeText;
                break;
            case kYesNo:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for yes-no survey page with index=%d...", surveyPageIndex);
                //    // Yes-No iVars
                //    IBOutlet UIButton *newNoButton;
                //    IBOutlet UIButton *newYesButton;
                
                //                currentPromptLabel.text = currentPromptString;
                newYesNoLabel.text = newYesNoText;
                extraNoLabel.text = extraNoText;
                extraYesLabel.text = extraYesText;
                //    IBOutlet NSString *newYesNoText;
                break;
            case kProviderTest:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for provider-test survey page with index=%d...", surveyPageIndex);
                //    // Provider Test iVars
                //    provider1ImageThumb, provider2ImageThumb, provider3ImageThumb, provider4ImageThumb
//                NSArray *allClinicPhysicians = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians]; // original (hardcoded) list of clinicians
//                NSMutableArray *allPhysicianNames = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysicians];
//                int currentPhysicianIndex = [allPhysicianNames indexOfObject:thisCellText];
//                if (currentPhysicianIndex < [allClinicPhysicians count]){
//                    // if index is for original hardcoded clinician then get thumb image from plist in hidden folder
//                    NSArray *allPhysicianThumbs = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs];
//                    NSString *imageToLoad = [NSString stringWithFormat:@"%@",[allPhysicianThumbs objectAtIndex:currentPhysicianIndex]];
//                    NSLog(@"PhysicianCellViewController.cellForItemAtIndexPath() imageToLoad: %@", imageToLoad);
//                    cell.image.image = [UIImage imageNamed:imageToLoad];
//                }
//                else {
//                    // if index is for new (not hardcoded) clinician then get thumb image from documents directory
//                    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                    NSString  *documentsDirectory = [paths objectAtIndex:0];
//                    ClinicianInfo *currentClinician =
//                    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController]
//                     getClinician:currentPhysicianIndex];
//                    if (currentClinician){
//                        NSString *filename = [currentClinician getImageFilename];
//                        cell.image.image = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] loadImage:filename];
//                    }
//                }
                
                // get provider 1 image and text
                UIImage* image = [UIImage imageNamed:provider1ImageThumb];
                if (!image)
                    image = [DynamicContent loadImage:provider1ImageThumb];
                [provider1ImageButton setImage:image forState:UIControlStateNormal];
                [provider1ImageButton setContentMode: UIViewContentModeScaleAspectFit];
                provider1ImageButton.clipsToBounds = YES;
                provider1ImageButton.adjustsImageWhenHighlighted;
                
                //get provider 2 image and text
                image = [UIImage imageNamed:provider2ImageThumb];
                if (!image)
                    image = [DynamicContent loadImage:provider2ImageThumb];
                [provider2ImageButton setImage:image forState:UIControlStateNormal];
                provider2ImageButton.adjustsImageWhenHighlighted;
                
                // get provider 3 image and text
                image = [UIImage imageNamed:provider3ImageThumb];
                if (!image)
                    image = [DynamicContent loadImage:provider3ImageThumb];
                [provider3ImageButton setImage:image forState:UIControlStateNormal];
                provider3ImageButton.adjustsImageWhenHighlighted;
                
                // get provider 4 image and text
                image = [UIImage imageNamed:provider4ImageThumb];
                if (!image)
                    image = [DynamicContent loadImage:provider4ImageThumb];
                [provider4ImageButton setImage:image forState:UIControlStateNormal];
                provider4ImageButton.adjustsImageWhenHighlighted;
                
                provider5ImageButton.adjustsImageWhenHighlighted;
                
                //                provider1Text, provider2Text, provider3Text, provider4Text,
                
                //                provider1TextButton.titleLabel.text = provider1Text;
                //                provider2TextButton.titleLabel.text = provider2Text;
                //                provider3TextButton.titleLabel.text = provider3Text;
                //                provider4TextButton.titleLabel.text = provider4Text;
                
                [provider1TextButton setTitle:provider1Text forState:UIControlStateNormal];
                [provider2TextButton setTitle:provider2Text forState:UIControlStateNormal];
                [provider3TextButton setTitle:provider3Text forState:UIControlStateNormal];
                [provider4TextButton setTitle:provider4Text forState:UIControlStateNormal];
                
                //    IBOutlet UIButton *provider1TextButton;
                //    IBOutlet UIButton *provider2ImageButton;
                //    IBOutlet UIButton *provider2TextButton;
                //    IBOutlet UIButton *provider3ImageButton;
                //    IBOutlet UIButton *provider3TextButton;
                //    IBOutlet UIButton *provider4ImageButton;
                //    IBOutlet UIButton *provider4TextButton;
                //    IBOutlet UILabel *providerTestLabel;
                
                providerTestLabel.text = providerTestText;
                
                //    IBOutlet NSString *providerTestText;
                break;
            case kSubclinicTest:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for subclinic-test survey page with index=%d...", surveyPageIndex);
                //    // Subclinic Test iVars
                //                subclinic1Text, subclinic2Text, subclinic3Text, subclinic4Text,
                
                NSLog(@"SwitchedImageViewController.viewDidLoad() subclinic1Text=%@\nsubclinic2Text=%@\nsubclinic3Text=%@\nsubclinic4Text=%@",subclinic1Text,subclinic2Text,subclinic3Text,subclinic4Text);
                
                //                subclinic1TextButton.titleLabel.text = subclinic1Text;
                [subclinic1TextButton setTitle:subclinic1Text forState:UIControlStateNormal];
                [subclinic2TextButton setTitle:subclinic2Text forState:UIControlStateNormal];
                [subclinic3TextButton setTitle:subclinic3Text forState:UIControlStateNormal];
                [subclinic4TextButton setTitle:subclinic4Text forState:UIControlStateNormal];
                
                //    IBOutlet UIButton *subclinic1TextButton;
                //    IBOutlet UIButton *subclinic2TextButton;
                //    IBOutlet UIButton *subclinic3TextButton;
                //    IBOutlet UIButton *subclinic4TextButton;
                //    IBOutlet UILabel *subclinicTestLabel;
                
                subclinicTestLabel.text = subclinicTestText;
                
                //    IBOutlet NSString *subclinicTestText;
                break;
            case kHelpfulPainScale:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for helpful-painscale survey page with index=%d...", surveyPageIndex);
                //    // Helpful iVars
                //    IBOutlet UISegmentedControl *helpfulRating;
                
                //                currentPromptLabel.text = currentPromptString;
                helpfulLabel.text = helpfulText;
                
                //                UILabel *currentPromptLabel;
                //                NSString *currentPromptString;
                break;
            case kChooseGoal:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for choose-goal survey page with index=%d...", surveyPageIndex);
                // Choose Goal iVars
                //                goal1Text, goal2Text, goal3Text, goal4Text;
                NSLog(@"SwitchedImageViewController.viewDidLoad() goal1Text=%@\ngoal2Text=%@\ngoal3Text=%@\ngoal4Text=%@\ngoal5Text=%@",goal1Text,goal2Text,goal3Text,goal4Text,goal5Text);
                
                NSString *currentRespondent = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] respondentType];
                // sandy 7-20 removed the word doctor and replaced it with provider
//                GoalInfo* goalInfo = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getGoalInfo];
                    NSString* selectedClinic = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName];
                GoalInfo* goalInfo = [DynamicContent getGoalsForClinic:[DynamicContent getCurrentClinic]];
                if (goalInfo != NULL){
                    goal1Text = @"";
                    goal2Text = @"";
                    goal3Text = @"";
                    goal4Text = @"";
                    goal5Text = @"";
                    goal6Text = @"";
                    goal7Text = @"";
                    goal8Text = @"";
                    goal9Text = @"";
                    goal10Text = @"";
                    NSArray* goals = NULL;
                    if ([currentRespondent isEqualToString:@"family"])
                        goals = [goalInfo getFamilyGoals];
                    else
                    if ([currentRespondent isEqualToString:@"caregiver"])
                        goals = [goalInfo getCaregiverGoals];
                    else
                        goals = [goalInfo getSelfGoals];
                    if (goals != NULL){
                        int count = [goals count];
                        if (count == 1){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = @"Enter my own goal...";
                            goal3Text = @"None of the Above";
                        }
                        else
                        if (count == 2){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = @"Enter my own goal...";
                            goal4Text = @"None of the Above";
                        }
                        else
                        if (count == 3){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = @"Enter my own goal...";
                            goal5Text = @"None of the Above";
                        }
                        else
                        if (count == 4){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = [goals objectAtIndex:3];
                            goal5Text = @"Enter my own goal...";
                            goal6Text = @"None of the Above";
                        }
                        else
                        if (count == 5){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = [goals objectAtIndex:3];
                            goal5Text = [goals objectAtIndex:4];
                            goal6Text = @"Enter my own goal...";
                            goal7Text = @"None of the Above";
                        }
                        else
                        if (count == 6){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = [goals objectAtIndex:3];
                            goal5Text = [goals objectAtIndex:4];
                            goal6Text = [goals objectAtIndex:5];
                            goal7Text = @"Enter my own goal...";
                            goal8Text = @"None of the Above";
                        }
                        else
                        if (count == 7){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = [goals objectAtIndex:3];
                            goal5Text = [goals objectAtIndex:4];
                            goal6Text = [goals objectAtIndex:5];
                            goal7Text = [goals objectAtIndex:6];
                            goal8Text = @"Enter my own goal...";
                            goal9Text = @"None of the Above";
                        }
                        else
                        if (count == 8){
                            goal1Text = [goals objectAtIndex:0];
                            goal2Text = [goals objectAtIndex:1];
                            goal3Text = [goals objectAtIndex:2];
                            goal4Text = [goals objectAtIndex:3];
                            goal5Text = [goals objectAtIndex:4];
                            goal6Text = [goals objectAtIndex:5];
                            goal7Text = [goals objectAtIndex:6];
                            goal8Text = [goals objectAtIndex:7];
                            goal9Text = @"Enter my own goal...";
                            goal10Text = @"None of the Above";
                        }
                    } // if goals != null
                } // if goalInfo != null
                else { // use default goals for caregiver and family
                    if ([currentRespondent isEqualToString:@"caregiver"]){
                        // use default caregiver goals
                        goal1Text = @"Reduce my patient's pain";
                        goal2Text = @"Help my patient sleep better";
                        goal3Text = @"Help my patient be more active";
                        goal4Text = @"Talk to my patient's treatment provider";
                        goal5Text = @"Help my patient have more energy";
                        goal6Text = @"Get my patient's tests done";
                        goal7Text = @"Help my patient feel healthy";
                        goal8Text = @"Get my patient's next treatment";
                        goal9Text = @"Enter my own goal...";
                        goal10Text = @"None of the above";
                    }
                    else
                    if ([currentRespondent isEqualToString:@"family"]) {
                        goal1Text = @"Reduce my family member's pain";
                        goal2Text = @"Help my family member sleep better";
                        goal3Text = @"Help my family member be more active";
                        goal4Text = @"Talk to my family member's provider";
                        goal5Text = @"Help my family megoalmber have more energy";
                        goal6Text = @"Get my family member's tests done";
                        goal7Text = @"Help my family member feel healthy";
                        goal8Text = @"Get my family member's next treatment";
                        goal9Text = @"Enter my own goal...";
                        goal10Text= @"None of the above";
                    }
                }
        
                [goal1TextButton setTitle:goal1Text forState:UIControlStateNormal];
                [goal2TextButton setTitle:goal2Text forState:UIControlStateNormal];
                [goal3TextButton setTitle:goal3Text forState:UIControlStateNormal];
                [goal4TextButton setTitle:goal4Text forState:UIControlStateNormal];
                [goal5TextButton setTitle:goal5Text forState:UIControlStateNormal];
                [goal6TextButton setTitle:goal6Text forState:UIControlStateNormal];
                [goal7TextButton setTitle:goal7Text forState:UIControlStateNormal];
                [goal8TextButton setTitle:goal8Text forState:UIControlStateNormal];
                [goal9TextButton setTitle:goal9Text forState:UIControlStateNormal];
                [goal10TextButton setTitle:goal10Text forState:UIControlStateNormal];
                
                
                goalChooseLabel.text = goalChooseText;
                
                break;
            case kRateGoalPainScale:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for rate-goal-painscale survey page with index=%d...", surveyPageIndex);
                //
                //    // Rate Goal iVars
                //    IBOutlet UISegmentedControl *goalRating;
                
                currentPromptLabel.text = currentPromptString;
                goalRateLabel.text = goalRateText;
                
                //    IBOutlet UILabel *goalRateLabel;
                //    IBOutlet NSString *goalRateText;
                break;
            case kGeneralSurveyPage:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for general survey page with index=%d...", surveyPageIndex);
                
                currentPromptLabel.text = currentPromptString;
                
                //                UILabel *currentPromptLabel;
                //                NSString *currentPromptString;
                break;
            case kChooseModule:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for choose module survey page with index=%d...", surveyPageIndex);
                chooseModuleLabel.text = chooseModuleText;
                extraModule1Label.text = extraModule1Text;
                extraModule2Label.text = extraModule2Text;
              
                WRViewController* wrvc = [WRViewController getViewController];
                if (wrvc != NULL)
                    //WRViewController* wrvc = [WRViewController getViewController];
                    [wrvc storeCurrentUXTimeForPreTreatment];  // sandy 10-14-14 this is a hack that this is called here - cant find actual start
                
                //                module1Button, module2Button, chooseModuleLabel, chooseModuleText, extraModule1Label, extraModule1Text, extraModule2Label, extraModule2Text;
                break;
            case kEnterGoal:
                NSLog(@"SwitchedImageViewController.viewDidLoad() Loading view content for enter goal survey page with index=%d...", surveyPageIndex);
                
//                currentPromptLabel.text = currentPromptString;
                
                //                UILabel *currentPromptLabel;
                //                NSString *currentPromptString;
                break;
            default:
                break;
        }
        
    } else {
        //        NSLog(@"NEED TO SET SURVEY PAGE TYPE TO LOAD CONTENT DYNAMICALLY");
    }
}

- (void)doneEnteringGoal:(id)sender {
    NSLog(@"doneEnteringGoal...");
    [enterGoalTextField endEditing:YES];
    [self storeAndUpdateEnteredGoal];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideModalEnterGoalView];
}

- (void)agreeButtonPressed:(id)sender {
    NSLog(@"agreeButtonPressed...");
}


- (void)disagreeButtonPressed:(id)sender {
    NSLog(@"disagreeButtonPressed...");
}

- (void)okButtonPressed:(id)sender {
    NSLog(@"okButtonPressed...");
    
    //    DynamicModuleViewController_Pad *currentDelegate = delegate;
    [delegate dismissCurrentModalVC];
}

- (void)yesButtonPressed:(id)sender {
    NSLog(@"yesButtonPressed...");
    [delegate modalYesPressedInSender:self];
}


- (void)noButtonPressed:(id)sender {
    NSLog(@"noButtonPressed...");
    [delegate modalNoPressedInSender:self];
}

- (void)doHighlight:(UIButton*)b {
    NSLog(@"selected %@",b.titleLabel.text);
    [b setHighlighted:YES];
    [b setSelected:YES];
}

- (void)removeHighlight:(UIButton*)b {
    NSLog(@"unselected %@",b.titleLabel.text);
    [b setHighlighted:NO];
    [b setSelected:NO];
}

- (void)goal1ButtonPressed:(id)sender {
    NSLog(@"goal1ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal1TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal1TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 1;
    
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
//    [thisDelegate overlayNextPressed];
   // [thisDelegate showOverlayNextButton];
    
    if (goal1TextButton.highlighted) {
        goal1TextButton.highlighted = NO;
    } else {
        goal1TextButton.highlighted = YES;
    }
        //    [thisDelegate overlayNextPressed];
    //[thisDelegate showOverlayNextButton];

    
    if (!goal1TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal1TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal1TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
    
}


- (void)goal2ButtonPressed:(id)sender {
    NSLog(@"goal2ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal2TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal2TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 2;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //[thisDelegate showOverlayNextButton];
    
    if (goal2TextButton.highlighted) {
        goal2TextButton.highlighted = NO;
    } else {
        goal2TextButton.highlighted = YES;
    }

    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    //[thisDelegate showOverlayNextButton];
    
    if (!goal2TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal2TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal2TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
}


- (void)goal3ButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.goal3ButtonPressed()");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal3TextButton.titleLabel.text;
    NSLog(@"SwitchedImageViewController.goal3ButtonPressed() todaysGoal set to: %@...", goal3TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 3;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal3TextButton.highlighted) {
        goal3TextButton.highlighted = NO;
    } else {
        goal3TextButton.highlighted = YES;
    }
    
    if (!goal3TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal3TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal3TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];

}


- (void)goal4ButtonPressed:(id)sender {
    NSLog(@"goal4ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal4TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal4TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 4;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal4TextButton.highlighted) {
        goal4TextButton.highlighted = NO;
    } else {
        goal4TextButton.highlighted = YES;
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    [thisDelegate showOverlayNextButton];
    
    if (!goal4TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal4TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal4TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
    
}

- (void)goal5ButtonPressed:(id)sender {
    NSLog(@"goal5ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal5TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal5TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 5;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    //[thisDelegate showOverlayNextButton];
    
    if (goal5TextButton.highlighted) {
        goal5TextButton.highlighted = NO;
    } else {
        goal5TextButton.highlighted = YES;
    }

    
    if (!goal5TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal5TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal5TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
}

- (void)goal6ButtonPressed:(id)sender {
    NSLog(@"goal6ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal6TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal6TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 6;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal6TextButton.highlighted) {
        goal6TextButton.highlighted = NO;
    } else {
        goal6TextButton.highlighted = YES;
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    [thisDelegate showOverlayNextButton];
    
    if (!goal6TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal6TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal6TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
}

- (void)goal7ButtonPressed:(id)sender {
    NSLog(@"goal7ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal7TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal7TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 7;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal7TextButton.highlighted) {
        goal7TextButton.highlighted = NO;
    } else {
        goal7TextButton.highlighted = YES;
    }

    
    //    [thisDelegate overlayNextPressed];
    [thisDelegate showOverlayNextButton];
    
    if (!goal7TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal7TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal7TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
}

- (void)goal8ButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.goal8ButtonPressed() ");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal8TextButton.titleLabel.text;
    NSLog(@"SwitchedImageViewController.goal8ButtonPressed() todaysGoal set to: %@...", goal8TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 8;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal8TextButton.highlighted) {
        goal8TextButton.highlighted = NO;
    } else {
        goal8TextButton.highlighted = YES;
    }

    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    [thisDelegate showOverlayNextButton];
    
    if (!goal8TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal8TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal8TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
    NSLog(@"SwitchedImageViewController.goal8ButtonPressed() exit");

}

- (void)goal9ButtonPressed:(id)sender {
    NSLog(@"goal9ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal9TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal9TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 9;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
//    [thisDelegate showOverlayNextButton];
    
    if (goal9TextButton.highlighted) {
        goal9TextButton.highlighted = NO;
    } else {
        goal9TextButton.highlighted = YES;
    }
    
    if (!goal9TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal9TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal9TextButton afterDelay:0];
    }
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showModalEnterGoalView];    
    
}

- (void)goal10ButtonPressed:(id)sender {
    NSLog(@"goal10ButtonPressed...");
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    thisDelegate.todaysGoal = goal10TextButton.titleLabel.text;
    NSLog(@"todaysGoal set to: %@...", goal10TextButton.titleLabel.text);
    
    [thisDelegate updateGoalRatingText];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 10;
    if (goalsSelected == -1) {
        goalsSelected = thisEquivalentSegmentIndex;
    } else {
        goalsSelected = [[NSString stringWithFormat:@"%d%d",goalsSelected,thisEquivalentSegmentIndex] intValue];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
   // [thisDelegate showOverlayNextButton];
    
    if (goal10TextButton.highlighted) {
        goal10TextButton.highlighted = NO;
    } else {
        goal10TextButton.highlighted = YES;
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:goalsSelected];
    
    //    [thisDelegate overlayNextPressed];
    [thisDelegate showOverlayNextButton];
    
    if (!goal10TextButton.selected) {
        [self performSelector:@selector(doHighlight:) withObject:goal10TextButton afterDelay:0];
    } else {
        [self performSelector:@selector(removeHighlight:) withObject:goal10TextButton afterDelay:0];
    }
    [thisDelegate overlayNextPressed];
}

- (void)storeAndUpdateEnteredGoal {
//    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] dynamicSurveyModule] newChildControllers] objectAtIndex:[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] dynamicSurveyModule] vcIndex]];
    
    userEnteredGoalText = [enterGoalTextField.text copy];
    [DynamicContent speakText:userEnteredGoalText];

    [thisSurveyPage.goal9TextButton setTitle:userEnteredGoalText forState:UIControlStateNormal];
    [thisSurveyPage.goal9TextButton setTitle:userEnteredGoalText forState:UIControlStateHighlighted];
    [thisSurveyPage.goal9TextButton setTitle:userEnteredGoalText forState:UIControlStateDisabled];
    [thisSurveyPage.goal9TextButton setTitle:userEnteredGoalText forState:UIControlStateSelected];
    [thisSurveyPage.goal9TextButton setEnabled:NO];
    
    enterGoalTextField.text = @"";
    
//    [goal9TextButton setTitle:enterGoalTextField.text forState:UIControlStateNormal];
//    [goal9TextButton setTitle:enterGoalTextField.text forState:UIControlStateHighlighted];
//    [goal9TextButton setTitle:enterGoalTextField.text forState:UIControlStateDisabled];
//    [goal9TextButton setTitle:enterGoalTextField.text forState:UIControlStateSelected];
    
//    [goal9TextButton setEnabled:NO];
    
    NSLog(@"Storing and updating user entered goal: %@",userEnteredGoalText);
// 9_17_14 sandy
   NSLog(@"Attempting to store user typed goal to db: %@...",userEnteredGoalText);
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    if (rootViewController != NULL)
        [rootViewController updateSurveyTextForField:@"goaltyped" withThisText:[NSString stringWithFormat:@"%@",userEnteredGoalText]];
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    [thisDelegate overlayNextPressed];
}



- (void)disableAllProviderButtons {
    provider1ImageButton.enabled = NO;
    provider2ImageButton.enabled = NO;
    provider3ImageButton.enabled = NO;
    provider4ImageButton.enabled = NO;
    provider5ImageButton.enabled = NO;
    
    provider1TextButton.enabled = NO;
    provider2TextButton.enabled = NO;
    provider3TextButton.enabled = NO;
    provider4TextButton.enabled = NO;
    provider5TextButton.enabled = NO;
}


- (void)provider1ButtonPressed:(id)sender {
    NSLog(@"provider1ButtonPressed...");
//    [self disableAllProviderButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 1;
    [self providerButtonVerification:thisEquivalentSegmentIndex];
   // [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //sandy 10-13-14t emp uncomment to check for how the provider test is being validated
    //[currentDelegate showModalProviderTestCorrectView];

    [currentDelegate overlayNextPressed];
}


- (void)provider2ButtonPressed:(id)sender {
    NSLog(@"provider2ButtonPressed...");
//    [self disableAllProviderButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 2;
    [self providerButtonVerification:thisEquivalentSegmentIndex];
    //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //sandy 10-13-14t emp uncomment to check for how the provider test is being validated
    //    [currentDelegate showModalProviderTestCorrectView];

    [currentDelegate overlayNextPressed];
}


- (void)provider3ButtonPressed:(id)sender {
    NSLog(@"provider3ButtonPressed...");
//    [self disableAllProviderButtons];
    
    
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 3;
    [self providerButtonVerification:thisEquivalentSegmentIndex];
   // [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //sandy 10-13-14t emp uncomment to check for how the provider test is being validated
    //[currentDelegate showModalProviderTestCorrectView];
    // sandy testing showing the next button after the provider is selected
    //[currentDelegate showOverlayNextButton];
    
    [currentDelegate overlayNextPressed];
}


- (void)provider4ButtonPressed:(id)sender {
    NSLog(@"provider4ButtonPressed...");
//    [self disableAllProviderButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 4;
    [self providerButtonVerification:thisEquivalentSegmentIndex];
   // [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //sandy 10-13-14t emp uncomment to check for how the provider test is being validated
    //[currentDelegate showModalProviderTestCorrectView];


    [currentDelegate overlayNextPressed];
}

- (void)provider5ButtonPressed:(id)sender {
    NSLog(@"provider5ButtonPressed (don't know)...");
//    [self disableAllProviderButtons];
    NSString* dontknow = @"dont know";
    // Store rating for dynamic survey item
   // int thisEquivalentSegmentIndex = 5;
    BOOL matched = FALSE;
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    
    [rootViewController  updateSurveyNumberForField:@"protest" withThisRatingNum: matched];
    [rootViewController updateSurveyTextForField:@"providernameselected" withThisText:[NSString stringWithFormat:@"%@",dontknow]];

  //  bypass this
  //  [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalProviderTestIncorrectView];
    [currentDelegate overlayNextPressed];
}

- (void)providerButtonVerification:(int)segmentIndex {
    
    //   need an arrary of values setup when this is initialized
    //   providerTest.provider4Text = [allPhysicians objectAtIndex:provider4Index];
    // access as:
    // NSMutableArray* myProviderStringArray = [DynamicContent getProviderStrings];
    // NSString *str1 = providerTest.provider1Text;
    BOOL matched = false;
    NSString *selectedProviderFullName  = NULL;
    NSMutableArray* myProviderStringArray = [DynamicContent getProviderStrings];
    selectedProviderFullName  = [myProviderStringArray objectAtIndex:segmentIndex-1];
    //get value selected by user and store to selectedPhysicianNameAlone
    NSMutableArray *selectedPhysicianNameTokens = [[NSMutableArray alloc] initWithArray:[selectedProviderFullName componentsSeparatedByString:@","] copyItems:YES];
    NSString *selectedPhysicianNameAlone = [selectedPhysicianNameTokens objectAtIndex:0];
    NSLog(@"selected provider was%@",selectedPhysicianNameAlone);
    
    //get value stored by receptionist and store to correctPhysicianNameAlone
    NSString *thecurrentProviderName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName];
    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thecurrentProviderName componentsSeparatedByString:@","] copyItems:YES];
    NSString *correctPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    NSLog(@"correct value should be %@",correctPhysicianNameAlone);
    
   // NSString *providerCorrectText = [NSString stringWithFormat:@"That's right, you are meeting with Dr. %@ today.  Press OK to continue.",thisPhysicianNameAlone];
    //char *cStr = "Homebrew";
    NSString *str3 = [NSString stringWithUTF8String:selectedPhysicianNameAlone];
    NSString *str4 = [NSString stringWithUTF8String:correctPhysicianNameAlone];

    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    
    if ([str3 isEqualToString:str4]){
        NSLog (@"str3 equals str4 - strings match - correct physician selected");
    //update value in db
        
       matched = true;
        [rootViewController updateSurveyNumberForField:@"protest" withThisRatingNum: matched];
        }
    else {
        NSLog (@"str3 does not equal str4- strings don't match - wrong physician selected");
        matched = FALSE;
        [rootViewController  updateSurveyNumberForField:@"protest" withThisRatingNum: matched];
    }
    
    [rootViewController updateSurveyTextForField:@"providernameselected" withThisText:[NSString stringWithFormat:@"%@",selectedPhysicianNameAlone]];


}

- (void)disableAllSublinicButtons {
    subclinic1TextButton.enabled = NO;
    subclinic2TextButton.enabled = NO;
    subclinic3TextButton.enabled = NO;
    subclinic4TextButton.enabled = NO;
    
    subclinic5TextButton.enabled = NO;
}

- (void)subclinic1ButtonPressed:(id)sender {
    NSLog(@"subclinic1ButtonPressed...");
    //    subclinic1TextButton.titleLabel.text = subclinic1Text;
//    [self disableAllSublinicButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 1;
        [self clinicTestButtonVerification:thisEquivalentSegmentIndex];
    //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalSubclinicTestIncorrectView];
    [currentDelegate overlayNextPressed];
}


- (void)subclinic2ButtonPressed:(id)sender {
    NSLog(@"subclinic2ButtonPressed...");
    //    subclinic2TextButton.titleLabel.text = subclinic2Text;
//    [self disableAllSublinicButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 2;
    [self clinicTestButtonVerification:thisEquivalentSegmentIndex];
    //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalSubclinicTestIncorrectView];
    [currentDelegate overlayNextPressed];
}


- (void)subclinic3ButtonPressed:(id)sender {
    NSLog(@"subclinic3ButtonPressed...");
    //    subclinic3TextButton.titleLabel.text = subclinic3Text;
//    [self disableAllSublinicButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 3;
    [self clinicTestButtonVerification:thisEquivalentSegmentIndex];
    //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalSubclinicTestIncorrectView];
    [currentDelegate overlayNextPressed];
}


- (void)subclinic4ButtonPressed:(id)sender {
    NSLog(@"subclinic4ButtonPressed...");
//    [self disableAllSublinicButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 4;
    [self clinicTestButtonVerification:thisEquivalentSegmentIndex];
    //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalSubclinicTestCorrectView];
    [currentDelegate overlayNextPressed];
}

- (void)subclinic5ButtonPressed:(id)sender {
    NSLog(@"subclinic5ButtonPressed (i don't know)...");
//    [self disableAllSublinicButtons];
    
    // Store rating for dynamic survey item
    int thisEquivalentSegmentIndex = 5;
[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:thisEquivalentSegmentIndex];
    
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    //    [currentDelegate showModalSubclinicTestCorrectView];
    [currentDelegate overlayNextPressed];
}

- (void)clinicTestButtonVerification:(int)segmentIndex {
    
    //   need an arrary of values setup when this is initialized
    //   providerTest.provider4Text = [allPhysicians objectAtIndex:provider4Index];
    // access as:
    // NSMutableArray* myProviderStringArray = [DynamicContent getProviderStrings];
    // NSString *str1 = providerTest.provider1Text;
    BOOL matched = false;
    NSString *selectedClinic  = NULL;
    NSMutableArray* myClinicTestStringArray = [DynamicContent getClinicTestStrings];
    selectedClinic  = [myClinicTestStringArray objectAtIndex:segmentIndex];
    NSLog(@"selected provider was%@",selectedClinic);
    
    //get value stored by receptionist and store to correctPhysicianNameAlone
    
    NSString *thisClinicName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentClinicName];
//    NSString *thisSubClinicName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSubClinicName];
 //   NSString *thisSpecialtyClinicName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName];
    
    NSString *theCorrectClinic = 'none';
   // NSString *default = @"Default";
    
   // if ([thisSpecialtyClinicName isNotEqualToString:default])  {
  //     theCorrectClinic = thisSpecialtyClinicName;
   // }
  //  else if ([thisSubClinicName isNotEqualToString:default])  {
   //     theCorrectClinic = thisSubClinicName;
   // }
   // else
    theCorrectClinic = thisClinicName;
        
    NSLog(@"correct value should be %@",theCorrectClinic);
    
    // NSString *providerCorrectText = [NSString stringWithFormat:@"That's right, you are meeting with Dr. %@ today.  Press OK to continue.",thisPhysicianNameAlone];
    //char *cStr = "Homebrew";
    NSString *str4 = [NSString stringWithUTF8String:selectedClinic];
    NSString *str5 = [NSString stringWithUTF8String:theCorrectClinic];
    
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    
    if ([str4 isEqualToString:str5]){
        NSLog (@"str3 equals str4 - strings match - correct clinicselected");
        //update value in db
        
        matched = true;
        [rootViewController updateSurveyNumberForField:@"clinictest" withThisRatingNum: matched];
    }
    else {
        NSLog (@"str3 does not equal str4- strings don't match - wrong clinic selected");
        matched = FALSE;
        [rootViewController  updateSurveyNumberForField:@"clinictest" withThisRatingNum: matched];
    }
    
    [rootViewController updateSurveyTextForField:@"clinicselected" withThisText:[NSString stringWithFormat:@"%@",selectedClinic]];
    
    
}

- (void)helpfulSegmentedControlIndexChanged:(UISegmentedControl *)aControl {
    NSLog(@"helpfulSegmentedControlIndexChanged...");
    DynamicSurveyViewController_Pad *currentDelegate = delegate;
    [currentDelegate overlayNextPressed];
    
    // Store rating for dynamic survey item
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:aControl.selectedSegmentIndex];
}


- (void)goalRatingSegmentedControlIndexChanged:(UISegmentedControl *)aControl {
    NSLog(@"goalRatingSegmentedControlIndexChanged...");
    
    // Store rating for dynamic survey item
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedDynamicSurveyItemWithSegmentIndex:aControl.selectedSegmentIndex];
}

- (IBAction)module1ButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewController.module1ButtonPressed()");
    
    module1Button.enabled = NO;
    
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    //    [thisDelegate overlayNextPressed];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] menuButtonPressed:[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbiEdButton]];
    
}

- (IBAction)module2ButtonPressed:(id)sender {
    NSLog(@"module2ButtonPressed...");
    
    module2Button.enabled = NO;
    
    DynamicSurveyViewController_Pad *thisDelegate = (DynamicSurveyViewController_Pad *)delegate;
    //    [thisDelegate overlayNextPressed];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] menuButtonPressed:[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] newsButton]];
}

- (void)showComingSoonAlert {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc]  sayComingSoon];
    UIAlertView *comingSoonAlert = [[UIAlertView alloc] initWithTitle:@"Feature Unavailable" message:@"This Feature is coming soon!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    comingSoonAlert.delegate = self;
    [comingSoonAlert show];
    [comingSoonAlert release];
}

// sandy use survey_module_choice_template_fourchoices.storyboard if there are 4 education modules
- (IBAction)module3ButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewcontroller.module3ButtonPressed()");
    [self showComingSoonAlert];
}

- (IBAction)module4ButtonPressed:(id)sender {
    NSLog(@"SwitchedImageViewcontroller.module4ButtonPressed()");
    [self showComingSoonAlert];
}





@end
