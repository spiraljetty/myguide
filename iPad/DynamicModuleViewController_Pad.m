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
#import "PopoverPlaygroundViewController.h"

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

@synthesize masterTTSPlayer;

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
@synthesize standardPageButtonOverlay, yesNoButtonOverlay, dynamicModuleHeader, showModuleHeader;

@synthesize termPopoverViewController, hiddenPopoverButton;

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
    
    standardPageButtonOverlay.view.frame = CGRectMake(390, 400, 1024, 233);
//    standardPageButtonOverlay.view.backgroundColor = [UIColor redColor];
    
    standardPageButtonOverlay.view.alpha = 0.0;
    yesNoButtonOverlay.view.alpha = 0.0;
    standardPageButtonOverlay.view.transform = rotateLeft;
    yesNoButtonOverlay.view.transform = rotateLeft;
//    [standardPageButtonOverlay.view setCenter:CGPointMake(522.0f, 385.0f)];
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
    
//    [self.playerView setPlayer:self.queuePlayer];

//    BOOL addPrePostSurveyItems;
//    BOOL addMiniSurveyItems;
//    
//    if (inSubclinicMode) {
//        addPrePostSurveyItems = YES;
//        addMiniSurveyItems = YES;
//    } else {
//        addPrePostSurveyItems = NO;
//    }
    
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
        
//        if ([thisPage.headerText isEqualToString:@"NA"]) {
//            dynamicPageSubDetailVC.headerLabelText = @"";
//            dynamicPageSubDetailVC.dynamicPageHeaderLabel.text = @"";
//        } else {
            dynamicPageSubDetailVC.headerLabelText = thisPage.headerText;
            dynamicPageSubDetailVC.dynamicPageHeaderLabel.text = thisPage.headerText;
//        }
        
        if (thisPage.imagePage) {
            dynamicPageSubDetailVC.needsImage = YES;
//            dynamicPageSubDetailVC.dynamicImageView.image = [UIImage imageNamed:thisPage.imageFilename];
            dynamicPageSubDetailVC.currentImageFilename = thisPage.imageFilename;
        }
        
        dynamicPageSubDetailVC.view.tag = 1066;
        dynamicPageSubDetailVC.view.frame = backsplash.bounds;
        
        [thisPage.view addSubview:dynamicPageSubDetailVC.view];
        
        [self addChildViewController:thisPage];
        
        pageIndex++;
    }
    
//    if (addPrePostSurveyItems) {
//        
//        UIStoryboard *helpfulStoryboard = [UIStoryboard storyboardWithName:@"survey_helpful_template" bundle:[NSBundle mainBundle]];
//        
//        SwitchedImageViewController *subclinicModuleHelpful = [helpfulStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        
//        subclinicModuleHelpful.currentSurveyPageType = kHelpfulPainScale;
//        subclinicModuleHelpful.surveyPageIndex = 1;
//        subclinicModuleHelpful.delegate = self;
//        subclinicModuleHelpful.isSurveyPage = YES;
//        subclinicModuleHelpful.helpfulText = @"Using the scale provided below, please tap how helpful you found this information on the clinic you are visiting today.";
//        [newChildControllers addObject:subclinicModuleHelpful];
//        
//        UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_subclinic_test_template" bundle:[NSBundle mainBundle]];
//        
//        SwitchedImageViewController *subclinicTest = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        
//        subclinicTest.currentSurveyPageType = kSubclinicTest;
//        subclinicTest.surveyPageIndex = 1;
//        subclinicTest.delegate = self;
//        subclinicTest.isSurveyPage = YES;
    
