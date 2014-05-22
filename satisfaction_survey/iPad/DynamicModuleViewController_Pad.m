    //
//  RootViewController_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "DynamicModuleViewController_Pad.h"
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

#import "DynamicModulePageViewController.h"
#import "DynamicPageSubDetailViewController.h"

NSString *kModuleNameKey = @"Name";
NSString *kModuleTypeKey = @"Type";
NSString *kCreateModuleDynamicallyKey = @"CreateDynamically";
NSString *kModuleImageNameKey = @"Image";
NSString *kModuleTransitionsKey = @"Transitions";
NSString *kModuleThemeKey = @"Theme";
NSString *kModuleColorKey = @"Color";
NSString *kMandatoryModuleKey = @"Mandatory";
NSString *kShowModuleHeaderKey = @"ShowModuleHeader";
NSString *kModuleShouldRecognizeUserSpeechWordsKey = @"RecognizeUserSpeechWords";
NSString *kSuperModuleKey = @"SuperModule";
NSString *kSubModulesKey = @"SubModules";
NSString *kModulePagesKey = @"Pages";

NSString *kTermTextKey = @"Text";
NSString *kTermTTSTextFilenamePrefixKey = @"TTSTextFilenamePrefix";
NSString *kTermImageTermKey = @"ImageTerm";
NSString *kTermImageFilenameKey = @"ImageFilename";
NSString *kTermAllTextKey = @"TermText";
NSString *kTermTTSTermTextFilenamePrefixKey = @"TTSTermTextFilenamePrefix";
NSString *kTermMediumOriginCoordsKey = @"MediumOriginCoords";
NSString *kTermLargeOriginCoordsKey = @"LargeOriginCoords";
NSString *kTermSmallOriginCoordsKey = @"SmallOriginCoords";

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define COOKBOOK_NEW_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.31176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

#define GRADIENT_TEAL_COLOR	[UIColor colorWithRed:0.11372f green:0.55294f blue:0.49019f alpha:1.0f]
#define GRADIENT_BLUE_COLOR	[UIColor colorWithRed:0.00000f green:0.45098f blue:0.65882f alpha:1.0f]


@implementation DynamicModuleViewController_Pad

@synthesize delegate;
@synthesize newTimer;
@synthesize queuePlayer = mQueuePlayer;
@synthesize playerView = mPlayerView;

@synthesize modalContent;

@synthesize speakItemsAloud, showDefaultButton, showFlipButton, showDissolveButton, showCurlButton;
@synthesize respondentType;
@synthesize databasePath, mainTable, csvpath, movViewController, playingMovie, animationPath, rotationViewController;

@synthesize currentPhysicianDetails, currentPhysicianDetailSectionNames;

@synthesize dynModDict, dynModDictKeys;
@synthesize moduleName, moduleType, createModuleDynamically, moduleImageName;
@synthesize start_transition_type, end_transition_type, start_transition_origin, end_transition_origin;

@synthesize moduleTheme, moduleColor, isModuleMandatory, recognizeUserSpeechWords, superModule, subModules, pages;
@synthesize newChildControllers, ttsSoundFileDict, labelObjects;
@synthesize standardPageButtonOverlay, yesNoButtonOverlay, dynamicModuleHeader, showModuleHeader;

- (id)initWithPropertyList:(NSString *)propertyListName {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    [self setupWithPropertyList:propertyListName];
    
    return self;
}

