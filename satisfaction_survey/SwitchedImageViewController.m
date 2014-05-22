/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "SwitchedImageViewController.h"
#import "RootViewController_Pad.h"
#import "AppDelegate_Pad.h"

@implementation SwitchedImageViewController

@synthesize currentSatisfactionLabel, currentReplayButton, moviePlayerController, currentPromptLabel;

@synthesize imageDirectory, rotationView;
@synthesize stronglyDisagreeButton, disagreeButton, agreeButton, stronglyAgreeButton, neutralButton, doesNotApplyButton;
@synthesize satisfactionRating;
@synthesize satisfactionRating1;
@synthesize satisfactionRating2;
@synthesize satisfactionRating3;
@synthesize satisfactionRating4;
@synthesize satisfactionRating5;
@synthesize satisfactionRating6;
@synthesize satisfactionRating7;
@synthesize satisfactionRating8;
@synthesize satisfactionRating9;
@synthesize satisfactionRating10;
@synthesize satisfactionRating11;
@synthesize satisfactionRating12;
@synthesize satisfactionRating13;
@synthesize satisfactionRating14;
@synthesize satisfactionRating15;
@synthesize satisfactionRating16;
@synthesize satisfactionRating17;
@synthesize satisfactionRating18;
@synthesize satisfactionRating19;
@synthesize satisfactionRating20;
@synthesize satisfactionRating21;
@synthesize satisfactionRating22;
@synthesize satisfactionRating23;
@synthesize satisfactionRating24;
@synthesize satisfactionRating25;
@synthesize satisfactionRating26;
@synthesize satisfactionRating27;
@synthesize satisfactionRating28;


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

-(void)rotationViewDidStartDecelerating:(RVRotationView *)rotationView
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
        
//    [[AppDelegate_Pad sharedAppDelegate] selectedSatisfactionWithVC:self andSegmentIndex:aControl.selectedSegmentIndex];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:aControl.selectedSegmentIndex];
    [self segmentedControlPressedWithIndex:aControl.selectedSegmentIndex];
    
}

-(void)stronglyDisagreeFaceButtonPressed:(id)sender {
     NSLog(@"Strongly disagree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 0;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
    
}

-(void)disagreeFaceButtonPressed:(id)sender {
    NSLog(@"Disagree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 1;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)agreeFaceButtonPressed:(id)sender {
    NSLog(@"Agree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 3;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)stronglyAgreeFaceButtonPressed:(id)sender {
    NSLog(@"Strongly agree pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 4;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)neutralFaceButtonPressed:(id)sender {
    NSLog(@"Neutral pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 2;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}

-(void)doesNotApplyFaceButtonPressed:(id)sender {
    NSLog(@"Does not apply pressed...");
    
    int segmentedControlEquivalentIndexSelected;
    stronglyDisagreeButton.alpha = 1.0;
    disagreeButton.alpha = 0.7;
    neutralButton.alpha = 0.7;
    agreeButton.alpha = 0.7;
    stronglyAgreeButton.alpha = 0.7;
    doesNotApplyButton.alpha = 0.7;
    
    segmentedControlEquivalentIndexSelected = 5;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
    [self segmentedControlPressedWithIndex:segmentedControlEquivalentIndexSelected];
    
}


- (void)faceButtonPressed:(id)sender {
    
    NSLog(@"Face button pressed...");
    
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
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] selectedSatisfactionWithVC:self andSegmentIndex:segmentedControlEquivalentIndexSelected];
//    satisfactionRating.selectedSegmentIndex = segmentedControlEquivalentIndexSelected;
}

- (void)segmentedControlPressedWithIndex:(int)segmentedControlIndex {
    
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
    
    UISegmentedControl *currentlyActiveSegmentedControl;
    int currentVCIndex = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] vcIndex];
    
    switch (currentVCIndex) {
        case 0:
            currentlyActiveSegmentedControl = satisfactionRating1;
            break;
        case 27:
            currentlyActiveSegmentedControl = satisfactionRating2;
            break;
        case 26:
            currentlyActiveSegmentedControl = satisfactionRating3;
            break;
        case 25:
            currentlyActiveSegmentedControl = satisfactionRating4;
            break;
        case 24:
            currentlyActiveSegmentedControl = satisfactionRating5;
            break;
        case 23:
            currentlyActiveSegmentedControl = satisfactionRating6;
            break;
        case 22:
            currentlyActiveSegmentedControl = satisfactionRating7;
            break;
        case 21:
            currentlyActiveSegmentedControl = satisfactionRating8;
            break;
        case 20:
            currentlyActiveSegmentedControl = satisfactionRating9;
            break;
        case 19:
            currentlyActiveSegmentedControl = satisfactionRating10;
            break;
        case 18:
            currentlyActiveSegmentedControl = satisfactionRating11;
            break;
        case 17:
            currentlyActiveSegmentedControl = satisfactionRating12;
            break;
        case 16:
            currentlyActiveSegmentedControl = satisfactionRating13;
            break;
        case 15:
            currentlyActiveSegmentedControl = satisfactionRating14;
            break;
        case 14:
            currentlyActiveSegmentedControl = satisfactionRating15;
            break;
        case 13:
            currentlyActiveSegmentedControl = satisfactionRating16;
            break;
        case 12:
            currentlyActiveSegmentedControl = satisfactionRating17;
            break;
        case 11:
            currentlyActiveSegmentedControl = satisfactionRating18;
            break;
        case 10:
            currentlyActiveSegmentedControl = satisfactionRating19;
            break;
        case 9:
            currentlyActiveSegmentedControl = satisfactionRating20;
            break;
        case 8:
            currentlyActiveSegmentedControl = satisfactionRating21;
            break;
        case 7:
            currentlyActiveSegmentedControl = satisfactionRating22;
            break;
        case 6:
            currentlyActiveSegmentedControl = satisfactionRating23;
            break;
        case 5:
            currentlyActiveSegmentedControl = satisfactionRating24;
            break;
        case 4:
            currentlyActiveSegmentedControl = satisfactionRating25;
            break;
        case 3:
            currentlyActiveSegmentedControl = satisfactionRating26;
            break;
        case 2:
            currentlyActiveSegmentedControl = satisfactionRating27;
            break;
        case 1:
            currentlyActiveSegmentedControl = satisfactionRating28;
            break;  
        default:
            break;
    }
    
    currentlyActiveSegmentedControl.selectedSegmentIndex = segmentedControlIndex;

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
    [moviePlayerController stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayerController];
    [moviePlayerController.view removeFromSuperview];
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    iv.alpha = 0.5f;
}
@end
