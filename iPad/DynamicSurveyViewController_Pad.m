 //
//  DynamicSurveyViewController_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "DynamicSurveyViewController_Pad.h"
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
#import "PopoverPlaygroundViewController.h"

#import "DynamicContent.h"

//NSString *kModuleNameKey = @"Name";
//NSString *kModuleTypeKey = @"Type";
//NSString *kCreateModuleDynamicallyKey = @"CreateDynamically";
//NSString *kModuleImageNameKey = @"Image";
//NSString *kModuleTransitionsKey = @"Transitions";
//NSString *kModuleThemeKey = @"Theme";
//NSString *kModuleColorKey = @"Color";
//NSString *kMandatoryModuleKey = @"Mandatory";
//NSString *kShowModuleHeaderKey = @"ShowModuleHeader";
//NSString *kModuleShouldRecognizeUserSpeechWordsKey = @"RecognizeUserSpeechWords";
//NSString *kSuperModuleKey = @"SuperModule";
//NSString *kSubModulesKey = @"SubModules";
//NSString *kModulePagesKey = @"Pages";
//
//NSString *kTermTextKey = @"Text";
//NSString *kTermTTSTextFilenamePrefixKey = @"TTSTextFilenamePrefix";
//NSString *kTermImageTermKey = @"ImageTerm";
//NSString *kTermImageFilenameKey = @"ImageFilename";
//NSString *kTermAllTextKey = @"TermText";
//NSString *kTermTTSTermTextFilenamePrefixKey = @"TTSTermTextFilenamePrefix";
//NSString *kTermMediumOriginCoordsKey = @"MediumOriginCoords";
//NSString *kTermLargeOriginCoordsKey = @"LargeOriginCoords";
//NSString *kTermSmallOriginCoordsKey = @"SmallOriginCoords";

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define COOKBOOK_NEW_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.31176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

#define GRADIENT_TEAL_COLOR	[UIColor colorWithRed:0.11372f green:0.55294f blue:0.49019f alpha:1.0f]
#define GRADIENT_BLUE_COLOR	[UIColor colorWithRed:0.00000f green:0.45098f blue:0.65882f alpha:1.0f]


@implementation DynamicSurveyViewController_Pad

@synthesize delegate;
@synthesize newTimer;
@synthesize queuePlayer = mQueuePlayer;
@synthesize playerView = mPlayerView;

@synthesize vcIndex;

@synthesize masterTTSPlayer, currentFinishingIndex, todaysGoal, miniSurveyPage1;

@synthesize modalContent;

@synthesize speakItemsAloud, showDefaultButton, showFlipButton, showDissolveButton, showCurlButton;
@synthesize respondentType;
@synthesize databasePath, mainTable, csvpath, movViewController, playingMovie, animationPath, rotationViewController;

@synthesize currentPhysicianDetails, currentPhysicianDetailSectionNames, inSubclinicMode, inWhatsNewMode;

@synthesize dynModDict, dynModDictKeys;
@synthesize moduleName, moduleType, createModuleDynamically, moduleImageName;
@synthesize start_transition_type, end_transition_type, start_transition_origin, end_transition_origin;

@synthesize moduleTheme, moduleColor, isModuleMandatory, recognizeUserSpeechWords, superModule, subModules, pages;
@synthesize newChildControllers, ttsSoundFileDict, labelObjects;
@synthesize standardPageButtonOverlay, yesNoButtonOverlay, dynamicModuleHeader, showModuleHeader, numberOfPostTreatmentItems;

@synthesize termPopoverViewController, hiddenPopoverButton;


static SwitchedImageViewController *providerModuleHelpful = NULL;
static SwitchedImageViewController *subclinicModuleHelpful = NULL;
static DynamicSurveyViewController_Pad *mViewController = NULL;

+ (DynamicSurveyViewController_Pad*) getViewController{
    return mViewController;
}


+ (void) setProviderHelpfulText:(NSString*) text {
    providerModuleHelpful.helpfulLabel.text = text;
}

+ (void) setClinicHelpfulText:(NSString*) text {
//    subclinicModuleHelpful.helpfulLabel.text = text;
    subclinicModuleHelpful.helpfulText = text;
}


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
    
    
    //    moduleName = [dynModDict objectForKey:kModuleNameKey];
    //    moduleType = [dynModDict objectForKey:kModuleTypeKey];
    //    createModuleDynamically = [[dynModDict objectForKey:kCreateModuleDynamicallyKey] boolValue];
    //    moduleImageName = [dynModDict objectForKey:kModuleImageNameKey];
    //
    //    NSDictionary *tempModuleTransitionsDict = [dynModDict objectForKey:kModuleTransitionsKey];
    //    start_transition_type = [tempModuleTransitionsDict objectForKey:@"start_transition_type"];
    //    end_transition_type = [tempModuleTransitionsDict objectForKey:@"end_transition_type"];
    //    start_transition_origin = [tempModuleTransitionsDict objectForKey:@"start_transition_origin"];
    //    end_transition_origin = [tempModuleTransitionsDict objectForKey:@"end_transition_origin"];
    //
    //    moduleTheme = [dynModDict objectForKey:kModuleThemeKey];
    //    moduleColor = [dynModDict objectForKey:kModuleColorKey];
    //    isModuleMandatory = [[dynModDict objectForKey:kMandatoryModuleKey] boolValue];
    //    showModuleHeader = [[dynModDict objectForKey:kShowModuleHeaderKey] boolValue];
    //    recognizeUserSpeechWords = [dynModDict objectForKey:kModuleShouldRecognizeUserSpeechWordsKey];
    //    superModule = [dynModDict objectForKey:kSuperModuleKey];
    //    subModules = [dynModDict objectForKey:kSubModulesKey];
    //    pages = [dynModDict objectForKey:kModulePagesKey];
}

- (void)loadPages {
    
    NSLog(@"Loading %d pages...",[pages count]);
    
    int pageIndex = 0;
    
    numberOfPostTreatmentItems = 0;
    
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
        NSLog(@"DynamicSurveyViewController.loadSoundFileNames() Loading page %d sound filenames...",numPageTextsCounted);
        
        //        if (thisPage.containsTerminology) {
        //            for (NSDictionary *thisTermDict in thisPage.terminologyButtons) {
        //                [ttsSoundFileDict setObject:[thisTermDict objectForKey:kTermTextKey] forKey:[thisTermDict objectForKey:kTermTTSTextFilenamePrefixKey]];
        //                [ttsSoundFileDict setObject:[thisTermDict objectForKey:kTermAllTextKey] forKey:[thisTermDict objectForKey:kTermTTSTermTextFilenamePrefixKey]];
        //                numTermsCounted++;
        //                numTermTextsCounted++;
        //            }
        //        }
        
        //        if (thisPage.showHeader) {
        //            [ttsSoundFileDict setObject:thisPage.headerText forKey:thisPage.headerTTSFilenamePrefix];
        //            numHeadersCounted++;
        //        }
        if (thisPage.TTSFilenamePrefix != NULL)
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
    
    standardPageButtonOverlay.view.frame = CGRectMake(390, 400, 1024, 233);
    //    standardPageButtonOverlay.view.backgroundColor = [UIColor redColor];
    
    standardPageButtonOverlay.view.alpha = 0.0;
    yesNoButtonOverlay.view.alpha = 0.0;
    standardPageButtonOverlay.view.transform = rotateLeft;
    
    //    standardPageButtonOverlay.view.backgroundColor = [UIColor redColor];
    //    [standardPageButtonOverlay.view setCenter:CGPointMake(542.0f, 0.0f)];
    
    yesNoButtonOverlay.view.transform = rotateLeft;
    //    [standardPageButtonOverlay.view setCenter:CGPointMake(522.0f, 385.0f)];
    [yesNoButtonOverlay.view setCenter:CGPointMake(542.0f, 400.0f)];
    [self.view addSubview:standardPageButtonOverlay.view];
    [self.view addSubview:yesNoButtonOverlay.view];
    
    //    [self.view sendSubviewToBack:standardPageButtonOverlay.view];
    //    [self.view sendSubviewToBack:yesNoButtonOverlay.view];
}

