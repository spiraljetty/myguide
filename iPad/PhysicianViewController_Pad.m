    //
//  RootViewController_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "PhysicianViewController_Pad.h"
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

#import "PhysicianSubDetailViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define COOKBOOK_NEW_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.31176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))


@implementation PhysicianViewController_Pad

@synthesize newTimer;
@synthesize queuePlayer = mQueuePlayer;
@synthesize playerView = mPlayerView;

@synthesize modalContent;

@synthesize speakItemsAloud, showDefaultButton, showFlipButton, showDissolveButton, showCurlButton;
@synthesize respondentType;
@synthesize databasePath, mainTable, csvpath, movViewController, playingMovie, animationPath, rotationViewController;

@synthesize currentPhysicianDetails, currentPhysicianDetailSectionNames, masterTTSPlayer;

// Establish core interface

- (void)viewDidLoad {
    NSLog(@"PhysicianViewController.viewDidLoad()");

//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    float leftAngle =  90 * M_PI  / 180;
//    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
//    BOOL addPrePostSurveyItems = YES;
    
    finishingLastItem = NO;
    
    playingMovie = NO;
    
//    [self checkAndLoadLocalDatabase];
    
    // Create a basic background.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create backsplash for animation support
    CGRect backFrame = self.view.frame;
//    backsplash = [[ReflectingView alloc] initWithFrame:CGRectInset(self.view.frame, 75.0f, 0.0f)];
    backsplash = [[ReflectingView alloc] initWithFrame:backFrame];
    [backsplash setCenter:CGPointMake(512.0f, 500.0f)];
    backsplash.usesGradientOverlay = NO;
//    backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, 75.0f);
//    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    backsplash.transform = rotateLeft;
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
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 800.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.alpha = 0.0;
    pageControl.numberOfPages = [currentPhysicianDetailSectionNames count];
    [self.view addSubview:pageControl];
    
    int remainingDetailSections = [currentPhysicianDetailSectionNames count] - 1;
    
    NSString *longSectionPrefix = @"~";
    
    for (int i = 0; i <= remainingDetailSections; i++) {
        
        PhysicianSubDetailViewController *physicianSubDetailVC = [[PhysicianSubDetailViewController alloc] init];
        
        NSString *thisHeaderSection = currentPhysicianDetailSectionNames[i];
        if ([thisHeaderSection hasPrefix:longSectionPrefix]) {
            thisHeaderSection = [thisHeaderSection substringFromIndex:[longSectionPrefix length]];
        }
        
        physicianSubDetailVC.physicianHeaderLabel.text = thisHeaderSection;
        physicianSubDetailVC.headerLabelText = currentPhysicianDetailSectionNames[i];
        physicianSubDetailVC.physicianSubDetailSectionLabel.text = currentPhysicianDetails[currentPhysicianDetailSectionNames[i]];
        physicianSubDetailVC.subDetailSectionLabelText = currentPhysicianDetails[currentPhysicianDetailSectionNames[i]];
        
        physicianSubDetailVC.view.tag = 1066;
        physicianSubDetailVC.view.frame = backsplash.bounds;
        
        if (i == 0) {
            newChildControllers = [[NSMutableArray alloc] initWithObjects:physicianSubDetailVC,nil];
        } else {
            [newChildControllers insertObject:physicianSubDetailVC atIndex:0];
        }
        
        [self addChildViewController:physicianSubDetailVC];
        
        NSLog(@"PhysicianViewController.viewDidLoad() Added Physician Sub Detail Section %d with Header Title: %@",i+1,currentPhysicianDetailSectionNames[i]);
    }
    
    int numChildControllers = [newChildControllers count];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] addToTotalSlides:numChildControllers];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setFirstVisitSlides:[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] firstVisitSlides] + numChildControllers];
    
    NSLog(@"PhysicianViewController.viewDidLoad() CREATED %d PHYSICIAN SUB DETAIL CHILDCONTROLLERS...",numChildControllers);
    
    // Initialize scene with first child controller
    vcIndex = numChildControllers-1;
    
    PhysicianSubDetailViewController *firstController = (PhysicianSubDetailViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [backsplash addSubview:firstController.view];

}

- (void)goForward {
    NSLog(@"PhysicianViewController.goForward()");

    [self regress:self];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
}

- (void)goBackward {
    NSLog(@"PhysicianViewController.goBackward()");
    [self progress:self];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] decrementProgressBar];
}

