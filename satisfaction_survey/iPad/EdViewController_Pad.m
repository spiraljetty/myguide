    //
//  RootViewController_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "EdViewController_Pad.h"
#import "RotatingSegue.h"
//#import "ReflectingView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NewPlayerView.h"
#import "SampleViewController.h"
#import "AppDelegate_Pad.h"
#import "SwitchedImageViewController.h"

#import "QuickMovieViewController.h"
#import "RVRotationViewerController.h"

#import "ZipArchive.h"
#import "PSFileManager.h"

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define COOKBOOK_NEW_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.31176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))


@implementation EdViewController_Pad

@synthesize newTimer;
@synthesize queuePlayer = mQueuePlayer;
@synthesize playerView = mPlayerView;

@synthesize modalContent;

@synthesize speakItemsAloud, showDefaultButton, showFlipButton, showDissolveButton, showCurlButton;
@synthesize respondentType;
@synthesize databasePath, mainTable, csvpath, movViewController, playingMovie, animationPath, rotationViewController;

// Establish core interface
- (void)viewDidLoad
{
    
    finishingLastItem = NO;
    
    playingMovie = NO;
    
//    [self checkAndLoadLocalDatabase];
    
    // Create a basic background.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create backsplash for animation support
    backsplash = [[ReflectingView alloc] initWithFrame:CGRectInset(self.view.frame, 0.0f, 75.0f)];
    backsplash.usesGradientOverlay = NO;
    backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, -75.0f);
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
//    [backsplash setupReflection];
    // [self setupGradient];
    
    // Create small view to control AVPlayerQueue
    self.playerView = [[NewPlayerView alloc] initWithFrame:CGRectInset(self.view.frame, 100.0f, 150.0f)];
    self.playerView.frame = CGRectOffset(self.playerView.frame, 0.0f, 80.0f);
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.playerView];
    [self.view sendSubviewToBack:self.playerView];
    
    // Add a page view controller
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 16;
    [self.view addSubview:pageControl];
    
    [self createImageRootInDocDir];
    
    fileman = [[PSFileManager alloc] init];
    
    NSString *docPath = [fileman getDocumentsDirectoryPath];
    
    
    animationPath = [docPath stringByAppendingPathComponent:@"animation"];
    
    
    rotationViewController = [[RVRotationViewerController alloc] initWithImageDirectory:animationPath];
    
    [fileman release];
    
    rotationViewController.view.alpha = 0.0;
    [rotationViewController.view setCenter:CGPointMake(512.0f, 362.0f)];
    
    [self.view addSubview:rotationViewController.view];
    [self.view sendSubviewToBack:rotationViewController.view];
    
    // Load a survey type from storyboard
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"ed_module" bundle:[NSBundle mainBundle]];
    
    newChildControllers = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"0"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"1"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"2"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"3"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"4"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"5"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"6"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"7"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"8"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"9"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"10"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"11"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"12"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"13"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"14"],
                                                                 [aStoryboard instantiateViewControllerWithIdentifier:@"15"],
                                                                 nil]];
    
    NSLog(@"CREATED CHILDCONTROLLERS...");
    
    int controllerIndex = 0;
    
    // Set each child as a child view controller, setting its tag and frame
    for (SwitchedImageViewController *controller in newChildControllers)
    {
        controller.view.tag = 1066;
        controller.view.frame = backsplash.bounds;
        
//        if (controllerIndex == 13) {
//        //rootViewController = [[RVRotationViewerController alloc] initWithImageDirectory:animationPath];
//            [controller initWithImageDirectory:animationPath];
//            [controller uniqueRotationViewSetup];
//        }
        
        [self addChildViewController:controller];
        
//        controllerIndex++;
    }
    
    // Initialize scene with first child controller
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[newChildControllers objectAtIndex:0];
    [backsplash addSubview:controller.view];
    
    // Create Navigation Item for custom bar
    item = [[UINavigationItem alloc] initWithTitle:@"What is a TBI?"];
//    item.leftBarButtonItem = BARBUTTON(@"\u25C0 Previous", @selector(progress:));
//    item.rightBarButtonItem = BARBUTTON(@"Next \u25B6", @selector(regress:));
    
    // Create and add custom Navigation Bar
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    bar.tintColor = COOKBOOK_NEW_COLOR;
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bar.items = [NSArray arrayWithObject:item];
    [self.view addSubview:bar];
    
    [self.view addSubview:movViewController.view];
    [self.view sendSubviewToBack:movViewController.view];
	
}