- (void)goForward {
    NSLog(@"DynamicSurveyViewController_Pad.goForward() dynamicSurveyModule...");
    [self overlayNextPressed];
}

- (void)goBackward {
    NSLog(@"goBackward dynamicSurveyModule...");
    [self overlayPreviousPressed];
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
- (void)viewDidLoad {
    NSLog(@"DynamicSurveyViewController_Pad.viewDidLoad()");
    mViewController = self;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    //    [self.playerView setPlayer:self.queuePlayer];
    
    addPrePostSurveyItems = YES;
    
    addGoalSurveyItems = YES;
    
    addMiniSurveyItems = YES;
    
    todaysGoal = @"";
    
    numberOfPostTreatmentItems = 0;
    
    //    if (inSubclinicMode) {
    //        addPrePostSurveyItems = YES;
    //        addMiniSurveyItems = YES;
    //    } else {
    //        addPrePostSurveyItems = NO;
    //    }
    
    BOOL isFollowUpVisit;
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isFirstVisit]) {
        isFollowUpVisit = NO;
    } else {
        isFollowUpVisit = YES;
    }
    
    if (addPrePostSurveyItems) {
        newChildControllers = [[NSMutableArray alloc] initWithObjects:nil];
    }
    
    finishingLastItem = NO;
    
    playingMovie = NO;
    
    // Create a basic background.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    //sandy
    //self.view.backgroundColor = [UIColor clearColor];
    //    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create backsplash for animation support
    //    CGRect backFrame = self.view.frame;
    CGRect backFrame = CGRectMake(0, 0, 1024, 748);
    //    backsplash = [[ReflectingView alloc] initWithFrame:CGRectInset(self.view.frame, 75.0f, 0.0f)];
    backsplash = [[ReflectingView alloc] initWithFrame:backFrame];
    [backsplash setCenter:CGPointMake(512.0f, 350.0f)];
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
    NSLog(@"----------size of width @%f",self.view.frame.size.width);
    // Sandy Attempting to make view wider so buttons are fully enabled
 // original   pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 800.0f)];
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 800.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = [pages count];
    //    pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pageControl];
    
    //    [self loadButtonOverlays];
    
}

- (void)loadAllSurveyPages {
    NSLog(@"DynamicSurveyViewController.loadAllSurveyPages()");

    newChildControllers = [self createArrayOfAllSurveyPages];
    
    int numChildControllers = [newChildControllers count];
    
    int preTreatmentSurveyItems = numChildControllers = numberOfPostTreatmentItems;
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] addToTotalSlides:preTreatmentSurveyItems];
    
    NSLog(@"DynamicSurveyViewController.loadAllSurveyPages() CREATED %d DYNAMIC SURVEY PAGE CHILDCONTROLLERS...",numChildControllers);
    
    // Initialize scene with first child controller
    //    vcIndex = numChildControllers-1;
    vcIndex = 0;
    
    SwitchedImageViewController *firstPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [backsplash addSubview:firstPage.view];
    
    [self.view bringSubviewToFront:backsplash];
    
    currentFinishingIndex = [newChildControllers count] - 1;
    NSLog(@"DynamicSurveyViewController.loadAllSurveyPages() exit");

}