//- (void)showModalProviderTestCorrectView {
//    NSLog(@"In showModalSubclinicTestCorrectView...");
//    
//    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
//    SwitchedImageViewController *providerTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
//    
//    if (currentModalVC) {
//        currentModalVC = nil;
//    }
//    currentModalVC = providerTestCorrect;
//    
//    providerTestCorrect.currentSurveyPageType = kOk;
//    providerTestCorrect.surveyPageIndex = 2;
//    providerTestCorrect.delegate = self;
//    providerTestCorrect.isSurveyPage = YES;
//    
//    int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
//    NSString *currentProviderFullName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:currentProviderIndex];
//
//    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
//    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
//    
//    NSString *providerCorrectText = [NSString stringWithFormat:@"That's right, you are meeting with Dr. %@ today.  Press OK to continue.",thisPhysicianNameAlone];
//    
//    providerTestCorrect.currentPromptString = providerCorrectText;
//    providerTestCorrect.currentPromptLabel.text = providerCorrectText;
//    
//    providerTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    providerTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
////    [providerTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    providerTestCorrect.view.transform = rotateRight;
//    [self presentModalViewController:providerTestCorrect animated:YES];
//    [providerTestCorrect release];
//    
//    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
//    thisSurveyPage.providerTestLabel.text = @"Press next to continue.";
//    
//    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] nextPhysicianDetailButton] setEnabled:NO];
//
//}
//
//- (void)showModalProviderTestIncorrectView {
//    NSLog(@"In showModalSubclinicTestIncorrectView...");
//    
//    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
//    SwitchedImageViewController *providerTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
//    
//    if (currentModalVC) {
//        currentModalVC = nil;
//    }
//    currentModalVC = providerTestCorrect;
//    
//    providerTestCorrect.currentSurveyPageType = kOk;
//    providerTestCorrect.surveyPageIndex = 2;
//    providerTestCorrect.delegate = self;
//    providerTestCorrect.isSurveyPage = YES;
//    
//    int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
//    NSString *currentProviderFullName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:currentProviderIndex];
//    
//    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
//    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
//    
//    NSString *providerIncorrectText = [NSString stringWithFormat:@"Not quite.  While that healthcare provider also works at the VA, today you will be meeting with Dr. %@.  Press OK to continue.",thisPhysicianNameAlone];
//    
//    providerTestCorrect.currentPromptString = providerIncorrectText;
//    providerTestCorrect.currentPromptLabel.text = providerIncorrectText;
//    
//    providerTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    providerTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
////    [providerTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    providerTestCorrect.view.transform = rotateRight;
//    [self presentModalViewController:providerTestCorrect animated:YES];
//    [providerTestCorrect release];
//    
//    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
//    thisSurveyPage.providerTestLabel.text = @"Press next to continue.";
//    
//    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] nextPhysicianDetailButton] setEnabled:NO];
//
//}

//- (void)dismissCurrentModalVC {
//    [currentModalVC dismissModalViewControllerAnimated:YES];
//    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] nextPhysicianDetailButton] setEnabled:YES];
//}

// Informal delegate method re-enables bar buttons
- (void)segueDidComplete
{
//    item.rightBarButtonItem.enabled = YES;
//    item.leftBarButtonItem.enabled = YES;
    
    pageControl.currentPage = vcIndex;
    
//    if (speakItemsAloud) {
//        
//        [self playSound];
//    }

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

- (void)playSoundForPage:(PhysicianSubDetailViewController *)currentPage {
    if (speakItemsAloud) {
        NSString *headerForPage = currentPage.headerLabelText;
        
        NSLog(@"retriving Sounds For Page With Header: %@",headerForPage);
        
        [masterTTSPlayer playItemsWithNames:[self getSoundFilenamesForSection:headerForPage]];
    }
}

// Transition to new view using custom segue
- (void)switchToView:(int)newIndex goingForward:(BOOL)goesForward
{
    NSLog(@"PhysicianViewController.switchToView()");
    if (finishingLastItem && !goesForward)
    {
        // Back to menu
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setPhysicianModuleCompleted:YES];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];

//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchDynamicClinicEducationModule];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] handlePhysicianModuleCompleted];
        
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadePhysicianDetailOut];

        
    } else if (vcIndex >= 0 && newIndex >= 0){
        
        finishingLastItem = NO;
        
        NSLog(@"PhysicianViewController.switchToView() SWITCHING from physician item %d to item %d", vcIndex, newIndex);
        
        // Prepare for segue by disabling bar buttons
//        item.rightBarButtonItem.enabled = NO;
//        item.leftBarButtonItem.enabled = NO;
        
        if (newIndex < 0){
            newIndex = 0;
        }
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        PhysicianSubDetailViewController *currentController = (PhysicianSubDetailViewController *)[newChildControllers objectAtIndex:vcIndex];
        
//        if (vcIndex <= 1) {
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadePhysicianDetailVCOut];
//            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
//            
//        } else if (vcIndex == ([newChildControllers count]-2)) {
//            
////            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadePhysicianDetailVCIn];
////            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] handleFirstPhysicianPageSoundAndLabelFade];
//        } else {
            [self playSoundForPage:currentController];