- (void)setupWithPropertyList:(NSString *)propertyListName {
    
    NSData *tmp = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:propertyListName withExtension:@"plist"] options:NSDataReadingMappedIfSafe error:nil];
    dynModDict = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
    dynModDictKeys = [[dynModDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    
    moduleName = [dynModDict objectForKey:kModuleNameKey];
    moduleType = [dynModDict objectForKey:kModuleTypeKey];
    createModuleDynamically = [[dynModDict objectForKey:kCreateModuleDynamicallyKey] boolValue];
    moduleImageName = [dynModDict objectForKey:kModuleImageNameKey];
    
    NSDictionary *tempModuleTransitionsDict = [dynModDict objectForKey:kModuleTransitionsKey];
    start_transition_type = [tempModuleTransitionsDict objectForKey:@"start_transition_type"];
    end_transition_type = [tempModuleTransitionsDict objectForKey:@"end_transition_type"];
    start_transition_origin = [tempModuleTransitionsDict objectForKey:@"start_transition_origin"];
    end_transition_origin = [tempModuleTransitionsDict objectForKey:@"end_transition_origin"];
    
    moduleTheme = [dynModDict objectForKey:kModuleThemeKey];
    moduleColor = [dynModDict objectForKey:kModuleColorKey];
    isModuleMandatory = [[dynModDict objectForKey:kMandatoryModuleKey] boolValue];
    showModuleHeader = [[dynModDict objectForKey:kShowModuleHeaderKey] boolValue];
    recognizeUserSpeechWords = [dynModDict objectForKey:kModuleShouldRecognizeUserSpeechWordsKey];
    superModule = [dynModDict objectForKey:kSuperModuleKey];
    subModules = [dynModDict objectForKey:kSubModulesKey];
    pages = [dynModDict objectForKey:kModulePagesKey];
}

- (void)loadPages {
    
    NSLog(@"Loading %d pages...",[pages count]);
    
    int pageIndex = 0;
    
    for (NSDictionary *pageDict in pages) {
        DynamicModulePageViewController *dynamicModulePage = [[DynamicModulePageViewController alloc] initWithDictionary:pageDict];
        
        if ([moduleColor isEqualToString:@"teal"]) {
            [dynamicModulePage setPageHeaderColorTo:GRADIENT_TEAL_COLOR];
        } else {
            [dynamicModulePage setPageHeaderColorTo:GRADIENT_BLUE_COLOR];
        }
        
        if (pageIndex == 0) {
            newChildControllers = [[NSMutableArray alloc] initWithObjects:dynamicModulePage,nil];
        } else {
            [newChildControllers addObject:dynamicModulePage];
        }
        
        dynamicModulePage.delegate = self;
        
        pageIndex++;
    }
    
    NSLog(@"Load pages progress: %d of %d pages loaded!",pageIndex,[pages count]);
}

- (void)loadSoundFileNames {
    ttsSoundFileDict = [[NSMutableDictionary alloc] init];
    
    int numTermsCounted = 0;
    int numTermTextsCounted = 0;
    int numHeadersCounted = 0;
    int numPageTextsCounted = 0;
    
    for (DynamicModulePageViewController *thisPage in newChildControllers) {
        NSLog(@"Loading page %d sound filenames...",numPageTextsCounted);
        
        if (thisPage.containsTerminology) {
            for (NSDictionary *thisTermDict in thisPage.terminologyButtons) {
                [ttsSoundFileDict setObject:[thisTermDict objectForKey:kTermTextKey] forKey:[thisTermDict objectForKey:kTermTTSTextFilenamePrefixKey]];
                [ttsSoundFileDict setObject:[thisTermDict objectForKey:kTermAllTextKey] forKey:[thisTermDict objectForKey:kTermTTSTermTextFilenamePrefixKey]];
                numTermsCounted++;
                numTermTextsCounted++;
            }
        }
        
        if (thisPage.showHeader) {
            [ttsSoundFileDict setObject:thisPage.headerText forKey:thisPage.headerTTSFilenamePrefix];
            numHeadersCounted++;
        }
        
        [ttsSoundFileDict setObject:thisPage.text forKey:thisPage.TTSFilenamePrefix];
        numPageTextsCounted++;
    }
    
    NSLog(@"Finished loading the following TTS Filename Prefixes and Text Values in TTS Dictionary:");
    NSLog(@"- Terms: %d\n- Term Texts: %d\n- Headers: %d\n- Page Texts: %d",numTermsCounted,numTermTextsCounted,numHeadersCounted,numPageTextsCounted);
}

- (void)loadLabelObjects {
    NSLog(@"Loading label objects -- NEED TO COMPLETE THIS");
}

- (void)loadButtonOverlays {
    NSLog(@"Loading button overlays...");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    standardPageButtonOverlay = [[DynamicButtonOverlayViewController alloc] initWithButtonOverlayType:@"previousnext"];
    yesNoButtonOverlay = [[DynamicButtonOverlayViewController alloc] initWithButtonOverlayType:@"yesno"];
    
    standardPageButtonOverlay.view.alpha = 0.0;
    yesNoButtonOverlay.view.alpha = 0.0;
    standardPageButtonOverlay.view.transform = rotateLeft;
    yesNoButtonOverlay.view.transform = rotateLeft;
    [standardPageButtonOverlay.view setCenter:CGPointMake(522.0f, 385.0f)];
    [yesNoButtonOverlay.view setCenter:CGPointMake(512.0f, 400.0f)];
    [self.view addSubview:standardPageButtonOverlay.view];
    [self.view addSubview:yesNoButtonOverlay.view];
    
//    [self.view sendSubviewToBack:standardPageButtonOverlay.view];
//    [self.view sendSubviewToBack:yesNoButtonOverlay.view];
}

- (void)loadModuleHeader {
    NSLog(@"Loading module header...");
    
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    dynamicModuleHeader = [[DynamicPageDetailViewController alloc] initWithNibName:nil bundle:nil];
    //    dynamicPageHeader.view.alpha = 1.0;
//    dynamicModuleHeader.view.frame = CGRectMake(0, 0, 1024, 233);
    dynamicModuleHeader.view.backgroundColor = [UIColor clearColor];
//    [dynamicModuleHeader.view setCenter:CGPointMake(500.0f, 504.0f)];
    [dynamicModuleHeader.view setCenter:CGPointMake(640.0f, 500.0f)];
//    dynamicModuleHeader.view.transform = rotateLeft;
    
//    DynamicModuleViewController_Pad *currDelegate = (DynamicModuleViewController_Pad *)delegate;
//    dynamicPageHeader.dynamicModuleName = currDelegate.moduleName;
    
    dynamicModuleHeader.dynamicModuleName = moduleName;
    dynamicModuleHeader.dynamicModuleNameLabel.text = moduleName;
    
    NSLog(@"Header set to: %@",moduleName);
    
    [self.view addSubview:dynamicModuleHeader.view];
    //    [self.view sendSubviewToBack:physicianDetailVC.view];
}

// Establish core interface
- (void)viewDidLoad
{
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    finishingLastItem = NO;
    
    playingMovie = NO;
        
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
    pageControl.numberOfPages = [pages count];
//    pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pageControl];
    
    [self loadPages];
    [self loadSoundFileNames];
    [self loadLabelObjects];
    if (showModuleHeader) {
        [self loadModuleHeader];
    }
    
    [self loadButtonOverlays];
    
    int pageIndex = 0;
    
    for (DynamicModulePageViewController *thisPage in newChildControllers) {
        DynamicPageSubDetailViewController *dynamicPageSubDetailVC = [[DynamicPageSubDetailViewController alloc] init];
        
        dynamicPageSubDetailVC.subDetailSectionLabelText = thisPage.text;
        dynamicPageSubDetailVC.dynamicPageSubDetailSectionLabel.text = thisPage.text;
        
        if ([thisPage.headerText isEqualToString:@"NA"]) {
            dynamicPageSubDetailVC.headerLabelText = @"";
            dynamicPageSubDetailVC.dynamicPageHeaderLabel.text = @"";
        } else {
            dynamicPageSubDetailVC.headerLabelText = thisPage.headerText;
            dynamicPageSubDetailVC.dynamicPageHeaderLabel.text = thisPage.headerText;
        }
        
        dynamicPageSubDetailVC.view.tag = 1066;
        dynamicPageSubDetailVC.view.frame = backsplash.bounds;
        
        [thisPage.view addSubview:dynamicPageSubDetailVC.view];
        
        [self addChildViewController:thisPage];
        
        pageIndex++;
    }
    
    int numChildControllers = [newChildControllers count];
    
    NSLog(@"CREATED %d DYNAMIC SUB DETAIL CHILDCONTROLLERS...",numChildControllers);
    
    // Initialize scene with first child controller
//    vcIndex = numChildControllers-1;
    vcIndex = 0;
    
    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [backsplash addSubview:firstPage.view];
    
    [self.view bringSubviewToFront:backsplash];
//    [self.view bringSubviewToFront:pageControl];
    
}

- (void)startingFirstPage {
    
    NSLog(@"startingFirstPage of dynamic module...");
          
//    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
//    if ([firstPage.showButtonsFor isEqualToString:@"previousnext"]) {
//        [self showButtonOverlay:￼standardPageButtonOverlay];
//    } else if ([firstPage.showButtonsFor isEqualToString:@"yesno"]) {
//        [self showButtonOverlay:yesNoButtonOverlay];
//    } else {
//        [self showButtonOverlay:￼standardPageButtonOverlay];
//    }
    
    if (showModuleHeader) {
        [self.view bringSubviewToFront:dynamicModuleHeader.view];
        [self fadeThisObjectIn:dynamicModuleHeader.view];
    }
    
    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    [self fadeThisObjectIn:standardPageButtonOverlay.view];

}

- (void)showButtonOverlay:(UIViewController *)thisButtonOverlay {
    [self.view bringSubviewToFront:thisButtonOverlay.view];
    [self fadeThisObjectIn:thisButtonOverlay.view];
}

- (void)hideButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay {
    [self fadeThisObjectOut:thisButtonOverlay.view];
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

#pragma mark DynamicButtonOverlayDelegate Methods

- (void)overlayNextPressed {
    NSLog(@"overlayNextPressed...");
    [self progress:self];
}

- (void)overlayPreviousPressed {
    NSLog(@"overlayPreviousPressed...");
    [self regress:self];
}

- (void)overlayYesPressed {
    NSLog(@"overlayYesPressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchSatisfactionSurvey];
}

- (void)overlayNoPressed {
    NSLog(@"overlayNoPressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] returnToMenu];
}

- (void)overlayMenuPressed {
    NSLog(@"overlayMenuPressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] returnToMenu];
}

- (void)overlayFontsizePressed {
    NSLog(@"overlayFontsizePressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fontsizeButtonPressed:self];
}

- (void)overlayVoicePressed {
    NSLog(@"overlayVoicePressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
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
    
    if (finishingLastItem)
    {
        // Back to menu

//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchEducationModule];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicEdModuleOut];
        
  return;
        
    } else {
        
        
        NSLog(@"SWITCHING to item %d", vcIndex);
        
        DynamicModulePageViewController *newPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];

        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        
//        if ([newPage.showButtonsFor isEqualToString:@"yesno"]) {
//            [self.view bringSubviewToFront:yesNoButtonOverlay.view];
//            [self fadeThisObjectIn:yesNoButtonOverlay.view];
//            [self fadeThisObjectOut:standardPageButtonOverlay.view];
//        } else if ([newPage.showButtonsFor isEqualToString:@"previousnext"]) {
//            [self.view bringSubviewToFront:standardPageButtonOverlay.view];
//            [self fadeThisObjectIn:standardPageButtonOverlay.view];
//            [self fadeThisObjectOut:yesNoButtonOverlay];
//        }
        
        
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
        

        vcIndex = newIndex;
        
        
        
        if (vcIndex == ([newChildControllers count] - 1)) {
            NSLog(@"LAST PAGE");
            finishingLastItem = YES;
            [self.view bringSubviewToFront:yesNoButtonOverlay.view];
            [self fadeThisObjectIn:yesNoButtonOverlay.view];
            [self fadeThisObjectOut:standardPageButtonOverlay.view];
        }
        
        
        if (vcIndex == 0) {
            NSLog(@"FIRST PAGE");
            standardPageButtonOverlay.previousPageButton.enabled = NO;
        } else {
            standardPageButtonOverlay.previousPageButton.enabled = YES;
        }
        
        // Update to new sound
//        if (vcIndex == 0) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_1_item];
//            finishingLastItem = YES;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            
//            //            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setEducationModuleInProgress:YES];
//            //            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];
//            
//        } else if (vcIndex == 15) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_2_item];
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            finishingLastItem = NO;
//        } else if (vcIndex == 14) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_3_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//        } else if (vcIndex == 13) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_4_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 12) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_5_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 11) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_6_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            
//        } else if (vcIndex == 10) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_7_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 9) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_8_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 8) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_9_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 7) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_10_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            
//        } else if (vcIndex == 6) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_11_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//        } else if (vcIndex == 5) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_12_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            
//        } else if (vcIndex == 4) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_13_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            //            [self.view sendSubviewToBack:rotationViewController.view];
//            //            rotationViewController.view.alpha = 0.0;
//            
//        } else if (vcIndex == 3) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_14_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deactivatePhysicianBackButton];
//            
//            
//            
//        } else if (vcIndex == 2) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_15_item];
//            finishingLastItem = NO;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            
//            //            [self.view sendSubviewToBack:rotationViewController.view];
//            //            rotationViewController.view.alpha = 0.0;
//            
//        } else if (vcIndex == 1) {
//            //            [self.queuePlayer replaceCurrentItemWithPlayerItem:pt_sound_16_item];
//            //            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pt_sound_16_item,nil]];
//            //            finishingLastItem = YES;
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activatePhysicianBackButton];
//            //            [self.view bringSubviewToFront:movViewController.view];
//        }
        
        [self.playerView setPlayer:self.queuePlayer];
        
        // Create a new AVPlayerItem and make it the player's current item.
        //	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        if (speakItemsAloud) {
            NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
            //        [self.queuePlayer advanceToNextItem];
            
            [self.queuePlayer play];
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
    //    int newIndex = vcIndex--;
    [self switchToView:newIndex goingForward:NO];
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
    
    //    int newIndex = vcIndex++;
    int newIndex = vcIndex - 1;
    
    if (newIndex < 0) newIndex = newChildControllers.count - 1;
    //    if (newIndex < 0) newIndex = 3 - 1;
    [self switchToView:newIndex goingForward:YES];
}

- (void)stopMoviePlayback {
    if (playingMovie) {
        NSLog(@"Stopping currently playing movie...");
        SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
        [currentSwitchedController stopMovie:self];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
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