- (NSMutableArray *)createArrayOfAllSurveyPages {
    NSLog(@"DynamicSurveyViewController.createArrayOfAllSurveyPages()");
    
    NSMutableArray *surveyPageArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    int pageIndex = 0;
    
    if (addPrePostSurveyItems) {
        
        UIStoryboard *providerTestStoryboard = [UIStoryboard storyboardWithName:@"survey_provider_test_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *providerTest = [providerTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [providerTest retain];
        
        providerTest.currentSurveyPageType = kProviderTest;
        providerTest.surveyPageIndex = pageIndex;
        providerTest.delegate = self;
        providerTest.isSurveyPage = YES;
        providerTest.hidePreviousButton = YES;
 //sandy hide the next button here and then show it again after the selection
        providerTest.hideNextButton = YES;
        
        int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
        int numAttendingPhysicians = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysicians] count];
        int provider1Index = currentProviderIndex - 1;
        if (provider1Index < 0) {
            provider1Index = numAttendingPhysicians - 1;
        }
        int provider2Index = currentProviderIndex;
        int provider3Index = provider1Index - 1;
        if (provider3Index < 0) {
            provider3Index = numAttendingPhysicians - 1;
        }
        int provider4Index = provider3Index - 1;
        if (provider4Index < 0) {
            provider4Index = numAttendingPhysicians - 1;
        }
 
        //sandy hide the next button here and then show it again after the selection
        providerTest.hideNextButton = YES;
// sandy updated 7_15
        //        providerTest.providerTestText = @"Based on the information you have been given, please tap the healthcare provider you will be seeing today.";
        providerTest.providerTestText = @"Please tap the treatment provider you will be seeing today.";
        
        
        if (false){ //currentProviderIndex < [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs] count]){
            // if index is less than count of original (hardcoded) clinicians then use hardcoded thumb filename
            providerTest.provider1ImageThumb = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs] objectAtIndex:provider1Index];
            providerTest.provider2ImageThumb = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs] objectAtIndex:provider2Index];
            providerTest.provider3ImageThumb = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs] objectAtIndex:provider3Index];
            providerTest.provider4ImageThumb = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs] objectAtIndex:provider4Index];
        
            providerTest.provider1Text = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:provider1Index];
            providerTest.provider2Text = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:provider2Index];
            providerTest.provider3Text = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:provider3Index];
            providerTest.provider4Text = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:provider4Index];
        } else {
            //rjl 8/16/14
            NSMutableArray* allPhysicians = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysicians];
            NSMutableArray* allPhysiciansImages = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysiciansImages];
            
            // if index is greater than count of original (hardcoded) clinicians then use downloaded image filename
            providerTest.provider1ImageThumb = [allPhysiciansImages objectAtIndex:provider1Index];
            providerTest.provider2ImageThumb = [allPhysiciansImages objectAtIndex:provider2Index];
            providerTest.provider3ImageThumb = [allPhysiciansImages objectAtIndex:provider3Index];
            providerTest.provider4ImageThumb = [allPhysiciansImages objectAtIndex:provider4Index];
            
            providerTest.provider1Text = [allPhysicians objectAtIndex:provider1Index];
            providerTest.provider2Text = [allPhysicians objectAtIndex:provider2Index];
            providerTest.provider3Text = [allPhysicians objectAtIndex:provider3Index];
            providerTest.provider4Text = [allPhysicians objectAtIndex:provider4Index];
            
        }
        [providerTest.provider1TextButton setTitle:providerTest.provider1Text forState:UIControlStateNormal];
        [providerTest.provider2TextButton setTitle:providerTest.provider2Text forState:UIControlStateNormal];
        [providerTest.provider3TextButton setTitle:providerTest.provider3Text forState:UIControlStateNormal];
        [providerTest.provider4TextButton setTitle:providerTest.provider4Text forState:UIControlStateNormal];
        
        providerTest.view.frame = backsplash.bounds;
        
        [surveyPageArray addObject:providerTest];
        
        pageIndex++;
        
        UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_subclinic_test_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *subclinicTest = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [subclinicTest retain];
        
        subclinicTest.currentSurveyPageType = kSubclinicTest;
        subclinicTest.surveyPageIndex = pageIndex;
        subclinicTest.delegate = self;
        subclinicTest.isSurveyPage = YES;
        subclinicTest.hidePreviousButton = NO;
        //sandy hide the next button here and then show it again after the selection
        subclinicTest.hidePreviousButton = YES;
        subclinicTest.hideNextButton = YES;
 // sandy 7-14
        //        subclinicTest.subclinicTestText = @"Based on the information you have been given, please tap the clinic you will be seen in today.";
        subclinicTest.subclinicTestText = @"Please tap the clinic you will be seen in today.";
        subclinicTest.subclinicTestLabel.text = subclinicTest.subclinicTestText;
        
        if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"General PM&R"]) {
            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
            subclinicTest.subclinic2Text = @"PNS Clinic";
            subclinicTest.subclinic3Text = @"EMG Clinic";
            subclinicTest.subclinic4Text = @"PM&R Clinic";
        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Acupuncture"]) {
            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
            subclinicTest.subclinic2Text = @"PNS Clinic";
            subclinicTest.subclinic3Text = @"EMG Clinic";
            subclinicTest.subclinic4Text = @"Acupuncture Clinic";
        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Pain"]) {
            subclinicTest.subclinic1Text = @"Acupuncture Clinic";
            subclinicTest.subclinic2Text = @"PNS Clinic";
            subclinicTest.subclinic3Text = @"EMG Clinic";
            subclinicTest.subclinic4Text = @"Chronic Pain Clinic";
        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"PNS"]) {
            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
            subclinicTest.subclinic2Text = @"Acupuncture Clinic";
            subclinicTest.subclinic3Text = @"EMG Clinic";
            subclinicTest.subclinic4Text = @"PNS Clinic";
        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"EMG"]) {
            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
            subclinicTest.subclinic2Text = @"PNS Clinic";
            subclinicTest.subclinic3Text = @"Acupuncture Clinic";
            subclinicTest.subclinic4Text = @"EMG Clinic";
        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"AT"]) {
            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
            subclinicTest.subclinic2Text = @"PNS Clinic";
            subclinicTest.subclinic3Text = @"Acupuncture Clinic";
            subclinicTest.subclinic4Text = @"AT Center";
        }
        
        [subclinicTest.subclinic1TextButton setTitle:subclinicTest.subclinic1Text forState:UIControlStateNormal];
        [subclinicTest.subclinic2TextButton setTitle:subclinicTest.subclinic2Text forState:UIControlStateNormal];
        [subclinicTest.subclinic3TextButton setTitle:subclinicTest.subclinic3Text forState:UIControlStateNormal];
        [subclinicTest.subclinic4TextButton setTitle:subclinicTest.subclinic4Text forState:UIControlStateNormal];
        
        [surveyPageArray addObject:subclinicTest];
        
        pageIndex++;
        
    }
    
    if (addGoalSurveyItems) {
        UIStoryboard *chooseGoalStoryboard = [UIStoryboard storyboardWithName:@"survey_choose_goal_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *chooseGoalPatient = [chooseGoalStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [chooseGoalPatient retain];
        
        chooseGoalPatient.currentSurveyPageType = kChooseGoal;
        chooseGoalPatient.surveyPageIndex = pageIndex;
        chooseGoalPatient.delegate = self;
        chooseGoalPatient.isSurveyPage = YES;
        chooseGoalPatient.hideNextButton = YES;
        //sandy hiding previous button here to ensure a selection
        // original chooseGoalPatient.hidePreviousButton = NO;
        chooseGoalPatient.hidePreviousButton = YES;
        
        // sandy 7-14
         //   chooseGoalPatient.goalChooseText = @"To better understand your sense of comfort for today's visit, which of the following would you like help with today?";
        chooseGoalPatient.goalChooseText = @"Which of the following would you like help with today?";
        chooseGoalPatient.goalChooseLabel.text = chooseGoalPatient.goalChooseText;
//        DynamicModuleViewController_Pad *currDelegate = (DynamicModuleViewController_Pad *)delegate;
//        GoalInfo* goalInfo = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getGoalInfo];
        GoalInfo* goalInfo = [DynamicContent getAllGoals];
        if (goalInfo != NULL){
            chooseGoalPatient.goal1Text = @"";
            chooseGoalPatient.goal2Text = @"";
            chooseGoalPatient.goal3Text = @"";
            chooseGoalPatient.goal4Text = @"";
            chooseGoalPatient.goal5Text = @"";
            chooseGoalPatient.goal6Text = @"";
            chooseGoalPatient.goal7Text = @"";
            chooseGoalPatient.goal8Text = @"";
            chooseGoalPatient.goal9Text = @"";
            chooseGoalPatient.goal10Text = @"";

            NSArray* selfGoals = [goalInfo getSelfGoals];
            if (selfGoals != NULL){
                int count = [selfGoals count];
                if (count == 1){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = @"Enter my own goal...";
                    chooseGoalPatient.goal3Text = @"None of the Above";
                    chooseGoalPatient.goal4Text = @"";
                    chooseGoalPatient.goal5Text = @"";
                    chooseGoalPatient.goal6Text = @"";
                    chooseGoalPatient.goal7Text = @"";
                    chooseGoalPatient.goal8Text = @"";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 2){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = @"Enter my own goal...";
                    chooseGoalPatient.goal4Text = @"None of the Above";
                    chooseGoalPatient.goal5Text = @"";
                    chooseGoalPatient.goal6Text = @"";
                    chooseGoalPatient.goal7Text = @"";
                    chooseGoalPatient.goal8Text = @"";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 3){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = @"Enter my own goal...";
                    chooseGoalPatient.goal5Text = @"None of the Above";
                    chooseGoalPatient.goal6Text = @"";
                    chooseGoalPatient.goal7Text = @"";
                    chooseGoalPatient.goal8Text = @"";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 4){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = [selfGoals objectAtIndex:3];
                    chooseGoalPatient.goal5Text = @"Enter my own goal...";
                    chooseGoalPatient.goal6Text = @"None of the Above";
                    chooseGoalPatient.goal7Text = @"";
                    chooseGoalPatient.goal8Text = @"";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                
                else
                if (count == 5){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = [selfGoals objectAtIndex:3];
                    chooseGoalPatient.goal5Text = [selfGoals objectAtIndex:4];
                    chooseGoalPatient.goal6Text = @"Enter my own goal...";
                    chooseGoalPatient.goal7Text = @"None of the Above";
                    chooseGoalPatient.goal8Text = @"";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 6){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = [selfGoals objectAtIndex:3];
                    chooseGoalPatient.goal5Text = [selfGoals objectAtIndex:4];
                    chooseGoalPatient.goal6Text = [selfGoals objectAtIndex:5];
                    chooseGoalPatient.goal7Text = @"Enter my own goal...";
                    chooseGoalPatient.goal8Text = @"None of the Above";
                    chooseGoalPatient.goal9Text = @"";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 7){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = [selfGoals objectAtIndex:3];
                    chooseGoalPatient.goal5Text = [selfGoals objectAtIndex:4];
                    chooseGoalPatient.goal6Text = [selfGoals objectAtIndex:5];
                    chooseGoalPatient.goal7Text = [selfGoals objectAtIndex:6];
                    chooseGoalPatient.goal8Text = @"Enter my own goal...";
                    chooseGoalPatient.goal9Text = @"None of the Above";
                    chooseGoalPatient.goal10Text = @"";
                }
                else
                if (count == 8){
                    chooseGoalPatient.goal1Text = [selfGoals objectAtIndex:0];
                    chooseGoalPatient.goal2Text = [selfGoals objectAtIndex:1];
                    chooseGoalPatient.goal3Text = [selfGoals objectAtIndex:2];
                    chooseGoalPatient.goal4Text = [selfGoals objectAtIndex:3];
                    chooseGoalPatient.goal5Text = [selfGoals objectAtIndex:4];
                    chooseGoalPatient.goal6Text = [selfGoals objectAtIndex:5];
                    chooseGoalPatient.goal7Text = [selfGoals objectAtIndex:6];
                    chooseGoalPatient.goal8Text = [selfGoals objectAtIndex:7];
                    chooseGoalPatient.goal9Text = @"Enter my own goal...";
                    chooseGoalPatient.goal10Text = @"None of the Above";
                }
            }
        }
        else {
            // no goal file found so use hardcoded goals
            chooseGoalPatient.goal1Text = @"Reduce my pain";
            chooseGoalPatient.goal2Text = @"Sleep better";
            chooseGoalPatient.goal3Text = @"Be more physically active";
            chooseGoalPatient.goal4Text = @"Talk to my treatment provider";
            chooseGoalPatient.goal5Text = @"Have more energy";
            chooseGoalPatient.goal6Text = @"Get tests done";
            chooseGoalPatient.goal7Text = @"Feel healthy";
            chooseGoalPatient.goal8Text = @"Get my next treatment";
            chooseGoalPatient.goal9Text = @"Enter my own goal...";
            chooseGoalPatient.goal10Text = @"None of the Above";
        }
        
        [chooseGoalPatient.goal1TextButton setTitle:chooseGoalPatient.goal1Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal2TextButton setTitle:chooseGoalPatient.goal2Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal3TextButton setTitle:chooseGoalPatient.goal3Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal4TextButton setTitle:chooseGoalPatient.goal4Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal5TextButton setTitle:chooseGoalPatient.goal5Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal6TextButton setTitle:chooseGoalPatient.goal6Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal7TextButton setTitle:chooseGoalPatient.goal7Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal8TextButton setTitle:chooseGoalPatient.goal8Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal9TextButton setTitle:chooseGoalPatient.goal9Text forState:UIControlStateNormal];
        [chooseGoalPatient.goal10TextButton setTitle:chooseGoalPatient.goal10Text forState:UIControlStateNormal];
        
        [surveyPageArray addObject:chooseGoalPatient];
        
        pageIndex++;
        NSLog(@"DynamicSurveyViewController_Pad.createarrayofAllSurveyPages() using minisurveypage2 survey_new_Painscale_template");
        UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *miniSurveyPage2 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage2 retain];
        
        miniSurveyPage2.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage2.surveyPageIndex = pageIndex;
        miniSurveyPage2.delegate = self;
        miniSurveyPage2.isSurveyPage = YES;
        // sandy be consistent with hiding previous so they don't go back into selections
        // original        miniSurveyPage2.hidePreviousButton = NO;
        miniSurveyPage2.hidePreviousButton = YES;
        // sandy need to read fontsize button here
        // sandy 7-14
        //miniSurveyPage2.currentPromptString = @"Please indicate how much you agree or disagree with the following statement:";
        miniSurveyPage2.currentPromptString = @"Please indicate how much you agree or disagree with the following statements:";
        miniSurveyPage2.currentPromptLabel.text = miniSurveyPage2.currentPromptString;
        miniSurveyPage2.currentSatisfactionString = @"I understand the reason or reasons for today's visit.";
        miniSurveyPage2.currentSatisfactionLabel.text = miniSurveyPage2.currentSatisfactionString;
        
        [surveyPageArray addObject:miniSurveyPage2];
        
        pageIndex++;
        // sandy 7-16 using simplepainscaleStoryboard with no label instead of painScaleStoryboard
        NSLog(@"DynamicSurveyViewController_Pad.createarrayofAllSurveyPages() using minisurveypage3 survey_new_Painscale_noprompt_template");
        UIStoryboard *simplePainscaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_noprompt_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *miniSurveyPage3 = [simplePainscaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage3 retain];
        
        miniSurveyPage3.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage3.surveyPageIndex = pageIndex;
        miniSurveyPage3.delegate = self;
        miniSurveyPage3.isSurveyPage = YES;
        miniSurveyPage3.hidePreviousButton = NO;
        miniSurveyPage3.currentPromptString = @"";
       // sandy 7-16 removed prompt label here instead of on form to roll back if needed
        // original miniSurveyPage3.currentPromptLabel.text = miniSurveyPage3.currentPromptString;
        miniSurveyPage3.currentPromptLabel.text = @"";
        miniSurveyPage3.currentSatisfactionString = @"I feel prepared for today's visit.";
        miniSurveyPage3.currentSatisfactionLabel.text = miniSurveyPage3.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage3];
        
        pageIndex++;
        // sandy 7-16 using simplepainscaleStoryboard with no label
        SwitchedImageViewController *miniSurveyPage4 = [simplePainscaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage4 retain];
        
        miniSurveyPage4.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage4.surveyPageIndex = pageIndex;
        miniSurveyPage4.delegate = self;
        miniSurveyPage4.isSurveyPage = YES;
        miniSurveyPage4.hidePreviousButton = NO;
        miniSurveyPage4.currentPromptString = @"";
        // sandy 7-16 removed prompt label here instead of on form to roll back if needed
        //miniSurveyPage4.currentPromptLabel.text = miniSurveyPage4.currentPromptString;
         miniSurveyPage4.currentPromptLabel.text = @"";
        miniSurveyPage4.currentSatisfactionString = @"I am looking forward to today's visit.";
        miniSurveyPage4.currentSatisfactionLabel.text = miniSurveyPage4.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage4];
        
        pageIndex++;
                NSLog(@"DynamicSurveyViewController.createarrayofAllSurveyPages() miniSurveyPageTransition uses storyboard survey_blank_template");
        UIStoryboard *generalSurveyStoryboard = [UIStoryboard storyboardWithName:@"survey_blank_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *miniSurveyPageTransition = [generalSurveyStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPageTransition retain];
        
        miniSurveyPageTransition.currentSurveyPageType = kGeneralSurveyPage;
        miniSurveyPageTransition.surveyPageIndex = pageIndex;
        miniSurveyPageTransition.delegate = self;
        miniSurveyPageTransition.isSurveyPage = YES;
        //sandy hide previous button here too
        // original miniSurveyPageTransition.hidePreviousButton = NO;
        miniSurveyPageTransition.hidePreviousButton = YES;
 
        //sandy right before ready button is enabled
        // sandy 7-20 removed the word doctor and replaced it with provider
        if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isFirstVisit]) {
            miniSurveyPageTransition.currentPromptString = @"Thank you for sharing your thoughts about today's visit.  Press next to learn more about your provider and the clinic where you will be seen today.";
        } else {
            miniSurveyPageTransition.currentPromptString = @"Thank you for sharing your thoughts about today's visit.  Press next to continue.";
        }
        
        miniSurveyPageTransition.currentPromptLabel.text = miniSurveyPage2.currentPromptString;
        
        [surveyPageArray addObject:miniSurveyPageTransition];
        
        pageIndex++;
        NSLog(@"DynamicSurveyViewController.createarrayofAllSurveyPages() provider module helpful uses storyboard survey_helpful_template");
        UIStoryboard *helpfulStoryboard = [UIStoryboard storyboardWithName:@"survey_helpful_template" bundle:[NSBundle mainBundle]];
        
        providerModuleHelpful = [helpfulStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [providerModuleHelpful retain];
        
        providerModuleHelpful.currentSurveyPageType = kHelpfulPainScale;
        providerModuleHelpful.surveyPageIndex = pageIndex;
        providerModuleHelpful.delegate = self;
        providerModuleHelpful.isSurveyPage = YES;
        providerModuleHelpful.hidePreviousButton = YES;
        
        // sandy 7-14
        //        providerModuleHelpful.helpfulText = @"Using the scale provided below, please indicate how helpful you found this information on your doctor.";
        // sandy 7-20 removed the word doctor and replaced it with provider
        providerModuleHelpful.helpfulText = @"Please indicate how helpful you found this information about your provider.";
        providerModuleHelpful.view.frame = backsplash.bounds;
        [surveyPageArray addObject:providerModuleHelpful];
        
        pageIndex++;
        
        //        UIStoryboard *helpfulStoryboard = [UIStoryboard storyboardWithName:@"survey_helpful_template" bundle:[NSBundle mainBundle]];
        
        subclinicModuleHelpful = [helpfulStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [subclinicModuleHelpful retain];
        
        subclinicModuleHelpful.currentSurveyPageType = kHelpfulPainScale;
        subclinicModuleHelpful.surveyPageIndex = pageIndex;
        subclinicModuleHelpful.delegate = self;
        subclinicModuleHelpful.isSurveyPage = YES;
        subclinicModuleHelpful.hidePreviousButton = YES;
        
        //sandy 7-14
        //        subclinicModuleHelpful.helpfulText = @"Using the scale provided below, please indicate how helpful you found this clinic information.";
        subclinicModuleHelpful.helpfulText = @"Please indicate how helpful you found this clinic information.";
        [surveyPageArray addObject:subclinicModuleHelpful];
        
        pageIndex++;
        
        UIStoryboard *chooseModuleStoryboard = [UIStoryboard storyboardWithName:@"survey_module_choice_template" bundle:[NSBundle mainBundle]];
        
        SwitchedImageViewController *chooseModule = [chooseModuleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [chooseModule retain];
        
        chooseModule.currentSurveyPageType = kChooseModule;
        chooseModule.surveyPageIndex = pageIndex;
        chooseModule.delegate = self;
        chooseModule.isSurveyPage = YES;
        chooseModule.hideNextButton = YES;
        chooseModule.hidePreviousButton = YES;
        
        chooseModule.chooseModuleText = @"Thank you for this information. As you wait a few more minutes for your appointment, would you like to:";
        chooseModule.chooseModuleLabel.text = chooseModule.chooseModuleText;
        chooseModule.extraModule1Text = @"Learn more about TBI and the Brain?";
        chooseModule.extraModule2Text = @"Learn more about What's New at the VA Polytrauma System of Care?";
        chooseModule.extraModule1Label.text = chooseModule.extraModule1Text;
        chooseModule.extraModule2Label.text = chooseModule.extraModule2Text;
        
        //        chooseGoal.view.frame = backsplash.bounds;
        [surveyPageArray addObject:chooseModule];
        
        pageIndex++;
        NSLog(@"DynamicSurveyViewController.createArrayOfAllSurveyPages() exit");

    }
    
    if (addMiniSurveyItems) {
        
        UIStoryboard *generalSurveyStoryboard = [UIStoryboard storyboardWithName:@"survey_blank_template" bundle:[NSBundle mainBundle]];
        SwitchedImageViewController *resumePageTransition = [generalSurveyStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [resumePageTransition retain];
        
        resumePageTransition.currentSurveyPageType = kGeneralSurveyPage;
        resumePageTransition.surveyPageIndex = pageIndex;
        resumePageTransition.delegate = self;
        resumePageTransition.isSurveyPage = YES;
        resumePageTransition.hidePreviousButton = YES;
        
        resumePageTransition.currentPromptString = @"Now that you have finished your visit with your treatment provider, please press next to move on to the satisfaction survey.";
        resumePageTransition.currentPromptLabel.text = resumePageTransition.currentPromptString;
        
        [surveyPageArray addObject:resumePageTransition];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        NSLog(@"DynamicSurveyViewController_Pad.addMiniSurveyItems() numberOfPostTreatmentItems %d",numberOfPostTreatmentItems);
        //        int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
        NSString *currentProviderFullName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName];
        
        NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
        NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
        NSLog(@"DynamicSurveyViewController_Pad.createarrayofAllSurveyPages() right before goals section of minisurveypages survey_new_Painscale_template");
       /* sandy 7-17 hack UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_template" bundle:[NSBundle mainBundle]];
        */
        /* sandy 7-16 make template conditional hack 
            This is set prior to the receptionist handing to patient
         Use a different index*/
        int currentpageVCIndex = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] vcIndex];
        
        NSLog(@"DynamicSurveyViewController.faceButtonPressed() uses storyboard survey_NEW_painscale_template or noprompt numberOfPostTreatmentItems = %d",numberOfPostTreatmentItems);
        UIStoryboard *painScaleStoryboard = NULL;
        if( currentpageVCIndex== 11)
            painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_template" bundle:[NSBundle mainBundle]];
        else
            painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_noprompt_template" bundle:[NSBundle mainBundle]];
        
        
         //sandy 7-14
        // goals section of miniSurveypage1 of post survey not used in updated version
        miniSurveyPage1 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage1 retain];
        
        miniSurveyPage1.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage1.surveyPageIndex = pageIndex;
        miniSurveyPage1.delegate = self;
        miniSurveyPage1.isSurveyPage = YES;
        miniSurveyPage1.hidePreviousButton = YES;
        
        NSString *fullPromptWithGoal = [NSString stringWithFormat:@"Earlier you shared some goals for today's visit."];

        if ([todaysGoal isEqualToString:@"None of the Above"]) {
            miniSurveyPage1.currentPromptString = [NSString stringWithFormat:@""];
            miniSurveyPage1.currentPromptLabel.text = miniSurveyPage1.currentPromptString;
            miniSurveyPage1.currentSatisfactionString = @"Please indicate how much you agree or disagree that today's visit met your expectations in general.";
        } else {
            miniSurveyPage1.currentPromptString = fullPromptWithGoal;
            miniSurveyPage1.currentPromptLabel.text = miniSurveyPage1.currentPromptString;
            miniSurveyPage1.currentSatisfactionString = @"Please indicate how much you agree or disagree that today's visit met your expectations regarding these goals.";
        }
        
        miniSurveyPage1.currentSatisfactionLabel.text = miniSurveyPage1.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage1];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        //
        // Waiting Room Comfort Items
        // sandy 7-14
        // waiting room comfort survey not used after 7-15
        SwitchedImageViewController *wrComfortPage1 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [wrComfortPage1 retain];
        
        wrComfortPage1.currentSurveyPageType = kAgreementPainScale;
        wrComfortPage1.surveyPageIndex = pageIndex;
        wrComfortPage1.delegate = self;
        wrComfortPage1.isSurveyPage = YES;
        wrComfortPage1.hidePreviousButton = NO;
        wrComfortPage1.currentPromptString = @"Based on my time in this waiting room:";
        wrComfortPage1.currentPromptLabel.text = wrComfortPage1.currentPromptString;
        wrComfortPage1.currentSatisfactionString = @"I have enjoyed the decorations.";
        wrComfortPage1.currentSatisfactionLabel.text = wrComfortPage1.currentSatisfactionString;
        [surveyPageArray addObject:wrComfortPage1];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        SwitchedImageViewController *wrComfortPage2 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [wrComfortPage2 retain];
        
        wrComfortPage2.currentSurveyPageType = kAgreementPainScale;
        wrComfortPage2.surveyPageIndex = pageIndex;
        wrComfortPage2.delegate = self;
        wrComfortPage2.isSurveyPage = YES;
        wrComfortPage2.hidePreviousButton = NO;
        wrComfortPage2.currentPromptString = @"Based on my time in this waiting room:";
        wrComfortPage2.currentPromptLabel.text = wrComfortPage2.currentPromptString;
        wrComfortPage2.currentSatisfactionString = @"I feel welcome and comfortable.";
        wrComfortPage2.currentSatisfactionLabel.text = wrComfortPage2.currentSatisfactionString;
        [surveyPageArray addObject:wrComfortPage2];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        SwitchedImageViewController *wrComfortPage3 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [wrComfortPage3 retain];
        
        wrComfortPage3.currentSurveyPageType = kAgreementPainScale;
        wrComfortPage3.surveyPageIndex = pageIndex;
        wrComfortPage3.delegate = self;
        wrComfortPage3.isSurveyPage = YES;
        wrComfortPage3.hidePreviousButton = NO;
        wrComfortPage3.currentPromptString = @"Based on my time in this waiting room:";
        wrComfortPage3.currentPromptLabel.text = wrComfortPage3.currentPromptString;
        wrComfortPage3.currentSatisfactionString = @"I like the amenities, such as the coffee, TV, and reading material.";
        wrComfortPage3.currentSatisfactionLabel.text = wrComfortPage3.currentSatisfactionString;
        [surveyPageArray addObject:wrComfortPage3];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        SwitchedImageViewController *wrComfortPage4 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [wrComfortPage4 retain];
        
        wrComfortPage4.currentSurveyPageType = kAgreementPainScale;
        wrComfortPage4.surveyPageIndex = pageIndex;
        wrComfortPage4.delegate = self;
        wrComfortPage4.isSurveyPage = YES;
        wrComfortPage4.hidePreviousButton = NO;
        wrComfortPage4.currentPromptString = @"Based on my time in this waiting room:";
        wrComfortPage4.currentPromptLabel.text = wrComfortPage4.currentPromptString;
        wrComfortPage4.currentSatisfactionString = @"I wish more waiting rooms were like this one.";
        wrComfortPage4.currentSatisfactionLabel.text = wrComfortPage4.currentSatisfactionString;
        [surveyPageArray addObject:wrComfortPage4];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        // End Waiting Room Comfort Items
        
        SwitchedImageViewController *miniSurveyPage5 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage5 retain];
        
        miniSurveyPage5.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage5.surveyPageIndex = pageIndex;
        miniSurveyPage5.delegate = self;
        miniSurveyPage5.isSurveyPage = YES;
        miniSurveyPage5.hidePreviousButton = NO;
        miniSurveyPage5.currentPromptString = @"Based on my use of this waiting room guide:";
        miniSurveyPage5.currentPromptLabel.text = miniSurveyPage5.currentPromptString;
        miniSurveyPage5.currentSatisfactionString = @"I felt more prepared for today's visit.";
        miniSurveyPage5.currentSatisfactionLabel.text = miniSurveyPage5.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage5];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        SwitchedImageViewController *miniSurveyPage6 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage6 retain];
        
        miniSurveyPage6.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage6.surveyPageIndex = pageIndex;
        miniSurveyPage6.delegate = self;
        miniSurveyPage6.isSurveyPage = YES;
        miniSurveyPage6.hidePreviousButton = NO;
        miniSurveyPage6.currentPromptString = miniSurveyPage5.currentPromptString;
        miniSurveyPage6.currentPromptLabel.text = miniSurveyPage6.currentPromptString;
        miniSurveyPage6.currentSatisfactionString = @"I felt more knowledgeable about my visit.";
        miniSurveyPage6.currentSatisfactionLabel.text = miniSurveyPage6.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage6];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
   
        SwitchedImageViewController *miniSurveyPage7 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage7 retain];
        
        miniSurveyPage7.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage7.surveyPageIndex = pageIndex;
        miniSurveyPage7.delegate = self;
        miniSurveyPage7.isSurveyPage = YES;
        miniSurveyPage7.hidePreviousButton = NO;
        miniSurveyPage7.currentPromptString = miniSurveyPage5.currentPromptString;
        miniSurveyPage7.currentPromptLabel.text = miniSurveyPage7.currentPromptString;
        miniSurveyPage7.currentSatisfactionString = @"I would recommend this guide to a friend or family member.";
        miniSurveyPage7.currentSatisfactionLabel.text = miniSurveyPage7.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage7];
        
        pageIndex++;
        numberOfPostTreatmentItems++;
        
        SwitchedImageViewController *miniSurveyPage8 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        [miniSurveyPage8 retain];
        
        miniSurveyPage8.currentSurveyPageType = kAgreementPainScale;
        miniSurveyPage8.surveyPageIndex = pageIndex;
        miniSurveyPage8.delegate = self;
        miniSurveyPage8.isSurveyPage = YES;
        miniSurveyPage8.hidePreviousButton = NO;
        miniSurveyPage8.currentPromptString = miniSurveyPage5.currentPromptString;
        miniSurveyPage8.currentPromptLabel.text = miniSurveyPage8.currentPromptString;
        miniSurveyPage8.currentSatisfactionString = @"Overall, I like this type of technology.";
        miniSurveyPage8.currentSatisfactionLabel.text = miniSurveyPage8.currentSatisfactionString;
        [surveyPageArray addObject:miniSurveyPage8];

        pageIndex++;
        numberOfPostTreatmentItems++;
       
        //sandy tried to turn of next button at end of survey This is the front button. It gets set at the start of the survey page presentation,
       // miniSurveyPage8.hideNextButton = YES;
        
    }
    
    return surveyPageArray;
}