//        int currentProviderIndex = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianIndex];
//        int numAttendingPhysicians = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians] count];
//        int provider1Index = currentProviderIndex - 1;
//        if (provider1Index < 0) {
//            provider1Index = numAttendingPhysicians - 1;
//        }
//        int provider2Index = currentProviderIndex;
//        int provider3Index = provider1Index - 1;
//        if (provider3Index < 0) {
//            provider3Index = numAttendingPhysicians - 1;
//        }
//        int provider4Index = provider3Index - 1;
//        if (provider4Index < 0) {
//            provider4Index = numAttendingPhysicians - 1;
//        }
//        
//        subclinicTest.subclinicTestText = @"Based on the information you have been given, please tap the clinic you will be seen in today.";
//
//        if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Acupuncture"]) {
//            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
//            subclinicTest.subclinic2Text = @"PNS Clinic";
//            subclinicTest.subclinic3Text = @"EMG Clinic";
//            subclinicTest.subclinic4Text = @"Acupuncture Clinic";
//            
//        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Pain"]) {
//            subclinicTest.subclinic1Text = @"Acupuncture Clinic";
//            subclinicTest.subclinic2Text = @"PNS Clinic";
//            subclinicTest.subclinic3Text = @"EMG Clinic";
//            subclinicTest.subclinic4Text = @"Chronic Pain Clinic";
//        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"PNS"]) {
//            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
//            subclinicTest.subclinic2Text = @"Acupuncture Clinic";
//            subclinicTest.subclinic3Text = @"EMG Clinic";
//            subclinicTest.subclinic4Text = @"PNS Clinic";
//        } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"EMG"]) {
//            subclinicTest.subclinic1Text = @"Chronic Pain Clinic";
//            subclinicTest.subclinic2Text = @"PNS Clinic";
//            subclinicTest.subclinic3Text = @"Acupuncture Clinic";
//            subclinicTest.subclinic4Text = @"EMG Clinic";
//        }
//        
//        subclinicTest.subclinic1TextButton.titleLabel.text = subclinicTest.subclinic1Text;
//        subclinicTest.subclinic2TextButton.titleLabel.text = subclinicTest.subclinic2Text;
//        subclinicTest.subclinic3TextButton.titleLabel.text = subclinicTest.subclinic3Text;
//        subclinicTest.subclinic4TextButton.titleLabel.text = subclinicTest.subclinic4Text;
//        
//        
//        [newChildControllers addObject:subclinicTest];
//        
//    }
//    
//    if (addMiniSurveyItems) {
//        UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_agree_disagree_template" bundle:[NSBundle mainBundle]];
//        
//        SwitchedImageViewController *miniSurveyPage1 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage1 retain];
//        
//        miniSurveyPage1.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage1.surveyPageIndex = 0;
//        miniSurveyPage1.delegate = self;
//        miniSurveyPage1.isSurveyPage = YES;
//        miniSurveyPage1.currentPromptString = @"Please indicate whether you agree or disagree with the following statement:";
//        miniSurveyPage1.currentPromptLabel.text = @"Please indicate whether you agree or disagree with the following statement:";
//        miniSurveyPage1.newAgreeDisagreeLabel.text = @"I have some concerns about today's visit.";
//        miniSurveyPage1.newAgreeDisagreeText = @"I have some concerns about today's visit.";
//        [newChildControllers addObject:miniSurveyPage1];
//        
//        SwitchedImageViewController *miniSurveyPage2 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage2 retain];
//        
//        miniSurveyPage2.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage2.surveyPageIndex = 1;
//        miniSurveyPage2.delegate = self;
//        miniSurveyPage2.isSurveyPage = YES;
//        miniSurveyPage2.currentPromptString = miniSurveyPage1.currentPromptString;
//        miniSurveyPage2.currentPromptLabel.text = miniSurveyPage2.currentPromptString;
//        miniSurveyPage2.newAgreeDisagreeText = @"I understand the reason or reaons for today's visit.";
//        [newChildControllers addObject:miniSurveyPage2];
//        
//        SwitchedImageViewController *miniSurveyPage3 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage3 retain];
//        
//        miniSurveyPage3.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage3.surveyPageIndex = 2;
//        miniSurveyPage3.delegate = self;
//        miniSurveyPage3.isSurveyPage = YES;
//        miniSurveyPage3.currentPromptString = miniSurveyPage1.currentPromptString;
//        miniSurveyPage3.currentPromptLabel.text = miniSurveyPage3.currentPromptString;
//        miniSurveyPage3.newAgreeDisagreeText = @"I feel prepared for today's visit.";
//        [newChildControllers addObject:miniSurveyPage3];
//        
//        SwitchedImageViewController *miniSurveyPage4 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage4 retain];
//        
//        miniSurveyPage4.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage4.surveyPageIndex = 3;
//        miniSurveyPage4.delegate = self;
//        miniSurveyPage4.isSurveyPage = YES;
//        miniSurveyPage4.currentPromptString = miniSurveyPage1.currentPromptString;
//        miniSurveyPage4.currentPromptLabel.text = miniSurveyPage4.currentPromptString;
//        miniSurveyPage4.newAgreeDisagreeText = @"I am looking forward to today's visit.";
//        [newChildControllers addObject:miniSurveyPage4];
//        
//        SwitchedImageViewController *miniSurveyPage5 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage5 retain];
//        
//        miniSurveyPage5.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage5.surveyPageIndex = 4;
//        miniSurveyPage5.delegate = self;
//        miniSurveyPage5.isSurveyPage = YES;
//        miniSurveyPage5.currentPromptString = @"Based on my use of this myGuide app:";
//        miniSurveyPage5.currentPromptLabel.text = miniSurveyPage5.currentPromptString;
//        miniSurveyPage5.newAgreeDisagreeText = @"I feel more prepared for today's visit.";
//        [newChildControllers addObject:miniSurveyPage5];
//        
//        SwitchedImageViewController *miniSurveyPage6 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage6 retain];
//        
//        miniSurveyPage6.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage6.surveyPageIndex = 5;
//        miniSurveyPage6.delegate = self;
//        miniSurveyPage6.isSurveyPage = YES;
//        miniSurveyPage6.currentPromptString = miniSurveyPage5.currentPromptString;
//        miniSurveyPage6.currentPromptLabel.text = miniSurveyPage6.currentPromptString;
//        miniSurveyPage6.newAgreeDisagreeText = @"I feel more knowledgeable about my visit.";
//        [newChildControllers addObject:miniSurveyPage6];
//        
//        SwitchedImageViewController *miniSurveyPage7 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage7 retain];
//        
//        miniSurveyPage7.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage7.surveyPageIndex = 6;
//        miniSurveyPage7.delegate = self;
//        miniSurveyPage7.isSurveyPage = YES;
//        miniSurveyPage7.currentPromptString = miniSurveyPage5.currentPromptString;
//        miniSurveyPage7.currentPromptLabel.text = miniSurveyPage7.currentPromptString;
//        miniSurveyPage7.newAgreeDisagreeText = @"I would recommend this app to a friend or family member.";
//        [newChildControllers addObject:miniSurveyPage7];
//        
//        SwitchedImageViewController *miniSurveyPage8 = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
//        [miniSurveyPage8 retain];
//        
//        miniSurveyPage8.currentSurveyPageType = kAgreeDisagree;
//        miniSurveyPage8.surveyPageIndex = 7;
//        miniSurveyPage8.delegate = self;
//        miniSurveyPage8.isSurveyPage = YES;
//        miniSurveyPage8.currentPromptString = miniSurveyPage5.currentPromptString;
//        miniSurveyPage8.currentPromptLabel.text = miniSurveyPage8.currentPromptString;
//        miniSurveyPage8.newAgreeDisagreeText = @"Overall, I like this type of technology.";
//        [newChildControllers addObject:miniSurveyPage8];
//    }
    
    int numChildControllers = [newChildControllers count];
    
    NSLog(@"CREATED %d DYNAMIC SUB DETAIL CHILDCONTROLLERS...",numChildControllers);
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] addToTotalSlides:numChildControllers];
    
    // Initialize scene with first child controller