-(void)createImageRootInDocDir
{
    
    // unzip animation images from bundle to doc dir to have somthing to display
    
    fileman = [[PSFileManager alloc] init];
    
    NSString *docPath = [fileman getDocumentsDirectoryPath];
    
    ZipArchive *zipper = [[ZipArchive alloc] init];
    
    animationPath = [docPath stringByAppendingPathComponent:@"animation"];
    
    if (![fileman fileExistsAtPath:animationPath]) {
        [fileman createDirectoryAtPath:[docPath stringByAppendingPathComponent:@"animation"] withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Initially created animation directory in documents directory");
    }
    
    
    //    [zipper UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"animation_sample" ofType:@"zip"]];
    //    [zipper UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"whole_brain-vert" ofType:@"zip"]];
    //    [zipper UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"whole_brain-horiz-hires_smallest" ofType:@"zip"]];
    [zipper UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"whole_brain-horiz-hires_smallest" ofType:@"zip"]];
    [zipper UnzipFileTo:animationPath overWrite:YES];
    [zipper CloseZipFile2];
    
    NSLog(@"unzipped test images to %@", animationPath);
    
    [zipper release];
    [fileman release];
    
}

// Informal delegate method re-enables bar buttons
- (void) segueDidComplete
{
    item.rightBarButtonItem.enabled = YES;
    item.leftBarButtonItem.enabled = YES;
    
    pageControl.currentPage = vcIndex;
    
//    if (speakItemsAloud) {
//        
//        [self playSound];
//    }

}

- (void)playSound
{
    //	if ([MPMusicPlayerController iPodMusicPlayer].playbackState ==  MPMusicPlaybackStatePlaying)
    //		AudioServicesPlayAlertSound(mysound);
    //	else
    
//    CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:sndpath];
//	
//	// Identify it as not a UI Sound
//    AudioServicesCreateSystemSoundID(baseURL, &currentsound);
//    //    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:sndpath], &currentsound);
//	AudioServicesPropertyID flag = 0;  // 0 means always play
//	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), &currentsound, sizeof(AudioServicesPropertyID), &flag);
//    
//    
//    NSLog(@"Playing audio for item %d", vcIndex);
//    AudioServicesPlaySystemSound(currentsound);
    
//    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"1_Patient"
//                                                withExtension: @"mp3"];
//    
//    // Store the URL as a CFURLRef instance
//    self.soundFileURLRef1 = (CFURLRef) [tapSound retain];
//    
//    tapSound   = [[NSBundle mainBundle] URLForResource: @"1_Patient"
//                                         withExtension: @"mp3"];
 
}

-(IBAction)nextDone:(id)inSender
{
	[self.queuePlayer advanceToNextItem];
	
	NSInteger remainingItems = [[self.queuePlayer items] count];
	
	if (remainingItems < 1)
	{
		[inSender setEnabled:NO];
	}
}

// Transition to new view using custom segue
- (void)switchToView:(int) newIndex goingForward:(BOOL) goesForward
{
    if (finishingLastItem )
    {
        // Back to menu
        [self.view sendSubviewToBack:rotationViewController.view];
        rotationViewController.view.alpha = 0.0;
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setEducationModuleCompleted:YES];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];
        
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] edModuleFinished];
        