//sandy 7-14 goal rating questions removed on 7-15

- (void)updateGoalRatingText {
    NSLog(@"DynamicSurveyViewController_Pad.updateGoalRatingText()");

    int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
    NSMutableArray* allPhysicians = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysicians];
    
    NSString *currentProviderFullName = [allPhysicians objectAtIndex:currentProviderIndex];
//    NSString *currentProviderFullName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:currentProviderIndex];
    
    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    //    NSString *fullPromptWithGoal = [NSString stringWithFormat:@"Right before your visit with Dr. %@, you shared that you wanted to: %@", thisPhysicianNameAlone,todaysGoal];
    
//    NSString *fullPromptWithGoal = [NSString stringWithFormat:@"Right before your visit you shared this goal: %@", thisPhysicianNameAlone,todaysGoal];// rjl

    NSString *fullPromptWithGoal = [NSString stringWithFormat:@"Right before your visit you shared this goal: %@",todaysGoal];// rjl
    if ([todaysGoal isEqualToString:@"None of the Above"]) {
        miniSurveyPage1.currentPromptString = [NSString stringWithFormat:@""];
        miniSurveyPage1.currentPromptLabel.text = miniSurveyPage1.currentPromptString;
        miniSurveyPage1.currentSatisfactionString = @"Please indicate how much you agree or disagree that today's visit met your expectations in general.";
    } else {
        miniSurveyPage1.currentPromptString = fullPromptWithGoal;
        miniSurveyPage1.currentPromptLabel.text = miniSurveyPage1.currentPromptString;
        miniSurveyPage1.currentSatisfactionString = @"Please indicate how much you agree or disagree that today's visit met your expectations regarding this goal.";
    }
}
// sandy as of version 2.0 this  clinic id test is no longer used
- (void)showModalSubclinicTestCorrectView {
    NSLog(@"In showModalSubclinicTestCorrectView...");
    
    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
    SwitchedImageViewController *subclinicTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = subclinicTestCorrect;
    
    subclinicTestCorrect.currentSurveyPageType = kOk;
    subclinicTestCorrect.surveyPageIndex = 2;
    subclinicTestCorrect.delegate = self;
    subclinicTestCorrect.isSurveyPage = YES;
    
    //    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thisFullPhysicianName componentsSeparatedByString:@","] copyItems:YES];
    //    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    
    NSString *subclinicCorrectText = [NSString stringWithFormat:@"That's right, you will be seen today in the  %@ Clinic.  Press OK to continue.",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
    
    subclinicTestCorrect.currentPromptString = subclinicCorrectText;
    subclinicTestCorrect.currentPromptLabel.text = subclinicCorrectText;
    
    subclinicTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    subclinicTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
    subclinicTestCorrect.view.transform = rotateRight;
    [self presentModalViewController:subclinicTestCorrect animated:YES];
    [subclinicTestCorrect release];
    
    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    thisSurveyPage.subclinicTestLabel.text = @"Press next to continue.";
    
    //    [self hideButtonOverlay:standardPageButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideCurrentButtonOverlay];
}

- (void)showModalSubclinicTestIncorrectView {
    NSLog(@"In showModalSubclinicTestIncorrectView...");
    
    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
    SwitchedImageViewController *subclinicTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = subclinicTestCorrect;
    
    subclinicTestCorrect.currentSurveyPageType = kOk;
    subclinicTestCorrect.surveyPageIndex = 2;
    subclinicTestCorrect.delegate = self;
    subclinicTestCorrect.isSurveyPage = YES;
    
    //    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thisFullPhysicianName componentsSeparatedByString:@","] copyItems:YES];
    //    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    
    NSString *subclinicCorrectText = [NSString stringWithFormat:@"Actually, while that is an example of a clinic here, you will be seen today in the  %@ Clinic.  Press OK to continue.",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
    
    subclinicTestCorrect.currentPromptString = subclinicCorrectText;
    subclinicTestCorrect.currentPromptLabel.text = subclinicCorrectText;
    
    subclinicTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    subclinicTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
    subclinicTestCorrect.view.transform = rotateRight;
    [self presentModalViewController:subclinicTestCorrect animated:YES];
    [subclinicTestCorrect release];
    
    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    thisSurveyPage.subclinicTestLabel.text = @"Press next to continue.";
    
    //    [self hideButtonOverlay:standardPageButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideCurrentButtonOverlay];
    
}

- (void)showModalProviderTestCorrectView {
    NSLog(@"In showModalSubclinicTestCorrectView...");
    
    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
    SwitchedImageViewController *providerTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = providerTestCorrect;
    
    providerTestCorrect.currentSurveyPageType = kOk;
    providerTestCorrect.surveyPageIndex = 2;
    providerTestCorrect.delegate = self;
    providerTestCorrect.isSurveyPage = YES;
    
    int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
    NSString *currentProviderFullName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:currentProviderIndex];
    
    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    
    NSString *providerCorrectText = [NSString stringWithFormat:@"That's right, you are meeting with Dr. %@ today.  Press OK to continue.",thisPhysicianNameAlone];
    
    providerTestCorrect.currentPromptString = providerCorrectText;
    providerTestCorrect.currentPromptLabel.text = providerCorrectText;
    
    providerTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    providerTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [providerTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
    providerTestCorrect.view.transform = rotateRight;
    [self presentModalViewController:providerTestCorrect animated:YES];
    [providerTestCorrect release];
    
    //    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    //    thisSurveyPage.providerTestLabel.text = @"Press next to continue.";
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] nextPhysicianDetailButton] setEnabled:NO];
    
}