//    vcIndex = numChildControllers-1;
    vcIndex = 0;
    
    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [backsplash addSubview:firstPage.view];
    
    [self.view bringSubviewToFront:backsplash];
//    [self.view bringSubviewToFront:pageControl];
    
}

//- (void)showModalSubclinicTestCorrectView {
//    NSLog(@"In showModalSubclinicTestCorrectView...");
//    
//    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
//    SwitchedImageViewController *subclinicTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
//    
//    if (currentModalVC) {
//        currentModalVC = nil;
//    }
//    currentModalVC = subclinicTestCorrect;
//    
//    subclinicTestCorrect.currentSurveyPageType = kOk;
//    subclinicTestCorrect.surveyPageIndex = 2;
//    subclinicTestCorrect.delegate = self;
//    subclinicTestCorrect.isSurveyPage = YES;
//    
////    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thisFullPhysicianName componentsSeparatedByString:@","] copyItems:YES];
////    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
//    
//    NSString *subclinicCorrectText = [NSString stringWithFormat:@"That's right, you will be seen today in the  %@ Clinic.  Press OK to continue.",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
//    
//    subclinicTestCorrect.currentPromptString = subclinicCorrectText;
//    subclinicTestCorrect.currentPromptLabel.text = subclinicCorrectText;
//    
//    subclinicTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    subclinicTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
////    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    subclinicTestCorrect.view.transform = rotateRight;
//    [self presentModalViewController:subclinicTestCorrect animated:YES];
//    [subclinicTestCorrect release];
//    
//    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
//    thisSurveyPage.subclinicTestLabel.text = @"Press next to continue.";
//    
//    [self hideButtonOverlay:standardPageButtonOverlay];
//}
//
//- (void)showModalSubclinicTestIncorrectView {
//    NSLog(@"In showModalSubclinicTestIncorrectView...");
//    
//    UIStoryboard *subclinicTestStoryboard = [UIStoryboard storyboardWithName:@"survey_ok_template" bundle:[NSBundle mainBundle]];
//    SwitchedImageViewController *subclinicTestCorrect = [subclinicTestStoryboard instantiateViewControllerWithIdentifier:@"0"];
//    
//    if (currentModalVC) {
//        currentModalVC = nil;
//    }
//    currentModalVC = subclinicTestCorrect;
//    
//    subclinicTestCorrect.currentSurveyPageType = kOk;
//    subclinicTestCorrect.surveyPageIndex = 2;
//    subclinicTestCorrect.delegate = self;
//    subclinicTestCorrect.isSurveyPage = YES;
//    
//    //    NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thisFullPhysicianName componentsSeparatedByString:@","] copyItems:YES];
//    //    NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
//    
//    NSString *subclinicCorrectText = [NSString stringWithFormat:@"Not quite.  While that is an example of a clinic here, you will be seen today in the  %@ Clinic.  Press OK to continue.",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
//    
//    subclinicTestCorrect.currentPromptString = subclinicCorrectText;
//    subclinicTestCorrect.currentPromptLabel.text = subclinicCorrectText;
//    
//    subclinicTestCorrect.view.frame = CGRectMake(0, 0, 1024, 768);
//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    subclinicTestCorrect.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
////    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    subclinicTestCorrect.view.transform = rotateRight;
//    [self presentModalViewController:subclinicTestCorrect animated:YES];
//    [subclinicTestCorrect release];
//    
//    SwitchedImageViewController *thisSurveyPage = (SwitchedImageViewController *)[newChildControllers objectAtIndex:vcIndex];
//    thisSurveyPage.subclinicTestLabel.text = @"Press next to continue.";
//    
//    [self hideButtonOverlay:standardPageButtonOverlay];
//
//}
//
//- (void)dismissCurrentModalVC {
//    [currentModalVC dismissModalViewControllerAnimated:YES];
//    [self showButtonOverlay:standardPageButtonOverlay];
//}