//        [self saySurveyCompletion];
//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] surveyCompleted];
//        [self writeLocalDbToCSVFile];
        
    } else if (vcIndex == newIndex)
    {
        return;
        
    } else {
        
        
        NSLog(@"SWITCHING to item %d", vcIndex);
        
        // Prepare for segue by disabling bar buttons
        item.rightBarButtonItem.enabled = NO;
        item.leftBarButtonItem.enabled = NO;
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        
        
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
        
        NSString *pt_sound_1 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q1-care" ofType:@"mp3"];
        NSString *pt_sound_2 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q2-respect" ofType:@"mp3"];
        NSString *pt_sound_3 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q3-ease" ofType:@"mp3"];
        NSString *pt_sound_4 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q4-clear_info" ofType:@"mp3"];
        NSString *pt_sound_5 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q5-concerns_questions" ofType:@"mp3"];
        NSString *pt_sound_6 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q6-goals" ofType:@"mp3"];
        NSString *pt_sound_7 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q7-rights" ofType:@"mp3"];
        NSString *pt_sound_8 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q8-school" ofType:@"mp3"];
        NSString *pt_sound_9 = [[NSBundle mainBundle]
                                pathForResource:@"Patient_Q9-work" ofType:@"mp3"];
        NSString *pt_sound_10 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q10-solve_probs" ofType:@"mp3"];
        NSString *pt_sound_11 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q11-communication" ofType:@"mp3"];
        NSString *pt_sound_12 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q12-leisure" ofType:@"mp3"];
        NSString *pt_sound_13 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q13-physical" ofType:@"mp3"];
        NSString *pt_sound_14 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q14-emotional" ofType:@"mp3"];
        NSString *pt_sound_15 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q15-QOL" ofType:@"mp3"];
        NSString *pt_sound_16 = [[NSBundle mainBundle]
                                 pathForResource:@"Patient_Q16-progress" ofType:@"mp3"];
        
        
        pt_sound_1_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_1]];
        pt_sound_2_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_2]];
        pt_sound_3_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_3]];
        pt_sound_4_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_4]];
        pt_sound_5_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_5]];
        pt_sound_6_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_6]];
        pt_sound_7_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_7]];
        pt_sound_8_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_8]];
        pt_sound_9_item = [AVPlayerItem playerItemWithURL:
                           [NSURL fileURLWithPath:pt_sound_9]];
        pt_sound_10_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_10]];
        pt_sound_11_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_11]];
        pt_sound_12_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_12]];
        pt_sound_13_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_13]];
        pt_sound_14_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_14]];
        pt_sound_15_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_15]];
        pt_sound_16_item = [AVPlayerItem playerItemWithURL:
                            [NSURL fileURLWithPath:pt_sound_16]];
        
        // Update to new sound
        if (vcIndex == 0) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_1_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_1_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deactivateEdBackButton];
            
            item.title = @"What is a TBI?";

            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setEducationModuleInProgress:YES];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];
            
        } else if (vcIndex == 15) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_2_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_2_item,nil]];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            finishingLastItem = NO;
        } else if (vcIndex == 14) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_3_item];
            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_3_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            item.title = @"TBI - Key Points";
        } else if (vcIndex == 13) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_4_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_4_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 12) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_5_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_5_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 11) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_6_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_6_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            item.title = @"Mild TBI";
            
        } else if (vcIndex == 10) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_7_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_7_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 9) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_8_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_8_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 8) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_9_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_9_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 7) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_10_item];
            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_10_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            item.title = @"Moderate to Severe TBI";
            
        } else if (vcIndex == 6) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_11_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_11_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
        } else if (vcIndex == 5) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_12_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_12_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            item.title = @"Anatomy of the Brain";
            
        } else if (vcIndex == 4) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_13_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_13_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            [self.view sendSubviewToBack:rotationViewController.view];
            rotationViewController.view.alpha = 0.0;
            
        } else if (vcIndex == 3) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_14_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_14_item,nil]];
            finishingLastItem = YES;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            [self.view bringSubviewToFront:rotationViewController.view];
            
            [UIView beginAnimations:nil context:nil];
            {
                [UIView	setAnimationDuration:0.6];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                
                rotationViewController.view.alpha = 1.0;
                
            }
            [UIView commitAnimations];
            
        } else if (vcIndex == 2) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_15_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_15_item,nil]];
            finishingLastItem = NO;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            
            [self.view sendSubviewToBack:rotationViewController.view];
            rotationViewController.view.alpha = 0.0;
            
        } else if (vcIndex == 1) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_16_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_16_item,nil]];
            finishingLastItem = YES;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateEdBackButton];
            [self.view bringSubviewToFront:movViewController.view];
        }
        
        [self.playerView setPlayer:self.queuePlayer];
        
        // Create a new AVPlayerItem and make it the player's current item.
        //	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        if (speakItemsAloud) {
            NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
            //        [self.queuePlayer advanceToNextItem];
            
//            [self.queuePlayer play];
            //
            //        NSInteger remainingItems = [[self.queuePlayer items] count];
            //
            //        if (remainingItems < 1)
            //        {
            //            //            [inSender setEnabled:NO];
            //            NSLog(@"REACHED LAST ITEM IN AVPLAYERQUEUE");
            //        }
        } // if speakItemsAloud
        
    }
}

// Go forward
- (void)progress:(id)sender
{
    
    if (playingMovie) {
        [self stopMoviePlayback];
    }
    int newIndex = ((vcIndex + 1) % newChildControllers.count);
    [self switchToView:newIndex goingForward:YES];
    if (speakItemsAloud) {
        
        NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
        [self.queuePlayer advanceToNextItem];
        
        NSInteger remainingItems = [[self.queuePlayer items] count];
        
        if (remainingItems < 1)
        {
//            [inSender setEnabled:NO];
            NSLog(@"REACHED LAST ITEM IN AVPLAYERQUEUE");
        }
    }
}