- (void)showModalProviderTestIncorrectView {
    NSLog(@"In showModalSubclinicTestIncorrectView...");
    
    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
    SwitchedImageViewController *providerTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = providerTestCorrect;
    
    providerTestCorrect.currentSurveyPageType = kOk;
    providerTestCorrect.surveyPageIndex = 2;
    providerTestCorrect.delegate = self;
    providerTestCorrect.isSurveyPage = YES;
    
    int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
    NSString *currentProviderFullName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] objectAtIndex:currentProviderIndex];
    
    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[currentProviderFullName componentsSeparatedByString:@","] copyItems:YES];
    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
    
    NSString *providerIncorrectText = [NSString stringWithFormat:@"Actually, while that treatment provider also works at the VA, today you will be meeting with Dr. %@.  Press OK to continue.",thisPhysicianNameAlone];
    
    providerTestCorrect.currentPromptString = providerIncorrectText;
    providerTestCorrect.currentPromptLabel.text = providerIncorrectText;
    
    providerTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    providerTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [providerTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
    providerTestCorrect.view.transform = rotateRight;
    [self presentModalViewController:providerTestCorrect animated:YES];
    [providerTestCorrect release];
    
    //    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    //    thisSurveyPage.providerTestLabel.text = @"Press next to continue.";
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] nextPhysicianDetailButton] setEnabled:NO];
    
}