- (void)showTempPopover {
    
    NSLog(@"showTempPopover...");
    
    [termPopoverViewController showPopover:self.view];
}

- (void)goForward {
    NSLog(@"goForward dynamicSubclinicModule...");
    [self overlayNextPressed];
}

- (void)goBackward {
    NSLog(@"goForward dynamicSubclinicModule...");
    [self overlayPreviousPressed];
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
    
//    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
//    [self fadeThisObjectIn:standardPageButtonOverlay.view];
    
    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
    
    [self playSoundForPage:firstPage];
    
    

}

//- (void)startingFirstMiniSurveyPage {
//    
//    NSLog(@"startingFirstPage of dynamic module...");
//    
//    //    DynamicModulePageViewController *firstPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
//    
//    //    if ([firstPage.showButtonsFor isEqualToString:@"previousnext"]) {
//    //        [self showButtonOverlay:￼standardPageButtonOverlay];
//    //    } else if ([firstPage.showButtonsFor isEqualToString:@"yesno"]) {
//    //        [self showButtonOverlay:yesNoButtonOverlay];
//    //    } else {
//    //        [self showButtonOverlay:￼standardPageButtonOverlay];
//    //    }
//    
////    if (showModuleHeader) {
//        [self.view sendSubviewToBack:dynamicModuleHeader.view];
//        [self fadeThisObjectOut:dynamicModuleHeader.view];
////    }
//    
//    [self.view bringSubviewToFront:standardPageButtonOverlay.view];
//    [self fadeThisObjectIn:standardPageButtonOverlay.view];
//    
//    [self switchToView:7 goingForward:NO];
//    
//    DynamicModulePageViewController *firstMiniSurveyPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:([newChildControllers count]-6)];
//    
//    [self playSoundForPage:firstMiniSurveyPage];
//    
//    
//    
//}
//
//- (void)startingFinalSurveyPage {
//    
//}

- (void)playSoundForPage:(DynamicModulePageViewController *)currentPage {
    
    if (speakItemsAloud) {
        NSMutableArray *soundNameArray = [[NSMutableArray alloc] initWithObjects: nil];
        
        if (currentPage.showHeader) {
            
            [soundNameArray addObject:currentPage.headerTTSFilenamePrefix];
        }
        
        [soundNameArray addObject:currentPage.TTSFilenamePrefix];
        
        [masterTTSPlayer playItemsWithNames:soundNameArray];
    }
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
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
}

- (void)overlayPreviousPressed {
    NSLog(@"overlayPreviousPressed...");
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
    NSLog(@"DynamicModuleViewController_Pad.overlayFontsizePressed()...");
    // sandy should call something similar    [tbvc cycleFontSizeForAllLabels];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fontsizeButtonPressed:self];
}
// sandy accidentally put this here I think
//- (void)cycleFontSizeForAllLabels {
//    CGFloat newFontSize;
    
    // 1 = avenir medium 30
 //   if (currentFontSize == 1) {