// Go backwards
- (void)regress:(id)sender
{
    if (playingMovie) {
        [self stopMoviePlayback];
    }
    
    int newIndex = vcIndex - 1;
    if (newIndex < 0) newIndex = newChildControllers.count - 1;
//    if (newIndex < 0) newIndex = 3 - 1;
    [self switchToView:newIndex goingForward:NO];
}

- (void)stopMoviePlayback {
    if (playingMovie) {
        NSLog(@"Stopping currently playing movie...");
        SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
        [currentSwitchedController stopMovie:self];
    }
}

-(void)madeSatisfactionRatingForVC:(id)currentVC withSegmentIndex:(int)selectedIndex {
    NSLog(@"Satisfaction Rating Selected: %d", selectedIndex);
    NSString *fieldToUpdate;
    
    switch (vcIndex) {
        case 0:
//            [[AppDelegate_Pad sharedAppDelegate] deactivateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q1"];
            break;
        case 1:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q2"];
            break;
        case 2:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q3"];
            break;
        case 3:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q4"];
            break;
        case 4:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q5"];
            break;
        case 5:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q6"];
            break;
        case 6:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q7"];
            break;
        case 7:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q8"];
            break;
        case 8:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q9"];
            break;
        case 9:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q10"];
            break;
        case 10:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q11"];
            break;
        case 11:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q12"];
            break;
        case 12:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q13"];
            break;
        case 13:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q14"];
            break;
        case 14:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q15"];
            break;
        case 15:
            fieldToUpdate = [NSString stringWithFormat:@"q16"];
            break;
        default:
            break;
    }
    
    switch (selectedIndex) {
        case 0:
            [self sayStrongDisagree];
            break;
        case 1:
            [self sayDisagree];
            break;
        case 2:
            [self sayNeutral];
            break;
        case 3:
            [self sayAgree];
            break;
        case 4:
            [self sayStrongAgree];
            break;
        case 5:
            [self sayNA];
            break;
        default:
            break;
    }
    
//    [self updaterecordInTable:mainTable withIDField:@"uniqueid" IDFieldValue:currentUniqueID andNewField:fieldToUpdate newFieldValue:[NSString stringWithFormat:@"%d", selectedIndex]];
    [self updateSatisfactionRatingForField:fieldToUpdate withSelectedIndex:selectedIndex];
}

- (void)sayWelcomeToApp {
    //    // Define path to sounds
    
    if ([[AppDelegate_Pad sharedAppDelegate] isFirstVisit]) {
    NSString *welcome_sound = [[NSBundle mainBundle]
                               pathForResource:@"welcome_to_the" ofType:@"mp3"];
        NSString *clinic_sound = [[NSBundle mainBundle]
                                   pathForResource:@"clinic" ofType:@"mp3"];
        NSString *read_sound = [[NSBundle mainBundle]
                                pathForResource:@"would_you_like_me_to_read" ofType:@"mp3"];
        AVPlayerItem *welcome_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:welcome_sound]];
        AVPlayerItem *clinic_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:clinic_sound]];
        
        AVPlayerItem *read_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:read_sound]];
        
        
        
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:welcome_item,clinic_item,read_item,nil]];
    } else {
        NSString *welcome_sound = [[NSBundle mainBundle]
                                   pathForResource:@"welcome_back_to_clinic" ofType:@"mp3"];
        NSString *read_sound = [[NSBundle mainBundle]
                                pathForResource:@"would_you_like_me_to_read" ofType:@"mp3"];
        AVPlayerItem *welcome_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:welcome_sound]];
        
        AVPlayerItem *read_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:read_sound]];
        
        
        
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:welcome_item,read_item,nil]];
    }
    
    
    
    
	[self.playerView setPlayer:self.queuePlayer];
    
    
    if (speakItemsAloud) {
        
        [self.queuePlayer play];
        
        NSLog(@"STARTING queuePlayer...");
    }
}