- (void)dismissCurrentModalVC {
    [currentModalVC dismissModalViewControllerAnimated:YES];
    //    [self showButtonOverlay:standardPageButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
    
    //    [self overlayNextPressed];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] overlayNextPressed];
}

- (void)showTempPopover {
    
    NSLog(@"showTempPopover...");
    
    [termPopoverViewController showPopover:self.view];
}

- (void)startingFirstPage {
    
    [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"silence_quarter_second", nil]];
    
    NSLog(@"DynamicSurveyViewController.startingFirstPage() startingFirstPage of dynamic survey module...");
    
    finishingLastItem = NO;
    currentFinishingIndex = 6;
    
    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    [self fadeThisObjectIn:standardPageButtonOverlay.view];
    
    SwitchedImageViewController *firstPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [self handleButtonOverlayForPageIndex:vcIndex];
    [self playSoundForSurveyPage:firstPage];
    
}

- (void)startOnSurveyPageWithIndex:(int)pageIndex withFinishingIndex:(int)finishingPageIndex {
    
    [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"silence_quarter_second", nil]];
    
    NSLog(@"DynamicSurveyViewController.startOnSurveyPageWithIndex() start and stop index! starting on survey page: %d and ending on survey page: %d...", pageIndex, finishingPageIndex);
    
    currentFinishingIndex = finishingPageIndex;
    finishingLastItem = NO;
    
    //    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    //    [self fadeThisObjectIn:standardPageButtonOverlay.view];
    
    [self switchToView:pageIndex goingForward:NO];
    
    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:pageIndex];
    
    [self handleButtonOverlayForPageIndex:pageIndex];
    [self playSoundForSurveyPage:thisSurveyPage];
    
}