//        newFontSize = 40.0f;
//        currentFontSize = 2;
//    } else if (currentFontSize == 2) {
//        newFontSize = 50.0f;
 //       currentFontSize = 3;
 //   } else {
 //       newFontSize = 30.0f;
 //       currentFontSize = 1;
 //   }
 //
 //   for (SwitchedImageViewController *switchedController in newChildControllers)
 //   {
//        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
        //sandy added prompt resizing
//        switchedController.currentPromptLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
//    }
    
//}
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
- (void)switchToView:(int)newIndex goingForward:(BOOL)goesForward
{
    
    if (finishingLastItem && !goesForward)
    {
        // Back to menu
//        DynamicModulePageViewController *newPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
//        [self playSoundForPage:newPage];
        
        //        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchEducationModule];
        if (inWhatsNewMode) {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicWhatsNewModuleOut];
        }
        
        if (!inSubclinicMode) {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchDynamicSubclinicEducationModule];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicEdModuleOut];
            
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setDynamicEdModuleCompleted:YES];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] createBadgeOnClinicInfoButton];
            //            dynamicEdModuleCompleted = NO;
        } else {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setDynamicEdModuleCompleted:YES];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] updateMiniDemoSettings];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] handleDynamicEdModuleCompleted];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicSubclinicEdModuleOut];
        }
        
        
        
        return;
        
    } else {
        
        finishingLastItem = NO;
        
        NSLog(@"SWITCHING from dynamic module item %d to item %d", vcIndex, newIndex);
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        DynamicModulePageViewController *newPage = (DynamicModulePageViewController *)[newChildControllers objectAtIndex:vcIndex];
        [self playSoundForPage:newPage];
        
        if (vcIndex == ([newChildControllers count] - 1)) {
            NSLog(@"LAST PAGE: %d", vcIndex);
            finishingLastItem = YES;
            if (!inSubclinicMode) {
                //            [self.view bringSubviewToFront:yesNoButtonOverlay.view];
                //            [self fadeThisObjectIn:yesNoButtonOverlay.view];
                //            [self fadeThisObjectOut:standardPageButtonOverlay.view];
            }
            if (inWhatsNewMode) {
                
                [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideCurrentButtonOverlay];
                
                [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicSubclinicEdModuleOut];
                [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeDynamicEdModuleOut];
                
                [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] whatsNewCompleted];
                [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] createBadgeOnWhatsNewButton];
                [self hideButtonOverlay:standardPageButtonOverlay];
                //            standardPageButtonOverlay.view.alpha = 0.0;
                //            standardPageButtonOverlay.nextPageButton.enabled = NO;
                //            standardPageButtonOverlay.previousPageButton.enabled = NO;
            }
        }
        
        
        if (vcIndex == 0) {
            NSLog(@"FIRST PAGE");
            standardPageButtonOverlay.previousPageButton.enabled = NO;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
        } else {
            standardPageButtonOverlay.previousPageButton.enabled = YES;
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
        }
        
        //        if (vcIndex == 1) {
        //            termPopoverViewController = [[PopoverPlaygroundViewController alloc] init];
        //
        //            hiddenPopoverButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //            hiddenPopoverButton.frame = CGRectMake(100, 100, 150, 50);
        //            hiddenPopoverButton.showsTouchWhenHighlighted = YES;
        //            hiddenPopoverButton.backgroundColor = [UIColor redColor];
        //            [hiddenPopoverButton setCenter:CGPointMake(620.0f, 400.0f)];
        //            [hiddenPopoverButton addTarget:self action:@selector(showTempPopover) forControlEvents:UIControlEventTouchUpInside];
        //            hiddenPopoverButton.enabled = YES;
        //            hiddenPopoverButton.hidden = NO;
        //            hiddenPopoverButton.alpha = 1.0;
        //            [hiddenPopoverButton retain];
        //            //            nextSettingsButton.transform = rotateRight;
        //
        //            [self.view addSubview:termPopoverViewController.view];
        //
        //            termPopoverViewController.popoverContent.adminMenuButton.alpha = 0.0;
        //            termPopoverViewController.popoverContent.appVersionLabel.text = @"Physiatry is a branch of medicine that diagnoses and treats disorders causing temporary or permanent impairment.";
        //            
        //            [self.view addSubview:hiddenPopoverButton];
        //            
        ////            [termPopoverViewController showPopover:self];
        //        }
        
        
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