- (void)sayFirstItem {
    if (speakItemsAloud) {
    NSString *pt_sound_1 = [[NSBundle mainBundle] pathForResource:@"Patient_Q1-care" ofType:@"mp3"];

    AVPlayerItem *pt_sound_1_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:pt_sound_1]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_1_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayOK {
    if (speakItemsAloud) {
    NSString *ok_sound = [[NSBundle mainBundle]
                          pathForResource:@"okay" ofType:@"mp3"];
    AVPlayerItem *ok_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:ok_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:ok_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayRespondentTypes {
    if (speakItemsAloud) {
    NSString *respondents_sound = [[NSBundle mainBundle]
                          pathForResource:@"pt_fam_or_caregiver" ofType:@"mp3"];
    AVPlayerItem *respondents_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:respondents_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:respondents_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)saySelectActivity {
    if (speakItemsAloud) {
    NSString *activity_sound = [[NSBundle mainBundle]
                                   pathForResource:@"please_choose_a_wr_activity" ofType:@"mp3"];
    AVPlayerItem *activity_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:activity_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:activity_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)saySurveyIntro {
    if (speakItemsAloud) {
    NSString *surveyintro_sound_a = [[NSBundle mainBundle]
                                   pathForResource:@"Patient_satisfaction_survey" ofType:@"mp3"];
    AVPlayerItem *surveyintro_item_a = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_a]];
    NSString *surveyintro_sound_b = [[NSBundle mainBundle]
                                     pathForResource:@"participation_is_voluntary" ofType:@"mp3"];
    AVPlayerItem *surveyintro_item_b = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_b]];
    NSString *surveyintro_sound_c= [[NSBundle mainBundle]
                                     pathForResource:@"thank_you_for_participating" ofType:@"mp3"];
    AVPlayerItem *surveyintro_item_c = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_c]];
        NSString *surveyintro_sound_d= [[NSBundle mainBundle]
                                        pathForResource:@"good_move_to_first_item" ofType:@"mp3"];
        AVPlayerItem *surveyintro_item_d = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_d]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveyintro_item_a,surveyintro_item_b,surveyintro_item_c,surveyintro_item_d,nil]];
    [self.queuePlayer play];
    }
}

- (void)saySurveyCompletion {
    if (speakItemsAloud) {
    NSString *surveycomplete_sound = [[NSBundle mainBundle]
                                   pathForResource:@"thank_you_for_input-menu_short" ofType:@"mp3"];
    AVPlayerItem *surveycomplete_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveycomplete_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveycomplete_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayComingSoon {
    if (speakItemsAloud) {
    NSString *comingsoon_sound = [[NSBundle mainBundle]
                                   pathForResource:@"coming_soon_short" ofType:@"mp3"];
    AVPlayerItem *comingsoon_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:comingsoon_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:comingsoon_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayAgree {
    if (speakItemsAloud) {
    NSString *agree_sound = [[NSBundle mainBundle]
                                  pathForResource:@"i_agree" ofType:@"mp3"];
    AVPlayerItem *agree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:agree_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:agree_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayDisagree {
    if (speakItemsAloud) {
    NSString *Disagree_sound = [[NSBundle mainBundle]
                                  pathForResource:@"i_disagree" ofType:@"mp3"];
    AVPlayerItem *Disagree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:Disagree_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:Disagree_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayNA {
    if (speakItemsAloud) {
    NSString *NA_sound = [[NSBundle mainBundle]
                                  pathForResource:@"does_not_apply_to_me" ofType:@"mp3"];
    AVPlayerItem *NA_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:NA_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:NA_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayNeutral {
    if (speakItemsAloud) {
    NSString *Neutral_sound = [[NSBundle mainBundle]
                                  pathForResource:@"i_am_neutral" ofType:@"mp3"];
    AVPlayerItem *Neutral_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:Neutral_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:Neutral_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayStrongAgree {
    if (speakItemsAloud) {
    NSString *StrongAgree_sound = [[NSBundle mainBundle]
                                  pathForResource:@"i_strongly_agree" ofType:@"mp3"];
    AVPlayerItem *StrongAgree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:StrongAgree_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:StrongAgree_item,nil]];
    [self.queuePlayer play];
    }
}

- (void)sayStrongDisagree {
    if (speakItemsAloud) {
    NSString *StrongDisagree_sound = [[NSBundle mainBundle]
                                  pathForResource:@"i_strongly_disagree" ofType:@"mp3"];
    AVPlayerItem *StrongDisagree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:StrongDisagree_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:StrongDisagree_item,nil]];
    [self.queuePlayer play];
    }
}

- (IBAction)showDefault:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showFlip:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showDissolve:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showCurl:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:sampleView animated:YES];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [backsplash setupReflection];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.queuePlayer = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