- (void)startOnSurveyPageWithIndex:(int)pageIndex {
    
    [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"silence_quarter_second", nil]];
    
    NSLog(@"DynamicSurveyViewController.startOnSurveyPageWithIndex() start index only! starting on survey page: %d...", pageIndex);
    
    finishingLastItem = NO;
    
    //    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    //    [self fadeThisObjectIn:standardPageButtonOverlay.view];
    
    [self switchToView:pageIndex goingForward:NO];
    
    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:pageIndex];
    
    [self handleButtonOverlayForPageIndex:pageIndex];
    [self playSoundForSurveyPage:thisSurveyPage];
    
}

- (void)startingFirstMiniSurveyPage {
    
    NSLog(@"DynamicSurveyViewController.startingFirstMiniSurveyPage() startingFirstPage of dynamic module...");
    
    //    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    //    if ([firstPage.showButtonsFor isEqualToString:@"previousnext"]) {
    //        [self showButtonOverlay:￼standardPageButtonOverlay];
    //    } else if ([firstPage.showButtonsFor isEqualToString:@"yesno"]) {
    //        [self showButtonOverlay:yesNoButtonOverlay];
    //    } else {
    //        [self showButtonOverlay:￼standardPageButtonOverlay];
    //    }
    
    //    if (showModuleHeader) {
    [self.view sendSubviewToBack:dynamicModuleHeader.view];
    [self fadeThisObjectOut:dynamicModuleHeader.view];
    //    }
    
    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
    [self fadeThisObjectIn:standardPageButtonOverlay.view];
    
    [self switchToView:7 goingForward:NO];
    
    SwitchedImageViewController *firstMiniSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:([newChildControllers count]-6)];
    
    [self playSoundForSurveyPage:firstMiniSurveyPage];
    
}

- (void)startingFinalSurveyPage {
        NSLog(@"DynamicSurveyViewController.startingFinalMiniSurveyPage()");
}

- (void)playSoundForCurrentSurveyPage {
    NSLog(@"DynamicSurveyViewController.playSoundForCurrentSurveyPage()");

    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    [self playSoundForSurveyPage:thisSurveyPage];
}

- (void)playSoundForSurveyPage:(SwitchedImageViewController *)currentSurveyPage {
    NSLog(@"DynamicSurveyViewController.playSoundForSurveyPage()");

    if (speakItemsAloud) {
        
        int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
        int numAttendingPhysicians = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] count];