//        }

        // Update to new sound
        if (vcIndex == 0) {
            finishingLastItem = YES;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
//            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_1_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_1_item,nil]];
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setEducationModuleInProgress:YES];
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];
            
        } else if (vcIndex == 15) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_2_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_2_item,nil]];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            finishingLastItem = NO;
        } else if (vcIndex == 14) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_3_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_3_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
        } else if (vcIndex == 13) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_4_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_4_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 12) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_5_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_5_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 11) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_6_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_6_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
            
        } else if (vcIndex == 10) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_7_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_7_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 9) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_8_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_8_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 8) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_9_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_9_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 7) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_10_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_10_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
            
        } else if (vcIndex == 6) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_11_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_11_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        } else if (vcIndex == 5) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_12_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_12_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
            
        } else if (vcIndex == 4) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_13_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_13_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
//            [self.view sendSubviewToBack:rotationViewController.view];
//            rotationViewController.view.alpha = 0.0;
            
        } else if (vcIndex == 3) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_14_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_14_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
            

            
        } else if (vcIndex == 2) {
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_15_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_15_item,nil]];
            finishingLastItem = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
//            [self.view sendSubviewToBack:rotationViewController.view];
//            rotationViewController.view.alpha = 0.0;
            
        } else if (vcIndex == 1) {
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            
            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_16_item];
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_16_item,nil]];
//            finishingLastItem = YES;
//            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
//            [self.view bringSubviewToFront:movViewController.view];
        }
        
//        [self.playerView setPlayer:self.queuePlayer];
        
        // Create a new AVPlayerItem and make it the player's current item.
        //	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        if (speakItemsAloud) {
            NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
            //        [self.queuePlayer advanceToNextItem];
            
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
    NSLog(@"PhysicianViewController.progress()");

    NSLog(@"PhysicianViewController.progress() Moving to previous physician detail page...");
    
    if (playingMovie) {
        [self stopMoviePlayback];
    }
    int newIndex = ((vcIndex + 1) % newChildControllers.count);
//    int newIndex = vcIndex--;
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
    NSLog(@"PhysicianViewController.regress()");

    NSLog(@"PhysicianViewController.regress() Moving to next physician detail page...");
    if (playingMovie) {
        [self stopMoviePlayback];
    }
    
//    int newIndex = vcIndex++;
    int newIndex = vcIndex - 1;

    if (newIndex < 0) newIndex = newChildControllers.count - 1;
//    if (newIndex < 0) newIndex = 3 - 1;
    [self switchToView:newIndex goingForward:NO];
}

- (void)stopMoviePlayback {
    if (playingMovie) {
        NSLog(@"PhysicianViewController.stopMoviePlayback()");
        SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
        [currentSwitchedController stopMovie:self];
    }
}

- (void)sayPhysicianDetailIntro {
    NSLog(@"PhysicianViewController.sayPhysicianDetailIntro()");

    
    if (speakItemsAloud) {
        
//        NSString *thisPhysicianTextFilename = [NSString stringWithFormat:@"%@_name",[allClinicPhysiciansSoundFiles objectAtIndex:physicianIndexNum]];
        
        NSLog(@"Today your care is being handled by...");
 
        NSString *physician_sound_file = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianSoundFile];
        
        PhysicianSubDetailViewController *firstPage = (PhysicianSubDetailViewController *)[newChildControllers objectAtIndex:vcIndex];
        NSString *headerForFirstPage = firstPage.headerLabelText;
        NSLog(@"retriving Sounds For First Page With Header: %@",headerForFirstPage);
        
        NSMutableArray *allStartingItems = [[NSMutableArray alloc] initWithObjects: nil];
        [allStartingItems addObject:@"today_your_care_handled_by"];
        [allStartingItems addObject:[NSString stringWithFormat:@"%@_name",physician_sound_file]];
        [allStartingItems addObject:@"silence_half_second"];
        for (NSString *thisFilename in [self getSoundFilenamesForSection:headerForFirstPage]) {
            [allStartingItems addObject:thisFilename];
        }

        [masterTTSPlayer playItemsWithNames:allStartingItems];

    }
}

- (NSMutableArray *)getSoundFilenamesForSection:(NSString *)sectionName {
    NSMutableArray *soundFilenameArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    NSString *physician_sound_file = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianSoundFile];
    
    NSString *currentSoundFileSuffix = [sectionName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSString *fullSubdetailFilename = [NSString stringWithFormat:@"~%@_%@",physician_sound_file,currentSoundFileSuffix];
    NSString *fullHeaderFilename = [NSString stringWithFormat:@"%@_%@_%@",physician_sound_file,currentSoundFileSuffix,@"header"];

    [soundFilenameArray addObject:fullHeaderFilename];
    [soundFilenameArray addObject:fullSubdetailFilename];
    
    NSLog(@"Preparing physician soundfiles: %@ and %@...",fullHeaderFilename,fullSubdetailFilename);
    
    return soundFilenameArray;
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