//        NSMutableArray *physicianSoundfiles = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansSoundFiles];
        
        NSMutableArray *allPhysicianSoundfiles = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysiciansSoundFiles];
        
        int provider1Index;
        
        NSMutableArray *soundNameArray = [[NSMutableArray alloc] initWithObjects: nil];
        
        switch (currentSurveyPage.currentSurveyPageType) {
            case kChooseGoal:
                [soundNameArray addObject:[NSString stringWithFormat:@"%@dynamicSurveyPage%d_%@",@"~",vcIndex,[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] respondentType]]];
                
                break;
            case kProviderTest:
                [soundNameArray addObject:[NSString stringWithFormat:@"~dynamicSurveyPage%d",vcIndex]];
                
                provider1Index = currentProviderIndex - 1;
                if (provider1Index < 0) {
                    provider1Index = numAttendingPhysicians - 1;
                }
                int provider2Index = currentProviderIndex;
                int provider3Index = provider1Index - 1;
                if (provider3Index < 0) {
                    provider3Index = numAttendingPhysicians - 1;
                }
                int provider4Index = provider3Index - 1;
                if (provider4Index < 0) {
                    provider4Index = numAttendingPhysicians - 1;
                }
                int physicianCount = [allPhysicianSoundfiles count];
                NSMutableArray *physicianButtonIndexes = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:provider1Index],[NSNumber numberWithInt:provider2Index],[NSNumber numberWithInt:provider3Index],[NSNumber numberWithInt:provider4Index], nil];
                for (NSNumber *thisPhysicianIndex in physicianButtonIndexes) {
                    int currentPhysicianIdx = [thisPhysicianIndex intValue];
                    if (currentPhysicianIdx < physicianCount){
                        NSString *thisPhysicianTextFilename = [NSString stringWithFormat:@"%@_name",[allPhysicianSoundfiles objectAtIndex:currentPhysicianIdx]];
                        [soundNameArray addObject:thisPhysicianTextFilename];
                    }
                }
                
                break;
            case kSubclinicTest:
                [soundNameArray addObject:[NSString stringWithFormat:@"~dynamicSurveyPage%d",vcIndex]];
                
                
                if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"General PM&R"]) {
                    [soundNameArray addObject:@"specialty_clinic_pain"];
                    [soundNameArray addObject:@"specialty_clinic_pns"];
                    [soundNameArray addObject:@"specialty_clinic_emg"];
                    [soundNameArray addObject:@"pmnr_main_clinic"];
                } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Acupuncture"]) {
                    [soundNameArray addObject:@"specialty_clinic_pain"];
                    [soundNameArray addObject:@"specialty_clinic_pns"];
                    [soundNameArray addObject:@"specialty_clinic_emg"];
                    [soundNameArray addObject:@"specialty_clinic_acupuncture"];
                } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Pain"]) {
                    [soundNameArray addObject:@"specialty_clinic_acupuncture"];
                    [soundNameArray addObject:@"specialty_clinic_pns"];
                    [soundNameArray addObject:@"specialty_clinic_emg"];
                    [soundNameArray addObject:@"specialty_clinic_pain"];
                } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"PNS"]) {
                    [soundNameArray addObject:@"specialty_clinic_pain"];
                    [soundNameArray addObject:@"specialty_clinic_acupuncture"];
                    [soundNameArray addObject:@"specialty_clinic_emg"];
                    [soundNameArray addObject:@"specialty_clinic_pns"];
                } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"EMG"]) {
                    [soundNameArray addObject:@"specialty_clinic_pain"];
                    [soundNameArray addObject:@"specialty_clinic_pns"];
                    [soundNameArray addObject:@"specialty_clinic_acupuncture"];
                    [soundNameArray addObject:@"specialty_clinic_emg"];
                }
                break;
            default:
                if (vcIndex == 11) {
                    if ([todaysGoal isEqualToString:@"None of the Above"]) {
                        [soundNameArray addObject:[NSString stringWithFormat:@"~feedback_none_selected"]];
                    } else {
                        [soundNameArray addObject:[NSString stringWithFormat:@"~feedback_goal_selected"]];
                    }
                } else if (vcIndex == 6) {
                    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isFirstVisit]) {
                        // First visit = default
                        [soundNameArray addObject:[NSString stringWithFormat:@"~dynamicSurveyPage%d",vcIndex]];
                    } else {
                        // Follow up visit = alternate
                        [soundNameArray addObject:[NSString stringWithFormat:@"~dynamicSurveyPage%d_followup",vcIndex]];
                    }
                } else {
                    [soundNameArray addObject:[NSString stringWithFormat:@"~dynamicSurveyPage%d",vcIndex]];
                }
                break;
        }
        
        [masterTTSPlayer playItemsWithNames:soundNameArray];
        
    }
}

- (void)showButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay {
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
    NSLog(@"DynamicSurveyViewController_Pad.overlayNextPressed()");
    [self progress:self];
  //  currentWRViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
}

- (void)overlayPreviousPressed {
    NSLog(@"overlayPreviousPressed...");
    finishingLastItem = false; //rjl
    [self regress:self];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] decrementProgressBar];
}

- (void)overlayYesPressed {
    NSLog(@"overlayYesPressed...");
    if (inSubclinicMode) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchSatisfactionSurvey];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchDynamicSubclinicEducationModule];
    }
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
    NSLog(@"DynamicSurveyViewController_Pad.overlayFontsizePressed()...");
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

- (void)showModule1CompletedBadge {
    SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    [currentSwitchedController showModule1Badge];
}

- (void)showModule2CompletedBadge {
    SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
    [currentSwitchedController showModule2Badge];
}

// Transition to new view using custom segue
- (void)switchToView:(int) newIndex goingForward:(BOOL) goesForward
{
    NSLog(@"DynamicSurveyViewController_Pad.switchToView() index %d", newIndex);
    
    if (finishingLastItem)
    {
        if (vcIndex == 6) {
            NSLog(@"DynamicSurveyViewController_Pad.switchToView() setCompletedProviderAndSubclinicSurvey=YES");
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setCompletedProviderAndSubclinicSurvey:YES];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] finishedPartOfDynamicSurvey];
            
        } else if (vcIndex == 19) {
            NSLog(@"DynamicSurveyViewController_Pad.switchToView() setCompletedFinalSurvey:YES");
            
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setCompletedFinalSurvey:YES];
            
            vcIndex = newIndex;
            
            newTimer = [[NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(handleSurveyFinished:) userInfo:nil repeats:NO] retain];
            [[NSRunLoop currentRunLoop] addTimer:newTimer forMode:NSDefaultRunLoopMode];
        } else {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] finishedPartOfDynamicSurvey];
        }
        
        
        
        //        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] finishedPartOfDynamicSurvey];
        
        // Back to menu
        //        SwitchedImageViewController *newPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
        //        [self playSoundForSurveyPage:newPage];
        
        return;
        
    } else {
        
        NSLog(@"DynamicSurveyViewController_Pad.switchToView() SWITCHING from dynamic survey item %d to item %d", vcIndex, newIndex);
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        source.view.frame = [[UIScreen mainScreen] applicationFrame];  //rjl
        destination.view.frame = [[UIScreen mainScreen] applicationFrame];  //rjl
        [destination.view layoutSubviews];
        [segue perform];

        vcIndex = newIndex;
        
        [self handleButtonOverlayForPageIndex:vcIndex];
        [self playSoundForSurveyPage:[newChildControllers objectAtIndex:vcIndex]];
        
        if (vcIndex == currentFinishingIndex) {
            NSLog(@"DynamicSurveyViewController_Pad.switchToView() LAST PAGE");
            finishingLastItem = YES;
            @try {
//               [[[AppDelegate_Pad sharedAppDelegate] miniDemoVC] menuButtonPressed];  //rjl 6/26/14
            }
            @catch(NSException *ne){
                NSLog(@"DynamicSurveyViewController_Pad.switchToView() ERROR");
            }
            // sandy turn off previous button if finished with survey - too late here
            //standardPageButtonOverlay.previousPageButton.enabled = NO;
            
            //        } else if (vcIndex == ([newChildControllers count] - 10)) {
            
            
        }
        
        if (vcIndex == 0) {
            NSLog(@"DynamicSurveyViewController_Pad.switchToView() FIRST PAGE");
            standardPageButtonOverlay.previousPageButton.enabled = NO;
        } else {
            standardPageButtonOverlay.previousPageButton.enabled = YES;
        }
        
    }
}

- (void)handleSurveyFinished:(NSTimer*)theTimer {
    [theTimer release];
	theTimer = nil;
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] finishedPartOfDynamicSurvey];
}

- (void)handleButtonOverlayForPageIndex:(int)thisPageIndex {
    NSLog(@"DynamicSurveyViewController_iPad.handleButtonOverlayForPageIndex() thisPageIndex: %d",thisPageIndex);
    SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:thisPageIndex];
    if (currentSwitchedController.hidePreviousButton) {
        //        [standardPageButtonOverlay fadeThisObjectOut:standardPageButtonOverlay.previousPageButton];
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
    } else {
        //        [standardPageButtonOverlay fadeThisObjectIn:standardPageButtonOverlay.previousPageButton];
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
    }
    if (currentSwitchedController.hideNextButton) {
        //        [standardPageButtonOverlay fadeThisObjectOut:standardPageButtonOverlay.nextPageButton];
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];
    } else {
        //        [standardPageButtonOverlay fadeThisObjectIn:standardPageButtonOverlay.nextPageButton];
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
    }
    
}

- (void)hideOverlayNextButton {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];
}

- (void)hideOverlayPreviousButton {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
}

- (void)showOverlayNextButton {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
}

- (void)showOverlayPreviousButton {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
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
     NSLog(@"DynamicSurveyViewController_Pad.stopMoviePlayback ...");
    if (playingMovie) {
        NSLog(@"Stopping currently playing movie if movie is playing...");
        SwitchedImageViewController *currentSwitchedController = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
        NSLog(@"vcindex=%d",vcIndex);
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