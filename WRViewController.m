//
//  WRViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import "WRViewController.h"
#import "SettingsViewController.h"
#import "ModalMeViewController.h"
#import "ContentViewController.h"
#import "ModalViewExampleViewController.h"
#import "PopoverPlaygroundViewController.h"
#import "DemoViewController.h"
#import "AppDelegate_Pad.h"
#import "PhysicianCellViewController.h"
#import "MasterViewController.h"
#import "ReturnTabletViewController.h"
#import "YLViewController.h"
#import "DynamicSurveyViewController_Pad.h"
#import "FPNumberPadView.h"
#import "ClinicianInfo.h"
#import "ClinicInfo.h"
#import "GoalInfo.h"
#import "QuestionList.h"
#import "DynamicContent.h"
#import "DynamicSpeech.h"
#import "UIImage-Extensions.h"


#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

@interface WRViewController ()

@end

@implementation WRViewController

@synthesize currentInstitution, currentMainClinic, readyScreen, settingsVC, returnTabletView;
@synthesize appVersion, isFirstVisit, deviceName, collectingPilotData;
@synthesize uxTimer, _ticks, uxTimerCurrentTimeString, secondsDur;
@synthesize endOfSplashTimer, splashAnimationsFinished, checkingForAdditionalInfo, checkingForMiniSurvey;
@synthesize resourceBack, surveyResourceBack, aWebView, menuCubeWebView, allWhiteBack;
@synthesize splashImageView, splashImageViewB, splashImageViewBb, splashImageViewC, splashSpinner, tabNAdView, statusViewWhiteBack;
@synthesize mapViewInitialized, mapTabEnabled;
@synthesize lastRowImportedFromUsersDb;
@synthesize tbvc, cubeViewController;
//@synthesize navigationController;
@synthesize modalViewController;
@synthesize modalContent, needToReturnToMainMenu, wantExtraInfo, wantMiniSurvey, startAtFinalSurvey, startAtMiniSurvey, wantFinalSurvey, checkingForFinalSurvey;
//@synthesize newViewController;
@synthesize keycodeField, inTreatmentIntermission;
@synthesize yesButton, noButton, patientButton, familyButton, caregiverButton, tbiEdButton, comingSoonButton, satisfactionButton, newsButton, clinicButton;
@synthesize beginSurveyButton, returnToMenuButton, nextSurveyItemButton, previousSurveyItemButton;
@synthesize firstVisitButton, returnVisitButton, readyAppButton, voiceAssistButton, fontsizeButton;
@synthesize readAloudLabel, respondentLabel, selectActivityLabel, surveyIntroLabel, presurveyIntroLabel, surveyCompleteLabel, visitSelectionLabel, selectedClinic, selectedVisit, selectedSubclinic;
@synthesize popoverViewController;
@synthesize taperedWhiteLine, demoSwitch, demoModeLabel, clinicSelectionLabel, clinicPickerView, currentClinicName, currentSubClinicName, currentSpecialtyClinicName;
@synthesize educationModuleCompleted, educationModuleInProgress, satisfactionSurveyCompleted, satisfactionSurveyDeclined, satisfactionSurveyInProgress, cameFromMainMenu, mainMenuInitialized, whatsNewInitialized, dynamicSurveyInitialized, dynamicEdModuleCompleted, whatsNewModuleCompleted, completedProviderSession, completedFinalSurvey, startedsurvey, finishedsurvey,completedProviderAndSubclinicSurvey, usingFullMenu;
@synthesize initialSettingsLabel, clinicSegmentedControl, specialtyClinicSegmentedControl, switchToSectionSegmentedControl, nextSettingsButton, edModule, physicianModule, dynamicEdModule, dynamicSubclinicEdModule, currentDynamicSubClinicEdModuleSpecFilename, nextEdItemButton, previousEdItemButton, nextPhysicianDetailButton, previousPhysicianDetailButton;
@synthesize currentDynamicClinicEdModuleSpecFilename, dynamicWhatsNewModule, dynamicEdModule1, dynamicEdModule2, dynamicEdModule3, dynamicEdModule4, dynamicEdModule5, dynamicEdModule6, dynamicEdModule7, dynamicEdModule8, dynamicEdModule9, dynamicEdModule10, currentDynamicWhatsNewModuleSpecFilename;
@synthesize agreeButton, disagreeButton, badgeImageView, badgeLabel, completedBadgeImageView, completedBadgeImageViewEdModule, completedBadgeImageViewDynEdModule, completedBadgeImageViewWhatsNewModule, edModuleCompleteLabel, edModuleIntroLabel, playMovieIcon;
@synthesize odetteButton, calvinButton, lauraButton, clinicianLabel, doctorButton, pscButton, appointmentButton;
@synthesize masterViewController, arrayDetailVCs, allClinicPhysicians, pmnrSubClinicPhysicians, splitViewController, allClinicPhysiciansThumbs, allClinicPhysiciansImages, allClinicPhysiciansBioPLists, attendingPhysicianSoundFile, allClinicPhysiciansSoundFiles;
@synthesize mainClinicName, subClinicName, attendingPhysicianName, attendingPhysicianThumb, attendingPhysicianImage, attendingPhysicianIndex, physicianDetailVC, physicianModuleCompleted, physicianModuleInProgress;
@synthesize mainTTSPlayer, allTTSItemsDict, baseTTSItemsDict, brainTTSItemsDict, physiciansTTSItemsDict, updateTTSItemsArray, surveyTTSItemsDict, dynamicSurveyTTSItemsDict;
@synthesize dynamicSurveyModule, alarmSounding, underUserControl, revealSettingsButtonPressed;
@synthesize totalSlidesInThisSection, slidesCompleted, progressSoFar, firstVisitSlides, forceToDemoMode;


#pragma mark - INIT
NSMutableArray *titleArray;
int indexCount;

static WRViewController* mViewController = NULL;

+ (WRViewController*) getViewController {
    return mViewController;
}

// this is the main method to launch the whole app!

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    // Launch app!
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        collectingPilotData = YES;
        
        // Custom initialization
        NSLog(@"WRViewController.initWithNibName()");
        runningAppInDemoMode = NO;

        forceToDemoMode = YES;
        
        inTreatmentIntermission = NO;
        
        underUserControl = NO;
        
        currentInstitution = kVAPAHCS;
        currentMainClinic = kNoMainClinic;
        
        alarmSounding = NO;
        
        revealSettingsButtonPressed = NO;
        
        uxTimerCurrentTimeString = @"0:0:0";
        
        skipToSplashIntro = NO;
        skipToPhysicianDetail = NO;
        skipToEducationModule = NO;
        skipToSatisfactionSurvey = NO;
        skipToMainMenu = NO;
        
        badgeCreated = NO;
        finalBadgeCreated = NO;
        
        checkingForAdditionalInfo = NO;
        checkingForMiniSurvey = NO;
        checkingForFinalSurvey = NO;
        startAtMiniSurvey = NO;
        startAtFinalSurvey = NO;
        
        totalSlidesInThisSection = 0;
        slidesCompleted = 0;
        firstVisitSlides = 0;
        progressSoFar = 0.0;
        [self resetProgressBar];
        
        // sandy speech dicts
        allTTSItemsDict = [[NSMutableDictionary alloc] init];
        baseTTSItemsDict = [[NSMutableDictionary alloc] init];
        physiciansTTSItemsDict = [[NSMutableDictionary alloc] init];
        surveyTTSItemsDict = [[NSMutableDictionary alloc] init];
        brainTTSItemsDict = [[NSMutableDictionary alloc] init];
        
        dynamicSurveyTTSItemsDict = [[NSMutableDictionary alloc] init];
        
        updateTTSItemsArray = [[NSMutableArray alloc] initWithObjects: nil];
        
        //appVersion = @"1.9.2";
        // sandy updated
        appVersion = @"2.0.1"; //sandy updated 10-9-14
        deviceName = [[UIDevice currentDevice] name];
        secondsDur = 0.0;
        
        NSLog(@"You are currently on tablet %@ running Waiting Room guide version %@", deviceName, appVersion);
        
        splashAnimationsFinished = NO;
        
        usingFullMenu = NO;
        
        currentClinicName = @"Default";
        currentSubClinicName = @"Default";
        currentSpecialtyClinicName = @"Default";
        
        mainClinicName = @"Default";
        subClinicName = @"Default";
        attendingPhysicianName = @"Default";
        attendingPhysicianThumb = @"Default";
        attendingPhysicianImage = @"Default";
        attendingPhysicianSoundFile = @"Default";
        attendingPhysicianIndex = 0;
        
        currentDynamicClinicEdModuleSpecFilename = @"Default";
        
        mainMenuInitialized = NO;
        whatsNewInitialized = NO;
        dynamicSurveyInitialized = NO;
        
        educationModuleCompleted = NO;
        educationModuleInProgress = NO;
        satisfactionSurveyCompleted = NO;
        satisfactionSurveyDeclined = NO;
        satisfactionSurveyInProgress = NO;
        cameFromMainMenu = NO;
        
        dynamicEdModuleInProgress = NO;
        dynamicEdSubclinicModuleInProgress = NO;
        
        dynamicEdModuleCompleted = NO;
        whatsNewModuleCompleted = NO;
        
        completedProviderAndSubclinicSurvey = NO;
        completedProviderSession = NO;
        startedsurvey = NO;
        finishedsurvey = NO;
        
        needToReturnToMainMenu = NO;
        
        selectedClinic = NO;
        selectedVisit = NO;
        selectedSubclinic = NO;
        
        titleArray = [[NSMutableArray arrayWithObjects:@"AT Center", @"PM&R Clinic", @"PNS Clinic", nil] retain];
        indexCount = 0;
	    
        [self completeInitialApplicationLaunch];
        
        [tbvc getAllUniqueIds];
        //[DynamicContent downloadAllData];
    }
    return self;
}


- (void)timerTick:(NSTimer *)timer
{
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
//    _ticks += 0.25;
//    double seconds = fmod(_ticks, 60.0);
//    double minutes = fmod(trunc(_ticks / 60.0), 60.0);
//    double hours = trunc(_ticks / 3600.0);
    secondsDur += 0.25;
    uxTimerCurrentTimeString = [NSString stringWithFormat:@"%4.4f",secondsDur];
}

- (void)completeInitialApplicationLaunch {
    NSLog(@"WRViewController.completeInitialApplicationLaunch()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    [self initSplashView];
    
	tbvc = [[RootViewController_Pad alloc] init];
    
    mainTTSPlayer = [[TTSPlayer alloc] init];
    mainTTSPlayer.currentlyPlayingVoiceSpeed = fastspeed;
    mainTTSPlayer.currentlyPlayingVoiceType = usenglishfemale;
    [mainTTSPlayer fadeToDesiredVolume:[DynamicSpeech defaultVolume]]; // rjl 10/22/14 set default volume
    settingsVC.soundViewController.volumeNumber.text = @"0.50";
    settingsVC.soundViewController.pitchNumber.text = @"1.50";
    settingsVC.soundViewController.speedNumber.text = @"0.50";
    settingsVC.soundViewController.languageText.text = @"en-US";
    
//    self.view.rootViewController = tbvc;
    tbvc.view.alpha = 0.0;
//    tbvc.view.transform = rotateRight;
    tbvc.masterTTSPlayer = mainTTSPlayer;
    [self.view addSubview:tbvc.view];
    
    [self.view sendSubviewToBack:tbvc.view]; //CommentMe
    
    edModule = [[EdViewController_Pad alloc] init];
    edModule.masterTTSPlayer = mainTTSPlayer;
    
    //    self.view.rootViewController = tbvc;
    edModule.view.alpha = 0.0;
    //edModule.view.transform = rotateRight;
    [self.view addSubview:edModule.view];
    [self.view sendSubviewToBack:edModule.view];

    int numSlidesInTBISection = [edModule.newChildControllers count];
 //   [self addToTotalSlides:numSlidesInTBISection];
    
    [DynamicContent setTbiEdModulePageCount:numSlidesInTBISection];
    
    physicianModule = [[PhysicianViewController_Pad alloc] init];
    physicianModule.masterTTSPlayer = mainTTSPlayer;
    
    dynamicEdModule = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule.inSubclinicMode = NO;
    dynamicEdModule.inWhatsNewMode = NO;
    dynamicEdModule.inEdModule1 = NO;
    dynamicEdModule.inEdModule2 = NO;
    dynamicEdModule.inEdModule3 = NO;
    dynamicEdModule.inEdModule4 = NO;
    dynamicEdModule.inEdModule5 = NO;
    dynamicEdModule.inEdModule6 = NO;
    dynamicEdModule.inEdModule7 = NO;
    dynamicEdModule.inEdModule8 = NO;
    dynamicEdModule.inEdModule9 = NO;
    dynamicEdModule.inEdModule10 = NO;
    
    dynamicSubclinicEdModule = [[DynamicModuleViewController_Pad alloc] init];
    dynamicSubclinicEdModule.masterTTSPlayer = mainTTSPlayer;
    dynamicSubclinicEdModule.speakItemsAloud = YES;
    dynamicSubclinicEdModule.inSubclinicMode = YES;
    dynamicSubclinicEdModule.inWhatsNewMode = NO;
    dynamicSubclinicEdModule.inEdModule1 = NO;
    dynamicSubclinicEdModule.inEdModule2 = NO;
    dynamicSubclinicEdModule.inEdModule3 = NO;
    dynamicSubclinicEdModule.inEdModule4 = NO;
    dynamicSubclinicEdModule.inEdModule5 = NO;
    dynamicSubclinicEdModule.inEdModule6 = NO;
    dynamicSubclinicEdModule.inEdModule7 = NO;
    dynamicSubclinicEdModule.inEdModule8 = NO;
    dynamicSubclinicEdModule.inEdModule9 = NO;
    dynamicSubclinicEdModule.inEdModule10 = NO;
    
    dynamicWhatsNewModule = [[DynamicModuleViewController_Pad alloc] init];
    dynamicWhatsNewModule.masterTTSPlayer = mainTTSPlayer;
    dynamicWhatsNewModule.speakItemsAloud = YES;
    dynamicWhatsNewModule.inSubclinicMode = NO;
    dynamicWhatsNewModule.inWhatsNewMode = YES;
    dynamicWhatsNewModule.inEdModule1 = NO;
    dynamicWhatsNewModule.inEdModule2 = NO;
    dynamicWhatsNewModule.inEdModule3 = NO;
    dynamicWhatsNewModule.inEdModule4 = NO;
    dynamicWhatsNewModule.inEdModule5 = NO;
    dynamicWhatsNewModule.inEdModule6 = NO;
    dynamicWhatsNewModule.inEdModule7 = NO;
    dynamicWhatsNewModule.inEdModule8 = NO;
    dynamicWhatsNewModule.inEdModule9 = NO;
    dynamicWhatsNewModule.inEdModule10 = NO;
    currentDynamicWhatsNewModuleSpecFilename = @"psc_whats_new_module_test2";
    
    dynamicEdModule1 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule1.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule1.speakItemsAloud = YES;
    dynamicEdModule1.inSubclinicMode = NO;
    dynamicEdModule1.inWhatsNewMode = YES;
    dynamicEdModule1.inEdModule1 = YES;
    dynamicEdModule1.inEdModule2 = NO;
    dynamicEdModule1.inEdModule3 = NO;
    dynamicEdModule1.inEdModule4 = NO;
    dynamicEdModule1.inEdModule5 = NO;
    dynamicEdModule1.inEdModule6 = NO;
    dynamicEdModule1.inEdModule7 = NO;
    dynamicEdModule1.inEdModule8 = NO;
    dynamicEdModule1.inEdModule9 = NO;
    dynamicEdModule1.inEdModule10 = NO;
    
    dynamicEdModule2 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule2.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule2.speakItemsAloud = YES;
    dynamicEdModule2.inSubclinicMode = NO;
    dynamicEdModule2.inWhatsNewMode = YES;
    dynamicEdModule2.inEdModule1 = NO;
    dynamicEdModule2.inEdModule2 = YES;
    dynamicEdModule2.inEdModule3 = NO;
    dynamicEdModule2.inEdModule4 = NO;
    dynamicEdModule2.inEdModule5 = NO;
    dynamicEdModule2.inEdModule6 = NO;
    dynamicEdModule2.inEdModule7 = NO;
    dynamicEdModule2.inEdModule8 = NO;
    dynamicEdModule2.inEdModule9 = NO;
    dynamicEdModule2.inEdModule10 = NO;
    
    dynamicEdModule3 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule3.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule3.speakItemsAloud = YES;
    dynamicEdModule3.inSubclinicMode = NO;
    dynamicEdModule3.inWhatsNewMode = YES;
    dynamicEdModule3.inEdModule1 = NO;
    dynamicEdModule3.inEdModule2 = NO;
    dynamicEdModule3.inEdModule3 = YES;
    dynamicEdModule3.inEdModule4 = NO;
    dynamicEdModule3.inEdModule5 = NO;
    dynamicEdModule3.inEdModule6 = NO;
    dynamicEdModule3.inEdModule7 = NO;
    dynamicEdModule3.inEdModule8 = NO;
    dynamicEdModule3.inEdModule9 = NO;
    dynamicEdModule3.inEdModule10 = NO;
    
    dynamicEdModule4 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule4.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule4.speakItemsAloud = YES;
    dynamicEdModule4.inSubclinicMode = NO;
    dynamicEdModule4.inWhatsNewMode = YES;
    dynamicEdModule4.inEdModule1 = NO;
    dynamicEdModule4.inEdModule2 = NO;
    dynamicEdModule4.inEdModule3 = NO;
    dynamicEdModule4.inEdModule4 = YES;
    dynamicEdModule4.inEdModule5 = NO;
    dynamicEdModule4.inEdModule6 = NO;
    dynamicEdModule4.inEdModule7 = NO;
    dynamicEdModule4.inEdModule8 = NO;
    dynamicEdModule4.inEdModule9 = NO;
    dynamicEdModule4.inEdModule10 = NO;
    
    dynamicEdModule5 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule5.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule5.speakItemsAloud = YES;
    dynamicEdModule5.inSubclinicMode = NO;
    dynamicEdModule5.inWhatsNewMode = YES;
    dynamicEdModule5.inEdModule1 = NO;
    dynamicEdModule5.inEdModule2 = NO;
    dynamicEdModule5.inEdModule3 = NO;
    dynamicEdModule5.inEdModule4 = NO;
    dynamicEdModule5.inEdModule5 = YES;
    dynamicEdModule5.inEdModule6 = NO;
    dynamicEdModule5.inEdModule7 = NO;
    dynamicEdModule5.inEdModule8 = NO;
    dynamicEdModule5.inEdModule9 = NO;
    dynamicEdModule5.inEdModule10 = NO;
    
    dynamicEdModule6 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule6.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule6.speakItemsAloud = YES;
    dynamicEdModule6.inSubclinicMode = NO;
    dynamicEdModule6.inWhatsNewMode = YES;
    dynamicEdModule6.inEdModule1 = NO;
    dynamicEdModule6.inEdModule2 = NO;
    dynamicEdModule6.inEdModule3 = NO;
    dynamicEdModule6.inEdModule4 = NO;
    dynamicEdModule6.inEdModule5 = NO;
    dynamicEdModule6.inEdModule6 = YES;
    dynamicEdModule6.inEdModule7 = NO;
    dynamicEdModule6.inEdModule8 = NO;
    dynamicEdModule6.inEdModule9 = NO;
    dynamicEdModule5.inEdModule10 = NO;
    
    dynamicEdModule7 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule7.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule7.speakItemsAloud = YES;
    dynamicEdModule7.inSubclinicMode = NO;
    dynamicEdModule7.inWhatsNewMode = YES;
    dynamicEdModule7.inEdModule1 = NO;
    dynamicEdModule7.inEdModule2 = NO;
    dynamicEdModule7.inEdModule3 = NO;
    dynamicEdModule7.inEdModule4 = NO;
    dynamicEdModule7.inEdModule5 = NO;
    dynamicEdModule7.inEdModule6 = NO;
    dynamicEdModule7.inEdModule7 = YES;
    dynamicEdModule7.inEdModule8 = NO;
    dynamicEdModule7.inEdModule9 = NO;
    dynamicEdModule7.inEdModule10 = NO;
    
    dynamicEdModule8 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule8.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule8.speakItemsAloud = YES;
    dynamicEdModule8.inSubclinicMode = NO;
    dynamicEdModule8.inWhatsNewMode = YES;
    dynamicEdModule8.inEdModule1 = NO;
    dynamicEdModule8.inEdModule2 = NO;
    dynamicEdModule8.inEdModule3 = NO;
    dynamicEdModule8.inEdModule4 = NO;
    dynamicEdModule8.inEdModule5 = NO;
    dynamicEdModule8.inEdModule6 = NO;
    dynamicEdModule8.inEdModule7 = NO;
    dynamicEdModule8.inEdModule8 = YES;
    dynamicEdModule8.inEdModule9 = NO;
    dynamicEdModule8.inEdModule10 = NO;
    
    dynamicEdModule9 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule9.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule9.speakItemsAloud = YES;
    dynamicEdModule9.inSubclinicMode = NO;
    dynamicEdModule9.inWhatsNewMode = YES;
    dynamicEdModule9.inEdModule1 = NO;
    dynamicEdModule9.inEdModule2 = NO;
    dynamicEdModule9.inEdModule3 = NO;
    dynamicEdModule9.inEdModule4 = NO;
    dynamicEdModule9.inEdModule5 = NO;
    dynamicEdModule9.inEdModule6 = NO;
    dynamicEdModule9.inEdModule7 = NO;
    dynamicEdModule9.inEdModule8 = NO;
    dynamicEdModule9.inEdModule9 = YES;
    dynamicEdModule9.inEdModule10 = NO;
    
    dynamicEdModule10 = [[DynamicModuleViewController_Pad alloc] init];
    dynamicEdModule10.masterTTSPlayer = mainTTSPlayer;
    dynamicEdModule10.speakItemsAloud = YES;
    dynamicEdModule10.inSubclinicMode = NO;
    dynamicEdModule10.inWhatsNewMode = YES;
    dynamicEdModule10.inEdModule1 = NO;
    dynamicEdModule10.inEdModule2 = NO;
    dynamicEdModule10.inEdModule3 = NO;
    dynamicEdModule10.inEdModule4 = NO;
    dynamicEdModule10.inEdModule5 = NO;
    dynamicEdModule10.inEdModule6 = NO;
    dynamicEdModule10.inEdModule7 = NO;
    dynamicEdModule10.inEdModule8 = NO;
    dynamicEdModule10.inEdModule9 = NO;
    dynamicEdModule10.inEdModule10 = YES;
    
    dynamicSurveyModule = [[DynamicSurveyViewController_Pad alloc] init];
    dynamicSurveyModule.masterTTSPlayer = mainTTSPlayer;
    dynamicSurveyModule.speakItemsAloud = YES;
    dynamicSurveyModule.inSubclinicMode = NO;
    dynamicSurveyModule.inWhatsNewMode = NO;
    dynamicSurveyModule.inEdModule1 = NO;
    dynamicSurveyModule.inEdModule2 = NO;
    dynamicSurveyModule.inEdModule3 = NO;
    dynamicSurveyModule.inEdModule4 = NO;
    dynamicSurveyModule.inEdModule5 = NO;
    dynamicSurveyModule.inEdModule6 = NO;
    dynamicSurveyModule.inEdModule7 = NO;
    dynamicSurveyModule.inEdModule8 = NO;
    dynamicSurveyModule.inEdModule9 = NO;
    dynamicSurveyModule.inEdModule10 = NO;
    
    edModule.speakItemsAloud = YES;
    physicianModule.speakItemsAloud = YES;
    dynamicEdModule.speakItemsAloud = YES;
    mainTTSPlayer.speakItemsAloud = YES;
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] readyForAppointmentButton] setEnabled:YES];
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] readyForAppointmentButton] setAlpha:1.0];
    
    [self prepareAppBeforeSplashView];
    
    popoverViewController = [[PopoverPlaygroundViewController alloc] init];
    
    [self.view addSubview:popoverViewController.view];
    [self.view sendSubviewToBack:popoverViewController.view];
    
//    [self.view makeKeyAndVisible];
    
    NSLog(@"Completed Initial Application Launch");
}

- (void)prepareAppBeforeSplashView {
    NSLog(@"WRViewController.prepareAppBeforeSplashView()");

    float angle =   270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    allWhiteBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
    allWhiteBack.frame = CGRectMake(0, 0, 768, 1024);
    [self.view addSubview:allWhiteBack];
    
    //    firstVisitButton, returnVisitButton, readyAppButton, voiceAssistButton, fontsizeButton

//    clinicSegmentedControl = [[UISegmentedControl alloc] initWithItems:titleArray];
//    clinicSegmentedControl.frame = CGRectMake(35, 200, 650, 50);
//    clinicSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
////    clinicSegmentedControl.selectedSegmentIndex = 1;
//    [clinicSegmentedControl addTarget:self action:@selector(clinicSegmentChanged:) forControlEvents:UIControlEventValueChanged];
//    [clinicSegmentedControl setCenter:CGPointMake(320.0f, 612.0f)];
//    clinicSegmentedControl.transform = rotateRight;
//    [clinicSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    // DISABLING 'GENERIC CLINIC' AND 'PNS' UNTIL CONTENT IS READY
//    [clinicSegmentedControl setEnabled:NO forSegmentAtIndex:0];
//    [clinicSegmentedControl setEnabled:NO forSegmentAtIndex:2];
//    [self.view addSubview:clinicSegmentedControl];
    
//    specialtyClinicSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"General PM&R", @"Acupuncture", @"Pain", @"EMG", nil]];
//    specialtyClinicSegmentedControl.frame = CGRectMake(35, 200, 750, 50);
//    specialtyClinicSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
////    specialtyClinicSegmentedControl.selectedSegmentIndex = 1;
//    [specialtyClinicSegmentedControl addTarget:self action:@selector(specialtyClinicSegmentChanged:) forControlEvents:UIControlEventValueChanged];
//    specialtyClinicSegmentedControl.alpha = 0.0;
//    [specialtyClinicSegmentedControl setCenter:CGPointMake(380.0f, 612.0f)];
//    specialtyClinicSegmentedControl.transform = rotateRight;
//    [specialtyClinicSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
//
//    [self.view addSubview:specialtyClinicSegmentedControl];
    
//    initialSettingsLabel = [[KSLabel alloc] initWithFrame:f];
    initialSettingsLabel = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)];
    initialSettingsLabel.drawBlackOutline = YES;
    initialSettingsLabel.drawGradient = YES;
    initialSettingsLabel.text = @"Launch Settings";
    initialSettingsLabel.textAlignment = UITextAlignmentCenter;
    initialSettingsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:60];
    [initialSettingsLabel setCenter:CGPointMake(512.0f, 100.0f)];
//    [initialSettingsLabel setCenter:CGPointMake(100.0f, 512.0f)];
    //initialSettingsLabel.transform = rotateRight;
    [self.view addSubview:initialSettingsLabel];
    
//    clinicSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 700, 250)];
//	clinicSelectionLabel.text = @"Please select the appropriate clinic and specialty:";
//	clinicSelectionLabel.textAlignment = UITextAlignmentCenter;
//	clinicSelectionLabel.textColor = [UIColor blackColor];
//	clinicSelectionLabel.backgroundColor = [UIColor clearColor];
//    clinicSelectionLabel.font = [UIFont fontWithName:@"Avenir" size:30];
//	clinicSelectionLabel.opaque = YES;
//	[clinicSelectionLabel setCenter:CGPointMake(270.0f, 650.0f)];
//    clinicSelectionLabel.transform = rotateRight;
//    
//    [self.view addSubview:clinicSelectionLabel];
    
//    clinicianLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 700, 250)];
//	clinicianLabel.text = @"Selected:";
//	clinicianLabel.textAlignment = UITextAlignmentCenter;
//	clinicianLabel.textColor = [UIColor blackColor];
//	clinicianLabel.backgroundColor = [UIColor clearColor];
//    clinicianLabel.font = [UIFont fontWithName:@"Avenir" size:25];
//    clinicianLabel.numberOfLines = 0;
//	clinicianLabel.opaque = YES;
//	[clinicianLabel setCenter:CGPointMake(650.0f, 419.0f)];
//    clinicianLabel.alpha = 0.0;
//    clinicianLabel.transform = rotateRight;
//    
//    [self.view addSubview:clinicianLabel];
//    [self.view sendSubviewToBack:clinicianLabel];
    
    taperedWhiteLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapered_fade_dividing_line-horiz-lrg.png"]];
    taperedWhiteLine.frame = CGRectMake(0, 0, 700, 50);
    [taperedWhiteLine setCenter:CGPointMake(512.0f, 200.0f)];
//    [taperedWhiteLine setCenter:CGPointMake(200.0f, 512.0f)];
    //taperedWhiteLine.transform = rotateRight;
    [self.view addSubview:taperedWhiteLine];
    
    demoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 26.0)];
    [demoSwitch addTarget:self action:@selector(demoSwitchFlipped:) forControlEvents:UIControlEventTouchUpInside];
    if (forceToDemoMode) {
        if (!collectingPilotData) {
            [demoSwitch setOn:YES];
        }
    } else {
        [demoSwitch setOn:NO];
    }
    
    [demoSwitch setCenter:CGPointMake(400.0f, 600.0f)];
//    [demoSwitch setCenter:CGPointMake(600.0f, 700.0f)];
    [demoSwitch setBackgroundColor:[UIColor clearColor]];
    //demoSwitch.transform = rotateRight;
    [self.view addSubview:demoSwitch];
    
    demoModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    // sandy removed mode to fit was "Demo Mode:"
	demoModeLabel.text = @"Demo:";
	demoModeLabel.textAlignment = UITextAlignmentCenter;
	demoModeLabel.textColor = [UIColor blackColor];
	demoModeLabel.backgroundColor = [UIColor clearColor];
    demoModeLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	demoModeLabel.opaque = YES;
    [demoModeLabel setCenter:CGPointMake(200.0f, 600.0f)];
//    [demoModeLabel setCenter:CGPointMake(600.0f, 900.0f)];
    //demoModeLabel.transform = rotateRight;
    
    [self.view addSubview:demoModeLabel];
    
    
    
    nextSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextSettingsButton.frame = CGRectMake(0, 0, 150, 139);
	nextSettingsButton.showsTouchWhenHighlighted = YES;
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
	nextSettingsButton.backgroundColor = [UIColor clearColor];
    // sandy shifted this to match others. Changed to:[nextSettingsButton setCenter:CGPointMake(685.0f, 80.0f)];
    [nextSettingsButton setCenter:CGPointMake(940.0f, 620.0f)];
//    [nextSettingsButton setCenter:CGPointMake(620.0f, 80.0f)];
    
	[nextSettingsButton addTarget:self action:@selector(slideVisitButtonsOut) forControlEvents:UIControlEventTouchUpInside];
	nextSettingsButton.enabled = NO;
	nextSettingsButton.hidden = NO;
	[nextSettingsButton retain];
    //nextSettingsButton.transform = rotateRight;
    [self.view addSubview:nextSettingsButton];
    
//    visitSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000)];
    visitSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
	visitSelectionLabel.text = @"Patient's first visit or a return visit?";
	visitSelectionLabel.textAlignment = UITextAlignmentCenter;
	visitSelectionLabel.textColor = [UIColor blackColor];
	visitSelectionLabel.backgroundColor = [UIColor clearColor];
    visitSelectionLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	visitSelectionLabel.opaque = YES;
//    [visitSelectionLabel setCenter:CGPointMake(330.0f, 755.0f)];
    [visitSelectionLabel setCenter:CGPointMake(512.0f, 320.0f)];
//    [visitSelectionLabel setCenter:CGPointMake(330.0f, 755.0f)];
//    visitSelectionLabel.transform = rotateRight;
    
    [self.view addSubview:visitSelectionLabel];
    
    //firstVisitButton - decide if patient's first visit
	firstVisitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	firstVisitButton.frame = CGRectMake(0, 0, 113, 76);
	firstVisitButton.showsTouchWhenHighlighted = YES;
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image.png"] forState:UIControlStateNormal];
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image_pressed.png"] forState:UIControlStateSelected];
	firstVisitButton.backgroundColor = [UIColor clearColor];
	[firstVisitButton setCenter:CGPointMake(400.0f, 400.0f)];
//    [firstVisitButton setCenter:CGPointMake(400.0f, 860.0f)];
	[firstVisitButton addTarget:self action:@selector(visitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	firstVisitButton.enabled = YES;
	firstVisitButton.hidden = NO;
    firstVisitButton.selected = YES;
    //    firstVisitButton.alpha = 0.0;
	[firstVisitButton retain];
//    firstVisitButton.transform = rotateRight;
    
    [self.view addSubview:firstVisitButton];
    
//    switchToSectionSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Skip to Splash", @"Skip to Pretest", @"Skip to Ed", @"Skip to Survey", @"Skip to Menu", nil]];
//    switchToSectionSegmentedControl.frame = CGRectMake(35, 200, 800, 50);
//    switchToSectionSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
////    switchToSectionSegmentedControl.selectedSegmentIndex = 1;
//    [switchToSectionSegmentedControl addTarget:self action:@selector(skipToSegmentChanged:) forControlEvents:UIControlEventValueChanged];
//    [switchToSectionSegmentedControl setCenter:CGPointMake(675.0f, 612.0f)];
//    [switchToSectionSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
//    switchToSectionSegmentedControl.transform = rotateRight;
//    switchToSectionSegmentedControl.alpha = 0.0;
//    
//    [switchToSectionSegmentedControl setEnabled:NO forSegmentAtIndex:0];
//    [switchToSectionSegmentedControl setEnabled:NO forSegmentAtIndex:2];
//    [switchToSectionSegmentedControl setEnabled:NO forSegmentAtIndex:3];
//    [switchToSectionSegmentedControl setEnabled:NO forSegmentAtIndex:4];
//    
//    [self.view addSubview:switchToSectionSegmentedControl];
//    [self.view sendSubviewToBack:switchToSectionSegmentedControl];
    
    //returnVisitButton - decide if patient's followup/return visit
	returnVisitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnVisitButton.frame = CGRectMake(0, 0, 113, 76);
	returnVisitButton.showsTouchWhenHighlighted = YES;
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image.png"] forState:UIControlStateNormal];
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image_pressed.png"] forState:UIControlStateSelected];
	returnVisitButton.backgroundColor = [UIColor clearColor];
    [returnVisitButton setCenter:CGPointMake(620.0f, 400.0f)];
//    [returnVisitButton setCenter:CGPointMake(400.0f, 660.0f)];
	[returnVisitButton addTarget:self action:@selector(visitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	returnVisitButton.enabled = YES;
	returnVisitButton.hidden = NO;
    returnVisitButton.selected = YES;
    //    returnVisitButton.alpha = 0.0;
	[returnVisitButton retain];
//    returnVisitButton.transform = rotateRight;
    
    [self.view addSubview:returnVisitButton];
    
    settingsVC = [[SettingsViewController alloc] init];
    settingsVC.view.frame = CGRectMake(0, 0, 1024, 1040);
    
    settingsVC.view.backgroundColor = [UIColor clearColor];
//    [settingsVC.view setCenter:CGPointMake(270.0f, 640.0f)];

    [settingsVC.view setCenter:CGPointMake(512.0f, 1205.0f)];
//    [settingsVC.view setCenter:CGPointMake(1205.0f, 512.0f)];

//    settingsVC.view.transform = rotateRight;
    [self.view addSubview:settingsVC.view];
    
    [self createClinicSplitViewController];
    
//    splitViewController.view.transform = rotateRight;
    splitViewController.view.alpha = 0.0;
    [self.view addSubview:splitViewController.view];
//    [self.view sendSubviewToBack:splitViewController.view];
    
    //readyAppButton - launch splashView images and prompts once staff have been selected
	readyAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
	readyAppButton.frame = CGRectMake(0, 0, 258, 182);
	readyAppButton.showsTouchWhenHighlighted = YES;
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button.png"] forState:UIControlStateNormal];
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button_pressed.png"] forState:UIControlStateHighlighted];
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button_pressed.png"] forState:UIControlStateSelected];
	readyAppButton.backgroundColor = [UIColor clearColor];
   // [readyAppButton setCenter:CGPointMake(130.0f, 670.0f)];
    [readyAppButton setCenter:CGPointMake(880.0f, 670.0f)];
	[readyAppButton addTarget:self action:@selector(readyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	readyAppButton.enabled = NO;
	readyAppButton.hidden = NO;
    readyAppButton.alpha = 0.0;
	[readyAppButton retain];
//    readyAppButton.transform = rotateRight;
    
    [self.view addSubview:readyAppButton];
    [self.view sendSubviewToBack:readyAppButton];
    
    if (forceToDemoMode ) {
        NSLog(@"FORCING INTO DEMO MODE...");
        if (!collectingPilotData) {
            runningAppInDemoMode = YES;
            NSLog(@"Demo Mode ON");
        } else {
           // sandy making this line skipped forces mini demo mode to display, but buttons dont work
            runningAppInDemoMode = NO;
            NSLog(@"Collecting pilot data with atypical settings - Demo Mode OFF");
        }
        [self.view bringSubviewToFront:switchToSectionSegmentedControl];
        [self.view bringSubviewToFront:settingsVC.view];
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            switchToSectionSegmentedControl.alpha = 1.0;
            
        }
        [UIView commitAnimations];
        
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInMiniDemoMenu];
        demoSwitch.enabled = YES;
//        demoSwitch.alpha = 0.6;
    }
    
    
    NSLog(@"Prepared pre-splash items");
}

#pragma mark - clinic and provider/physician picker

- (void)createClinicSplitViewController {
    NSLog(@"WRViewController.createClinicSplitViewController()");

    masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    allClinicPhysicians = [@[@"Lawrence Huang, M.D.",
                           @"Steven Chao, M.D., Ph.D.",
                           @"Ninad Karandikar, M.D.",
                           @"Wade Kingery, M.D.",
                           @"Roger Klima, M.D.",
                           @"Oanh Mandal, M.D.",
                           @"Ted Scott, M.D.",
                           @"Jeff Teraoka, M.D.",
                           @"Molly Ann Timmerman, D.O.",
                           @"Debbie Pitsch, MPT, GCS, ATP",
                           @"Karen Parecki, MS, OTR/L, CBIS, ATP",
                           @"Eve Klein, MA, CCC-SLP"] mutableCopy];
    
    NSLog(@"WRViewController.createClinicSplitViewController() allClinicPhysicians: %@", allClinicPhysicians);

    allClinicPhysiciansThumbs = [@[@"pmnr_huang_thumb.png",
                                 @"pmnr_chao_thumb2.png",
                           @"pmnr_karandikar_thumb.png",
                                 @"pmnr_kingery_thumb2.png",
                           @"pmnr_klima_thumb2.png",
                           @"pmnr_mandal_thumb3.png",
                           @"pmnr_scott_thumb.png",
                           @"pmnr_teraoka_thumb.png",
                            @"pns_timmerman_thumb.png",
                            @"at_pitsch_thumb.png",
                            @"at_parecki_thumb.png",
                            @"at_klein_thumb.png"] mutableCopy];
    
    allClinicPhysiciansImages = [@[@"pmnr_huang.png",
                                 @"pmnr_chao2.png",
                                 @"pmnr_karandikar.png",
                                 @"pmnr_kingery2.png",
                                 @"pmnr_klima2.png",
                                 @"pmnr_mandal3.png",
                                 @"pmnr_scott.png",
                                 @"pmnr_teraoka.png",
                                 @"pns_timmerman.png",
                                 @"at_pitsch.png",
                                 @"at_parecki.png",
                                 @"at_klein.png"] mutableCopy];
    
    allClinicPhysiciansBioPLists = [@[@"pmnr_huang_bio",
                                    @"pmnr_chao_bio",
                                    @"pmnr_karandikar_bio",
                                    @"pmnr_kingery_bio",
                                    @"pmnr_klima_bio",
                                    @"pmnr_mandal_bio",
                                    @"pmnr_scott_bio",
                                    @"pmnr_teraoka_bio",
                                    @"pns_timmerman_bio",
                                    @"at_pitsch_bio",
                                    @"at_parecki_bio",
                                    @"at_klein_bio"] mutableCopy];
    
    allClinicPhysiciansSoundFiles = [@[@"pmnr_huang",
                                     @"pmnr_chao",
                                     @"pmnr_karandikar",
                                     @"pmnr_kingery",
                                     @"pmnr_klima",
                                     @"pmnr_mandal",
                                     @"pmnr_scott",
                                     @"pmnr_teraoka",
                                     @"pns_timmerman",
                                     @"at_pitsch",
                                     @"at_parecki",
                                     @"at_klein"] mutableCopy];
    
//    allClinicPhysicians = [@[@"Lawrence Huang, M.D.",
//                           @"Steven Chao, M.D., Ph.D.",
//                           @"Ninad Karandikar, M.D.",
//                           @"Wade Kingery, M.D.",
//                           @"Roger Klima, M.D.",
//                           @"Oanh Mandal, M.D.",
//                           @"Ted Scott, M.D.",
//                           @"Kamala Shankar, M.D., MBBS",
//                           @"Jeff Teraoka, M.D."] mutableCopy];
//    
//    allClinicPhysiciansThumbs = [@[@"pmnr_huang_thumb.png",
//                                 @"pmnr_chao_thumb2.png",
//                                 @"pmnr_karandikar_thumb.png",
//                                 @"pmnr_kingery_thumb.png",
//                                 @"pmnr_klima_thumb2.png",
//                                 @"pmnr_mandal_thumb2.png",
//                                 @"pmnr_scott_thumb.png",
//                                 @"pmnr_shankar_thumb.png",
//                                 @"pmnr_teraoka_thumb.png"] mutableCopy];
//    
//    allClinicPhysiciansImages = [@[@"pmnr_huang.png",
//                                 @"pmnr_chao2.png",
//                                 @"pmnr_karandikar.png",
//                                 @"pmnr_kingery.png",
//                                 @"pmnr_klima2.png",
//                                 @"pmnr_mandal2.png",
//                                 @"pmnr_scott.png",
//                                 @"pmnr_shankar.png",
//                                 @"pmnr_teraoka.png"] mutableCopy];
//    
//    allClinicPhysiciansBioPLists = [@[@"pmnr_huang_bio",
//                                    @"pmnr_chao_bio",
//                                    @"pmnr_karandikar_bio",
//                                    @"pmnr_kingery_bio",
//                                    @"pmnr_klima_bio",
//                                    @"pmnr_mandal_bio",
//                                    @"pmnr_scott_bio",
//                                    @"pmnr_shankar_bio",
//                                    @"pmnr_teraoka_bio"] mutableCopy];
//    
//    allClinicPhysiciansSoundFiles = [@[@"pmnr_huang",
//                                     @"pmnr_chao",
//                                     @"pmnr_karandikar",
//                                     @"pmnr_kingery",
//                                     @"pmnr_klima",
//                                     @"pmnr_mandal",
//                                     @"pmnr_scott",
//                                     @"pmnr_shankar",
//                                     @"pmnr_teraoka"] mutableCopy];
    
    //rjl 8/16/14 dynamically add a new clinician
    NSMutableArray *mutableAllClinicPhysicians = [DynamicContent getNewClinicianNames];
//    pmnrSubClinicPhysicians = [[NSArray alloc] initWithObjects:allClinicPhysicians,
    pmnrSubClinicPhysicians = [[NSArray alloc] initWithObjects:mutableAllClinicPhysicians,
                               [NSArray arrayWithObjects:@"Lawrence Huang, M.D.",
                                @"Ninad Karandikar, M.D.",
                                @"Wade Kingery, M.D.",
                                @"Roger Klima, M.D.",
                                @"Oanh Mandal, M.D.",nil],
                               [NSArray arrayWithObjects:@"Ninad Karandikar, M.D.",
                                @"Roger Klima, M.D.",
                                @"Ted Scott, M.D.",
                                @"Jeff Teraoka, M.D.",nil],
                               [NSArray arrayWithObjects:@"Steven Chao, M.D., Ph.D.",
                                @"Oanh Mandal, M.D.",
                                @"Jeff Teraoka, M.D.",
                                @"Molly Ann Timmerman, D.O.",nil],
                               [NSArray arrayWithObjects:@"Jeff Teraoka2, M.D.", nil],
                               [NSArray arrayWithObjects:@"Debbie Pitsch, MPT, GCS, ATP",
                                @"Karen Parecki, MS, OTR/L, CBIS, ATP",
                                @"Eve Klein, MA, CCC-SLP",nil],nil];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    PhysicianCellViewController *newDetailViewController0 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController1 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController2 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController3 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController4 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController5 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController6 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController7 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController8 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController9 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController10 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController11 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController12 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController13 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController14 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController15 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];

    // rjl 8/16/14 here is the list of clinic detail display pages
    arrayDetailVCs = [[NSArray alloc]initWithObjects:newDetailViewController0, newDetailViewController1, newDetailViewController2, newDetailViewController3, newDetailViewController4, newDetailViewController5, newDetailViewController6, newDetailViewController7,
        newDetailViewController8, newDetailViewController9, newDetailViewController10, newDetailViewController11, newDetailViewController12,
        newDetailViewController13, newDetailViewController14, newDetailViewController15,  nil];
    
    masterViewController.myDetailViewController = newDetailViewController0;
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = @[
   [[UINavigationController alloc] initWithRootViewController:masterViewController],
    [[UINavigationController alloc] initWithRootViewController:newDetailViewController0]
    ];

    splitViewController.delegate = self;
}

//- (NSMutableArray*) getAllClinicPhysicians { //rjl 8/16/14
//    return [DynamicContent getNewClinicianNames];
//}
//    NSLog(@"WRViewController.getAllClinicPhysicians()");
//    NSMutableArray *mutableAllClinicPhysicians = [[NSMutableArray alloc] init];//[allClinicPhysicians mutableCopy];
//    NSArray * newClinicians = [DynamicContent getNewClinicianNames];
//    for (NSString *name in newClinicians){
//
////        NSString* newClinicianName = @"Eleanor Roosevelt";
//        [mutableAllClinicPhysicians addObject:name];
//    }
//    NSLog(@"WRViewController.getAllClinicPhysicians() exit");
//    return newClinicians; //mutableAllClinicPhysicians;
//}

//- (NSMutableArray*) getAllClinicPhysiciansThumbs { //rjl 8/16/14
////    NSLog(@"WRViewController.getAllClinicPhysiciansThumbs()");
//
//    NSMutableArray *mutableAllClinicPhysiciansThumbs = [allClinicPhysiciansThumbs mutableCopy];
//    NSMutableArray * newClinicians = [self getNewClinicianNames];
//    for (NSString *name in newClinicians){
//        NSString* newClinicianThumb = @"pmnr_teraoka_thumb.png";
//        [mutableAllClinicPhysiciansThumbs addObject:newClinicianThumb];
//    }
////    NSLog(@"WRViewController.getAllClinicPhysiciansThumbs exit()");
//
//    return mutableAllClinicPhysiciansThumbs;
//}

//- (NSMutableArray*) getAllClinicPhysiciansImages { //rjl 8/16/14
    //    NSLog(@"WRViewController.getAllClinicPhysiciansImages()");
//    return  [DynamicContent getNewClinicianImages];
//}
//    NSMutableArray *mutableAllClinicPhysiciansImages = [allClinicPhysiciansImages mutableCopy];
//    NSMutableArray * newClinicianImages = [DynamicContent getNewClinicianImages];
//    for (NSString *imageFilename in newClinicianImages){
////        NSString* newClinicianImage = @"pmnr_teraoka.png";
//        [mutableAllClinicPhysiciansImages addObject:imageFilename];
//    }
//    //    NSLog(@"WRViewController.getAllClinicPhysiciansImages() exit()");
//    
//    return mutableAllClinicPhysiciansImages;
//}


- (NSMutableArray*) getAllClinicPhysiciansBioPlists { //rjl 8/16/14
    //    NSLog(@"WRViewController.getAllClinicPhysiciansBioPlists()");
    
    NSMutableArray *mutableAllClinicPhysiciansBioPlists = [allClinicPhysiciansBioPLists mutableCopy];
    NSMutableArray * newClinicians = [DynamicContent getNewClinicianNames];
    for (NSString *name in newClinicians){
        NSString* newClinicianPlist = @"pmnr_teraoka_bio";
        [mutableAllClinicPhysiciansBioPlists addObject:newClinicianPlist];
    }
    //    NSLog(@"WRViewController.getAllClinicPhysiciansBioPlists() exit()");
    
    return mutableAllClinicPhysiciansBioPlists;
}

- (NSMutableArray*) getAllClinicPhysiciansSoundFiles { //rjl 8/16/14
    //    NSLog(@"WRViewController.getAllClinicPhysiciansSoundFiles()");

    NSMutableArray *mutableAllClinicPhysiciansSoundFiles = [allClinicPhysiciansSoundFiles mutableCopy];
    NSMutableArray * newClinicians = [DynamicContent getNewClinicianNames];
    for (NSString *name in newClinicians){
        NSString *silence_sound = [[NSBundle mainBundle] pathForResource:@"silence_half_second" ofType:@"wav"];
//        NSString* newClinicianSoundFile = @"pmnr_teraoka";
        NSString * newClinicianSoundFile = silence_sound;
        [mutableAllClinicPhysiciansSoundFiles addObject:newClinicianSoundFile];
    }
    //    NSLog(@"WRViewController.getAllClinicPhysiciansBioPlists() exit()");
    
    return mutableAllClinicPhysiciansSoundFiles;
}



// TBD sandy 10_13_14 add variables for other progress values
//selfcompleteper;
//totalcompleteper;

- (void)setProgressBarSlidesCompleted:(int)slidesCompletedCount {
    //    totalSlidesInThisSection = 0;
    slidesCompleted = slidesCompletedCount;
    progressSoFar = (CGFloat)slidesCompleted / totalSlidesInThisSection;
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] progressVC] updateProgressTo:progressSoFar];
    
    //int perCom = (int)progressSoFar * 100; %.0f%
    float perCom = (float)progressSoFar * 100;
    if (completedProviderSession) {
        NSLog(@"Updating post tx progress to: %.0f %%...",perCom);
        [tbvc updateSurveyNumberForField:@"posttxcompleteper" withThisRatingNum:perCom];
    } else {
        NSLog(@"Updating pre tx progress to: %.0f %%...",perCom);
        [tbvc updateSurveyNumberForField:@"pretxcompleteper" withThisRatingNum:perCom];
    }
}

- (void)incrementProgressBar {
//    totalSlidesInThisSection = 0;
    slidesCompleted += 1;
    progressSoFar = (CGFloat)slidesCompleted / totalSlidesInThisSection;
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] progressVC] updateProgressTo:progressSoFar];
    
    //int perCom = (int)progressSoFar * 100; %.0f%
    float perCom = (float)progressSoFar * 100;
    if (completedProviderSession) {
        NSLog(@"Updating post tx progress to: %.0f %%...",perCom);
        [tbvc updateSurveyNumberForField:@"posttxcompleteper" withThisRatingNum:perCom];
    } else {
        NSLog(@"Updating pre tx progress to: %.0f %%...",perCom);
        [tbvc updateSurveyNumberForField:@"pretxcompleteper" withThisRatingNum:perCom];
    }
}

- (void)decrementProgressBar {
    //    totalSlidesInThisSection = 0;
    slidesCompleted -= 1;
    progressSoFar = (CGFloat)slidesCompleted / totalSlidesInThisSection;
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] progressVC] updateProgressTo:progressSoFar];
    
    int perCom = (int)progressSoFar * 100;
    if (completedProviderSession) {
        NSLog(@"Updating post tx progress to: %d %%...",perCom);
        [tbvc updateSurveyNumberForField:@"posttxcompleteper" withThisRatingNum:perCom];
    } else {
        NSLog(@"Updating pre tx progress to: %d %%...",perCom);
        [tbvc updateSurveyNumberForField:@"pretxcompleteper" withThisRatingNum:perCom];
    }
}

- (void)resetProgressBar {
    slidesCompleted = 0;
    totalSlidesInThisSection = 0;
    progressSoFar = 0.0;
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] progressVC] updateProgressTo:progressSoFar];
}

- (void)addToTotalSlides:(int)thisManySlides {
   // totalSlidesInThisSection += thisManySlides;
   // NSLog(@"Adding %d to total slides (new total = %d)...",thisManySlides,totalSlidesInThisSection);
}



- (void)setNewDetailVCForRow:(int)newRow {
    NSLog(@"WRViewController.setNewDetailForRow() newRow: %d", newRow);
    //newRow = newRow-1;
    if (newRow < 0)
        newRow = 0;
    id vc = [splitViewController.viewControllers objectAtIndex:0];
    int count = [arrayDetailVCs count];
    if (count <= newRow){
        NSLog(@"WRViewController.setNewDetailVCForRow() index %d exceeds count %d",newRow, count);
        return;
        }

        id detailVc = [arrayDetailVCs objectAtIndex:newRow]; // rjl 1/27/15 newRow is 6 but list length is 6 (0-based). Bug is that list should contain seven objects
    NSArray *newVCs = [NSArray arrayWithObjects:vc, detailVc, nil];
    
    splitViewController.viewControllers = newVCs;
    
    NSLog(@"Updated detail VC for master VC row: %d",newRow);
}

#pragma mark HorizontalPickerView DataSource Methods

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    NSLog(@"WRViewController.numberOfElementsInHorizontalPickerView()");
	return [titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	return [titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    NSLog(@"WRViewController.horizontalPickerView()");
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text = [titleArray objectAtIndex:index];
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    //	self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
    initialSettingsLabel.text = [NSString stringWithFormat:@"%@ App - Launch Settings",[titleArray objectAtIndex:index]];
}

#pragma mark Button Pressed Methods

- (void)skipToSegmentChanged:(id)sender {
    if (switchToSectionSegmentedControl.selectedSegmentIndex == 0) {
        skipToSplashIntro = YES;
        skipToPhysicianDetail = NO;
        skipToEducationModule = NO;
        skipToSatisfactionSurvey = NO;
        skipToMainMenu = NO;
    } else if (switchToSectionSegmentedControl.selectedSegmentIndex == 1) {
        skipToSplashIntro = YES;
        skipToPhysicianDetail = YES;
        skipToEducationModule = NO;
        skipToSatisfactionSurvey = NO;
        skipToMainMenu = NO;
    } else if (switchToSectionSegmentedControl.selectedSegmentIndex == 2) {
        skipToSplashIntro = YES;
        skipToPhysicianDetail = YES;
        skipToEducationModule = YES;
        skipToSatisfactionSurvey = NO;
        skipToMainMenu = NO;
    } else if (switchToSectionSegmentedControl.selectedSegmentIndex == 3) {
        skipToSplashIntro = YES;
        skipToPhysicianDetail = YES;
        skipToEducationModule = YES;
        skipToSatisfactionSurvey = YES;
        skipToMainMenu = NO;
    } else {
        skipToSplashIntro = YES;
        skipToPhysicianDetail = YES;
        skipToEducationModule = YES;
        skipToSatisfactionSurvey = YES;
        skipToMainMenu = YES;
    }
}

- (void)clinicSegmentChanged:(id)sender {
    NSLog(@"WRViewController.clinicSegmentChanged()");

    if (clinicSegmentedControl.selectedSegmentIndex == 0) {
        currentClinicName = @"AT Center";
        currentMainClinic = kATLab;
        
        [self fadeOutSpecialtyClinicSegmentedControl];
        [DynamicContent setCurrentClinic:@"at"];
        currentSpecialtyClinicName = @"AT";
        selectedSubclinic = YES;
        NSLog(@"WRViewController.clinicSegmentChanged() Selected Specialty Clinic: %@...",currentSpecialtyClinicName);
        
        [splashImageViewBb setImage:[UIImage imageNamed:@"vapahcs_new_polytrauma_logo_splash_landscape.png"]];
        
        [self setDynamicEdClinicSpecFileForSpecialtyClinicName:currentSpecialtyClinicName];
    } else if (clinicSegmentedControl.selectedSegmentIndex == 1) {
        [DynamicContent setCurrentClinic:@"pmnr"];
        currentClinicName = @"PM&R Clinic";
        currentMainClinic = kPMNRClinic;
        
        [splashImageViewBb setImage:[UIImage imageNamed:@"vapahcs_new_PMNR_logo_splash_landscape.png"]];
        
        //[self fadeInSpecialtyClinicSegmentedControl];
    } else {
        [DynamicContent setCurrentClinic:@"pns"];
        currentClinicName = @"PNS Clinic";
        currentMainClinic = kPNSClinic;
        
        [self fadeOutSpecialtyClinicSegmentedControl];
        currentSpecialtyClinicName = @"PNS";
        selectedSubclinic = YES;
        NSLog(@"WRViewController.clinicSegmentChanged() Selected Specialty Clinic: %@...",currentSpecialtyClinicName);
        
        [splashImageViewBb setImage:[UIImage imageNamed:@"vapahcs_new_polytrauma_logo_splash_landscape.png"]];
        
        [self setDynamicEdClinicSpecFileForSpecialtyClinicName:currentSpecialtyClinicName];

    }
    NSLog(@"WRViewController.clinicSegmentChanged() Selected Clinic: %@...",currentClinicName);
    
    initialSettingsLabel.text = [NSString stringWithFormat:@"%@ App - Launch Settings",currentClinicName];
    
    mainClinicName = currentClinicName;
    
    [self updateMiniDemoSettings];
    
    selectedClinic = YES;
    
    if (selectedVisit && selectedSubclinic) {
        nextSettingsButton.enabled = YES;
    }
    
    
    if (!whatsNewInitialized) {
        [self initializeWhatsNewModule];
    }
    if (!dynamicSurveyInitialized) {
        [self setUpDynamicSurveyForTheFirstTime];
    }
    [self setDynamicWhatsNewSoundFileDict];
}

- (void)setClinic:(NSString*)clinicName {
    NSLog(@"WRViewController.setClinic() %@", clinicName);
    if ([clinicName isEqualToString:@"All"] || [clinicName isEqualToString:@"Default"]){
        NSArray* allClinics = [DynamicContent getClinicSubclinicComboNames];
        clinicName = [allClinics objectAtIndex:0];
        NSLog(@"WRViewController.setClinic() Default clinic is: %@", clinicName);

    }
    ClinicInfo* clinicInfo = [DynamicContent getClinic:clinicName];
    if (clinicInfo == NULL){
        NSLog(@"WRViewController.setClinic() ERROR! clinic info not found for: %@", clinicName);
        return;
    }
    currentClinicName = clinicName; //@"AT Center";
    //currentMainClinic = kATLab;
    
    //        [self fadeOutSpecialtyClinicSegmentedControl];
    NSString* clinicNameShort = [clinicInfo getClinicSubclinicComboName];
    if ([clinicNameShort length] == 0)
        clinicNameShort = [clinicInfo getSubclinicNameShort];
    if ([clinicNameShort length] == 0)
        clinicNameShort = [clinicInfo getClinicNameShort];
    [DynamicContent setCurrentClinic:clinicNameShort];
    NSString* clinicImage = [clinicInfo getClinicImage];
    if (clinicImage != NULL && [clinicImage length] > 0){
        if (![clinicImage hasPrefix:@"nophotoyet."]){
            UIImage* image = [DynamicContent loadImage:clinicImage];
            UIImage* rotatedImage = [image imageRotatedByDegrees:-90.0];
            [splashImageViewBb setImage:rotatedImage];
            splashImageViewBb.contentMode=UIViewContentModeScaleAspectFit;
        }
        else
            [splashImageViewBb setImage:NULL];
    }
    else
        [splashImageViewBb setImage:[UIImage imageNamed:@"vapahcs_new_polytrauma_logo_splash_landscape.png"]];

    
    [self setDynamicEdClinicSpecFileForSpecialtyClinicName:currentSpecialtyClinicName];
    
    selectedSubclinic = YES;
    NSLog(@"WRViewController.setClinic() currentClinicName: %@",currentClinicName);
    
    initialSettingsLabel.text = [NSString stringWithFormat:@"%@ App - Launch Settings",currentClinicName];
    
    mainClinicName = currentClinicName;
    
    [self updateMiniDemoSettings];
    
    selectedClinic = YES;
    
    if (selectedVisit && selectedSubclinic) {
        nextSettingsButton.enabled = YES;
    }
    
    
    if (!whatsNewInitialized) {
       // [self initializeWhatsNewModule];
        [self initializeEdModulesForCurrentClinic];
//        [self initializeEdModule1];
//        [self initializeEdModule2];
//        [self initializeEdModule3];
//        [self initializeEdModule4];
//        [self initializeEdModule5];
    }
    if (!dynamicSurveyInitialized) {
        [self setUpDynamicSurveyForTheFirstTime];
    }
//    [self setDynamicWhatsNewSoundFileDict];
}


- (void)fadeInSpecialtyClinicSegmentedControl {

    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        specialtyClinicSegmentedControl.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)fadeOutSpecialtyClinicSegmentedControl {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        specialtyClinicSegmentedControl.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)specialtyClinicSegmentChanged:(id)sender {
    if (specialtyClinicSegmentedControl.selectedSegmentIndex == 0) {
        currentSpecialtyClinicName = @"General PM&R";
        [DynamicContent setCurrentClinic:@"pmnr"];
    } else if (specialtyClinicSegmentedControl.selectedSegmentIndex == 1) {
        currentSpecialtyClinicName = @"Acupuncture clinic";
        [DynamicContent setCurrentClinic:@"acupuncture"];
    } else if (specialtyClinicSegmentedControl.selectedSegmentIndex == 2) {
        currentSpecialtyClinicName = @"Pain";
        [DynamicContent setCurrentClinic:@"pain"];
   } else if (specialtyClinicSegmentedControl.selectedSegmentIndex == 3) {
        currentSpecialtyClinicName = @"EMG";
       [DynamicContent setCurrentClinic:@"emg"];
   } else {
       currentSpecialtyClinicName = @"Pain";
       [DynamicContent setCurrentClinic:@"pain"];
   }
    
    NSLog(@"WRViewController.specialtyClinicSegmentChanged() Selected Specialty Clinic: %@...",currentSpecialtyClinicName);
    
    [self setDynamicEdClinicSpecFileForSpecialtyClinicName:currentSpecialtyClinicName];
    
    selectedSubclinic = YES;
    
    if (selectedVisit && selectedClinic) {
        nextSettingsButton.enabled = YES;
    }
    
//    initialSettingsLabel.text = [NSString stringWithFormat:@"%@ App - Launch Settings",currentClinicName];
    
}

- (void)setDynamicEdClinicSpecFileForSpecialtyClinicName:(NSString *)thisSpecialtyClinicName {
    //NSLog(@"WRViewController.setDynamicEdClinicSpecFileForSpecialtyClinicName() Selected Specialty Clinic: %@...",currentSpecialtyClinicName);
    currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pain_ed_module_test2"; // dummy value used for sound files

//    if ([thisSpecialtyClinicName isEqualToString:@"None"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pain_ed_module_test2";
//    } else if ([thisSpecialtyClinicName hasPrefix:@"Acupuncture"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_acu_ed_module_test2";
//    } else if ([thisSpecialtyClinicName hasPrefix:@"Pain"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pain_ed_module_test2";
//    } else if ([thisSpecialtyClinicName isEqualToString:@"PNS"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pns_ed_module_test3";
//    } else if ([thisSpecialtyClinicName isEqualToString:@"EMG"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_emg_ed_module_test2";
//    } else if ([thisSpecialtyClinicName isEqualToString:@"General PM&R"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_education_module_test1";
//    } else if ([thisSpecialtyClinicName isEqualToString:@"AT"]) {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pns_ed_module_test2";
//    } else {
//        currentDynamicSubClinicEdModuleSpecFilename = @"pmnr_pain_ed_module_test2";
//    }
//    NSLog(@"Set Dynamic Specialty Clinic Ed Module Specfilename to: %@...",currentDynamicSubClinicEdModuleSpecFilename);

    
    [self initializeDynamicSubClinicEducationModule];
    [self setDefaultDynamicSubClinicSoundFileDict];
    
    firstVisitSlides = firstVisitSlides + [dynamicSubclinicEdModule.newChildControllers count];
    firstVisitSlides = firstVisitSlides + 3;
//    [self setThisDynamicSoundFileDict:currentDynamicSubClinicEdModuleSpecFilename];
    
}

//- (void)setDynamicEdClinicSpecFileForClinicName:(NSString *)thisClinicName {
//    NSLog(@"WRViewController.setDynamicEdClinicSpecFileForClinicName()");
//    if ([thisClinicName isEqualToString:@"PM&R Clinic"]) {
//        currentDynamicClinicEdModuleSpecFilename = @"pmnr_education_module_test1";
//        NSLog(@"Set Dynamic Clinic Ed Module Specfilename to: %@...",currentDynamicClinicEdModuleSpecFilename);
//    } else if ([thisClinicName isEqualToString:@"PNS Clinic"]) {
//        currentDynamicClinicEdModuleSpecFilename = @"pmnr_education_module_test1";
//        NSLog(@"Set Dynamic Clinic Ed Module Specfilename to: %@...",currentDynamicClinicEdModuleSpecFilename);
//    } else if ([thisClinicName isEqualToString:@"AT Center"]) {
//        currentDynamicClinicEdModuleSpecFilename = @"at_ed_module_test1";
//        NSLog(@"Set Dynamic Clinic Ed Module Specfilename to: %@...",currentDynamicClinicEdModuleSpecFilename);
//    }
//    
//    [self initializeDynamicEducationModule];
//    [self setDefaultDynamicSoundFileDict];
//    
//    totalSlidesInThisSection = totalSlidesInThisSection - [dynamicEdModule.newChildControllers count];
//    NSLog(@"Removing %d slides due to unused dynamicEdModule (new total = %d)...",[dynamicEdModule.newChildControllers count],totalSlidesInThisSection);
//}

- (void)demoSwitchFlipped:(id)sender {
    
    if (demoSwitch.isOn) {
        runningAppInDemoMode = YES;
        NSLog(@"WRViewController.demoSwitchFlipped() runningAppInDemoMode = YES");
        [self.view bringSubviewToFront:switchToSectionSegmentedControl];
        [self.view bringSubviewToFront:settingsVC.view];
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            switchToSectionSegmentedControl.alpha = 1.0;
            
        }
        [UIView commitAnimations];
        
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInMiniDemoMenu];
        
    }  else {
        runningAppInDemoMode = NO;
        NSLog(@"WRViewController.demoSwitchFlipped() runningAppInDemoMode = NO");
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            switchToSectionSegmentedControl.alpha = 0.0;
            
        }
        [UIView commitAnimations];
        
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu];
    }
    
    [self updateMiniDemoSettings];
}

- (void)updateMiniDemoSettings {
    NSLog(@"WRViewController.updateMiniDemoSettings()");

//    if (forceToDemoMode) {
//        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInMiniDemoMenu];
//    }
    
    if (runningAppInDemoMode) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setDemoText:@"Yes"];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setDemoText:@"No"];
    }
    
//    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setClinicText:currentClinicName];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setClinicText:[NSString stringWithFormat:@"%@",currentClinicName]];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSubClinicText:[NSString stringWithFormat:@"%@",currentSpecialtyClinicName]];
    
    if (isFirstVisit) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setVisitText:@"First"];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setVisitText:@"Return"];
    }
    
    if (satisfactionSurveyCompleted) {
        NSLog(@"WRViewController.updateMiniDemoSettings() satisfactionSurveyCompleted = true");
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSatisfactionText:@"Completed"];
    } else if (satisfactionSurveyInProgress) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSatisfactionText:@"In progress..."];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSatisfactionText:@"Pending"];
    }
    
    if (educationModuleCompleted) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setEdText:@"Completed"];
    } else if (educationModuleInProgress) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setEdText:@"In progress..."];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setEdText:@"Pending"];
    }
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSeeingText:attendingPhysicianName];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setRespondentText:tbvc.respondentType];
    
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] updateAllMiniMenuLabels];
}

- (void)storeAttendingPhysicianSettingsForPhysicianName:(NSString *)selectedPhysicianName {
    NSLog(@"WRViewController.storeAttendingPhysicianSettingsForPhysicianName() selectedPhysicianName: %@", selectedPhysicianName);

    int currentPhysicianIndex = 0;
    int physicianArrayIndex = 0;
    
    // rjl 8/17/14
    /*
     *  Here is where we override the hardcoded values by calling covering functions to add dynamic content
     */
    
    NSMutableArray* allPhysicians = [DynamicContent getNewClinicianNames];
    NSMutableArray* allPhysiciansImages = [DynamicContent getNewClinicianImages];
    NSMutableArray* allPhysiciansSoundfiles = [self getAllClinicPhysiciansSoundFiles];
    
    for (NSString *thisPhysicianName in allPhysicians) // rjl 8/16/14
           {
                if ([thisPhysicianName isEqualToString:selectedPhysicianName]) {
                    currentPhysicianIndex = physicianArrayIndex;
                }
                physicianArrayIndex++;
            }
    NSLog(@"WRViewController.storeAttendingPhysicianSettingsForPhysicianName() Selected physician index: %d",currentPhysicianIndex);
    
    attendingPhysicianName = selectedPhysicianName;
    attendingPhysicianImage = [allPhysiciansImages objectAtIndex:currentPhysicianIndex];
    attendingPhysicianIndex = currentPhysicianIndex;
    attendingPhysicianSoundFile = [allPhysiciansSoundfiles objectAtIndex:currentPhysicianIndex];
    
    [self updateMiniDemoSettings];
}

- (void)visitButtonPressed:(id)sender {
    
    if (sender == firstVisitButton) {
		NSLog(@"WRViewcontroller.visitButtonPressed() First Visit");
        isFirstVisit = YES;
        firstVisitButton.selected = NO;
        returnVisitButton.selected = YES;
        firstVisitButton.alpha = 1.0;
        returnVisitButton.alpha = 0.5;
	} else if (sender == returnVisitButton) {
		NSLog(@"WRViewcontroller.visitButtonPressed() Return Visit");
        isFirstVisit = NO;
        firstVisitButton.selected = YES;
        returnVisitButton.selected = NO;
        firstVisitButton.alpha = 0.5;
        returnVisitButton.alpha = 1.0;
    }
    
    [self updateMiniDemoSettings];
    
    selectedVisit = YES;
    
    //if (selectedClinic && selectedSubclinic)
        nextSettingsButton.enabled = YES;
    //}
}

- (void)slideVisitButtonsOut {
    
    // rjl 9/22/14 hack below attempting to regenerate ed module pages for case when
    // when user first taps "AT" clinic then taps "PM&R" and subclinic
//    [self setDynamicEdClinicSpecFileForSpecialtyClinicName:currentSpecialtyClinicName];
//    DynamicModuleViewController_Pad* dynamicModuleViewController = [DynamicModuleViewController_Pad getViewController];
//    if (dynamicModuleViewController != NULL)
//       [dynamicModuleViewController updateViewContents];

    CGRect firstVisitFrame = firstVisitButton.frame;
    CGRect returnVisitFrame = returnVisitButton.frame;
    CGRect labelFrame = visitSelectionLabel.frame;
    firstVisitFrame.origin.y = 1500;
    returnVisitFrame.origin.y = -500;
    labelFrame.origin.x = 1500;
    
    NSLog(@"WRViewController.slideVisitButtonsOut()");
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        firstVisitButton.frame = firstVisitFrame;
        returnVisitButton.frame = returnVisitFrame;
        visitSelectionLabel.frame = labelFrame;
        
        clinicSegmentedControl.alpha = 0.0;
        specialtyClinicSegmentedControl.alpha = 0.0;
        initialSettingsLabel.alpha = 0.0;
        clinicSelectionLabel.alpha = 0.0;
        taperedWhiteLine.alpha = 0.0;
        demoSwitch.alpha = 0.0;
        demoModeLabel.alpha = 0.0;
        switchToSectionSegmentedControl.alpha = 0.0;
        nextSettingsButton.alpha = 0.0;
    }
    [UIView commitAnimations];
    
    if (skipToSplashIntro && runningAppInDemoMode) {
        [self launchAppWithSplashView];
    } else {
        [self fadePhysicianSelectorAndLaunchButtonIn];
    }
    
    [settingsVC hideSettingsFrame];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu];
}

- (void)activateLaunchButton {
    readyAppButton.enabled = YES;
}

- (void)deactivateLaunchButton {
    readyAppButton.enabled = NO;
}

- (void)clinicianSelectedWith:(id)sender {
    if (sender == odetteButton) {
        seeingClinician = @"Odette Harris, M.D., MPH";
        odetteButton.alpha = 1.0;
        calvinButton.alpha = 0.6;
        lauraButton.alpha = 0.6;
    } else if (sender == calvinButton) {
        seeingClinician = @"Calvin Gordon, M.D.";
        odetteButton.alpha = 0.6;
        calvinButton.alpha = 1.0;
        lauraButton.alpha = 0.6;
    } else {
        seeingClinician = @"Laura Howe, Ph.D., J.D.";
        odetteButton.alpha = 0.6;
        calvinButton.alpha = 0.6;
        lauraButton.alpha = 1.0;
    }
    
    clinicianLabel.text = [NSString stringWithFormat:@"Selected:\n%@",seeingClinician];
    
    [self updateMiniDemoSettings];
}

- (void)fadePhysicianSelectorAndLaunchButtonIn {
    NSLog(@"WRViewController.fadePhysicianSelectorAndLaunchButtonIn()");
    splitViewController.view.frame = [[UIScreen mainScreen] applicationFrame]; //CGRectMake(0, 0, 800, 1000); // rjl
    [self.view bringSubviewToFront:splitViewController.view];
    [self.view bringSubviewToFront:readyAppButton];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];

    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

        readyAppButton.alpha = 1.0;        
        splitViewController.view.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
}

- (void)readyButtonPressed:(id)sender {
    NSLog(@"WRViewController.readyButtonPressed() APP READY");
    [self setClinic:currentSubClinicName];
    underUserControl = YES;
    
    // Have selected a clinician/physician at this point
    [self updateMiniDemoSettings];
    
    [self slideClinicianSelectorAndReadyButtonOut];

    [self initializeReadyScreen];
    [self fadeInReadyScreen];
    
    [self initializePhysicianDetailView];
    [self initializeDynamicSurveyPages];
    //    [self initializeDynamicEducationModule];
    
}

- (void)startButtonPressed:(id)sender {
    NSLog(@"START APP");
    
//    [self launchAppWithSplashView];
    
    [self fadeThisObjectOut:readyScreen];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(beginToLaunchApp:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
    secondsDur = 0.0;
    uxTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:uxTimer forMode:NSDefaultRunLoopMode];
    NSLog(@"WRViewController.startButtonPressed() - starts timing the pretxdur");
    // sandy 10-12-14 writes startedsurvey to db when respondent type is set
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    NSDate *date = [NSDate date];
    int surveyStartedTimeStamp = [date timeIntervalSince1970];
    //     int endofpresurveyTimeStamp = [tbvc getCurrentDateTime];
    NSLog(@"WRViewController.startButtonPressed() - surveyStartedTimeStamp %d", surveyStartedTimeStamp);
    //store timestamp
    NSNumber *digitAsNumber = [NSNumber numberWithInt:surveyStartedTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
   [myTimeSegmentsArray addObject:digitAsNumber];

//    tbvc.currentDeviceName = deviceName;
}

- (void)storeCurrentUXTimeForPreTreatment {
    NSLog(@"Attempting to store pre-treatment time duration to db: %4.4f...",secondsDur);
    [tbvc updateSurveyTextForField:@"pretxdur" withThisText:[NSString stringWithFormat:@"%4.4f",secondsDur]];

    //------- reset Timer
    [self resetUXTimer];
    [uxTimer release];
    uxTimer = nil;
    secondsDur = 0.0;
    NSLog(@"WRViewController.resumeAppAfterTreatmentIntermission()",secondsDur);
    uxTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:uxTimer forMode:NSDefaultRunLoopMode];
    
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    NSDate *date = [NSDate date];
    int endofpresurveyTimeStamp = [date timeIntervalSince1970];
     NSLog(@"WRViewController.storeCurrentUXTimeForPreTreatment() - End of PreTreatment %d", endofpresurveyTimeStamp);
    //NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
   // [myTimeSegmentsArray addObject:endofpresurveyTimeStamp];
    //store timestamp
    NSNumber *digitAsNumber = [NSNumber numberWithInt:endofpresurveyTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    [myTimeSegmentsArray addObject:digitAsNumber];
   // [self resetUXTimer];
}


- (void)storeCurrentUXTimeForSelfGuidedStop {

    NSLog(@"Stopped selfguided use duration is db: %4.4f...",secondsDur);
    [tbvc updateSurveyTextForField:@"selfguidedur" withThisText:[NSString stringWithFormat:@"%4.4f",secondsDur]];
    
    //------- reset Timer
    [self resetUXTimer];
    [uxTimer release];
    uxTimer = nil;
    secondsDur = 0.0;
    NSLog(@"WRViewController.resumeAppAfterTreatmentIntermission()",secondsDur);
    uxTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:uxTimer forMode:NSDefaultRunLoopMode];
    
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    NSDate *date = [NSDate date];
    int endofselfguideTimeStamp = [date timeIntervalSince1970];
    NSLog(@"WRViewController.storeCurrentUXTimeForSelfGuidedStop() - End of selfguided %d", endofselfguideTimeStamp);
   // NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    //[myTimeSegmentsArray addObject:endofselfguideTimeStamp];
    NSNumber *digitAsNumber = [NSNumber numberWithInt:endofselfguideTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    [myTimeSegmentsArray addObject:digitAsNumber];
    //[self resetUXTimer];
}

- (void)storeCurrentUXTimeForTreatmentStop {
    NSLog(@"Treatment ended -  post-treatment time start value to db: %4.4f...",secondsDur);
    [tbvc updateSurveyTextForField:@"treatmentdur" withThisText:[NSString stringWithFormat:@"%4.4f",secondsDur]];
   
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    NSDate *date = [NSDate date];
    int endoftreatmentTimeStamp = [date timeIntervalSince1970];
    NSLog(@"WRViewController.storeCurrentUXTimeForTreatmentStop() - End of Treatment %d", endoftreatmentTimeStamp);
    //NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
   // [myTimeSegmentsArray addObject:endoftreatmentTimeStamp];
    NSNumber *digitAsNumber = [NSNumber numberWithInt:endoftreatmentTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    [myTimeSegmentsArray addObject:digitAsNumber];
       // [self resetUXTimer];
}
- (void)storeCurrentUXTimeForPostSurveyStop {
    NSLog(@"Storing postsurvey to db: %4.4f...",secondsDur);
    [tbvc updateSurveyTextForField:@"posttxdur" withThisText:[NSString stringWithFormat:@"%4.4f",secondsDur]];
    
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    
    NSDate *date = [NSDate date];
    int endofpostsurveyTimeStamp = [date timeIntervalSince1970];
    NSLog(@"WRViewController.storeCurrentUXTimeForPostSurveyStop() - End of PostSurvey %d", endofpostsurveyTimeStamp);
    //[myTimeSegmentsArray addObject:endofpostsurveyTimeStamp];
    NSNumber *digitAsNumber = [NSNumber numberWithInt:endofpostsurveyTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    [myTimeSegmentsArray addObject:digitAsNumber];
      //  [self resetUXTimer];
}

- (void)storeTotalTime {
     RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    NSDate *date = [NSDate date];
    int endofAppTimeStamp = [date timeIntervalSince1970];
    NSLog(@"WRViewController.storeTotalTime() - End of AppUse or Reset %d", endofAppTimeStamp);
    NSNumber *digitAsNumber = [NSNumber numberWithInt:endofAppTimeStamp];
    NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    [myTimeSegmentsArray addObject:digitAsNumber];
    //NSNumber* returnedtime =[[myTimeSegmentsArray objectAtIndex:0]intValue];
    int starttime = [[myTimeSegmentsArray objectAtIndex:0]intValue];

    int totaltime = endofAppTimeStamp - starttime;
    NSLog(@"WRViewController.storeTotalTime() - End of AppUse or Reset %d - %d = %d", endofAppTimeStamp,starttime,totaltime);
    [tbvc updateSurveyTextForField:@"totaldur" withThisText:[NSString stringWithFormat:@"%4.4d",totaltime]];
    [myTimeSegmentsArray removeAllObjects];
    
    //get timestamp value at start of arrayTimeSegmentsArray
    
    //    [self resetUXTimer];
}
- (void)resetUXTimer {
    [uxTimer invalidate];
}

#pragma mark - Physician/Provider Detail Module Methods

- (void)initializePhysicianDetailView {
    NSLog(@"WRViewController.initializePhysicianDetailView()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    physicianDetailVC = [[PhysicianDetailViewController alloc] initWithNibName:nil bundle:nil];
    physicianDetailVC.view.alpha = 0.0;
//    physicianDetailVC.view.frame = CGRectMake(0, 0, 1024, 233);
    physicianDetailVC.view.backgroundColor = [UIColor clearColor];
    [physicianDetailVC.view setCenter:CGPointMake(384.0f, 500.0f)];
//    [physicianDetailVC.view setCenter:CGPointMake(500.0f, 384.0f)];
//    physicianDetailVC.view.transform = rotateRight;
    
    [self.view addSubview:physicianDetailVC.view];
    [self.view sendSubviewToBack:physicianDetailVC.view];
    
    [self setUpPhysicianViewContents];
    //[self setUpPhysicianViewContentsFromPropertyList];
    
    NSLog(@"WRViewController.initializePhysicianDetailView() exit");
}

- (void)setUpPhysicianViewContents {
    NSLog(@"WRViewController.setUpPhysicianViewContents()");
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    int index = attendingPhysicianIndex;
    ClinicianInfo *clinician = [DynamicContent getClinician:index];//[self getCurrentClinician];
    if (clinician){
        physicianModule.currentPhysicianDetails = [clinician writeToDictionary];
        [DynamicContent setCurrentClinician:clinician];
    }
    
    physicianModule.currentPhysicianDetailSectionNames = [[physicianModule.currentPhysicianDetails allKeys] sortedArrayUsingSelector:@selector(compare:)];
    physicianModule.view.alpha = 0.0;
//    physicianModule.view.transform = rotateRight;
    [self.view addSubview:physicianModule.view];
    [self.view sendSubviewToBack:physicianModule.view];
    
}

//- (void)setUpPhysicianViewContentsFromPropertyList {
//    NSLog(@"WRViewController.setUpPhysicianViewContentsFromPropertyList()");
//    
//    float angle =  270 * M_PI  / 180;
//    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    
//    NSMutableArray* allPhysicianBioPlists = [self getAllClinicPhysiciansBioPlists];
//    
//    //    if (attendingPhysicianIndex < [allClinicPhysiciansBioPLists count]){ // rjl 8/16/14
//    //    NSString *currentPhysicianPListName = [allClinicPhysiciansBioPLists objectAtIndex:attendingPhysicianIndex];
//    NSString *currentPhysicianPListName = [allPhysicianBioPlists objectAtIndex:attendingPhysicianIndex];
//    
//    NSData *tmp = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:currentPhysicianPListName withExtension:@"plist"] options:NSDataReadingMappedIfSafe error:nil];
//    int originalPhysicianCount = [allClinicPhysiciansBioPLists count];
//    if (attendingPhysicianIndex < originalPhysicianCount){ // rjl 8/16/14
//        physicianModule.currentPhysicianDetails = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
//    } else {
//        int index = attendingPhysicianIndex-originalPhysicianCount;
//        ClinicianInfo *clinician = [DynamicContent getClinician:index];//[self getCurrentClinician];
//        if (clinician)
//            physicianModule.currentPhysicianDetails = [clinician writeToDictionary];
//    }
//    physicianModule.currentPhysicianDetailSectionNames = [[physicianModule.currentPhysicianDetails allKeys] sortedArrayUsingSelector:@selector(compare:)];
//    //    }
//    physicianModule.view.alpha = 0.0;
//    physicianModule.view.transform = rotateRight;
//    [self.view addSubview:physicianModule.view];
//    [self.view sendSubviewToBack:physicianModule.view];
//    
//}


- (void)combineAllSoundfileDicts {
    
    NSLog(@"WRViewController.combineAllSoundfileDicts() Combining all soundfile dicts...");
    
    NSString *allTTSSoundFilesKey = @"allTTSSoundFilesDict";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dynamicEdSoundFileDict;
    NSString *nextDictKeyToLoad = @"currentDynamicSoundFileDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        dynamicEdSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    // Look for various subclinic module keys
    NSMutableArray *subClinicNames = [[NSMutableArray alloc] initWithObjects:@"Acupuncture", @"Pain", @"PNS", @"EMG", nil];
//    NSString *thisSpecFilenameAndKey;
    
    int subClinicsToLoad = [subClinicNames count];
    int subClinicsLoaded = 0;
    
    NSMutableDictionary *dynamicSubclinicEdSoundFileDict;
//    nextDictKeyToLoad = @"currentDynamicSubclinicSoundFileDict";

    for (NSString *oneSubclinicName in subClinicNames) {
        if ([oneSubclinicName isEqualToString:@"None"]) {
            nextDictKeyToLoad = @"Default";
        } else if ([oneSubclinicName isEqualToString:@"Acupuncture"]) {
            nextDictKeyToLoad = @"pmnr_acu_ed_module_test2";
        } else if ([oneSubclinicName isEqualToString:@"Pain"]) {
            nextDictKeyToLoad = @"pmnr_pain_ed_module_test2";
        } else if ([oneSubclinicName isEqualToString:@"PNS"]) {
            nextDictKeyToLoad = @"pmnr_pns_ed_module_test2";
        } else if ([oneSubclinicName isEqualToString:@"EMG"]) {
            nextDictKeyToLoad = @"pmnr_emg_ed_module_test2";
        } else {
            nextDictKeyToLoad = @"Default";
        }
        
        // Attempt to load this subclinic specfile's sounds
        if ([defaults objectForKey:nextDictKeyToLoad]) {
            dynamicSubclinicEdSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
            NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
            
            [allTTSItemsDict addEntriesFromDictionary:dynamicSubclinicEdSoundFileDict];
            subClinicsLoaded++;
        } else {
            NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
        }
    }
    
    NSLog(@"====== LOADED %d of %d SUBCLINIC SOUNDFILE DICTS ===========", subClinicsLoaded,subClinicsToLoad);
    
    NSMutableDictionary *physicianSoundFileDict;
    nextDictKeyToLoad = @"currentPhysicianSoundFileDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        physicianSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    NSMutableDictionary *allBaseSoundFileDict;
    nextDictKeyToLoad = @"baseSoundFileDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        allBaseSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    NSMutableDictionary *surveySoundFileDict;
    nextDictKeyToLoad = @"surveySoundFileDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        surveySoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    NSMutableDictionary *whatsNewSoundFileDict;
    nextDictKeyToLoad = currentDynamicWhatsNewModuleSpecFilename;
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        whatsNewSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    NSMutableDictionary *currentBrainSoundFileDict;
    nextDictKeyToLoad = @"brainSoundFileDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        currentBrainSoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }

    NSMutableDictionary *currentDynamicSurveySoundFileDict;
    nextDictKeyToLoad = @"dynamicSurveyTTSItemsDict";
    if ([defaults objectForKey:nextDictKeyToLoad]) {
        currentDynamicSurveySoundFileDict = [defaults objectForKey:nextDictKeyToLoad];
        NSLog(@"Retrieved soundfile dict for key: %@",nextDictKeyToLoad);
    } else {
        NSLog(@"Unable to retrieve soundfile dict for key: %@",nextDictKeyToLoad);
    }
    
    [allTTSItemsDict addEntriesFromDictionary:dynamicEdSoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:physicianSoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:allBaseSoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:surveySoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:whatsNewSoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:currentBrainSoundFileDict];
    [allTTSItemsDict addEntriesFromDictionary:currentDynamicSurveySoundFileDict];
    
    [defaults setObject:allTTSItemsDict forKey:allTTSSoundFilesKey];
     
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSoundfilesToUpdate {
        
    [self loadAllWRModuleSoundfiles];
    [self combineAllSoundfileDicts];
    
    // Any soundfilenames in soundFilenamesToUpdate will be added or updated using their associated text info in their respective dictionaries
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *soundFilenamesToUpdate = [[NSMutableArray alloc] initWithObjects:nil];
    
//    // 1. Update survey items
//    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[surveyTTSItemsDict allKeys]]];
//    
//    // 2. Update physician items
    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[physiciansTTSItemsDict allKeys]]];
    
//    // 3. Update what's new items
//    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[[defaults objectForKey:currentDynamicWhatsNewModuleSpecFilename] allKeys]]];
//
//    // 4. Update new survey agree_disagree
//    [soundFilenamesToUpdate addObject:@"~thank_you_please_return_ipad-survey_completed"];
//    [soundFilenamesToUpdate addObject:@"~participation_is_voluntary_new"];
//    [soundFilenamesToUpdate addObject:@"~thank_you_please_return_ipad-survey_declined"];//
    
    // 5. Update base items
//    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[baseTTSItemsDict allKeys]]];
    
    // 6. Update dynamic survey items
//    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[dynamicSurveyTTSItemsDict allKeys]]];
    
    // 7. Update TBI and Brain Ed Module items
//    [soundFilenamesToUpdate addObjectsFromArray:[NSArray arrayWithArray:[brainTTSItemsDict allKeys]]];
    
    ////////// UPADTE INDIVIDUAL SUBCLINICS START ///////////
    BOOL updateSelectedSubclinicSoundfiles = YES;
    if (updateSelectedSubclinicSoundfiles) {
        NSMutableArray *subClinicNames = [[NSMutableArray alloc] initWithObjects:@"Acupuncture", @"Pain", @"PNS", @"EMG", nil];
        //    NSString *thisSpecFilenameAndKey;
        
        NSMutableDictionary *dynamicSubclinicEdSoundFileDict;
        //    nextDictKeyToLoad = @"currentDynamicSubclinicSoundFileDict";
        
        BOOL shouldUpdateADynamicSubClinic = NO;
        
        //    currentSpecialtyClinicName
        //    currentDynamicSubClinicEdModuleSpecFilename
        
        for (NSString *oneSubclinicName in subClinicNames) {
            if ([oneSubclinicName isEqualToString:currentSpecialtyClinicName]) {
                shouldUpdateADynamicSubClinic = YES;
            }
        }
        if (shouldUpdateADynamicSubClinic) {
            // Attempt to update this subclinic specfile's sounds
            if ([defaults objectForKey:currentDynamicSubClinicEdModuleSpecFilename]) {
                dynamicSubclinicEdSoundFileDict = [defaults objectForKey:currentDynamicSubClinicEdModuleSpecFilename];
                NSLog(@"Updating soundfile dict for key: %@",currentDynamicSubClinicEdModuleSpecFilename);
                
                soundFilenamesToUpdate = [NSMutableArray arrayWithArray:[dynamicSubclinicEdSoundFileDict allKeys]];
            } else {
                NSLog(@"Unable to update soundfile dict for key: %@",currentDynamicSubClinicEdModuleSpecFilename);
            }
        }
    }
    ////////// UPADTE INDIVIDUAL SUBCLINICS END ///////////
    
//    NSMutableDictionary *dynamicSubclinicEdSoundFileDict = [defaults objectForKey:@"currentDynamicSubclinicSoundFileDict"];
//    soundFilenamesToUpdate = [NSMutableArray arrayWithArray:[dynamicSubclinicEdSoundFileDict allKeys]];
    
//    NSMutableArray *surveyGroupsQuestions = [[NSMutableArray alloc] initWithObjects:tbvc.patientSatisfactionLabelItems, tbvc.familyPromptLabelItems, tbvc.caregiverPromptLabelItems, nil];
//    NSMutableArray *surveyGroupsNames = [[NSMutableArray alloc] initWithObjects:@"patient", @"family", @"caregiver", nil];
//    
//    int groupIndex = 0;
//    
//    for (NSArray *thisRespondentGroupQuestions in surveyGroupsQuestions) {
//        NSString *currentRespondentGroupName = [surveyGroupsNames objectAtIndex:groupIndex];
//        
//        int questionIndex = 0;
//        for (NSString *thisQuestion in thisRespondentGroupQuestions) {
////            int characterLimitForQuestion = 199;
////            int thisQuestionCharacters = [thisQuestion length];
////            NSString *longTextCharacterPrefix = @"~";
//            NSString *currentQuestionKey;
////
////            if (thisQuestionCharacters > characterLimitForQuestion) {
////                currentQuestionKey = [NSString stringWithFormat:@"%@%@_q_%d",longTextCharacterPrefix,currentRespondentGroupName,questionIndex];
////            } else {
//                currentQuestionKey = [NSString stringWithFormat:@"%@_q_%d",currentRespondentGroupName,questionIndex];
////            }
//            
//            [soundFilenamesToUpdate addObject:currentQuestionKey];
//            questionIndex++;
//        }
//        
//        groupIndex++;
//    }
    
    NSString *updateTTSSoundFilesKey = @"updateTTSSoundFilesKey";
    
    
    [defaults setObject:soundFilenamesToUpdate forKey:updateTTSSoundFilesKey];
    
    NSLog(@"Loading %d soundfilenames for defaults key: %@...",[soundFilenamesToUpdate count],updateTTSSoundFilesKey);
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSatisfactionSurveySoundfiles {
    
    [surveyTTSItemsDict setObject:@"Please tell us about the services you received in this clinic by marking the following scale" forKey:@"Patient_please_tell_about_clinic_by_marking_new"];
    [surveyTTSItemsDict setObject:@"Please tell us about the services your loved one received in this clinic, by marking the following scale" forKey:@"Family_please_tell_about_clinic_by_marking_new"];
    [surveyTTSItemsDict setObject:@"Please tell us about your impression of the services offered in this clinic by marking the following scale" forKey:@"CaregiverNew_please_tell_about_clinic_by_marking_new"];
    
    [surveyTTSItemsDict setObject:@"As a result of my coming to the clinic and therapies" forKey:@"as_a_result_of_my_coming_prompt_new"];
    [surveyTTSItemsDict setObject:@"As a result of my loved one coming to the clinic and therapies," forKey:@"FamilyNew_since_i_began_coming_new"];
    [surveyTTSItemsDict setObject:@"As a result of coming to the clinic and therapies," forKey:@"CaregiverNew_as_a_result_new"];
    
    [surveyTTSItemsDict setObject:@"Patient satisfaction survey" forKey:@"Patient_satisfaction_survey_new"];
    [surveyTTSItemsDict setObject:@"Family satisfaction survey" forKey:@"Family_satisfaction_survey_new"];
    [surveyTTSItemsDict setObject:@"Caregiver satisfaction survey" forKey:@"caregiver_satisfaction_survey_new"];
    
    [surveyTTSItemsDict setObject:@"Your participation in this survey is anonymous. Your responses will not be given to your treatment provider or any other clinic staff. Your responses will not influence the services you receive at this clinic. By participating, you can help us provide a better rehabilitation experience." forKey:@"~participation_is_voluntary_new"];
    
    [surveyTTSItemsDict setObject:@"Your participation in this survey is anonymous. Your responses will not be given to your treatment provider or any other clinic staff. Your responses will not influence the services you receive at this clinic." forKey:@"~privacy_policy"];
    
    [surveyTTSItemsDict setObject:@"We greatly appreciate your feedback since it helps us improve our delivery of high quality healthcare services.  Please tap, agree, if you would like to complete the survey, or disagree, if you would like to return to the main menu." forKey:@"~tap_agree_or_disagree_new"];
    
    [surveyTTSItemsDict setObject:@"Thank you for participating! You will be presented with a series of statements about your rehabilitation experience." forKey:@"thank_you_will_be_presented-short_new"];
    
    [surveyTTSItemsDict setObject:@"Let’s move on to the first item." forKey:@"lets_move_to_first-short_new"];
    
    [surveyTTSItemsDict setObject:@"Thank you for completing the satisfaction survey." forKey:@"thank_you_for_completing_the_new"];
    
    [surveyTTSItemsDict setObject:@"In five seconds, you will be returned to the main menu." forKey:@"in_five_seconds_returned_to_menu_new"];
    
    [surveyTTSItemsDict setObject:@"I agree." forKey:@"i_agree_new"];
    [surveyTTSItemsDict setObject:@"I disagree." forKey:@"i_disagree_new"];
    [surveyTTSItemsDict setObject:@"This item does not apply to me." forKey:@"does_not_apply_to_me_new"];
    [surveyTTSItemsDict setObject:@"I am neutral" forKey:@"i_am_neutral_new"];
    [surveyTTSItemsDict setObject:@"I strongly agree." forKey:@"i_strongly_agree_new"];
    [surveyTTSItemsDict setObject:@"I strongly disagree." forKey:@"i_strongly_disagree_new"];
    
    NSMutableArray *surveyGroupsQuestions = [[NSMutableArray alloc] initWithObjects:tbvc.patientSatisfactionLabelItems, tbvc.familySatisfactionLabelItems, tbvc.caregiverSatisfactionLabelItems, nil];
    NSMutableArray *surveyGroupsNames = [[NSMutableArray alloc] initWithObjects:@"patient", @"family", @"caregiver", nil];
    
    int groupIndex = 0;
    
    for (NSArray *thisRespondentGroupQuestions in surveyGroupsQuestions) {
        NSString *currentRespondentGroupName = [surveyGroupsNames objectAtIndex:groupIndex];
        
        int questionIndex = 0;
        for (NSString *thisQuestion in thisRespondentGroupQuestions) {
//            int characterLimitForQuestion = 199;
//            int thisQuestionCharacters = [thisQuestion length];
//            NSString *longTextCharacterPrefix = @"~";
            NSString *currentQuestionKey;
            
//            if (thisQuestionCharacters > characterLimitForQuestion) {
//                currentQuestionKey = [NSString stringWithFormat:@"%@%@_q_%d",longTextCharacterPrefix,currentRespondentGroupName,questionIndex];
//            } else {
                currentQuestionKey = [NSString stringWithFormat:@"%@_q_%d",currentRespondentGroupName,questionIndex];
//            }
            
            [surveyTTSItemsDict setObject:thisQuestion forKey:currentQuestionKey];
            questionIndex++;
        }
        
        groupIndex++;
    }
    
    
    // Store to defaults and add to combined dicts
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *surveySoundfilesKey = @"surveySoundFileDict";
    [defaults setObject:surveyTTSItemsDict forKey:surveySoundfilesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Loaded all survey soundfiles (stored to defaults key: %@)...",surveySoundfilesKey);
}

- (void)loadAllWRModuleSoundfiles {
    
    NSLog(@"Loading all soundfile dicts...");
    
   [self loadAllPhysicianSoundfilesFromPropertyLists];
    [self loadAllBaseSoundfiles];
    [self loadSatisfactionSurveySoundfiles];
    [self loadAllBrainSoundfiles];
    [self loadAllDynamicSurveySoundfiles];
}

- (void)loadAllDynamicSurveySoundfiles {
    
    NSLog(@"loadAllDynamicSurveySoundfiles...");
                                  
    [dynamicSurveyTTSItemsDict setObject:@"Thank you for returning to the" forKey:@"wantExtraInfo1_followup"];
    // sandy 7-20 replaced doctor with treatment provider
    [dynamicSurveyTTSItemsDict setObject:@"Would you like additional information about your treatment provider and about today's visit?" forKey:@"wantExtraInfo2_followup"];
    [dynamicSurveyTTSItemsDict setObject:@"Yes, I would like additional information." forKey:@"wantExtraInfo3_followup"];
    [dynamicSurveyTTSItemsDict setObject:@"No, I do not need additional information." forKey:@"wantExtraInfo4_followup"];
    
    [dynamicSurveyTTSItemsDict setObject:@"Thank you for sharing your thoughts about today's visit.  Press the NEXT button on the bottom row to continue." forKey:@"dynamicSurveyPage6_followup"];
    
    NSString *fullPromptWithGoal = [NSString stringWithFormat:@"Right before your visit, you shared this goal."];
    NSString *goalSelected = @"Please indicate how much you agree or disagree that today's visit met your expectations regarding this goal.";
    NSString *noneSelected = @"Please indicate how much you agree or disagree that today's visit met your expectations in general.";
    NSString *fullPromptWithGoalSelected = [NSString stringWithFormat:@"%@ %@",fullPromptWithGoal,goalSelected];
    NSString *fullPromptWithNoneSelected = [NSString stringWithFormat:@"%@ %@",fullPromptWithGoal,noneSelected];
    
    [dynamicSurveyTTSItemsDict setObject:fullPromptWithGoalSelected forKey:@"~feedback_goal_selected"];
    [dynamicSurveyTTSItemsDict setObject:fullPromptWithNoneSelected forKey:@"~feedback_none_selected"];
        
    NSMutableArray *surveyPageArray = [dynamicSurveyModule createArrayOfAllSurveyPages];
    
    int dynamicSurveyPageIndex = 0;
    NSString *thisDynamicSurveyPageSoundfilename;
    NSString *thisDynamicSurveyPageText;
    
    int currentNumCharactersInString;
    int substringCharacterLimit = 180;
    NSString *longFilenamePrefix = @"~";
    
    BOOL skipNormalDictAdd = NO;
    
    for (SwitchedImageViewController *thisSurveyPage in surveyPageArray) {
        skipNormalDictAdd = NO;
        
        thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"dynamicSurveyPage%d", dynamicSurveyPageIndex];
        switch (thisSurveyPage.currentSurveyPageType) {
            case kOk:
                thisDynamicSurveyPageText = thisSurveyPage.currentPromptString;
                break;
            case kAgreementPainScale:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@ %@",thisSurveyPage.currentPromptString,thisSurveyPage.currentSatisfactionString];
                break;
            case kAgreeDisagree:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@ %@",thisSurveyPage.currentPromptString,thisSurveyPage.newAgreeDisagreeText];
                break;
            case kYesNo:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@ %@ %@",thisSurveyPage.newYesNoText,thisSurveyPage.extraYesText,thisSurveyPage.extraNoText];
                break;
            case kProviderTest:
            case kEdModulePicker:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@",thisSurveyPage.providerTestText];
                break;
            case kSubclinicTest:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@",thisSurveyPage.subclinicTestText];
                break;
            case kHelpfulPainScale:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@",thisSurveyPage.helpfulText];
                break;
            case kChooseGoal:
                skipNormalDictAdd = YES;
                NSString *origSoundfilename = thisDynamicSurveyPageSoundfilename;
                // PATIENT
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@. %@. %@. %@. %@. %@. %@. %@. %@. %@. %@.",thisSurveyPage.goalChooseText,thisSurveyPage.goal1Text,thisSurveyPage.goal2Text,thisSurveyPage.goal3Text,thisSurveyPage.goal4Text,thisSurveyPage.goal5Text,thisSurveyPage.goal6Text,thisSurveyPage.goal7Text,thisSurveyPage.goal8Text,thisSurveyPage.goal9Text,thisSurveyPage.goal10Text];
                
                currentNumCharactersInString = [thisDynamicSurveyPageText length];
                if (currentNumCharactersInString > substringCharacterLimit) {
                    thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@%@",longFilenamePrefix,origSoundfilename];
                }
                thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@_%@",thisDynamicSurveyPageSoundfilename,@"patient"];
                
                NSLog(@"\nAdding dynamic survey sound %d: %@ with text:\n%@",dynamicSurveyPageIndex,thisDynamicSurveyPageSoundfilename,thisDynamicSurveyPageText);
                [dynamicSurveyTTSItemsDict setObject:thisDynamicSurveyPageText forKey:thisDynamicSurveyPageSoundfilename];
                
                // CAREGIVER
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@. %@. %@. %@. %@. %@. %@. %@. %@. %@. %@.",thisSurveyPage.goalChooseText,@"Reduce my patient's pain",@"Help my patient sleep better",@"Help my patient be more active",@"Talk to my patient's treatment provider",@"Help my patient have more energy",@"Get my patient's tests done",@"Help my patient feel healthy",@"Get my patient's next treatment",@"Help my patient return to work",thisSurveyPage.goal10Text];
                
                currentNumCharactersInString = [thisDynamicSurveyPageText length];
                if (currentNumCharactersInString > substringCharacterLimit) {
                    thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@%@",longFilenamePrefix,origSoundfilename];
                }
                thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@_%@",thisDynamicSurveyPageSoundfilename,@"caregiver"];
                
                NSLog(@"\nAdding dynamic survey sound %d: %@ with text:\n%@",dynamicSurveyPageIndex,thisDynamicSurveyPageSoundfilename,thisDynamicSurveyPageText);
                [dynamicSurveyTTSItemsDict setObject:thisDynamicSurveyPageText forKey:thisDynamicSurveyPageSoundfilename];

                    // FAMILY
                thisDynamicSurveyPageSoundfilename = @"";
                    thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@. %@. %@. %@. %@. %@. %@. %@. %@. %@. %@.",thisSurveyPage.goalChooseText,@"Reduce my family member's pain",@"Help my family member sleep better",@"Help my family member be more active",@"Talk to my family member's treatment provider",@"Help my family member have more energy",@"Get my family member's tests done",@"Help my family member feel healthy",@"Get my family member's next treatment",@"Help my family member return to work",thisSurveyPage.goal10Text];
                    
                    currentNumCharactersInString = [thisDynamicSurveyPageText length];
                    if (currentNumCharactersInString > substringCharacterLimit) {
                        thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@%@",longFilenamePrefix,origSoundfilename];
                    }
                    thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@_%@",thisDynamicSurveyPageSoundfilename,@"family"];
                    
                    NSLog(@"\nAdding dynamic survey sound %d: %@ with text:\n%@",dynamicSurveyPageIndex,thisDynamicSurveyPageSoundfilename,thisDynamicSurveyPageText);
                    [dynamicSurveyTTSItemsDict setObject:thisDynamicSurveyPageText forKey:thisDynamicSurveyPageSoundfilename];
                
                break;
            case kRateGoalPainScale:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@ %@",thisSurveyPage.currentPromptString,thisSurveyPage.goalRateText];
                break;
            case kGeneralSurveyPage:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@",thisSurveyPage.currentPromptString];
                break;
            case kChooseModule:
                thisDynamicSurveyPageText = [NSString stringWithFormat:@"%@. %@. %@.",thisSurveyPage.chooseModuleText,thisSurveyPage.extraModule1Text,thisSurveyPage.extraModule2Text];
            default:
                break;
        }
        
        if (!skipNormalDictAdd) {
            currentNumCharactersInString = [thisDynamicSurveyPageText length];
            if (currentNumCharactersInString > substringCharacterLimit) {
                thisDynamicSurveyPageSoundfilename = [NSString stringWithFormat:@"%@%@",longFilenamePrefix,thisDynamicSurveyPageSoundfilename];
            }
            
            NSLog(@"\nAdding dynamic survey sound %d: %@ with text:\n%@",dynamicSurveyPageIndex,thisDynamicSurveyPageSoundfilename,thisDynamicSurveyPageText);
            [dynamicSurveyTTSItemsDict setObject:thisDynamicSurveyPageText forKey:thisDynamicSurveyPageSoundfilename];
        }
        
        dynamicSurveyPageIndex++;
    }
    
    NSLog(@"Finished adding %d sounds to dynamicSurveyTTSItemsDict...",dynamicSurveyPageIndex);
    
    // Store to defaults and add to combined dicts
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dynamicSurveySoundfilesKey = @"dynamicSurveyTTSItemsDict";
    [defaults setObject:dynamicSurveyTTSItemsDict forKey:dynamicSurveySoundfilesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Loaded all survey soundfiles (stored to defaults key: %@)...",dynamicSurveySoundfilesKey);
    
}

- (void)loadAllBaseSoundfiles {
    NSLog(@"WRViewController.loadAllBaseSoundfiles()");

    [baseTTSItemsDict setObject:@"Please ask your treatment provider or the receptionist to unlock this Waiting Room Guide so you can continue." forKey:@"keycode_incorrect_alert"];
    
    [baseTTSItemsDict setObject:@"You will be seen by your treatment provider in a few moments.  Please hold on to this iPad and take it with you into your treatment session." forKey:@"treatment_intermission"];
    
    [baseTTSItemsDict setObject:@"V A Palo Alto Healthcare System" forKey:@"vapahcs_new"];
    [baseTTSItemsDict setObject:@"Welcome to the V A Palo Alto Healthcare System" forKey:@"welcome_to_the_new"];
    [baseTTSItemsDict setObject:@"Welcome back to the V A Palo Alto Healthcare System" forKey:@"welcome_back_to_the_new"];
    
    NSString *currentMainClinicFilename = @"main_clinic";
    NSString *currentSubClinicFilename = @"sub_clinic";
    NSString *currentSpecialtyClinicFilename = @"specialty_clinic";
    NSString *currentMainClinicText;
    NSString *currentSubClinicText;
    
//    switch (currentMainClinic) {
//        case kGeneralClinic:
//            currentMainClinicText = @"Physical Medicine and Rehabilitation";
//            break;
//        case kPMNRClinic:
//            currentMainClinicText = @"Physical Medicine and Rehabilitation";
//            break;
//        case kPNSClinic:
//            currentMainClinicText = @"Polytrauma Network Site";
//            break;
//        case kNoMainClinic:
//            currentMainClinicText = @"";
//            break;
//        default:
//            currentMainClinicText = @"";
//            break;
//    }
    [baseTTSItemsDict setObject:@"Physical Medicine and Rehabilitation" forKey:@"pmnr_main_clinic"];
    [baseTTSItemsDict setObject:@"Polytrauma Network Site" forKey:@"pns_main_clinic"];
    //sandy tried uncommenting this
    [baseTTSItemsDict setObject:@"Assistive Technology Center" forKey:@"at_main_clinic"];
    
    [baseTTSItemsDict setObject:@"acupuncture" forKey:@"sub_clinic_acupuncture"];
    [baseTTSItemsDict setObject:@"PNS" forKey:@"sub_clinic_pns"];
    [baseTTSItemsDict setObject:@"EMG" forKey:@"sub_clinic_emg"];
    [baseTTSItemsDict setObject:@"clinic" forKey:@"sub_clinic_all"];
    
    [baseTTSItemsDict setObject:@"EMG clinic" forKey:@"specialty_clinic_emg"];
    [baseTTSItemsDict setObject:@"acupuncture clinic" forKey:@"specialty_clinic_acupuncture"];
    [baseTTSItemsDict setObject:@"chronic pain clinic" forKey:@"specialty_clinic_pain"];
    [baseTTSItemsDict setObject:@"PNS clinic" forKey:@"specialty_clinic_pns"];
    
    [baseTTSItemsDict setObject:@"....,..........,..........,.......Would you like me to read the questions out loud?" forKey:@"would_you_like_me_to_read_new"];
    
    [baseTTSItemsDict setObject:@"Are you a patient, family member, or caregiver?" forKey:@"are_you_a_pt_fam_care"];
    
    [baseTTSItemsDict setObject:@"okay" forKey:@"okay_new"];
    
    [baseTTSItemsDict setObject:@"Please choose a waiting room activity" forKey:@"please_choose_a_wr_activity_new"];
    
//    [baseTTSItemsDict setObject:@",,,,,,,,,,,,,,,,,,,,,," forKey:@"silence"];
    
    [baseTTSItemsDict setObject:@"While you are waiting, would you like to learn about TBI and the brain?" forKey:@"would_you_like_to_learn_about_tbi"];
    [baseTTSItemsDict setObject:@"While you are waiting, would you like to learn about What's New at the Polytrauma System of Care?" forKey:@"would_you_like_to_learn_about_whats_new"];
    [baseTTSItemsDict setObject:@"Thank you for your feedback. Please return this iPad tablet to the receptionist." forKey:@"~thank_you_please_return_ipad-survey_completed"];
    [baseTTSItemsDict setObject:@"Thank you for taking the time to learn more about your visit today.  Please return your iPad tablet to the receptionist." forKey:@"~thank_you_please_return_ipad-survey_declined"];
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *baseSoundfilesKey = @"baseSoundFileDict";
    [defaults setObject:baseTTSItemsDict forKey:baseSoundfilesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Loaded all base soundfiles for clinic: %@ (stored to defaults key: %@)...",currentClinicName,baseSoundfilesKey);

}

- (void)loadAllBrainSoundfiles {
    [brainTTSItemsDict setObject:@"Learn about TBI and the Brain.  In the next few sections, you will be presented with information and media related to TBI and the Brain.  You can go at your own pace, and move ahead when you want to.  Press next to continue." forKey:@"~tbi_brain_intro"];
    
    [brainTTSItemsDict setObject:@"What is a TBI?  Traumatic Brain Injury.  A traumatic brain injury (TBI) is a direct blow or jolt to the head, penetrating head injury, or exposure to external forces such as blast waves that disrupts the function of the brain. Not all blows to the head or exposure to external forces  results in a TBI.  The severity of TBI may range from mild, a brief change in mental status or consciousness, to severe, an extended period of unconsciousness or confusion after the injury." forKey:@"~tbi_brain_1"];

    [brainTTSItemsDict setObject:@"Key points.  1. The brain is the body's control center.  2. The parts of the brain work together to help us think, feel, move, and talk.  3. A TBI is caused by a penetrating injury or by blunt force trauma to the head." forKey:@"~tbi_brain_2"];
    
    [brainTTSItemsDict setObject:@"What is a Traumatic Brain Injury?  A traumatic brain injury happens when something outside the body hits the head with a lot of force.  This could happen when a head hits a windshield during a car accident. It could happen when a piece of shrapnel enters the brain.  Or it could happen during an explosion of an I E D (improvised explosive device). There are many causes of traumatic brain injury (TBI)." forKey:@"~tbi_brain_3"];
    
    [brainTTSItemsDict setObject:@"How Common is TBI?  TBI is the leading injury among U S forces serving in Afghanistan (Operation Enduring Freedom (OEF) and Iraq (Operation Iraqi Freedom) (OIF).  The frequent use of eye E dees in these wars increases the chance that service members will be exposed to blasts and other injuries that can cause a TBI." forKey:@"~tbi_brain_4"];

    [brainTTSItemsDict setObject:@"How are T B eyes rated? Traumatic brain injuries range from mild to severe.  Injuries are rated on the basis of their severity at the time of the intjury." forKey:@"~tbi_brain_5"];
    
    [brainTTSItemsDict setObject:@"A TBI is rated as mild when the service member or veteran, has brief or no loss of consciousness, is momentarily dazed or has confusion lasting an hour or less, and, has an initial Glasgow Coma Scale (GCS) of 13 to 15." forKey:@"~tbi_brain_6"];

    [brainTTSItemsDict setObject:@"Common signs and symptoms.  Physical, headache, sleep disturbances, dizziness, balance problems, nausea/vomiting, fatigue, visual disturbances, light sensitivity, ringing in ears." forKey:@"~tbi_brain_7"];
    
    [brainTTSItemsDict setObject:@"Moderate to severe TBI.  A TBI is rated as moderate to severe when the service member or veteran: has loss of consciousness for more than 30 minutes, confusion lasting for hours, days, or weeks, a Glasgow Coma Scale score ranging from 3 to 12." forKey:@"~tbi_brain_8"];
    
    [brainTTSItemsDict setObject:@"More information on moderate or severe TBI." forKey:@"tbi_brain_9"];
    
    [brainTTSItemsDict setObject:@"What are the parts of the brain? How do they work? The brain is the body's control center. The brain has billions of nerve cells. The cells are arranged in sections that work together to control all of our movements, breathing, thoughts, behaviors, and emotions." forKey:@"~tbi_brain_10b"];
    
    [brainTTSItemsDict setObject:@"Use your finger to turn the three D model of the brain, to see how the different lobes of the brain are arranged in space. Press next when you are ready to continue." forKey:@"~tbi_brain_11b"];
    
    [brainTTSItemsDict setObject:@"You have completed the sections on TBI and the Brain. In five seconds, you will be returned to the main menu." forKey:@"tbi_brain_end"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *brainSoundfilesKey = @"brainSoundFileDict";
    [defaults setObject:brainTTSItemsDict forKey:brainSoundfilesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Loaded all base soundfiles for clinic: %@ (stored to defaults key: %@)...",currentClinicName,brainSoundfilesKey);
    
}

- (void)loadAllPhysicianSoundfilesFromPropertyLists {
    NSLog(@"WRViewController.loadAllPhysicianSoundfilesFromPropertyLists()");

    int thisPhysicianIndex = 0;
    int numPhysicianSoundfilesLoaded = 0;
    
    for (NSString *thisPhysicianPListName in allClinicPhysiciansBioPLists) {
        NSData *tmp = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:thisPhysicianPListName withExtension:@"plist"] options:NSDataReadingMappedIfSafe error:nil];
        NSDictionary *currentDict = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
        NSArray *currentSectionNames = [[currentDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSString *thisHeaderName in currentSectionNames) {
//            NSString *currentHeaderText = currentSectionNames[thisPhysicianIndex];
            
            NSString *currentSubDetailText = currentDict[thisHeaderName];
            
            NSString *currentSoundFilePrefix = [allClinicPhysiciansSoundFiles objectAtIndex:thisPhysicianIndex];
            NSString *currentSoundFileSuffix = [thisHeaderName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            
            NSString *longSectionPrefix = @"~";
            NSString *fullHeaderFilename;
            NSString *fullSubdetailFilename;
            if ([thisHeaderName hasPrefix:longSectionPrefix]) {
                NSString *newSoundFileSuffix = [thisHeaderName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                newSoundFileSuffix = [newSoundFileSuffix substringFromIndex:[longSectionPrefix length]];
                fullHeaderFilename = [NSString stringWithFormat:@"%@_%@_%@",currentSoundFilePrefix,newSoundFileSuffix,@"header"];
                fullSubdetailFilename = [NSString stringWithFormat:@"%@%@_%@",longSectionPrefix,currentSoundFilePrefix,newSoundFileSuffix];
            } else {
                fullHeaderFilename = [NSString stringWithFormat:@"%@_%@_%@",currentSoundFilePrefix,currentSoundFileSuffix,@"header"];
                fullSubdetailFilename = [NSString stringWithFormat:@"%@_%@",currentSoundFilePrefix,currentSoundFileSuffix];
            }
            
            NSLog(@"Setting physician header soundfile %@ to text %@",fullHeaderFilename,thisHeaderName);
            NSLog(@"Setting physician soundfile %@ to text %@",fullSubdetailFilename,currentSubDetailText);
            
            [physiciansTTSItemsDict setObject:thisHeaderName forKey:fullHeaderFilename];
            [physiciansTTSItemsDict setObject:currentSubDetailText forKey:fullSubdetailFilename];
           
            numPhysicianSoundfilesLoaded = numPhysicianSoundfilesLoaded + 2;
            
        }
        
        thisPhysicianIndex++;
    }
    
    [self addPhysicianNamesAndIntro];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *physicianSoundfilesKey = @"currentPhysicianSoundFileDict";
    [defaults setObject:physiciansTTSItemsDict forKey:physicianSoundfilesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Loaded %d physician soundfiles for clinic: %@ (stored to defaults key: %@)...",numPhysicianSoundfilesLoaded,currentClinicName,physicianSoundfilesKey);
    
}

- (void)addPhysicianNamesAndIntro {
    NSLog(@"WRViewController.addPhysicianNamesAndIntro()");

    int physicianIndexNum = 0;
    NSMutableArray* allPhysicians = [DynamicContent getNewClinicianNames];
    for (NSString *thisFullPhysicianName in allPhysicians) {
        NSMutableArray *physicianNameTokens = [[NSMutableArray alloc] initWithArray:[thisFullPhysicianName componentsSeparatedByString:@","] copyItems:YES];
        NSString *thisPhysicianNameAlone = [physicianNameTokens objectAtIndex:0];
        NSString *textForPhysicianName = [NSString stringWithFormat:@"Doctor %@",thisPhysicianNameAlone];
        NSString *thisPhysicianTextFilename = [NSString stringWithFormat:@"%@_name",[allClinicPhysiciansSoundFiles objectAtIndex:physicianIndexNum]];
        
        [physiciansTTSItemsDict setObject:textForPhysicianName forKey:thisPhysicianTextFilename];
        
        physicianIndexNum++;
    }
    
    [physiciansTTSItemsDict setObject:@"Today your care will be handled by" forKey:@"today_your_care_handled_by"];
}

- (void)showMasterButtonOverlayNoButtons {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlayNoButtons];
}

- (void)showMasterButtonOverlay {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
}

- (void)hideMasterButtonOverlay {
    if (!runningAppInDemoMode)
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu]; //rjl 7/2/14
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideCurrentButtonOverlay];
}

- (void)fadePhysicianModuleIn {
    
    NSLog(@"WRViewController.fadePhysicianModuleIn()");
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:physicianModule];
    [self showMasterButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
    
    physicianModuleInProgress = YES;
    
    physicianModule.view.alpha = 0.0;
        
//    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:physicianModule.view];
    
    [self.view bringSubviewToFront:physicianDetailVC.view];
    
//    [self.view bringSubviewToFront:nextPhysicianDetailButton];
//    [self.view bringSubviewToFront:previousPhysicianDetailButton];
    
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

        physicianDetailVC.view.alpha = 1.0;
        physicianModule.view.alpha = 1.0;
        
//        nextPhysicianDetailButton.alpha = 1.0;
//        previousPhysicianDetailButton.alpha = 1.0;
        
//        surveyResourceBack.alpha = 1.0;
        
//        voiceAssistButton.alpha = 1.0;
//        fontsizeButton.alpha = 1.0;

	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:physicianModule selector:@selector(sayPhysicianDetailIntro) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:2.5 target:physicianDetailVC selector:@selector(beginFadeOutOfCareHandledByLabel) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
//    [physicianModule sayPhysicianDetailIntro];
}

- (void)fadePhysicianDetailVCIn {
    NSLog(@"WRViewController.fadePhysicianDetailVCIn()");
    [self.view bringSubviewToFront:physicianDetailVC.view];
//    [self.view bringSubviewToFront:nextPhysicianDetailButton];
//    [self.view bringSubviewToFront:previousPhysicianDetailButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        physicianDetailVC.view.alpha = 1.0;
        
	}
	[UIView commitAnimations];
}

- (void)fadePhysicianDetailVCOut {
    NSLog(@"WRViewController.fadePhysicianDetailVCOut()");
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        physicianDetailVC.view.alpha = 0.0;
        
	}
	[UIView commitAnimations];
}



- (void)handleFirstPhysicianPageSoundAndLabelFade {
    NSLog(@"WRViewController.handleFirstPhysicianPageSoundAndLabelFade()");
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:physicianModule selector:@selector(sayPhysicianDetailIntro) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:2.5 target:physicianDetailVC selector:@selector(beginFadeOutOfCareHandledByLabel) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)handlePhysicianModuleCompleted {
    NSLog(@"WRViewController.handlePhysicianModuleCompleted()");

//    if (isFirstVisit) {
        [self launchDynamicSurveyWithProviderHelpful];
//    } else {
//        [self launchDynamicSubclinicEducationModule];
//    }
}

- (void)fadePhysicianDetailOut {
    NSLog(@"WRViewController.fadePhysicianDetailOut()");
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        physicianDetailVC.view.alpha = 0.0;
        physicianModule.view.alpha = 0.0;
        
        nextPhysicianDetailButton.alpha = 0.0;
        previousPhysicianDetailButton.alpha = 0.0;
        
//        surveyResourceBack.alpha = 1.0;
        //        voiceAssistButton.alpha = 1.0;
        //        fontsizeButton.alpha = 1.0;
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadePhysicianDetailOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishFadePhysicianDetailOut:(NSTimer*)theTimer {
    NSLog(@"WRViewController.finishFadePhysicianDetailOut()");

    [self.view sendSubviewToBack:physicianDetailVC.view];
    [self.view sendSubviewToBack:physicianModule.view];
    [self.view sendSubviewToBack:nextPhysicianDetailButton];
    [self.view sendSubviewToBack:previousPhysicianDetailButton];
    
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out physician Detail");
}

#pragma mark - Dynamic Clinic Education Module Methods

- (void)initializeWhatsNewModule {
    NSLog(@"WRViewController.initializeWhatsNewModule()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    //dynamicWhatsNewModule = [[DynamicModuleViewController_Pad alloc] init];
//    [dynamicWhatsNewModule setupWithPropertyList:currentDynamicWhatsNewModuleSpecFilename];
    [dynamicWhatsNewModule setupWhatsNewContent];
    
    dynamicWhatsNewModule.view.alpha = 0.0;
//    dynamicWhatsNewModule.view.transform = rotateRight;
    [self.view addSubview:dynamicWhatsNewModule.view];
    [self.view sendSubviewToBack:dynamicWhatsNewModule.view];
    
    NSLog(@"Dynamic WhatsNew Module Initialized with spec file: %@.plist",currentDynamicWhatsNewModuleSpecFilename);
    
    whatsNewInitialized = YES;
}

- (void) initializeEdModulesForCurrentClinic{
    NSArray* edModules = [DynamicContent getEdModulesForCurrentClinic];
    /*
       TODO: if (edModules contains TBI) module, then add that as last option.
     */
    
    if (edModules){
        int count = [edModules count];
        NSLog(@" found %d modules", count);
        if (count > 0)
            [self initializeEdModule1];
        if (count > 1)
            [self initializeEdModule2];
        if (count > 2)
            [self initializeEdModule3];
        if (count > 3)
            [self initializeEdModule4];
        if (count > 4)
            [self initializeEdModule5];
        if (count > 5)
            [self initializeEdModule6];
        if (count > 6)
            [self initializeEdModule7];
        if (count > 7)
            [self initializeEdModule8];
        if (count > 9)
            [self initializeEdModule10];
    }
}

- (void)initializeEdModule1 {
    NSLog(@"WRViewController.initializeEdModule1()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule1 setupEdModule:0];
    
    dynamicEdModule1.view.alpha = 0.0;
//    dynamicEdModule1.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule1.view];
    [self.view sendSubviewToBack:dynamicEdModule1.view];
    
    edModule1Initialized = YES;
}

- (void)initializeEdModule2 {
    NSLog(@"WRViewController.initializeEdModule2()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule2 setupEdModule:1];
    dynamicEdModule2.view.alpha = 0.0;
//    dynamicEdModule2.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule2.view];
    [self.view sendSubviewToBack:dynamicEdModule2.view];
    edModule2Initialized = YES;
}

- (void)initializeEdModule3 {
    NSLog(@"WRViewController.initializeEdModule3()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule3 setupEdModule:2];
    dynamicEdModule3.view.alpha = 0.0;
//    dynamicEdModule3.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule3.view];
    [self.view sendSubviewToBack:dynamicEdModule3.view];
    edModule3Initialized = YES;
}

- (void)initializeEdModule4 {
    NSLog(@"WRViewController.initializeEdModule4()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule4 setupEdModule:3];
    
    dynamicEdModule4.view.alpha = 0.0;
//    dynamicEdModule4.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule4.view];
    [self.view sendSubviewToBack:dynamicEdModule4.view];
    
    edModule4Initialized = YES;
}

- (void)initializeEdModule5 {
    NSLog(@"WRViewController.initializeEdModule5()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule5 setupEdModule:4];
    
    dynamicEdModule5.view.alpha = 0.0;
//    dynamicEdModule5.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule5.view];
    [self.view sendSubviewToBack:dynamicEdModule5.view];
    
    edModule5Initialized = YES;
}

- (void)initializeEdModule6 {
    NSLog(@"WRViewController.initializeEdModule6()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule6 setupEdModule:5];
    
    dynamicEdModule6.view.alpha = 0.0;
//    dynamicEdModule6.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule6.view];
    [self.view sendSubviewToBack:dynamicEdModule6.view];
    
    edModule6Initialized = YES;
}

- (void)initializeEdModule7 {
    NSLog(@"WRViewController.initializeEdModule7()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule7 setupEdModule:4];
    
    dynamicEdModule7.view.alpha = 0.0;
    dynamicEdModule7.view.transform = rotateRight;
//    [self.view addSubview:dynamicEdModule7.view];
    [self.view sendSubviewToBack:dynamicEdModule7.view];
    
    edModule7Initialized = YES;
}

- (void)initializeEdModule8 {
    NSLog(@"WRViewController.initializeEdModule8()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule8 setupEdModule:4];
    
    dynamicEdModule8.view.alpha = 0.0;
//    dynamicEdModule8.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule8.view];
    [self.view sendSubviewToBack:dynamicEdModule8.view];
    
    edModule8Initialized = YES;
}

- (void)initializeEdModule9 {
    NSLog(@"WRViewController.initializeEdModule5()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule9 setupEdModule:4];
    
    dynamicEdModule9.view.alpha = 0.0;
//    dynamicEdModule9.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule9.view];
    [self.view sendSubviewToBack:dynamicEdModule9.view];
    
    edModule9Initialized = YES;
}

- (void)initializeEdModule10 {
    NSLog(@"WRViewController.initializeEdModule10()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [dynamicEdModule10 setupEdModule:4];
    
    dynamicEdModule10.view.alpha = 0.0;
//    dynamicEdModule10.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule10.view];
    [self.view sendSubviewToBack:dynamicEdModule10.view];
    
    edModule10Initialized = YES;
}




- (void)setDynamicWhatsNewSoundFileDict {
    if (dynamicWhatsNewModule.ttsSoundFileDict) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dynamicWhatsNewModule.ttsSoundFileDict forKey:currentDynamicWhatsNewModuleSpecFilename];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"dynamicWhatsNewModule not found...unable to set key %@",currentDynamicWhatsNewModuleSpecFilename);
    }
}

- (void)initializeDynamicSubClinicEducationModule {
    NSLog(@"WRViewController.initializeDynamicSubClinicEducationModule()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);

    //[dynamicSubclinicEdModule setupWithPropertyList:currentDynamicSubClinicEdModuleSpecFilename];
    [dynamicSubclinicEdModule setupClinicContent];
    
    dynamicSubclinicEdModule.view.alpha = 0.0;
//    dynamicSubclinicEdModule.view.transform = rotateRight;
    [self.view addSubview:dynamicSubclinicEdModule.view];
    [self.view sendSubviewToBack:dynamicSubclinicEdModule.view];
    
    
    
//    NSLog(@"Dynamic Subclinic Education Module Initialized with spec file: %@.plist",currentDynamicSubClinicEdModuleSpecFilename);
}

- (void)initializeDynamicEducationModule {
    NSLog(@"WRViewController.initializeDynamicEducationModule()");

    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
//    dynamicEdModule = [[DynamicModuleViewController_Pad alloc] initWithPropertyList:currentDynamicClinicEdModuleSpecFilename];
    dynamicEdModule = [DynamicModuleViewController_Pad alloc];
    [dynamicEdModule setupClinicContent];
//    [dynamicEdModule setupWithPropertyList:currentDynamicClinicEdModuleSpecFilename];
//    dynamicEdModule.speakItemsAloud = YES;
    
    dynamicEdModule.view.alpha = 0.0;
//    dynamicEdModule.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule.view];
    [self.view sendSubviewToBack:dynamicEdModule.view];
    
//    NSLog(@"Dynamic Clinic Education Module Initialized with spec file: %@.plist",currentDynamicClinicEdModuleSpecFilename);
}

- (void)setDefaultDynamicSubClinicSoundFileDict {
    if (dynamicSubclinicEdModule.ttsSoundFileDict) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dynamicSubclinicEdModule.ttsSoundFileDict forKey:currentDynamicSubClinicEdModuleSpecFilename];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"dynamicSubclinicEdModule.ttsSoundFileDict not found...unable to set key %@",currentDynamicSubClinicEdModuleSpecFilename);
    }
}

- (void)setDefaultDynamicSoundFileDict {
    
    if (dynamicEdModule.ttsSoundFileDict) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dynamicEdModule.ttsSoundFileDict forKey:@"currentDynamicSoundFileDict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"dynamicEdModule.ttsSoundFileDict not found...unable to set %@",@"currentDynamicSoundFileDict");
    }
    
    
}

- (void)setThisDynamicSoundFileDict:(NSString *)usingThisSoundFileDictKey {

    if (dynamicEdModule.ttsSoundFileDict) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dynamicEdModule.ttsSoundFileDict forKey:usingThisSoundFileDictKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"dynamicEdModule.ttsSoundFileDict not found...unable to set %@",usingThisSoundFileDictKey);
    }
    
    
}

- (void)launchDynamicClinicEducationModule {
    //    if (educationModuleInProgress) {
    //        [self reshowEducationModule];
    //    } else {
    //        [self setUpEducationModuleForFirstTime];
    //        [self showEducationModuleIntro];
    //    }
    [self fadeDynamicEducationModuleIn];
}

- (void)fadeDynamicEducationModuleIn {
    
    NSLog(@"WRViewController.fadDynamicEducationModuleIn() Fading in dynamic ed module");
    
    dynamicEdModuleInProgress = YES;
    
    dynamicEdModule.view.alpha = 0.0;
    
    dynamicEdModule.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
    dynamicEdModule.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
    
//    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:dynamicEdModule.view];
    
    [self.view bringSubviewToFront:physicianDetailVC.view];
    
//    [self.view bringSubviewToFront:nextPhysicianDetailButton];
//    [self.view bringSubviewToFront:previousPhysicianDetailButton];
    
    //    [self.view bringSubviewToFront:voiceAssistButton];
    //    [self.view bringSubviewToFront:fontsizeButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicEdModule.view.alpha = 1.0;

        
	}
	[UIView commitAnimations];
    
    [dynamicEdModule startingFirstPage];
    
    [self.view sendSubviewToBack:surveyResourceBack];
    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:physicianModule selector:@selector(sayPhysicianDetailIntro) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:physicianDetailVC selector:@selector(beginFadeOutOfCareHandledByLabel) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
    //    [physicianModule sayPhysicianDetailIntro];
}

- (void)handleDynamicEdModuleCompleted {
    
//    if (isFirstVisit) {
    [self launchDynamicSurveyWithSubclinicHelpful];
//    } else {
//        NSLog(@"Something here about starting goal survey...");
//        [self launchDynamicSubclinicEducationModule];
//    }
}

- (void)fadeDynamicEdModuleOut {
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicEdModule.view.alpha = 0.0;
        
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeDynamicEdModuleOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishFadeDynamicEdModuleOut:(NSTimer*)theTimer {
    
    [self.view sendSubviewToBack:dynamicEdModule.view];
    
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out dynamic ed module");
}

- (void)setUpDynamicSurveyForTheFirstTime {
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    dynamicSurveyModule.view.transform = rotateRight;
    dynamicSurveyModule.view.alpha = 0.0;
    [dynamicSurveyModule.view setCenter:CGPointMake(552.0f, 400.0f)];
//    [dynamicSurveyModule.view setCenter:CGPointMake(400.0f, 552.0f)];
    [self.view addSubview:dynamicSurveyModule.view];
    [self.view sendSubviewToBack:dynamicSurveyModule.view];
    dynamicSurveyInitialized = YES;
}

- (void)initializeDynamicSurveyPages {
    NSLog(@"WRViewController.initializeDynamicSurveyPages()");
    [dynamicSurveyModule loadAllSurveyPages];
}

- (void)launchDynamicSurveyWithProviderAndSubclinicTest {
    NSLog(@"WRViewController.launchDynamicSurveyWithProviderAndSubclinicTest()");
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInReadyForAppointmentButton];
    
//    int currentSurveyPageIndex = 0;
//    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex];
    [dynamicSurveyModule startingFirstPage];
    [self fadeDynamicSurveyIn];
   // [DynamicContent disableFontSizeButton];
}

- (void)launchDynamicSurveyWithProviderHelpful {
  //  if ([DynamicSpeech isEnabled]){
  //      QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
  //      [DynamicSpeech speakText:[questionInfo getClinicianInfoRatingQuestion]];
  //  }
    int currentSurveyPageIndex = 7;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithSubclinicHelpful {
    int currentSurveyPageIndex = 8;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex+1];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithGoalPage {
    int currentSurveyPageIndex = 4;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex+4];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveySkipToChooseModule {
    
    slidesCompleted = slidesCompleted + firstVisitSlides;
    progressSoFar = (CGFloat)slidesCompleted / totalSlidesInThisSection;
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] progressVC] updateProgressTo:progressSoFar];
    
    int currentSurveyPageIndex = 9;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithChooseModuleTBI {
//    int currentSurveyPageIndex = 9;
//    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex+1];
    [dynamicSurveyModule playSoundForCurrentSurveyPage];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithChooseModuleWhatsNew {
//    int currentSurveyPageIndex = 9;
//    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex+1];
    [dynamicSurveyModule playSoundForCurrentSurveyPage];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideNextButton];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithPreSatisfactionTransition {
    int currentSurveyPageIndex = 10;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex];
    [self fadeDynamicSurveyIn];
}

- (void)launchDynamicSurveyWithAppPage {
    
    int currentSurveyPageIndex = 11;
    [dynamicSurveyModule startOnSurveyPageWithIndex:currentSurveyPageIndex withFinishingIndex:currentSurveyPageIndex+8];
  //  [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];//rjl
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
    
    [self fadeDynamicSurveyIn];
}

- (void)fadeDynamicSurveyIn {
    NSLog(@"WRViewController.fadeDynamicSurveyIn()");
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:dynamicSurveyModule];
    [self showMasterButtonOverlay];
    
    dynamicSurveyModule.view.alpha = 0.0;
    
//    dynamicSurveyModule.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
//    dynamicSurveyModule.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
    

    
    //    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:dynamicSurveyModule.view];
    

    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicSurveyModule.view.alpha = 1.0;
        
	}
	[UIView commitAnimations];
    
    
//    [dynamicSubclinicEdModule startingFirstPage];
    
//    [self.view sendSubviewToBack:surveyResourceBack];
    
}

- (void)fadeDynamicSurveyOut {
    NSLog(@"WRViewController.fadeDynamicSurveyOut()");
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicSurveyModule.view.alpha = 0.0;
        
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeDynamicSurveyOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishFadeDynamicSurveyOut:(NSTimer*)theTimer {
    NSLog(@"WRViewController.finishedFadeDynamicSurveyOut()");

    [self.view sendSubviewToBack:dynamicSurveyModule.view];
    
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out dynamic survey module");
}

- (void)finishedPartOfDynamicSurvey {
    NSLog(@"WRViewController.finishedPartOfDynamicSurvey()");

    [self fadeDynamicSurveyOut];
    
    if (completedFinalSurvey) {
        [self showReturnTabletView];
    } else if (completedProviderSession) {
        [self launchSatisfactionSurvey];
    } else if (dynamicEdModuleCompleted) {
        [self launchDynamicSurveyWithChooseModuleTBI];
    } else if (physicianModuleCompleted) {
        [self launchDynamicSubclinicEducationModule];
    } else if (completedProviderAndSubclinicSurvey) {
        if (isFirstVisit) {
            [self fadePhysicianModuleIn];
        } else {
            // Follow-up Visit
            [self hideMasterButtonOverlay];
            [self promptForAdditionalInfoOnFollowUpVisit];
        }
    }
}

- (void)launchDynamicSubclinicEducationModule {
    //    if (educationModuleInProgress) {
    //        [self reshowEducationModule];
    //    } else {
    //        [self setUpEducationModuleForFirstTime];
    //        [self showEducationModuleIntro];
    //    }
    [self fadeDynamicSubclinicEducationModuleIn];
}

- (void)fadeDynamicSubclinicEducationModuleIn {
    // right before clinic info module
    NSLog(@"WRViewController.fadeDynamicSubclinicEducationModuleIn() Fading in dynamic subclinic ed module");
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:dynamicSubclinicEdModule];
    [self showMasterButtonOverlay];
    
    dynamicEdSubclinicModuleInProgress = YES;
    
    dynamicSubclinicEdModule.view.alpha = 0.0;
    
//    dynamicSubclinicEdModule.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
//    dynamicSubclinicEdModule.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
    
    //    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:dynamicSubclinicEdModule.view];
    
    //    [self.view bringSubviewToFront:physicianDetailVC.view];
    
    //    [self.view bringSubviewToFront:nextPhysicianDetailButton];
    //    [self.view bringSubviewToFront:previousPhysicianDetailButton];
    
    //    [self.view bringSubviewToFront:voiceAssistButton];
    //    [self.view bringSubviewToFront:fontsizeButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicSubclinicEdModule.view.alpha = 1.0;
        
        
	}
	[UIView commitAnimations];
    

    [dynamicSubclinicEdModule startingFirstPage];
    
//    [self.view sendSubviewToBack:surveyResourceBack];

}

- (void)fadeDynamicSubclinicEdModuleOut {
    
    NSLog(@"Fading out dynamic subclinic ed module...");
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        dynamicSubclinicEdModule.view.alpha = 0.0;
        
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeDynamicSubclinicEdModuleOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishFadeDynamicSubclinicEdModuleOut:(NSTimer*)theTimer {
    
    [self.view sendSubviewToBack:dynamicSubclinicEdModule.view];
    
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out dynamic ed module");
}

//- (void)launchDynamicWhatsNewModule {
//    [DynamicSpeech stopSpeaking];
//    NSLog(@"WRViewController.launchDynamicWhatsNewModule()");
//    [self fadeDynamicWhatsNewModuleIn];
//    //sandy 10-15-14
//    //TBD add code to indicate that this module was started in the db
//    NSString* addToSelfGuideStatus  = @"WhatNewStart";
//    
//    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
//    //    [mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
//    NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
//    NSLog(@"WRViewController.launchDynamicWhatsNewModule() existing SelfGuideSting%@",existingSelfGuideString);
//    int count = [mySelfGuideStatusArray count];
//    for (int i = 0; i < count; i++)
//        NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
//    NSString *appendedSelfGuideStatusString;
//    appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
//    [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
//    [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
//    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
//    [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
//}
//
//- (void)fadeDynamicWhatsNewModuleIn {
//    
//    NSLog(@"WRViewController.fadeDynamicWhatsNewModuleIn() Fading in dynamic what's new module");
//    
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:dynamicWhatsNewModule];
//    
//    dynamicWhatsNewModule.view.alpha = 0.0;
//    
//    dynamicWhatsNewModule.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
//    dynamicWhatsNewModule.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
//    
//    [self.view bringSubviewToFront:dynamicWhatsNewModule.view];
//
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicWhatsNewModule.view.alpha = 1.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    [dynamicWhatsNewModule startingFirstPage];
//    
//    [self.view sendSubviewToBack:surveyResourceBack];
//
//}
//
//- (void)fadeDynamicWhatsNewModuleOut {
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicWhatsNewModule.view.alpha = 0.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeDynamicWhatsNewModuleOut:) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//}
//
//- (void)finishFadeDynamicWhatsNewModuleOut:(NSTimer*)theTimer {
//    
//    [self.view sendSubviewToBack:dynamicWhatsNewModule.view];
//    
//    [theTimer release];
//	theTimer = nil;
//    
//    NSLog(@"Finished fading out dynamic what's new module");
//}

//

- (void)launchEdModule:(int)index {
    NSLog(@"WRViewController.launchEdModule() index %d", index);
    [DynamicSpeech stopSpeaking];
    EdModuleInfo* moduleInfo = NULL;
    int edModuleCount = [[DynamicContent getAllEdModules] count];
    if (0 <= index && index < edModuleCount){
        moduleInfo = [DynamicContent getEdModuleAtIndex:index];
        if (moduleInfo){
            NSArray* pages = [moduleInfo getPages];
            int count = [pages count] -1.0; // skip first page because its a header
            if (count >= 0){
                [self resetProgressBar];
                //[self incrementProgressBar];
                totalSlidesInThisSection = count;
                NSLog(@"WRViewController.launchEdModule() index: %d page count: %d", index, count);
            }
        }
    }
    [DynamicContent fadeEdModulePickerOut];
    
    [self fadeEdModuleIn:[moduleInfo getModuleName]];
    //sandy 10-15-14
    //TBD add code to indicate that this module was started in the db
    NSString* addToSelfGuideStatus  = @"WhatNewStart";
    
    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
    //    [mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
    NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
    NSLog(@"WRViewController.launchEdModule() existing SelfGuideString%@",existingSelfGuideString);
    NSUInteger count = [mySelfGuideStatusArray count];
    for (int i = 0; i < count; i++)
        NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
    NSString *appendedSelfGuideStatusString;
    appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
    [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
    [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
}

//- (DynamicModuleViewController_Pad*) getEdModuleViewController:(int)index{
//    DynamicModuleViewController_Pad* edModuleViewController = NULL;
//    if (index == 1)
//        edModuleViewController = dynamicEdModule1;
//    else if (index == 2)
//        edModuleViewController = dynamicEdModule2;
//    else if (index == 3)
//        edModuleViewController = dynamicEdModule3;
//    else if (index == 4)
//        edModuleViewController = dynamicEdModule4;
//    else if (index == 5)
//        edModuleViewController = dynamicEdModule4;
//    return edModuleViewController;
//}

- (DynamicModuleViewController_Pad*) getEdModuleViewController:(NSString*)moduleName{
    DynamicModuleViewController_Pad* edModuleViewController = NULL;
    if ([moduleName isEqualToString:dynamicEdModule1.moduleName])
        edModuleViewController = dynamicEdModule1;
    else if ([moduleName isEqualToString:dynamicEdModule2.moduleName])
        edModuleViewController = dynamicEdModule2;
    else if ([moduleName isEqualToString:dynamicEdModule3.moduleName])
        edModuleViewController = dynamicEdModule3;
    else if ([moduleName isEqualToString:dynamicEdModule4.moduleName])
        edModuleViewController = dynamicEdModule4;
    else if ([moduleName isEqualToString:dynamicEdModule5.moduleName])
        edModuleViewController = dynamicEdModule5;
    else if ([moduleName isEqualToString:dynamicEdModule6.moduleName])
        edModuleViewController = dynamicEdModule6;
    else if ([moduleName isEqualToString:dynamicEdModule7.moduleName])
        edModuleViewController = dynamicEdModule7;
    else if ([moduleName isEqualToString:dynamicEdModule8.moduleName])
        edModuleViewController = dynamicEdModule8;
    else if ([moduleName isEqualToString:dynamicEdModule9.moduleName])
        edModuleViewController = dynamicEdModule9;
    else if ([moduleName isEqualToString:dynamicEdModule10.moduleName])
        edModuleViewController = dynamicEdModule10;
    return edModuleViewController;
}

- (void)fadeEdModuleIn:(NSString*)moduleName {
    
    NSLog(@"WRViewController.fadeEdModuleIn() Fading in ed module %@",moduleName);
    //rjl 11/15/14 the index below is not same as index input because the one below only is for clinic relevant
    DynamicModuleViewController_Pad* edModuleViewController = [self getEdModuleViewController:moduleName];
    if (!edModuleViewController)
        return;
    [DynamicContent setCurrentEdModuleViewController:edModuleViewController];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:edModuleViewController];
    
    edModuleViewController.view.alpha = 0.0;
    
    edModuleViewController.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
    edModuleViewController.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
    //[edModuleViewController setCurrentPage:1];
    [self.view bringSubviewToFront:edModuleViewController.view];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        edModuleViewController.view.alpha = 1.0;
        
        
	}
	[UIView commitAnimations];
    
    [edModuleViewController startingFirstPage];
    
    [self.view sendSubviewToBack:surveyResourceBack];
    
}

- (void)fadeCurrentEdModuleOut{
    DynamicModuleViewController_Pad* edModuleViewController = [DynamicContent getCurrentEdModuleViewController];
    if (!edModuleViewController)
        return;
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        edModuleViewController.view.alpha = 0.0;
        
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeCurrentEdModuleOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

//- (void)fadeCurrentEdModuleOut{
//    DynamicModuleViewController_Pad* edModuleViewController = [DynamicContent getCurrentEdModuleViewController];
//    if (!edModuleViewController)
//        return;
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        edModuleViewController.view.alpha = 0.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeCurrentEdModuleOut) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//}


//- (void)fadeEdModuleOut:(int)index {
//    DynamicModuleViewController_Pad* edModuleViewController = [self getEdModuleViewController:index];
//    if (!edModuleViewController)
//        return;
//
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        edModuleViewController.view.alpha = 0.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeEdModuleOut:index:) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//}

- (void)finishFadeCurrentEdModuleOut:(NSTimer*)theTimer{
    DynamicModuleViewController_Pad* edModuleViewController = [DynamicContent getCurrentEdModuleViewController];
    if (!edModuleViewController)
        return;
    
    [self.view sendSubviewToBack:edModuleViewController.view];
    
    [DynamicContent setCurrentEdModuleViewController:NULL];
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out ed module %@", [edModuleViewController moduleName]);
}

//- (void)finishFadeEdModuleOut:(NSTimer*)theTimer index:(int) moduleIndex{
//    DynamicModuleViewController_Pad* edModuleViewController = [self getEdModuleViewController:moduleIndex];
//    if (!edModuleViewController)
//        return;
//    
//    [self.view sendSubviewToBack:edModuleViewController.view];
//    
//    [theTimer release];
//	theTimer = nil;
//    
//    NSLog(@"Finished fading out ed module %d", moduleIndex);
//}

//- (void)launchEdModule1 {
//    [DynamicSpeech stopSpeaking];
//    NSLog(@"WRViewController.launchEdModule1()");
//    [self fadeEdModule1In];
//    //sandy 10-15-14
//    //TBD add code to indicate that this module was started in the db
//    NSString* addToSelfGuideStatus  = @"WhatNewStart";
//    
//    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
//    //    [mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
//    NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
//    NSLog(@"WRViewController.launchDynamicWhatsNewModule() existing SelfGuideSting%@",existingSelfGuideString);
//    int count = [mySelfGuideStatusArray count];
//    for (int i = 0; i < count; i++)
//        NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
//    NSString *appendedSelfGuideStatusString;
//    appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
//    [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
//    [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
//    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
//    [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
//}
//
//- (void)fadeEdModule1In {
//    
//    NSLog(@"WRViewController.fadeEdModule1In() Fading in ed module1");
//    
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:dynamicEdModule1];
//    
//    dynamicEdModule1.view.alpha = 0.0;
//    
//    dynamicEdModule1.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
//    dynamicEdModule1.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
//    
//    [self.view bringSubviewToFront:dynamicEdModule1.view];
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicEdModule1.view.alpha = 1.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    [dynamicEdModule1 startingFirstPage];
//    
//    [self.view sendSubviewToBack:surveyResourceBack];
//    
//}
//
//- (void)fadeEdModule1Out {
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicEdModule1.view.alpha = 0.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeEdModule1Out:) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//}
//
//- (void)finishFadeEdModule1Out:(NSTimer*)theTimer {
//    
//    [self.view sendSubviewToBack:dynamicEdModule1.view];
//    
//    [theTimer release];
//	theTimer = nil;
//    
//    NSLog(@"Finished fading out ed module1");
//}
//
//- (void)launchEdModule2 {
//    [DynamicSpeech stopSpeaking];
//    NSLog(@"WRViewController.launchEdModule2()");
//    [self fadeEdModule2In];
//    //sandy 10-15-14
//    //TBD add code to indicate that this module was started in the db
//    NSString* addToSelfGuideStatus  = @"WhatNewStart";
//    
//    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
//    //    [mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
//    NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
//    NSLog(@"WRViewController.launchDynamicWhatsNewModule() existing SelfGuideSting%@",existingSelfGuideString);
//    int count = [mySelfGuideStatusArray count];
//    for (int i = 0; i < count; i++)
//        NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
//    NSString *appendedSelfGuideStatusString;
//    appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
//    [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
//    [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
//    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
//    [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
//}
//
//- (void)fadeEdModule2In {
//    
//    NSLog(@"WRViewController.fadeEdModule1In() Fading in ed module2");
//    
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showCurrentButtonOverlay];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
//    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:dynamicEdModule2];
//    
//    dynamicEdModule2.view.alpha = 0.0;
//    
//    dynamicEdModule2.standardPageButtonOverlay.returnToMenuButton.enabled = NO;
//    dynamicEdModule2.standardPageButtonOverlay.returnToMenuButton.alpha = 0.0;
//    
//    [self.view bringSubviewToFront:dynamicEdModule2.view];
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicEdModule2.view.alpha = 1.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    [dynamicEdModule2 startingFirstPage];
//    
//    [self.view sendSubviewToBack:surveyResourceBack];
//    
//}
//
//- (void)fadeEdModule2Out {
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        dynamicEdModule2.view.alpha = 0.0;
//        
//        
//	}
//	[UIView commitAnimations];
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadeEdModule2Out:) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
//}
//
//- (void)finishFadeEdModule2Out:(NSTimer*)theTimer {
//    
//    [self.view sendSubviewToBack:dynamicEdModule2.view];
//    
//    [theTimer release];
//	theTimer = nil;
//    
//    NSLog(@"Finished fading out ed module2");
//}


//

- (void)slideClinicianSelectorAndReadyButtonOut {
    CGRect launchFrame = readyAppButton.frame;
    
    //sandy tried offseting here
    launchFrame.origin.y = 1500;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        readyAppButton.frame = launchFrame;
    
        splitViewController.view.alpha = 0.0;
    }
    [UIView commitAnimations];
    
}

- (void)initializeReadyScreen {
    NSLog(@"WRViewController.initializeReadyScreen() currentMainClinic: %d", currentMainClinic);
    
    
    NSString *welcomeBackText;
    
    if (isFirstVisit) {
        welcomeBackText = @"Welcome to the";
    } else {
        welcomeBackText = @"Welcome back to the";
    }
    
    NSString *fullClinicString;
    NSString *currentInstitutionImageFilename;
    
    switch (currentInstitution) {
        case kVAPAHCS:
            currentInstitutionImageFilename = @"vapachs_launch-ipad_landscape_trim.png";
            break;
        default:
            currentInstitutionImageFilename = @"vapachs_launch-ipad_landscape_trim.png";
            break;
    }
    
    NSString *currentMainClinicText;
     NSString *currentSubClinicText;
    
//    switch (currentMainClinic) {
//        case kATLab:
//            currentMainClinicText = @"AT Center";
//            currentSubClinicText = @"";
//            break;
//        case kPMNRClinic:
//            if ([currentSubClinicName isEqualToString:@"PM&R"]) {
//                currentMainClinicText = @"";
//                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic",currentSubClinicName];
//            } else if ([currentSubClinicName isEqualToString:@"All"]) {
//                currentMainClinicText = @"PM&R";
//                currentSubClinicText = @"Clinic";
//            } else {
//                currentMainClinicText = @"PM&R";
//                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic",currentSubClinicName];
//            }
//            currentMainClinicText = @"PM&R";
           // NSString* clinicName = [DynamicContent getCurrentClinic];
            ClinicInfo* clinicInfo = [DynamicContent getCurrentClinic];
            currentSubClinicText = [clinicInfo getSubclinicName];
            if ([currentSubClinicText length] == 0)
                currentSubClinicText = [clinicInfo getClinicName];
//            if ([currentSpecialtyClinicName isEqualToString:@"None"]) {
//                currentSubClinicText = [NSString stringWithFormat:@"Clinic"];
//            } else if ([currentSpecialtyClinicName isEqualToString:@"Acupuncture"]) {
//                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic", currentSpecialtyClinicName];
//            } else if ([currentSpecialtyClinicName isEqualToString:@"Pain"]) {
//                currentSubClinicText = [NSString stringWithFormat:@"Chronic %@ Clinic", currentSpecialtyClinicName];
//            } else if ([currentSpecialtyClinicName isEqualToString:@"PNS"]) {
//                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic", currentSpecialtyClinicName];
//            } else if ([currentSpecialtyClinicName isEqualToString:@"EMG"]) {
//                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic", currentSpecialtyClinicName];
//            } else {
//                currentSubClinicText = [NSString stringWithFormat:@"Clinic"];
//            }
//            break;
//        case kPNSClinic:
//            currentMainClinicText = @"PNS";
//            currentSubClinicText = [NSString stringWithFormat:@"Clinic"];
//            break;
//        case kNoMainClinic:
//            currentMainClinicText = @"";
//            currentSubClinicText = [NSString stringWithFormat:@"Clinic"];
//            break;
//        default:
//            currentMainClinicText = @"";
//            break;
//    }
    currentMainClinicText = @"";
    fullClinicString = [NSString stringWithFormat:@"%@ %@\n%@", welcomeBackText, currentMainClinicText, currentSubClinicText];
    readyScreen = [[DynamicStartAppView alloc] initWithFrame:self.view.frame institutionImageFileName:currentInstitutionImageFilename fullWelcomeClinicText:fullClinicString target:self selector:@selector(startButtonPressed:) showInstitutionImage:YES];
    readyScreen.alpha = 0.0;
    [self.view addSubview:readyScreen];
    
}

- (void)fadeInReadyScreen {
    [self fadeThisObjectIn:readyScreen];
}

#pragma mark - Fade Methods

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

#pragma mark - Splash Animation Methods

- (void)beginToLaunchApp:(NSTimer*)theTimer {
    
    [self launchAppWithSplashView];
    
    [theTimer release];
	theTimer = nil;
}

- (void)launchAppWithSplashView {
    
    if (skipToPhysicianDetail && runningAppInDemoMode) {
        endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(fadeSplashOutAndSlideButtonsIn:) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
        
        [tbvc setRespondentToPatient:self];
        
    } else {
//        [tbvc sayWelcomeToApp];
        [DynamicSpeech sayWelcomeToApp];
        [self animateTabBarOnAndStatusBackIn];
    }
}

- (void)initSplashView {
    NSLog(@"WRViewController.initSplashView()");

    
    splashImageViewB = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_launch-ipad_landscape.png"]];
    
    splashImageViewBb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_prc_splash1-ipad_landscape2.png"]];
	
    float angle =  90 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    [splashImageViewB setCenter:CGPointMake(500.0f, 400.0f)];
    [splashImageViewBb setCenter:CGPointMake(500.0f, 375.0f)];
    
    splashImageViewB.alpha = 0.0;
    splashImageViewBb.alpha = 0.0;
    splashImageViewB.transform = rotateRight;
    splashImageViewBb.transform = rotateRight;
    presurveyIntroLabel.alpha = 0.0; //rjl 7/8/14
    initialSettingsLabel.alpha = 0.0;// sandy 7/13
    taperedWhiteLine.alpha = 0.0;// sandy 7/13
    
    [self.view addSubview:splashImageViewB];
    [self.view addSubview:splashImageViewBb];
    [self.view addSubview:presurveyIntroLabel]; //rjl 7/8/14
    [self.view addSubview:initialSettingsLabel];
    [self.view addSubview:taperedWhiteLine];
    [self.view sendSubviewToBack:splashImageViewB];
    [self.view sendSubviewToBack:splashImageViewBb];
    [self.view sendSubviewToBack:presurveyIntroLabel]; //rjl 7/8/14
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
}

- (void)selectedDynamicSurveyItemWithSegmentIndex:(int)selectedIndex {
    [tbvc madeDynamicSurveyRatingWithSegmentIndex:selectedIndex];
}

- (void)selectedSatisfactionWithVC:(id)sender andSegmentIndex:(int)selectedIndex {
    [tbvc madeSatisfactionRatingForVC:sender withSegmentIndex:selectedIndex];
}

- (BOOL)isAppRunningInDemoMode {
    
    return runningAppInDemoMode;
}

- (void)animateTabBarOnAndStatusBackIn {
	NSLog(@"WRViewController.animateTabBarOnAndStatusBackIn()");
    
    [self.view bringSubviewToFront:splashImageViewB];
    
//	self.checkingForReachability = NO;
    [[AppDelegate_Pad sharedAppDelegate] setCheckingForReachability:NO];

    
//    [UIView beginAnimations:@"animateTabBarOnAndButtonsIn" context:nil];
//	{
//		[UIView	setAnimationDuration:1.0];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        //        splashImageView.alpha = 0.0;
//        
//    }
//	[UIView commitAnimations];
	
	[UIView beginAnimations:@"animateTabBarOnAndButtonsIn" context:nil];
	{
		[UIView	setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //		[tabNAdView setTransform:CGAffineTransformIdentity];
        //            tabNAdView.alpha = 0.0;
        splashImageViewB.alpha = 1.0;
	}
	[UIView commitAnimations];
	
	middleOfSplashTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(middleSplashAnimation:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:middleOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)middleSplashAnimation:(NSTimer*)theTimer {
    NSLog(@"WRViewController.middleSplashTimer()");

	[self.view bringSubviewToFront:splashImageViewBb];

    
	[UIView beginAnimations:@"fadeSplashOut" context:nil];
	{
		[UIView	setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		splashImageViewB.alpha = 0.0;
        splashImageViewBb.alpha = 1.0;
        
//        presurveyIntroLabel.alpha = 1.0; //rjl 7/8/14
		
	}
	[UIView commitAnimations];
	
	[theTimer release];
	theTimer = nil;
    
    //rjl 7/8/14
    middleOfSplashTimer = [[NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(finishSplashAnimation:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:middleOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishSplashAnimation:(NSTimer*)theTimer {
    NSLog(@"WRViewController.finishSplashAnimation()");
    // presurvey info moved to here rjl 7/8/14
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    presurveyIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    presurveyIntroLabel.numberOfLines = 0;
	presurveyIntroLabel.text = [DynamicContent getPrivacyPolicyForDisplay];
//	presurveyIntroLabel.text = @"•\t Your participation in this survey is anonymous. \n\n•\t Bob's responses will not be given to your treatment provider or any other clinic staff. \n\n•\t Your responses will not influence the services you receive at this clinic. ";
	presurveyIntroLabel.textColor = [UIColor blackColor];
	presurveyIntroLabel.backgroundColor = [UIColor clearColor];
    presurveyIntroLabel.font = [UIFont fontWithName:@"Avenir" size:34];
	presurveyIntroLabel.opaque = YES;
    [presurveyIntroLabel setCenter:CGPointMake(512.0f, 400.0f)];
//    [presurveyIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
//    presurveyIntroLabel.transform = rotateRight;
	presurveyIntroLabel.alpha = 0.0; //rjl 7/8/14
    
    [self.view addSubview:presurveyIntroLabel];
    
    
    initialSettingsLabel.text = @"Privacy Policy";
    initialSettingsLabel.alpha = 0.0;
    taperedWhiteLine.alpha = 0.0;
    [self.view bringSubviewToFront:initialSettingsLabel];
    [self.view bringSubviewToFront:taperedWhiteLine];
	[self.view bringSubviewToFront:presurveyIntroLabel]; //rjl 7/8/14 ]splashImageViewBb];
    
    
//	[self.view bringSubviewToFront:splashImageViewBb];//presurveyIntroLabel];//rjl 7/8/14
    
    [self.view sendSubviewToBack:odetteButton];
    [self.view sendSubviewToBack:calvinButton];
    [self.view sendSubviewToBack:lauraButton];
    [self.view sendSubviewToBack:clinicianLabel];
    
    
	[UIView beginAnimations:@"fadeSplashOut" context:nil];
	{
		[UIView	setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewBb.alpha = 1.0;
        
        splashImageViewBb.alpha = 0.0;
        presurveyIntroLabel.alpha = 1.0;
        initialSettingsLabel.alpha = 1.0;
        taperedWhiteLine.alpha = 1.0;
		
	}
	[UIView commitAnimations];
	
	[theTimer release];
	theTimer = nil;
    // sandy reset view to match length of sound was 20
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:14.0 target:self selector:@selector(fadeSplashOutAndSlideButtonsIn:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)sqlConnectedAnimation {
    
}

- (void)fadeSplashOutAndSlideButtonsIn:(NSTimer*)theTimer {
    NSLog(@"WRViewController.fadeSplashOutAndSlideButtonsIn()");
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //    resourceBack.alpha = 1.0;
    
    if (!skipToPhysicianDetail) {
        
        
        
//        [self.view sendSubviewToBack:splashImageViewB];
        
        [UIView beginAnimations:@"fadeSplashOut" context:nil];
        {
            [UIView	setAnimationDuration:1.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.alpha = 1.0;
            
//            splashImageViewBb.alpha = 1.0;
             presurveyIntroLabel.alpha = 0.0;
        }
        [UIView commitAnimations];
        
    }
    
    //    resourceBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_landscape2-SS-blueback.png"]];
    
    resourceBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_back_wht_gradient.png"]];
    
	resourceBack.frame = CGRectMake(0, 0, 768, 1024);
    resourceBack.alpha = 0.0;
	
	[self.view addSubview:resourceBack];
    [self.view sendSubviewToBack:resourceBack];
    
    surveyResourceBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_back_wht_gradient_clearback4.png"]];
    surveyResourceBack.opaque = NO;
	surveyResourceBack.frame = CGRectMake(0, 0, 768, 1024);
    surveyResourceBack.alpha = 0.0;
	
	[self.view addSubview:surveyResourceBack];
    [self.view sendSubviewToBack:surveyResourceBack];
    
    //nextSurveyItemButton - skip to next survey item
	nextSurveyItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextSurveyItemButton.frame = CGRectMake(0, 0, 150, 139);
	nextSurveyItemButton.showsTouchWhenHighlighted = YES;
	[nextSurveyItemButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
	[nextSurveyItemButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[nextSurveyItemButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
	nextSurveyItemButton.backgroundColor = [UIColor clearColor];
    [nextSurveyItemButton setCenter:CGPointMake(80.0f, 685.0f)];
//    [nextSurveyItemButton setCenter:CGPointMake(685.0f, 80.0f)];
	[nextSurveyItemButton addTarget:tbvc action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextSurveyItemButton.enabled = YES;
	nextSurveyItemButton.hidden = NO;
    nextSurveyItemButton.alpha = 0.0;
	[nextSurveyItemButton retain];
//    nextSurveyItemButton.transform = rotateRight;
    [self.view addSubview:nextSurveyItemButton];
    [self.view sendSubviewToBack:nextSurveyItemButton];
    
    //previousSurveyItemButton - skip to next survey item
	previousSurveyItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previousSurveyItemButton.frame = CGRectMake(0, 0, 150, 139);
	previousSurveyItemButton.showsTouchWhenHighlighted = YES;
	[previousSurveyItemButton setImage:[UIImage imageNamed:@"previous_button_image.png"] forState:UIControlStateNormal];
	[previousSurveyItemButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[previousSurveyItemButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateSelected];
	previousSurveyItemButton.backgroundColor = [UIColor clearColor];
    [previousSurveyItemButton setCenter:CGPointMake(945.0f, 685.0f)];
//    [previousSurveyItemButton setCenter:CGPointMake(685.0f, 945.0f)];
	[previousSurveyItemButton addTarget:tbvc action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousSurveyItemButton.enabled = NO;
	previousSurveyItemButton.hidden = NO;
    previousSurveyItemButton.alpha = 0.0;
	[previousSurveyItemButton retain];
//    previousSurveyItemButton.transform = rotateRight;
    [self.view addSubview:previousSurveyItemButton];
    [self.view sendSubviewToBack:previousSurveyItemButton];
    
    //nextEdItemButton - skip to next survey item
	nextEdItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextEdItemButton.frame = CGRectMake(0, 0, 150, 139);
	nextEdItemButton.showsTouchWhenHighlighted = YES;
	[nextEdItemButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
	[nextEdItemButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[nextEdItemButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
	nextEdItemButton.backgroundColor = [UIColor clearColor];
//    [nextEdItemButton setCenter:CGPointMake(80.0f, 685.0f)];
    [nextEdItemButton setCenter:CGPointMake(680.0f, 570.0f)];
	[nextEdItemButton addTarget:self action:@selector(beginEducationModule:) forControlEvents:UIControlEventTouchUpInside];
//    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextEdItemButton.enabled = YES;
	nextEdItemButton.hidden = NO;
    nextEdItemButton.alpha = 0.0;
	[nextEdItemButton retain];
//    nextEdItemButton.transform = rotateRight;
    [self.view addSubview:nextEdItemButton];
    [self.view sendSubviewToBack:nextEdItemButton];
    
    //previousEdItemButton - skip to previous survey item
	previousEdItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previousEdItemButton.frame = CGRectMake(0, 0, 150, 139);
	previousEdItemButton.showsTouchWhenHighlighted = YES;
	[previousEdItemButton setImage:[UIImage imageNamed:@"previous_button_image.png"] forState:UIControlStateNormal];
	[previousEdItemButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[previousEdItemButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateSelected];
	previousEdItemButton.backgroundColor = [UIColor clearColor];
    [previousEdItemButton setCenter:CGPointMake(945.0f, 685.0f)];
//    [previousEdItemButton setCenter:CGPointMake(685.0f, 945.0f)];
	[previousEdItemButton addTarget:edModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousEdItemButton.enabled = NO;
	previousEdItemButton.hidden = NO;
    previousEdItemButton.alpha = 0.0;
	[previousEdItemButton retain];
//    previousEdItemButton.transform = rotateRight;
    [self.view addSubview:previousEdItemButton];
    [self.view sendSubviewToBack:previousEdItemButton];
    
    //nextPhysicianDetailButton - skip to next physician detail item
	nextPhysicianDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextPhysicianDetailButton.frame = CGRectMake(0, 0, 150, 139);
	nextPhysicianDetailButton.showsTouchWhenHighlighted = YES;
	[nextPhysicianDetailButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
	[nextPhysicianDetailButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[nextPhysicianDetailButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
	nextPhysicianDetailButton.backgroundColor = [UIColor clearColor];
    [nextPhysicianDetailButton setCenter:CGPointMake(80.0f, 685.0f)];
//    [nextPhysicianDetailButton setCenter:CGPointMake(685.0f, 80.0f)];
//	[nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    //    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    [nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextPhysicianDetailButton.enabled = YES;
	nextPhysicianDetailButton.hidden = NO;
    nextPhysicianDetailButton.alpha = 0.0;
	[nextPhysicianDetailButton retain];
//    nextPhysicianDetailButton.transform = rotateRight;
    [self.view addSubview:nextPhysicianDetailButton];
    [self.view sendSubviewToBack:nextPhysicianDetailButton];
    
    //previousPhysicianDetailButton - skip to previous physician detail item
	previousPhysicianDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previousPhysicianDetailButton.frame = CGRectMake(0, 0, 150, 139);
	previousPhysicianDetailButton.showsTouchWhenHighlighted = YES;
	[previousPhysicianDetailButton setImage:[UIImage imageNamed:@"previous_button_image.png"] forState:UIControlStateNormal];
	[previousPhysicianDetailButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[previousPhysicianDetailButton setImage:[UIImage imageNamed:@"previous_button_image_pressed.png"] forState:UIControlStateSelected];
	previousPhysicianDetailButton.backgroundColor = [UIColor clearColor];
    [previousPhysicianDetailButton setCenter:CGPointMake(945.0f, 685.0f)];
//    [previousPhysicianDetailButton setCenter:CGPointMake(685.0f, 945.0f)];
//	[previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
    [previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousPhysicianDetailButton.enabled = NO;
	previousPhysicianDetailButton.hidden = NO;
    previousPhysicianDetailButton.alpha = 0.0;
	[previousPhysicianDetailButton retain];
//    previousPhysicianDetailButton.transform = rotateRight;
    [self.view addSubview:previousPhysicianDetailButton];
    [self.view sendSubviewToBack:previousPhysicianDetailButton];
    
//    splashImageViewC = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_SS_splash2-new_ipad_landscape3_sml2.png"]];
//    splashImageViewC = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
//    splashImageViewC.alpha = 0.0;
	
//	[self.view addSubview:splashImageViewC];
//    [self.view sendSubviewToBack:splashImageViewC];
	
	[theTimer release];
	theTimer = nil;
	
	endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(removeSplashView:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
	
}

- (void)activateSurveyBackButton {
    previousSurveyItemButton.enabled = YES;
}

- (void)deactivateSurveyBackButton {
    previousSurveyItemButton.enabled = NO;
}

- (void)activateEdBackButton {
    previousEdItemButton.enabled = YES;
}

- (void)deactivateEdBackButton {
    previousEdItemButton.enabled = NO;
}

- (void)activatePhysicianBackButton {
    previousPhysicianDetailButton.enabled = YES;
}

- (void)deactivatePhysicianBackButton {
    previousPhysicianDetailButton.enabled = NO;
}

- (void)removeSplashView:(NSTimer*)theTimer {
	NSLog(@"WRViewController.removeSplashView() tabNAdview, statusViewWhiteBack, splashSpinner and stopping the spinner...");
    //sandy remove from previous view
    initialSettingsLabel.alpha = 0.0;
    taperedWhiteLine.alpha = 0.0;
    if (!skipToPhysicianDetail) {
        [UIView beginAnimations:@"fadeSplashOut" context:nil];
        {
            [UIView	setAnimationDuration:1.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.alpha = 1.0;
            
            splashImageViewBb.alpha = 0.0;
            
        }
        [UIView commitAnimations];
    }
	
	splashAnimationsFinished = YES;
    
    //    cubeViewController = [[MyViewController alloc] init];
    //    [self.view addSubview:[cubeViewController view]];
    
    //sandy move the patient survey consent info to here
    
    //    [self.view bringSubviewToFront:resourceBack]; //uncomment me
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    //    myView.transform = transform;
    
    readAloudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
	readAloudLabel.text = @"Would you like me to read the questions out loud?";
	readAloudLabel.textAlignment = UITextAlignmentCenter;
	readAloudLabel.textColor = [UIColor blackColor];
	readAloudLabel.backgroundColor = [UIColor clearColor];
    readAloudLabel.font = [UIFont fontWithName:@"Avenir" size:42];
	readAloudLabel.opaque = YES;
    [readAloudLabel setCenter:CGPointMake(512.0f, 690.0f)];
//    [readAloudLabel setCenter:CGPointMake(670.0f, 512.0f)];
//    readAloudLabel.transform = rotateRight;
	readAloudLabel.alpha = 0.0;
    
    [self.view addSubview:readAloudLabel];
    [self.view sendSubviewToBack:readAloudLabel];
    
    respondentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
	respondentLabel.text = @"Are you a patient, family member, or caregiver?";
	respondentLabel.textAlignment = UITextAlignmentCenter;
	respondentLabel.textColor = [UIColor blackColor];
	respondentLabel.backgroundColor = [UIColor clearColor];
    respondentLabel.font = [UIFont fontWithName:@"Avenir" size:45];
	respondentLabel.opaque = YES;
    [respondentLabel setCenter:CGPointMake(512.0f, 670.0f)];
//    [respondentLabel setCenter:CGPointMake(670.0f, 512.0f)];
//    respondentLabel.transform = rotateRight;
	respondentLabel.alpha = 0.0;
    
    [self.view addSubview:respondentLabel];
    [self.view sendSubviewToBack:respondentLabel];
    
    selectActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
	selectActivityLabel.text = @"Please choose a waiting room activity...";
	selectActivityLabel.textAlignment = UITextAlignmentCenter;
	selectActivityLabel.textColor = [UIColor blackColor];
	selectActivityLabel.backgroundColor = [UIColor clearColor];
    selectActivityLabel.font = [UIFont fontWithName:@"Avenir" size:45];
	selectActivityLabel.opaque = YES;
    [selectActivityLabel setCenter:CGPointMake(512.0f, 65.0f)];
//    [selectActivityLabel setCenter:CGPointMake(65.0f, 512.0f)];
//    selectActivityLabel.transform = rotateRight;
	selectActivityLabel.alpha = 0.0;
    
    [self.view addSubview:selectActivityLabel];
    [self.view sendSubviewToBack:selectActivityLabel];
    
    surveyIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    surveyIntroLabel.numberOfLines = 0;
	// sandy original 
    //surveyIntroLabel.text = @"Your participation in this survey is anonymous. Your responses will not be given to your physician or any other clinic staff. Your responses will not influence the services you receive at this clinic. By participating, you can help us provide a better rehabilitation experience.";
    surveyIntroLabel.text = @"•\t Your participation in this survey is anonymous. \n\n•\t Your responses will not be given to your treatment provider or any other clinic staff. \n\n•\t Your responses will not influence the services you receive at this clinic. ";
	surveyIntroLabel.textColor = [UIColor blackColor];
	surveyIntroLabel.backgroundColor = [UIColor clearColor];
    surveyIntroLabel.font = [UIFont fontWithName:@"Avenir" size:34];
	surveyIntroLabel.opaque = YES;
    [surveyIntroLabel setCenter:CGPointMake(512.0f, 400.0f)];
//    [surveyIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
//    surveyIntroLabel.transform = rotateRight;
	surveyIntroLabel.alpha = 0.0;
    
    [self.view addSubview:surveyIntroLabel];
    [self.view sendSubviewToBack:surveyIntroLabel];
    
    surveyCompleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 550)];
    surveyCompleteLabel.numberOfLines = 0;
//	surveyCompleteLabel.text = @"Thank you for your valuable input.\n\nPress menu to return to the main menu.";
    if ([tbvc.respondentType isEqualToString:@"patient"]) {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    } else if ([tbvc.respondentType isEqualToString:@"family"]) {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    } else {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    }
	surveyCompleteLabel.textAlignment = UITextAlignmentCenter;
	surveyCompleteLabel.textColor = [UIColor blackColor];
	surveyCompleteLabel.backgroundColor = [UIColor clearColor];
    surveyCompleteLabel.font = [UIFont fontWithName:@"Avenir" size:45];
	surveyCompleteLabel.opaque = YES;
    [surveyCompleteLabel setCenter:CGPointMake(525.0f, 300.0f)];
//    [surveyCompleteLabel setCenter:CGPointMake(300.0f, 525.0f)];
//    surveyCompleteLabel.transform = rotateRight;
	surveyCompleteLabel.alpha = 0.0;
    
    [self.view addSubview:surveyCompleteLabel];
    [self.view sendSubviewToBack:surveyCompleteLabel];
    
    edModuleIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    edModuleIntroLabel.numberOfLines = 0;
	edModuleIntroLabel.text = @"In the next few sections, you will be presented with information and media related to TBI and the Brain.\n\nYou can go at your own pace, and move ahead when you want to.\n\nPress next to continue.";
	edModuleIntroLabel.textColor = [UIColor blackColor];
	edModuleIntroLabel.backgroundColor = [UIColor clearColor];
    edModuleIntroLabel.font = [UIFont fontWithName:@"Avenir" size:34];
	edModuleIntroLabel.opaque = YES;
//    [edModuleIntroLabel setCenter:CGPointMake(512.0f, 400.0f)];
    [edModuleIntroLabel setCenter:CGPointMake(275.0f, 400.0f)];
    //    edModuleIntroLabel.transform = rotateRight;
	edModuleIntroLabel.alpha = 0.0;
    
    [self.view addSubview:edModuleIntroLabel];
    [self.view sendSubviewToBack:edModuleIntroLabel];
    
    edModuleCompleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 550)];
    edModuleCompleteLabel.numberOfLines = 0;
    edModuleCompleteLabel.text = @"You have completed the sections on TBI and the Brain.\n\nIn five seconds, you will be returned to the main menu.";
	edModuleCompleteLabel.textAlignment = UITextAlignmentCenter;
	edModuleCompleteLabel.textColor = [UIColor blackColor];
	edModuleCompleteLabel.backgroundColor = [UIColor clearColor];
    edModuleCompleteLabel.font = [UIFont fontWithName:@"Avenir" size:45];
	edModuleCompleteLabel.opaque = YES;
    [edModuleCompleteLabel setCenter:CGPointMake(300.0f, 250.0f)];
//    [edModuleCompleteLabel setCenter:CGPointMake(525.0f, 300.0f)];
//    [edModuleCompleteLabel setCenter:CGPointMake(300.0f, 525.0f)];
//    edModuleCompleteLabel.transform = rotateRight;
	edModuleCompleteLabel.alpha = 0.0;
    
    [self.view addSubview:edModuleCompleteLabel];
    [self.view sendSubviewToBack:edModuleCompleteLabel];
    
    //playMovieIcon
    playMovieIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_play_icon.png"]];
    playMovieIcon.frame = CGRectMake(0, 0, 176, 176);
//    playMovieIcon.transform = rotateRight;
    [playMovieIcon setCenter:CGPointMake(512.0f, 670.0f)];
//    [playMovieIcon setCenter:CGPointMake(670.0f, 512.0f)];
    playMovieIcon.alpha = 0.0;
    
//    [self.view addSubview:playMovieIcon];
//    [self.view sendSubviewToBack:playMovieIcon];
    
    // Initialize buttons for launch and menu screens
    // yesButton, noButton, patientButton, familyButton, caregiverButton, tbiEdButton, satisfactionButton, newsButton, clinicButton
	
    //yesButton - yes to voice assist
	yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	yesButton.frame = CGRectMake(0, 0, 416, 278);
	yesButton.showsTouchWhenHighlighted = YES;
	[yesButton setImage:[UIImage imageNamed:@"yes_button_image.png"] forState:UIControlStateNormal];
	[yesButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateHighlighted];
	[yesButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateSelected];
	yesButton.backgroundColor = [UIColor clearColor];
    [yesButton setCenter:CGPointMake(264.0f, 380.0f)];
//    [yesButton setCenter:CGPointMake(380.0f, 760.0f)];
	[yesButton addTarget:self action:@selector(yesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
	yesButton.enabled = YES;
	yesButton.hidden = NO;
    yesButton.alpha = 0.0;
	[yesButton retain];
//    yesButton.transform = rotateRight;
    
    [self.view addSubview:yesButton];
    [self.view sendSubviewToBack:yesButton];
    
    //noButton - no to voice assist
    noButton = [UIButton buttonWithType:UIButtonTypeCustom];
	noButton.frame = CGRectMake(0, 0, 416, 278);
	noButton.showsTouchWhenHighlighted = YES;
	[noButton setImage:[UIImage imageNamed:@"no_button_image.png"] forState:UIControlStateNormal];
	[noButton setImage:[UIImage imageNamed:@"no_button_image_pressed2.png"] forState:UIControlStateHighlighted];
	[noButton setImage:[UIImage imageNamed:@"no_button_image_pressed2.png"] forState:UIControlStateSelected];
	noButton.backgroundColor = [UIColor clearColor];
    [noButton setCenter:CGPointMake(760.0f, 380.0f)];
//    [noButton setCenter:CGPointMake(380.0f, 264.0f)];
    [noButton addTarget:self action:@selector(yesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
	noButton.enabled = YES;
	noButton.hidden = NO;
    noButton.alpha = 0.0;
	[noButton retain];
//    noButton.transform = rotateRight;
    
    [self.view addSubview:noButton];
    [self.view sendSubviewToBack:noButton];
    
    //patientButton
    patientButton = [UIButton buttonWithType:UIButtonTypeCustom];
	patientButton.frame = CGRectMake(0, 0, 318, 214);
	patientButton.showsTouchWhenHighlighted = YES;
	[patientButton setImage:[UIImage imageNamed:@"patient_button_image.png"] forState:UIControlStateNormal];
	[patientButton setImage:[UIImage imageNamed:@"patient_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[patientButton setImage:[UIImage imageNamed:@"patient_button_image_pressed.png"] forState:UIControlStateSelected];
	patientButton.backgroundColor = [UIColor clearColor];
    [patientButton setCenter:CGPointMake(171.0f, 380.0f)];
//    [patientButton setCenter:CGPointMake(853.0f, 380.0f)];
//    [patientButton setCenter:CGPointMake(380.0f, 853.0f)];
    [patientButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	patientButton.enabled = YES;
	patientButton.hidden = NO;
    patientButton.alpha = 0.0;
	[patientButton retain];
//    patientButton.transform = rotateRight;
    
    [self.view addSubview:patientButton];
    [self.view sendSubviewToBack:patientButton];
    
    //familyButton
    familyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	familyButton.frame = CGRectMake(0, 0, 318, 214);
	familyButton.showsTouchWhenHighlighted = YES;
	[familyButton setImage:[UIImage imageNamed:@"fam_button_image.png"] forState:UIControlStateNormal];
	[familyButton setImage:[UIImage imageNamed:@"fam_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[familyButton setImage:[UIImage imageNamed:@"fam_button_image_pressed.png"] forState:UIControlStateSelected];
	familyButton.backgroundColor = [UIColor clearColor];
    [familyButton setCenter:CGPointMake(512.0f, 380.0f)];
//    [familyButton setCenter:CGPointMake(512.0f, 380.0f)];
//    [familyButton setCenter:CGPointMake(380.0f, 512.0f)];
    [familyButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	familyButton.enabled = YES;
	familyButton.hidden = NO;
    familyButton.alpha = 0.0;
	[familyButton retain];
//    familyButton.transform = rotateRight;
    
    [self.view addSubview:familyButton];
    [self.view sendSubviewToBack:familyButton];
    
    //caregiverButton
    caregiverButton = [UIButton buttonWithType:UIButtonTypeCustom];
	caregiverButton.frame = CGRectMake(0, 0, 318, 214);
	caregiverButton.showsTouchWhenHighlighted = YES;
	[caregiverButton setImage:[UIImage imageNamed:@"care_button_image.png"] forState:UIControlStateNormal];
	[caregiverButton setImage:[UIImage imageNamed:@"care_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[caregiverButton setImage:[UIImage imageNamed:@"care_button_image_pressed.png"] forState:UIControlStateSelected];
	caregiverButton.backgroundColor = [UIColor clearColor];
    [caregiverButton setCenter:CGPointMake(853.0f, 380.0f)];
//    [caregiverButton setCenter:CGPointMake(171.0f, 380.0f)];
//    [caregiverButton setCenter:CGPointMake(380.0f, 171.0f)];
    [caregiverButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	caregiverButton.enabled = YES;
	caregiverButton.hidden = NO;
    caregiverButton.alpha = 0.0;
	[caregiverButton retain];
//    caregiverButton.transform = rotateRight;
    
    [self.view addSubview:caregiverButton];
    [self.view sendSubviewToBack:caregiverButton];
    
    //tbiEdButton
    tbiEdButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tbiEdButton.frame = CGRectMake(0, 0, 318, 214);
	tbiEdButton.showsTouchWhenHighlighted = YES;
	[tbiEdButton setImage:[UIImage imageNamed:@"learntbi_image3.png"] forState:UIControlStateNormal];
	[tbiEdButton setImage:[UIImage imageNamed:@"learntbi_image_pressed3.png"] forState:UIControlStateHighlighted];
	[tbiEdButton setImage:[UIImage imageNamed:@"learntbi_image_pressed3.png"] forState:UIControlStateSelected];
	tbiEdButton.backgroundColor = [UIColor clearColor];
    [tbiEdButton setCenter:CGPointMake(728.0f, 227.0f)];
//    [tbiEdButton setCenter:CGPointMake(227.0f, 728.0f)];
    [tbiEdButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	tbiEdButton.enabled = YES;
	tbiEdButton.hidden = NO;
    tbiEdButton.alpha = 0.0;
	[tbiEdButton retain];
//    tbiEdButton.transform = rotateRight;
    
    [self.view addSubview:tbiEdButton];
    [self.view sendSubviewToBack:tbiEdButton];
    
    //comingsoonButton
    comingSoonButton = [UIButton buttonWithType:UIButtonTypeCustom];
	comingSoonButton.frame = CGRectMake(0, 0, 318, 214);
	comingSoonButton.showsTouchWhenHighlighted = YES;
	[comingSoonButton setImage:[UIImage imageNamed:@"comingsoon_image.png"] forState:UIControlStateNormal];
	[comingSoonButton setImage:[UIImage imageNamed:@"comingsoon_image_pressed.png"] forState:UIControlStateHighlighted];
	[comingSoonButton setImage:[UIImage imageNamed:@"comingsoon_image_pressed.png"] forState:UIControlStateSelected];
	comingSoonButton.backgroundColor = [UIColor clearColor];
    [comingSoonButton setCenter:CGPointMake(728.0f, 227.0f)]; //sandy this must be shifted to left
//    [comingSoonButton setCenter:CGPointMake(227.0f, 728.0f)]; //sandy this must be shifted to left
    [comingSoonButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	comingSoonButton.enabled = YES;
	comingSoonButton.hidden = NO;
    comingSoonButton.alpha = 0.0;
	[comingSoonButton retain];
//    comingSoonButton.transform = rotateRight;
    
    [self.view addSubview:comingSoonButton];
    [self.view sendSubviewToBack:comingSoonButton];
    
    //satisfactionButton
    satisfactionButton = [UIButton buttonWithType:UIButtonTypeCustom];
	satisfactionButton.frame = CGRectMake(0, 0, 318, 214);
	satisfactionButton.showsTouchWhenHighlighted = YES;
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey.png"] forState:UIControlStateNormal];
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey_pressed.png"] forState:UIControlStateHighlighted];
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey_pressed.png"] forState:UIControlStateSelected];
	satisfactionButton.backgroundColor = [UIColor clearColor];
    [satisfactionButton setCenter:CGPointMake(296.0f, 227.0f)];
//    [satisfactionButton setCenter:CGPointMake(227.0f, 296.0f)];
    [satisfactionButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	satisfactionButton.enabled = YES;
	satisfactionButton.hidden = NO;
    satisfactionButton.alpha = 0.0;
	[satisfactionButton retain];
//    satisfactionButton.transform = rotateRight;
    
    [self.view addSubview:satisfactionButton];
    [self.view sendSubviewToBack:satisfactionButton];
    
    //newsButton
    newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	newsButton.frame = CGRectMake(0, 0, 318, 214);
	newsButton.showsTouchWhenHighlighted = YES;
	[newsButton setImage:[UIImage imageNamed:@"whatsnew_image.png"] forState:UIControlStateNormal];
	[newsButton setImage:[UIImage imageNamed:@"whatsnew_image_pressed.png"] forState:UIControlStateHighlighted];
	[newsButton setImage:[UIImage imageNamed:@"whatsnew_image_pressed.png"] forState:UIControlStateSelected];
	newsButton.backgroundColor = [UIColor clearColor];
    [newsButton setCenter:CGPointMake(296.0f, 521.0f)];
//    [newsButton setCenter:CGPointMake(521.0f, 296.0f)];
    [newsButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	newsButton.enabled = YES;
	newsButton.hidden = NO;
    newsButton.alpha = 0.0;
	[newsButton retain];
//    newsButton.transform = rotateRight;
    
    [self.view addSubview:newsButton];
    [self.view sendSubviewToBack:newsButton];
    
    //clinicButton
    clinicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	clinicButton.frame = CGRectMake(0, 0, 318, 214);
	clinicButton.showsTouchWhenHighlighted = YES;
	[clinicButton setImage:[UIImage imageNamed:@"clinic_image.png"] forState:UIControlStateNormal];
	[clinicButton setImage:[UIImage imageNamed:@"clinic_image_pressed.png"] forState:UIControlStateHighlighted];
	[clinicButton setImage:[UIImage imageNamed:@"clinic_image_pressed.png"] forState:UIControlStateSelected];
	clinicButton.backgroundColor = [UIColor clearColor];
    [clinicButton setCenter:CGPointMake(728.0f, 521.0f)];
//    [clinicButton setCenter:CGPointMake(521.0f, 728.0f)];
    [clinicButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	clinicButton.enabled = YES;
	clinicButton.hidden = NO;
    clinicButton.alpha = 0.0;
	[clinicButton retain];
//    clinicButton.transform = rotateRight;
    
    [self.view addSubview:clinicButton];
    [self.view sendSubviewToBack:clinicButton];
    
    //Doctor Button
    doctorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doctorButton.frame = CGRectMake(0, 0, 318, 214);
	doctorButton.showsTouchWhenHighlighted = YES;
	[doctorButton setImage:[UIImage imageNamed:@"doctor_button_image.png"] forState:UIControlStateNormal];
	[doctorButton setImage:[UIImage imageNamed:@"doctor_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[doctorButton setImage:[UIImage imageNamed:@"doctor_button_image_pressed.png"] forState:UIControlStateSelected];
	doctorButton.backgroundColor = [UIColor clearColor];
    [doctorButton setCenter:CGPointMake(728.0f, 521.0f)];
//    [doctorButton setCenter:CGPointMake(521.0f, 728.0f)];
    [doctorButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	doctorButton.enabled = YES;
	doctorButton.hidden = NO;
    doctorButton.alpha = 0.0;
	[doctorButton retain];
//    doctorButton.transform = rotateRight;
    
    [self.view addSubview:clinicButton];
    [self.view sendSubviewToBack:clinicButton];
    
    agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	agreeButton.frame = CGRectMake(0, 0, 299, 200);
	agreeButton.showsTouchWhenHighlighted = YES;
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image.png"] forState:UIControlStateNormal];
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image_pressed.png"] forState:UIControlStateSelected];
	agreeButton.backgroundColor = [UIColor clearColor];
    [agreeButton setCenter:CGPointMake(760.0f, 580.0f)];
//    [agreeButton setCenter:CGPointMake(580.0f, 760.0f)];
	[agreeButton addTarget:self action:@selector(agreeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	agreeButton.enabled = YES;
	agreeButton.hidden = NO;
    agreeButton.alpha = 0.0;
	[agreeButton retain];
//    agreeButton.transform = rotateRight;
    [self.view addSubview:agreeButton];
    
    disagreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	disagreeButton.frame = CGRectMake(0, 0, 299, 200);
	disagreeButton.showsTouchWhenHighlighted = YES;
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image.png"] forState:UIControlStateNormal];
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image_pressed2.png"] forState:UIControlStateHighlighted];
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image_pressed2.png"] forState:UIControlStateSelected];
	disagreeButton.backgroundColor = [UIColor clearColor];
    [disagreeButton setCenter:CGPointMake(264.0f, 580.0f)];
//    [disagreeButton setCenter:CGPointMake(580.0f, 264.0f)];
	[disagreeButton addTarget:self action:@selector(disagreeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	disagreeButton.enabled = YES;
	disagreeButton.hidden = NO;
    disagreeButton.alpha = 0.0;
	[disagreeButton retain];
//    disagreeButton.transform = rotateRight;
    [self.view addSubview:disagreeButton];
    
    ////// Additional Buttons
    //beginSurveyButton
    beginSurveyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	beginSurveyButton.frame = CGRectMake(0, 0, 231, 214);
	beginSurveyButton.showsTouchWhenHighlighted = YES;
	[beginSurveyButton setImage:[UIImage imageNamed:@"begin.png"] forState:UIControlStateNormal];
	[beginSurveyButton setImage:[UIImage imageNamed:@"begin_pressed.png"] forState:UIControlStateHighlighted];
	[beginSurveyButton setImage:[UIImage imageNamed:@"begin_pressed.png"] forState:UIControlStateSelected];
	beginSurveyButton.backgroundColor = [UIColor clearColor];
    [beginSurveyButton setCenter:CGPointMake(200.0f, 600.0f)];
//    [beginSurveyButton setCenter:CGPointMake(600.0f, 200.0f)];
    [beginSurveyButton addTarget:self action:@selector(beginSatisfactionSurvey:) forControlEvents:UIControlEventTouchUpInside];
	beginSurveyButton.enabled = YES;
	beginSurveyButton.hidden = NO;
    beginSurveyButton.alpha = 0.0;
	[beginSurveyButton retain];
//    beginSurveyButton.transform = rotateRight;
    
    [self.view addSubview:beginSurveyButton];
    [self.view sendSubviewToBack:beginSurveyButton];
    
    //returnToMenuButton
    returnToMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnToMenuButton.frame = CGRectMake(0, 0, 90, 85);
	returnToMenuButton.showsTouchWhenHighlighted = YES;
	[returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml.png"] forState:UIControlStateNormal];
	[returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateHighlighted];
	[returnToMenuButton setImage:[UIImage imageNamed:@"back2menu_button_image_sml_pressed.png"] forState:UIControlStateSelected];
	returnToMenuButton.backgroundColor = [UIColor clearColor];
    [returnToMenuButton setCenter:CGPointMake(300.0f, 625.0f)];
//    [returnToMenuButton setCenter:CGPointMake(725.0f, 500.0f)];
    [returnToMenuButton addTarget:self action:@selector(returnToMenu) forControlEvents:UIControlEventTouchUpInside];
	returnToMenuButton.enabled = YES;
	returnToMenuButton.hidden = NO;
    returnToMenuButton.alpha = 0.0;
	[returnToMenuButton retain];
//    returnToMenuButton.transform = rotateRight;
    
    [self.view addSubview:returnToMenuButton];
    [self.view sendSubviewToBack:returnToMenuButton];
    
    //    [self.view bringSubviewToFront:tbvc.view]; // Uncommentme
    
    if (skipToMainMenu) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicSurveyPages];
//        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
        [self fadeMenuItemsIn];

    } else if (skipToSatisfactionSurvey) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicSurveyPages];
//        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
        
    } else if (skipToEducationModule) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicSurveyPages];
//        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
    } else if (skipToPhysicianDetail) {
        
//        [self voiceassistButtonPressed:self];
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicSurveyPages];
//        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
//        if (isFirstVisit) {
//            [self fadePhysicianModuleIn];
//        } else {
//            [self promptForAdditionalInfoOnFollowUpVisit];
        // First and Follow-Up Visit
        [self launchDynamicSurveyWithProviderAndSubclinicTest];
//        }
    
    } else {
        
        if (skipToSplashIntro) {
            [self setDefaultPhysician];
            [self setDefaultSubClinic];
            [self initializePhysicianDetailView];
            [self initializeDynamicSurveyPages];
//            [self initializeDynamicEducationModule];
            [self updateMiniDemoSettings];
        }
        // Not skipping anywhere, run as usual
        [self.view bringSubviewToFront:yesButton];
        [self.view bringSubviewToFront:noButton];
        [self.view bringSubviewToFront:readAloudLabel];
//        [self.view bringSubviewToFront:presurveyIntroLabel]; //rjl 7/8/14
        
        [UIView beginAnimations:@"fadeSplashOut" context:nil];
        {
            [UIView	setAnimationDuration:1.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //		tbvc.view.alpha = 1.0;
            //        splashImageViewC.alpha = 0.0;
            
            //        resourceBack.alpha = 1.0; // Uncommentme
            yesButton.alpha = 1.0;
            noButton.alpha = 1.0;
            
            readAloudLabel.alpha = 1.0;
//            presurveyIntroLabel.alpha = 1.0; //rjl 7/8/14
            
        }
        [UIView commitAnimations];
    }
    // rjl 7/8/14
    //[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:tbvc];
    //[self showMasterButtonOverlay];
    //[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
//    @try { //rjl 7/8/14
//        [self showMasterButtonOverlay];
//        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton]; //rjl 7/8/14
//    }
//    @catch(NSException *ne){
//        NSLog(@"WRViewController.removeSplashWindow() ERROR");
//    }
	
	[self.view sendSubviewToBack:splashSpinner];
    
    //    [self.view bringSubviewToFront:modalViewController.view];
    //    [self.view bringSubviewToFront:newViewController.view];
    
    
	
	[theTimer release];
	theTimer = nil;
}

- (void)setDefaultPhysician {
    [self storeAttendingPhysicianSettingsForPhysicianName:[[DynamicContent getNewClinicianNames] objectAtIndex:0]];
}

- (void)setDefaultSubClinic {
    [masterViewController setSubClinicNameTo:[masterViewController.subClinicNames objectAtIndex:1]];
}

- (void)createBadgeOnSatisfactionSurveyButton {
    NSLog(@"WRViewController.createBadgeOnSatisfactionSurveyButton()");

    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //Create a label (width/height not important at this stage)
    badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    badgeLabel.text = [NSString stringWithFormat:@"%d",tbvc.surveyItemsRemaining];
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:30];
    badgeLabel.backgroundColor = [UIColor clearColor];
    [badgeLabel sizeToFit];
    
//    CGRect labelFrame = badgeLabel.frame;
    
    //Here we create a UIImage that is resizable, but will not resize the areas concerned with the cap insets you've defined
//    UIImage *badgeImage = [[UIImage imageNamed:@"red_badge.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_badge.png"]];
    badgeImageView.frame = CGRectMake(0, 0, 57, 58);

    
    
//    badgeImageView.contentMode = UIViewContentModeScaleToFill;
//    badgeImageView.backgroundColor = [UIColor clearColor];
    
//    labelFrame.size.width += 5; //This is the 'padding' on the right and left (added together)
    //If your badge edges are completely circular then you don't want to change the height, but if they're not then go ahead in the same way with the width. If your badge has a static height, you'll need to make sure the font size doesn't exceed this height; better start off with a small font-size
    
//    badgeImageView.frame = labelFrame; //The badge is now the right width with padding taken into account
    
    //Center the label on the badge image view
    badgeLabel.center = CGPointMake(badgeImageView.frame.size.width/2, badgeImageView.frame.size.height/2);
    
    //Finally we add the label to the badge image view
    
    
    [badgeImageView addSubview:badgeLabel];
    //Add your badge to the main view
    
//    badgeImageView.transform = rotateRight;
    [badgeImageView setCenter:CGPointMake(165.0f, 115.0f)];
//    [badgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
    
//    [satisfactionButton setCenter:CGPointMake(227.0f, 296.0f)];
    
    [self.view addSubview:badgeImageView];
    
    badgeCreated = YES;
    
//    
//    [badgeImageView release];
//    [badgeLabel release];
}

- (void)createBadgeOnClinicInfoButton {
    NSLog(@"WRViewController.createBadgeOnClinicInfoButton()");

    if (dynamicEdModuleCompleted) {
        clinicButton.enabled = NO;
        
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
//        [clinicButton setCenter:CGPointMake(521.0f, 728.0f)]; (x-origin - 112, y-origin - 131)
        
        completedBadgeImageViewDynEdModule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        completedBadgeImageViewDynEdModule.frame = CGRectMake(0, 0, 57, 58);
//        completedBadgeImageViewDynEdModule.transform = rotateRight;
        [completedBadgeImageViewDynEdModule setCenter:CGPointMake(597.0f, 409.0f)];
//        [completedBadgeImageViewDynEdModule setCenter:CGPointMake(409.0f, 597.0f)];
        completedBadgeImageViewDynEdModule.alpha = 0.0;
        
        [self.view addSubview:completedBadgeImageViewDynEdModule];
        
//        finalBadgeCreated = YES;
        
//    } else if (satisfactionSurveyInProgress) {
//        badgeLabel.text = [NSString stringWithFormat:@"%d",tbvc.surveyItemsRemaining];
    }
}

- (void)createBadgeOnEdModule:(int)index {
        float verticalPosition = 395.0f;
        if (index > 0){
            float offset = index * 85.0f;
            verticalPosition += offset;
        }
//        if (index == 2)
//            verticalPosition = 480.0f;
        
        completedBadgeImageViewWhatsNewModule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        completedBadgeImageViewWhatsNewModule.frame = CGRectMake(0, 0, 57, 58);
//        completedBadgeImageViewWhatsNewModule.transform = rotateRight;
        [completedBadgeImageViewWhatsNewModule setCenter:CGPointMake(730.0f, verticalPosition)];
        completedBadgeImageViewWhatsNewModule.alpha = 1.0;
        [[DynamicContent getEdModulePicker].view addSubview:completedBadgeImageViewWhatsNewModule];
        //[self.view addSubview:completedBadgeImageViewWhatsNewModule];
        
        //        finalBadgeCreated = YES;
        
        //    } else if (satisfactionSurveyInProgress) {
        //        badgeLabel.text = [NSString stringWithFormat:@"%d",tbvc.surveyItemsRemaining];
    
}


- (void)createBadgeOnWhatsNewButton {
    if (whatsNewModuleCompleted) {
        newsButton.enabled = NO;
        
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
        //        [newsButton setCenter:CGPointMake(521.0f, 296.0f)]; (x-origin - 112, y-origin - 131)
        
        completedBadgeImageViewWhatsNewModule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        completedBadgeImageViewWhatsNewModule.frame = CGRectMake(0, 0, 57, 58);
//        completedBadgeImageViewWhatsNewModule.transform = rotateRight;
        [completedBadgeImageViewWhatsNewModule setCenter:CGPointMake(165.0f, 409.0f)];
//        [completedBadgeImageViewWhatsNewModule setCenter:CGPointMake(409.0f, 165.0f)];
        completedBadgeImageViewWhatsNewModule.alpha = 0.0;

        [self.view addSubview:completedBadgeImageViewWhatsNewModule];
        
        //        finalBadgeCreated = YES;
        
        //    } else if (satisfactionSurveyInProgress) {
        //        badgeLabel.text = [NSString stringWithFormat:@"%d",tbvc.surveyItemsRemaining];
    }
}

- (void)updateBadgeOnSatisfactionSurveyButton {
    NSLog(@"WRViewController.updateBadgeOnSatisfactionSurveyButton()");

    if (satisfactionSurveyCompleted) {
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
        badgeLabel.alpha = 0.0;
        
        [badgeImageView release];
        badgeImageView = nil;
        
        badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        badgeImageView.frame = CGRectMake(0, 0, 57, 58);
//        badgeImageView.transform = rotateRight;
        [badgeImageView setCenter:CGPointMake(165.0f, 115.0f)];
//        [badgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
        badgeImageView.alpha = 0.0;
        
        [self.view addSubview:badgeImageView];
        
        completedBadgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        completedBadgeImageView.frame = CGRectMake(0, 0, 57, 58);
//        completedBadgeImageView.transform = rotateRight;
        [completedBadgeImageView setCenter:CGPointMake(165.0f, 115.0f)];
//        [completedBadgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
        completedBadgeImageView.alpha = 0.0;
        
        [self.view addSubview:completedBadgeImageView];
        
        //finalBadgeCreated = YES;
        
    } else if (satisfactionSurveyInProgress) {
        badgeLabel.text = [NSString stringWithFormat:@"%d",tbvc.surveyItemsRemaining];
    }
}

- (void)agreeButtonPressed {
    NSLog(@"Agree button pressed");
//    [tbvc sayAgreeLonger];
    
    [self fadeToLastSurveyPrompt:self];
}

- (void)disagreeButtonPressed {
    NSLog(@"Disagree button pressed");
    [tbvc sayDisagree];
    
    satisfactionButton.enabled = NO;
    satisfactionSurveyDeclined = YES;
    
//    [self returnToMenu];
//    [self showReturnTabletView];
    
}

- (void)clinicButtonOptionPressed:(id)sender {
    if (sender == doctorButton) {
        
    } else if (sender == pscButton) {
        
    } else {
        
    }
}

- (void)voiceassistButtonPressed:(id)sender {
    NSLog(@"WRViewController.voiceassistButtonPressed()");

    if (tbvc.speakItemsAloud) {
		NSLog(@"voiceassistButton Pressed - turning voice OFF");
        
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateNormal];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
        [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
        
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateNormal];
         
         [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
        
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
        
        [mainTTSPlayer stopPlayer];
        
        [tbvc turnVoiceOff:sender];
        voiceAssistButton.selected = YES;
        edModule.speakItemsAloud = NO;
        physicianModule.speakItemsAloud = NO;
        dynamicEdModule.speakItemsAloud = NO;
        mainTTSPlayer.speakItemsAloud = NO;
        dynamicSubclinicEdModule.speakItemsAloud = NO;
        dynamicWhatsNewModule.speakItemsAloud = NO;
        dynamicSurveyModule.speakItemsAloud = NO;
		
	} else  {
        BOOL shouldActivateSound;
        
        if (settingsVC.headsetPluggedIn) {
            shouldActivateSound = YES;
        } else {
            if (forceToDemoMode) {
                shouldActivateSound = YES;
            } else {
                [self checkForHeadset];
            }
        }
        
        if (shouldActivateSound) {
            NSLog(@"voiceassistButton Pressed - turning voice ON");
            
            [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_on.png"] forState:UIControlStateNormal];
            [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
            [voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
            
            [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_on.png"] forState:UIControlStateNormal];
            
            [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
            
            [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] voiceAssistButton] setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
            
            [tbvc turnVoiceOn:sender];
            voiceAssistButton.selected = NO;
            edModule.speakItemsAloud = YES;
            physicianModule.speakItemsAloud = YES;
            dynamicEdModule.speakItemsAloud = YES;
            mainTTSPlayer.speakItemsAloud = YES;
            dynamicSubclinicEdModule.speakItemsAloud = YES;
            dynamicWhatsNewModule.speakItemsAloud = YES;
            dynamicSurveyModule.speakItemsAloud = YES;
        }
    }
    
    
}

- (void)yesNoPressed:(id)sender {
    
    if (sender == yesButton) {
        BOOL shouldActivateSound;
        
        if (settingsVC.headsetPluggedIn) {
            NSLog(@"yesButton Pressed - keeping voice ON");
            shouldActivateSound = YES;
        } else {
            if (forceToDemoMode) {
                shouldActivateSound = YES;
            } else {
                [self checkForHeadset];
            }
        }
        if (shouldActivateSound) {
            [tbvc sayOK];
            [tbvc turnVoiceOn:sender];
            edModule.speakItemsAloud = YES;
            physicianModule.speakItemsAloud = YES;
            dynamicEdModule.speakItemsAloud = YES;
            mainTTSPlayer.speakItemsAloud = YES;
        }
        
	} else if (sender == noButton) {
        
        [self voiceassistButtonPressed:self];
        
        [tbvc turnVoiceOff:sender];
        edModule.speakItemsAloud = NO;
        physicianModule.speakItemsAloud = NO;
        dynamicEdModule.speakItemsAloud = NO;
        mainTTSPlayer.speakItemsAloud = NO;
    }
    
    [self slideYesNoOutAndRespondentTypeButtonsIn];
    
}

- (void)checkForHeadset {
    [settingsVC checkthatHeadsetIsPluggedIn];
}

- (void)fontsizeButtonPressed:(id)sender {
//    [self showComingSoonAlert];
    [tbvc cycleFontSizeForAllLabels];
    [dynamicSurveyModule cycleFontSizeForAllLabels];
//    [dynamicSubclinicEdModule cycleFontSizeForAllLabels];
//    [self updateAllSatisfactionLabelItems0a];
    NSLog(@"WRViewController.fontsizeButtonPressed() - current font size: %d",tbvc.currentFontSize);
}
////sandy still need to add this method but not sure if it will work
//- (void)cycleFontSizeForAllLabels {
//    CGFloat newFontSize,currentFontSize;
//    
//    // 1 = avenir medium 30
//    if (currentFontSize == 1) {
//        newFontSize = 40.0f;
//        currentFontSize = 2;
//    } else if (currentFontSize == 2) {
//        newFontSize = 50.0f;
//        currentFontSize = 3;
//    } else {
//        newFontSize = 30.0f;
//        currentFontSize = 1;
//    }
////
//    for (SwitchedImageViewController *switchedController in newChildControllers)
//    {
//        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
//        //sandy added prompt resizing
//        switchedController.currentPromptLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
//   }
//}

- (void)respondentButtonPressed:(id)sender {
    if (!runningAppInDemoMode)
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInRevealSettingsButton]; //7/2/14
    
    if (sender == patientButton) {
        [tbvc setRespondentToPatient:sender];
    } else if (sender == familyButton) {
        [tbvc setRespondentToFamily:sender];
    } else if (sender == caregiverButton) {
        [tbvc setRespondentToCaregiver:sender];
    }
    
    if ([tbvc.respondentType isEqualToString:@"patient"]) {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    } else if ([tbvc.respondentType isEqualToString:@"family"]) {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    } else {
        surveyCompleteLabel.text = @"Thank you for completing the satisfaction survey.\n\nIn five seconds, you will be returned to the main menu.";
    }
    totalSlidesInThisSection = [DynamicContent getPreTreatmentPageCount];
    [self slideRespondentsOut];
    [self updateMiniDemoSettings];
    
    [self launchDynamicSurveyWithProviderAndSubclinicTest];
    
//    if (isFirstVisit) {
//        [self fadePhysicianModuleIn];
//    } else {
//        [self promptForAdditionalInfoOnFollowUpVisit];
//    }
    
}

- (void)promptForAdditionalInfoOnFollowUpVisit {
    
//    if (tbvc.speakItemsAloud) {
//        NSString *currentSubclinicSoundfilename;
//        if ([currentSpecialtyClinicName isEqualToString:@"Acupuncture"]) {
//            currentSubclinicSoundfilename = @"specialty_clinic_acupuncture";
//        } else if ([currentSpecialtyClinicName isEqualToString:@"Pain"]) {
//            currentSubclinicSoundfilename = @"specialty_clinic_pain";
//        } else if ([currentSpecialtyClinicName isEqualToString:@"PNS"]) {
//            currentSubclinicSoundfilename = @"specialty_clinic_pns";
//        } else if ([currentSpecialtyClinicName isEqualToString:@"EMG"]) {
//            currentSubclinicSoundfilename = @"specialty_clinic_emg";
//        }
//        [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"wantExtraInfo1_followup",currentSubclinicSoundfilename,@"wantExtraInfo2_followup",@"wantExtraInfo3_followup",@"wantExtraInfo4_followup", nil]];
//    }

    UIStoryboard *yesNoStoryboard = [UIStoryboard storyboardWithName:@"survey_yes_no_template" bundle:[NSBundle mainBundle]];
    
//    wantExtraInfo = [[SwitchedImageViewController alloc] init];
    wantExtraInfo = [yesNoStoryboard instantiateViewControllerWithIdentifier:@"0"];
    [wantExtraInfo retain];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = wantExtraInfo;
    
    wantExtraInfo.currentSurveyPageType = kYesNo;
    wantExtraInfo.surveyPageIndex = 0;
    wantExtraInfo.delegate = self;
    wantExtraInfo.isSurveyPage = YES;
    
    wantExtraInfo.newYesNoText = [NSString stringWithFormat:@"Thank you for returning to the %@ Clinic.  Would you like additional information about your treatment provider and about today's visit?", [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
    wantExtraInfo.extraYesText = @"Yes, I would like additional information.";
    wantExtraInfo.extraNoText = @"No, I do not need additional information.";
    
    wantExtraInfo.view.frame = CGRectMake(0, 0, 1024, 768);
    wantExtraInfo.view.alpha = 0.0;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    wantExtraInfo.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [wantExtraInfo.view setCenter:CGPointMake(512.0f, 400.0f)];
//    [wantExtraInfo.view setCenter:CGPointMake(400.0f, 512.0f)];
//    wantExtraInfo.view.transform = rotateRight;
//    [self presentModalViewController:wantExtraInfo animated:YES];
    [self.view addSubview:wantExtraInfo.view];

//    [wantExtraInfo release];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        wantExtraInfo.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    checkingForAdditionalInfo = YES;
    checkingForMiniSurvey = NO;

}

- (void)promptForMiniSurvey {
    NSLog(@"WRViewController.promptForMiniSurvey()");

    UIStoryboard *yesNoStoryboard = [UIStoryboard storyboardWithName:@"survey_yes_no_template" bundle:[NSBundle mainBundle]];
    
    wantMiniSurvey = [yesNoStoryboard instantiateViewControllerWithIdentifier:@"0"];
    [wantMiniSurvey retain];
    
    wantMiniSurvey.currentSurveyPageType = kYesNo;
    wantMiniSurvey.surveyPageIndex = 0;
    wantMiniSurvey.delegate = self;
    wantMiniSurvey.isSurveyPage = YES;
    
    wantMiniSurvey.newYesNoText = [NSString stringWithFormat:@"Okay, as it will be a few minutes until you are seen by your provider, would you be willing to answer a few questions that will help us to better meet your ongoing care goals and needs?", [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName]];
    wantMiniSurvey.extraYesText = @"Yes, I can answer a few questions.";
    wantMiniSurvey.extraNoText = @"No, I do not wish to answer any questions.";
    
    wantMiniSurvey.view.frame = CGRectMake(0, 0, 1024, 768);
    wantMiniSurvey.view.alpha = 0.0;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//    wantMiniSurvey.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [wantMiniSurvey.view setCenter:CGPointMake(512.0f, 400.0f)];
//    [wantMiniSurvey.view setCenter:CGPointMake(400.0f, 512.0f)];
//    wantMiniSurvey.view.transform = rotateRight;
    wantMiniSurvey.view.alpha = 0.0;
//    [self presentModalViewController:wantMiniSurvey animated:YES];
    [self.view addSubview:wantMiniSurvey.view];
//    [wantMiniSurvey release];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.7];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

        wantMiniSurvey.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    checkingForMiniSurvey = YES;
    checkingForAdditionalInfo = NO;
    
}

- (void)transitionToSatisfactionSurvey {
    
    inTreatmentIntermission = NO;
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] readyForAppointmentButton] setEnabled:NO];
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] standardPageButtonOverlay] readyForAppointmentButton] setAlpha:0.6];
    
    [self resetProgressBar];
    [self addToTotalSlides:dynamicSurveyModule.numberOfPostTreatmentItems];
    int satisfactionSurveyItems;
    
    if ([tbvc.respondentType isEqualToString:@"patient"]) {
        satisfactionSurveyItems = [tbvc.newChildControllers count] - 8;
    } else if ([tbvc.respondentType isEqualToString:@"family"]) {
        satisfactionSurveyItems = [tbvc.newChildControllers count] - 4;
    } else {
        satisfactionSurveyItems = [tbvc.newChildControllers count];
    }
    [self addToTotalSlides:satisfactionSurveyItems];
    
    completedProviderSession = YES;
    [self launchDynamicSurveyWithPreSatisfactionTransition];
}

- (void)promptForFinalSurvey {
    
    if (currentModalVC) {
//        [currentModalVC dismissModalViewControllerAnimated:YES];
//        float angle =  270 * M_PI  / 180;
//        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
//        self.view.transform = rotateRight;
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.frame = ssIntroFrame;
            currentModalVC.view.alpha = 0.0;
            
            
        }
        [UIView commitAnimations];
    }
    
    UIStoryboard *yesNoStoryboard = [UIStoryboard storyboardWithName:@"survey_yes_no_template" bundle:[NSBundle mainBundle]];
    
    wantFinalSurvey = [yesNoStoryboard instantiateViewControllerWithIdentifier:@"0"];
    [wantFinalSurvey retain];
    
    wantFinalSurvey.currentSurveyPageType = kYesNo;
    wantFinalSurvey.surveyPageIndex = 0;
    wantFinalSurvey.delegate = self;
    wantFinalSurvey.isSurveyPage = YES;
    
    wantFinalSurvey.newYesNoText = [NSString stringWithFormat:@"Now that you've completed your clinic visit, would you mind answering a few questions?"];
    wantFinalSurvey.extraYesText = @"Yes, I can answer a few questions.";
    wantFinalSurvey.extraNoText = @"No, I do not wish to answer any questions.";
    
    wantFinalSurvey.view.frame = CGRectMake(0, 0, 1024, 768);
    wantFinalSurvey.view.alpha = 0.0;
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    //    wantMiniSurvey.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [wantFinalSurvey.view setCenter:CGPointMake(512.0f, 400.0f)];
//    [wantFinalSurvey.view setCenter:CGPointMake(400.0f, 512.0f)];
//    wantFinalSurvey.view.transform = rotateRight;
    wantFinalSurvey.view.alpha = 0.0;
    //    [self presentModalViewController:wantMiniSurvey animated:YES];
    [self.view addSubview:wantFinalSurvey.view];
    //    [wantMiniSurvey release];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.7];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        wantFinalSurvey.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    checkingForMiniSurvey = NO;
    checkingForAdditionalInfo = NO;
    
    checkingForFinalSurvey = YES;
    
}

- (void)modalYesPressedInSender:(UIViewController *)senderVC {
//    [currentModalVC dismissModalViewControllerAnimated:YES];
     NSLog(@"WRViewController.modelYesPressedInSender()");
    
    if (checkingForFinalSurvey) {
        NSLog(@"Giving additional information...");
        checkingForFinalSurvey = NO;
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        
//        [UIView beginAnimations:nil context:nil];
//        {
//            [UIView	setAnimationDuration:0.7];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//            
//            senderVC.view.alpha = 0.0;
//            
//        }
//        [UIView commitAnimations];
        
        [self resumeAppAfterTreatmentIntermission];
        [self launchDynamicSurveyWithPreSatisfactionTransition];
        NSLog(@"Todays goal: %@", dynamicSurveyModule.todaysGoal);
        
    } else if (checkingForAdditionalInfo) {
        NSLog(@"Giving additional information...");
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.7];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            senderVC.view.alpha = 0.0;
            
        }
        [UIView commitAnimations];
        [self fadePhysicianModuleIn];
        
    } else if (checkingForMiniSurvey) {
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        
        startAtMiniSurvey = NO;
        [self launchSatisfactionSurvey];
        
        NSLog(@"Skipping to the mini Survey");
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.7];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            senderVC.view.alpha = 0.0;
            
        }
        [UIView commitAnimations];
    }
}

- (void)modalNoPressedInSender:(UIViewController *)senderVC {
//    [currentModalVC dismissModalViewControllerAnimated:YES];
    NSLog(@"WRViewController.modelNoPressedInSender()");
    
    if (checkingForFinalSurvey) {
        checkingForFinalSurvey = NO;
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.7];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            senderVC.view.alpha = 0.0;
            
        }
        [UIView commitAnimations];
        [self showReturnTabletView];
        
    } else if (checkingForAdditionalInfo) {
        
        NSLog(@"No additional info wanted...");
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        
        dynamicEdModuleCompleted = YES;
        physicianModuleCompleted = YES;
        
        [self createBadgeOnClinicInfoButton];
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.7];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            senderVC.view.alpha = 0.0;
            
        }
        [UIView commitAnimations];
        
        [self launchDynamicSurveySkipToChooseModule];
        
    } else if (checkingForMiniSurvey) {
        
        checkingForMiniSurvey = NO;
        checkingForAdditionalInfo = NO;
        NSLog(@"No mini survey wanted, returning to main menu...");
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.7];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            senderVC.view.alpha = 0.0;
            
        }
        [UIView commitAnimations];
        
        [self returnToMenu];
    }
}

- (void)skipToMiniSurvey {
    NSLog(@"Skipping to the mini survey prompt...");
    [self promptForMiniSurvey];
}

#pragma mark - TBI Education Module Methods

- (void)setUpEducationModuleForFirstTime {
    NSLog(@"WRViewController.setUpEducationModuleForFirstTime()");
    if (!runningAppInDemoMode)
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu]; //rjl 6/29/14

    //        [self showComingSoonAlert];
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    edModule.view.alpha = 0.0;

    [self.view bringSubviewToFront:edModule.view];
    
//    [self.view bringSubviewToFront:surveyResourceBack];
    
//    [self.view bringSubviewToFront:nextEdItemButton];
//    [self.view bringSubviewToFront:previousEdItemButton];
    
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
//    [self.view bringSubviewToFront:returnToMenuButton];
    
    completedBadgeImageViewEdModule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
    completedBadgeImageViewEdModule.frame = CGRectMake(115, 700, 58, 58);
    completedBadgeImageViewEdModule.alpha = 0.0;
//    completedBadgeImageViewEdModule.transform = rotateRight;
    [completedBadgeImageViewEdModule setCenter:CGPointMake(600.0f, 115.0f)];
//    [completedBadgeImageViewEdModule setCenter:CGPointMake(115.0f, 600.0f)];
    [self.view addSubview:completedBadgeImageViewEdModule];
    [self.view sendSubviewToBack:completedBadgeImageViewEdModule];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        edModule.view.alpha = 1.0;
//        nextEdItemButton.alpha = 1.0;
//        previousEdItemButton.alpha = 1.0;
//        
//        surveyResourceBack.alpha = 1.0;
//        returnToMenuButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    educationModuleInProgress = YES;
    //sandy 10-15-14
    //TBD add code to indicate that this module was started in the db
    NSString* addToSelfGuideStatus  = @"TBIModStart";
    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
    //[mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
    NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
    NSLog(@"WRViewController.setUpEducationModuleForFirstTime() existing SelfGuideSting%@",existingSelfGuideString);
    int count = [mySelfGuideStatusArray count];
    for (int i = 0; i < count; i++)
        NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
    NSString *appendedSelfGuideStatusString;
    appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
    [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
    [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
    RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
    [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
    
}

- (void)reshowEducationModule {
    //        [self showComingSoonAlert];
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    edModule.view.alpha = 0.0;
    
    [self.view bringSubviewToFront:edModule.view];
    
//    [self.view bringSubviewToFront:surveyResourceBack];
//    
//    [self.view bringSubviewToFront:nextEdItemButton];
//    [self.view bringSubviewToFront:previousEdItemButton];
//    
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
//    [self.view bringSubviewToFront:returnToMenuButton];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
//        edModule.view.alpha = 1.0;
//        nextEdItemButton.alpha = 1.0;
//        previousEdItemButton.alpha = 1.0;
//        
//        surveyResourceBack.alpha = 1.0;
//        returnToMenuButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)showEducationModuleIntro {
    NSLog(@"WRViewController.showEducationModuleIntro()");
    if (!runningAppInDemoMode)
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu]; //rjl 6/29/14
    //sandy 10-15-14
    //TBD add code to indicate that this module was started in the db
    // NSString* addToSelfGuideStatus  = "TBIModStart";

    [self hideMasterButtonOverlay];
    
    //    beginSurveyButton.alpha = 0.0;
    //    tbvc.view.alpha = 0.0;
    //    [self.view bringSubviewToFront:tbvc.view];
    
    //    [self.view bringSubviewToFront:surveyResourceBack];
    //    [self.view bringSubviewToFront:nextSurveyItemButton];
    //    [self.view bringSubviewToFront:previousSurveyItemButton];
    //    [self.view bringSubviewToFront:voiceAssistButton];
    //    [self.view bringSubviewToFront:fontsizeButton];
    //    [self.view bringSubviewToFront:returnToMenuButton];
    
    allWhiteBack.alpha = 0.0;
    
    //    [self.view bringSubviewToFront:splashImageViewC];
    [self.view bringSubviewToFront:allWhiteBack];
    //    [self.view bringSubviewToFront:beginSurveyButton];
    [self.view bringSubviewToFront:edModuleIntroLabel];
    [self.view bringSubviewToFront:playMovieIcon];
    
    [self.view bringSubviewToFront:nextEdItemButton];
    
    initialSettingsLabel.text = @"Learn about TBI and the Brain";
    [initialSettingsLabel setCenter:CGPointMake(250.0f, 100.0f)];
    [taperedWhiteLine setCenter:CGPointMake(250.0f, 200.0f)];
    initialSettingsLabel.alpha = 0.0;
    taperedWhiteLine.alpha = 0.0;
    nextSettingsButton.alpha = 0.0;
    [self.view bringSubviewToFront:initialSettingsLabel];
    [self.view bringSubviewToFront:taperedWhiteLine];
    
    
    //    [self.view bringSubviewToFront:aWebView];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewC.alpha = 1.0;
        allWhiteBack.alpha = 1.0;
        
        //        beginSurveyButton.alpha = 1.0;
        
        nextEdItemButton.alpha = 1.0;
        
        edModuleIntroLabel.alpha = 1.0;
        
        initialSettingsLabel.alpha = 1.0;
        taperedWhiteLine.alpha = 1.0;
        
        playMovieIcon.alpha = 1.0;
        nextSettingsButton.alpha = 0.0;
		
	}
	[UIView commitAnimations];
    
    [edModule sayTBIEdModuleIntro];
}

//- (void)fadeToEducationModuleStart:(id)sender {
//
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//
//        //        splashImageViewC.alpha = 1.0;
//        allWhiteBack.alpha = 1.0;
//
//        //        beginSurveyButton.alpha = 1.0;
//
//        nextEdItemButton.alpha = 1.0;
//
//        edModuleIntroLabel.alpha = 1.0;
//
//        initialSettingsLabel.alpha = 1.0;
//        taperedWhiteLine.alpha = 1.0;
//
//        playMovieIcon.alpha = 1.0;
//
//	}
//	[UIView commitAnimations];
//
//}

- (void)beginEducationModule:(id)sender {
    
    NSLog(@"WRViewController.beginEducationModule()");
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:edModule];
    [self showMasterButtonOverlay];
    @try {
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
        //    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideMiniDemoMenu]; //rjl 6/26/14
//        [[[AppDelegate_Pad sharedAppDelegate] miniDemoVC] menuButtonPressed];  //rjl 6/26/14
    }
    @catch(NSException *ne){
        NSLog(@"WRViewController.beginEducationModule() ERROR");
    }

    

    [edModule sayFirstTBIItem];
    
    [nextEdItemButton removeTarget:self action:@selector(beginEducationModule:) forControlEvents:UIControlEventTouchUpInside];
    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    
    //    if (satisfactionSurveyInProgress) {
    
    edModule.view.alpha = 0.0;
    surveyResourceBack.alpha = 0.0;
    previousEdItemButton.alpha = 0.0;
    voiceAssistButton.alpha = 0.0;
    fontsizeButton.alpha = 0.0;
//    returnToMenuButton.alpha = 0.0;
    [edModule.view setCenter:CGPointMake(380.0f, 250.0f)];
    [self.view bringSubviewToFront:edModule.view];
//    [self.view bringSubviewToFront:surveyResourceBack];
//    [self.view bringSubviewToFront:nextEdItemButton];
//    [self.view bringSubviewToFront:previousEdItemButton];
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
//    [self.view bringSubviewToFront:returnToMenuButton];
    //    }
    
    //    CGRect ssIntroFrame = splashImageViewC.frame;
    //    ssIntroFrame.origin.y = 2200;
    //    CGRect ssIntroLabelFrame = surveyIntroLabel.frame;
    //    ssIntroLabelFrame.origin.x = -1000;
    //    CGRect ssCubeFrame = aWebView.frame;
    //    ssCubeFrame.origin.y = -600;
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        edModule.view.alpha = 1.0;
//        surveyResourceBack.alpha = 1.0;
//        nextEdItemButton.alpha = 1.0;
//        previousEdItemButton.alpha = 1.0;
//        voiceAssistButton.alpha = 1.0;
//        fontsizeButton.alpha = 1.0;
//        returnToMenuButton.alpha = 1.0;
        
        playMovieIcon.alpha = 0.0;
        allWhiteBack.alpha = 0.0;
        initialSettingsLabel.alpha = 0.0;
        taperedWhiteLine.alpha = 0.0;
        edModuleIntroLabel.alpha = 0.0;
        
		
	}
	[UIView commitAnimations];
    
    //    if (!satisfactionSurveyInProgress) {
    //        [tbvc sayFirstItem];
    //    }
    
    //    satisfactionSurveyInProgress = YES;
    
    [self updateMiniDemoSettings];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(completeBeginEducationModule:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)completeBeginEducationModule:(NSTimer*)theTimer {
    NSLog(@"WRViewController.completingBeginEducationModule()");

    [self.view sendSubviewToBack:playMovieIcon];
    [self.view sendSubviewToBack:allWhiteBack];
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
    [self.view sendSubviewToBack:edModuleIntroLabel];
    
    
    [theTimer release];
	theTimer = nil;
}

- (void)launchEducationModule {
    NSLog(@"WRViewController.launchEducationModule()");
    if (educationModuleInProgress) {
        [self reshowEducationModule];
    } else {
        [self setUpEducationModuleForFirstTime];
        [self showEducationModuleIntro];
    }
}

- (void)edModuleFinished {
    NSLog(@"WRViewController.edModuleFinished()");
//    if (cameFromMainMenu) {
//        [tbvc sayEducationModuleCompletion];
        
        allWhiteBack.alpha = 0.0;
        [self.view bringSubviewToFront:allWhiteBack];
        returnToMenuButton.alpha = 0.0;
        [self.view bringSubviewToFront:returnToMenuButton];
        edModuleCompleteLabel.alpha = 0.0;
        [self.view bringSubviewToFront:edModuleCompleteLabel];
        
        
        
        //    CGRect ssIntroFrame = splashImageViewC.frame;
        //    ssIntroFrame.origin.x = 0;
        //    ssIntroFrame.origin.y = 0;
        
        
        
        //    CGRect ssCubeFrame = aWebView.frame;
        //    ssCubeFrame.origin.x = 300;
        //    ssCubeFrame.origin.y = 300;
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.frame = ssIntroFrame;
            allWhiteBack.alpha = 1.0;
            returnToMenuButton.alpha = 1.0;
            
            edModuleCompleteLabel.alpha = 1.0;
            //        aWebView.frame = ssCubeFrame;
            
        }
        [UIView commitAnimations];
        
        //    [aWebView release];
        //    aWebView = nil;
        
        needToReturnToMainMenu = YES;
        
        endOfSplashTimer = [[NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(returnToMenuInFiveSeconds:) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
        NSArray* edModules = [DynamicContent getEdModulesForCurrentClinic];
        int index = 0;
        int matchingIndex = -1;
        if ([edModules count] == 0)
            matchingIndex = 0;
        else
        for (EdModuleInfo* module in edModules){
            if ([[module getModuleName] isEqualToString:@"Learn about Traumatic Brain Injury"])
                matchingIndex = index;
            else
                index++;
        }
        if (0 <= matchingIndex && matchingIndex < 5){
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] createBadgeOnEdModule:matchingIndex];
            [DynamicContent setEdModuleComplete:matchingIndex];
        }

//        int tbiEdModuleIndex = [DynamicContent getTbiEdModuleIndex];
//        if (tbiEdModuleIndex >= 0){
//            [self createBadgeOnEdModule:tbiEdModuleIndex];
//            [DynamicContent setEdModuleComplete:tbiEdModuleIndex];
//        }
//    } else {
//        // Didn't come from main menu, so still on track to auto-load satisfaction survey
//        [self launchSatisfactionSurvey];
//        
//    }
}



- (void)menuButtonPressed:(id)sender {
    NSLog(@"WRViewController.menuButtonPressed()");
    if (sender == tbiEdButton) {
//        [self hideMasterButtonOverlay];
        [self launchTbiEdModule];
        
    } else if (sender == satisfactionButton) {
        
        [tbvc sayOK];
        
        if (!satisfactionSurveyCompleted) {
            if (satisfactionSurveyInProgress) {
                [self beginSatisfactionSurvey:sender];
            } else {
                [self showSatisfactionIntro];
            }
        }
        
    } else if (sender == newsButton) {
        
        [self launchDynamicWhatsNewModule];
        
    } else if (sender == clinicButton) {
        
//        [self showComingSoonAlert];
        [self fadeDynamicEducationModuleIn];
    }
}

- (void) launchTbiEdModule {
    [DynamicContent fadeEdModulePickerOut];
    [self resetProgressBar];
    totalSlidesInThisSection = [DynamicContent getTbiEdModulePageCount];

    if (!runningAppInDemoMode)
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu];
    if (educationModuleInProgress) {
        [self reshowEducationModule];
    } else {
//        [self setUpEducationModuleForFirstTime];
        [self showEducationModuleIntro];
    }

}

- (void)showAdminKeypad {
    //    keypadViewController = [[DemoViewController alloc] init];
    //    keypadViewController.view.frame = CGRectMake(0, 0, 500, 500);
    //    [self.view addSubview:keypadViewController.view];
}

- (void)showAlertMsg:(NSString *)msg {
//    [tbvc sayComingSoon];
    UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@",msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    msgAlert.delegate = self;
    [msgAlert show];
    [msgAlert release];
}


- (void)showComingSoonAlert {
    [tbvc sayComingSoon];
    UIAlertView *comingSoonAlert = [[UIAlertView alloc] initWithTitle:@"Feature Unavailable" message:@"This Feature is coming soon!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    comingSoonAlert.delegate = self;
    [comingSoonAlert show];
    [comingSoonAlert release];
}

- (void)showDataSentAlert {
    UIAlertView *dataSentAlert = [[UIAlertView alloc] initWithTitle:@"Send Data Results" message:@"Data file successfully sent to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    UIAlertView *dataSentAlert = [[UIAlertView alloc] initWithTitle:@"Send Data Results" message:@"Datafile successfully emailed to: spiraljetty@yahoo.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dataSentAlert.delegate = self;
    [dataSentAlert show];
    [dataSentAlert release];
}

- (void)showDataSendFailedAlert {
    UIAlertView *dataSentAlert = [[UIAlertView alloc] initWithTitle:@"Send Data Results" message:@"Datafile upload attempt failed!  Please reconnect to a network and try again..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dataSentAlert.delegate = self;
    [dataSentAlert show];
    [dataSentAlert release];
}

- (void)slideYesNoOutAndRespondentTypeButtonsIn {
    
    [self.view sendSubviewToBack:splashImageViewBb];
    
    CGRect yesFrame = yesButton.frame;
    CGRect noFrame = noButton.frame;
    CGRect labelFrame = readAloudLabel.frame;
    yesFrame.origin.y = 1500;
    noFrame.origin.y = -500;
    labelFrame.origin.x = 1500;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        yesButton.frame = yesFrame;
        noButton.frame = noFrame;
        readAloudLabel.frame = labelFrame;
    }
    [UIView commitAnimations];
    
    [self fadeRespondentButtonsIn];
}

- (void)fadeRespondentButtonsIn {
    [self.view bringSubviewToFront:patientButton];
    [self.view bringSubviewToFront:familyButton];
    [self.view bringSubviewToFront:caregiverButton];
    [self.view bringSubviewToFront:respondentLabel];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        patientButton.alpha = 1.0;
        familyButton.alpha = 1.0;
        caregiverButton.alpha = 1.0;
        
        respondentLabel.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
    //[tbvc sayRespondentTypes];
    [DynamicSpeech sayRespondentTypes];
}

- (void)slideRespondentsOut {
    
    CGRect patientFrame = patientButton.frame;
    CGRect famFrame = familyButton.frame;
    CGRect careFrame = caregiverButton.frame;
    CGRect labelFrame = respondentLabel.frame;
    patientFrame.origin.y = 1500;
    careFrame.origin.y = -500;
    famFrame.origin.x = 1500;
    labelFrame.origin.x = 1500;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        patientButton.frame = patientFrame;
        familyButton.frame = famFrame;
        caregiverButton.frame = careFrame;
        respondentLabel.frame = labelFrame;
    }
    [UIView commitAnimations];
    
//    [self fadeMenuItemsIn];
}

- (void)fadeMenuItemsIn {
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    if (!mainMenuInitialized) {
    
    menuCubeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    NSString *mainPath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:mainPath];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cube_very_sml.html" ofType:nil];
    NSString *pageHTML = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    [menuCubeWebView setCenter:CGPointMake(683.0f, 934.0f)];
    menuCubeWebView.opaque = NO;
	menuCubeWebView.backgroundColor = [UIColor clearColor];
    menuCubeWebView.scrollView.scrollEnabled = NO;
    menuCubeWebView.scrollView.bounces = NO;
    menuCubeWebView.alpha = 0.0;
    
    //    webView.frame = CGRectMake(0, 0, 100, 200);
    
    [menuCubeWebView loadHTMLString:pageHTML baseURL:baseURL];
    
    [self.view addSubview:menuCubeWebView];
    
    //voiceAssistButton - turn voice assist on and off
	voiceAssistButton = [UIButton buttonWithType:UIButtonTypeCustom];
	voiceAssistButton.frame = CGRectMake(0, 0, 80, 80);
	voiceAssistButton.showsTouchWhenHighlighted = YES;
	[voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_on.png"] forState:UIControlStateNormal];
	[voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[voiceAssistButton setImage:[UIImage imageNamed:@"sound_button_image_sound_off.png"] forState:UIControlStateSelected];
	voiceAssistButton.backgroundColor = [UIColor clearColor];
        [voiceAssistButton setCenter:CGPointMake(770.0f, 725.0f)];
//        [voiceAssistButton setCenter:CGPointMake(725.0f, 770.0f)];
	[voiceAssistButton addTarget:self action:@selector(voiceassistButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	voiceAssistButton.enabled = YES;
	voiceAssistButton.hidden = NO;
    if (tbvc.speakItemsAloud) {
        voiceAssistButton.selected = NO;
    } else {
        voiceAssistButton.selected = YES;
    }
    voiceAssistButton.alpha = 0.0;
	[voiceAssistButton retain];
//    voiceAssistButton.transform = rotateRight;
    
    [self.view addSubview:voiceAssistButton];
    
    //fontsizeButton - cycle through font size options
	fontsizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	fontsizeButton.frame = CGRectMake(0, 0, 80, 80);
	fontsizeButton.showsTouchWhenHighlighted = YES;
	[fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image.png"] forState:UIControlStateNormal];
	[fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[fontsizeButton setImage:[UIImage imageNamed:@"fontsize_button_image_pressed.png"] forState:UIControlStateSelected];
	fontsizeButton.backgroundColor = [UIColor clearColor];
        [fontsizeButton setCenter:CGPointMake(670.0f, 725.0f)];
//        [fontsizeButton setCenter:CGPointMake(725.0f, 670.0f)];
	[fontsizeButton addTarget:self action:@selector(fontsizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	fontsizeButton.enabled = YES;
	fontsizeButton.hidden = NO;
    fontsizeButton.alpha = 0.0;
	[fontsizeButton retain];
    //fontsizeButton.transform = rotateRight;
    
    [self.view addSubview:fontsizeButton];
        
        popoverViewController.view.frame = CGRectMake(0, 0, 300, 300);
        [popoverViewController.view setCenter:CGPointMake(790.0f, 943.0f)];
        
        mainMenuInitialized = YES;
    }
    
    
    [self.view bringSubviewToFront:resourceBack];
    
    [self.view bringSubviewToFront:tbiEdButton];
    [self.view bringSubviewToFront:satisfactionButton];
    [self.view bringSubviewToFront:newsButton];
    [self.view bringSubviewToFront:clinicButton];
    [self.view bringSubviewToFront:selectActivityLabel];
    
    [self.view bringSubviewToFront:menuCubeWebView];
    [self.view bringSubviewToFront:voiceAssistButton];
    [self.view bringSubviewToFront:fontsizeButton];
    
    
    
    [self.view bringSubviewToFront:popoverViewController.view];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        resourceBack.alpha = 1.0;
		
        tbiEdButton.alpha = 1.0;
        satisfactionButton.alpha = 1.0;
        newsButton.alpha = 1.0;
        clinicButton.alpha = 1.0;
        
        selectActivityLabel.alpha = 1.0;
        
        menuCubeWebView.alpha = 1.0;
        voiceAssistButton.alpha = 1.0;
        fontsizeButton.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
    [tbvc saySelectActivity];
    
    cameFromMainMenu = YES;
}

#pragma mark - Satisfaction Survey Module Methods

- (void)showSatisfactionIntro {
    NSLog(@"WRViewController.showSatisfactionIntro()");
    beginSurveyButton.alpha = 0.0;
    tbvc.view.alpha = 0.0;
    
    [self.view bringSubviewToFront:tbvc.view];
    
//    [self.view bringSubviewToFront:surveyResourceBack];
//    [self.view bringSubviewToFront:nextSurveyItemButton];
//    [self.view bringSubviewToFront:previousSurveyItemButton];
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
//    [self.view bringSubviewToFront:returnToMenuButton];
    
    allWhiteBack.alpha = 0.0;
    
    //    [self.view bringSubviewToFront:splashImageViewC];

    [self.view bringSubviewToFront:allWhiteBack];
    [self.view bringSubviewToFront:beginSurveyButton];
    [self.view bringSubviewToFront:surveyIntroLabel];
    
    
    [nextSettingsButton removeTarget:self action:@selector(slideVisitButtonsOut) forControlEvents:UIControlEventTouchUpInside];
    [nextSettingsButton addTarget:self action:@selector(beginSatisfactionSurvey:) forControlEvents:UIControlEventTouchUpInside];
   [self.view bringSubviewToFront:nextSettingsButton];
    
    if ([tbvc.respondentType isEqualToString:@"patient"]) {
        initialSettingsLabel.text = @"Patient Satisfaction Survey";
    } else if ([tbvc.respondentType isEqualToString:@"family"]) {
        initialSettingsLabel.text = @"Family Satisfaction Survey";
    } else {
        initialSettingsLabel.text = @"Caregiver Satisfaction Survey";
    }
    
    initialSettingsLabel.alpha = 0.0;
    taperedWhiteLine.alpha = 0.0;
    [self.view bringSubviewToFront:initialSettingsLabel];
    [self.view bringSubviewToFront:taperedWhiteLine];
    
    [self.initialSettingsLabel setCenter:CGPointMake(250.0f, 100.0f)];
    [self.taperedWhiteLine setCenter:CGPointMake(250.0f, 200.0f)];
    [self.surveyIntroLabel setCenter:CGPointMake(250.0f, 385.0f)];
    [self.nextSettingsButton setCenter:CGPointMake(675.0f, 675.0f)];
    
    //    [self.view bringSubviewToFront:aWebView];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewC.alpha = 1.0;
        allWhiteBack.alpha = 1.0;
        
        //        beginSurveyButton.alpha = 1.0;
        
        nextSettingsButton.alpha = 1.0;
        
        surveyIntroLabel.alpha = 1.0;
        
        initialSettingsLabel.alpha = 1.0;
        taperedWhiteLine.alpha = 1.0;
        
        //        aWebView.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
    [tbvc saySurveyIntro];
}

- (void)fadeToNextSurveyPrompt:(id)sender {
    NSLog(@"WRViewController.fadeToNextSurveyPrompt()");
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        nextSettingsButton.alpha = 0.0;
        surveyIntroLabel.alpha = 0.0;
		
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(requestSurveyAgreement:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)requestSurveyAgreement:(NSTimer*)theTimer {
    [nextSettingsButton removeTarget:self action:@selector(fadeToNextSurveyPrompt:) forControlEvents:UIControlEventTouchUpInside];
    
    surveyIntroLabel.text = @"We greatly appreciate your feedback since it helps us improve our delivery of high quality healthcare services.  Please tap, agree, if you would like to complete the survey, or disagree, if you would like to return to the main menu.";
    [surveyIntroLabel setCenter:CGPointMake(300.0f, 512.0f)];
    
//    [tbvc saySurveyAgreement];
    [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"~tap_agree_or_disagree_new", nil]];
    
    [self.view bringSubviewToFront:agreeButton];
    [self.view bringSubviewToFront:disagreeButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.6];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        agreeButton.alpha = 1.0;
        disagreeButton.alpha = 1.0;
        surveyIntroLabel.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
    [theTimer release];
	theTimer = nil;
}

- (void)fadeToLastSurveyPrompt:(id)sender {
    NSLog(@"WRViewController.fadeToLastSurveyPrompt()");
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
//        nextSettingsButton.alpha = 1.0;
        surveyIntroLabel.alpha = 0.0;
		
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(lastSurveyPrompt:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)lastSurveyPrompt:(NSTimer*)theTimer {
    NSLog(@"WRViewController.lastSurveyPrompt()");
    [surveyIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
    surveyIntroLabel.text = @"Thank you for participating! You will be presented with a series of statements about your rehabilitation experience.\n\nLet’s move on to the first item.";
    [self.view bringSubviewToFront:beginSurveyButton];
    
    [self.view sendSubviewToBack:agreeButton];
    [self.view sendSubviewToBack:disagreeButton];
    
    [tbvc sayThankYouForParticipatingMoveToFirstItem];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.6];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        beginSurveyButton.alpha = 1.0;
        surveyIntroLabel.alpha = 1.0;
		
	}
	[UIView commitAnimations];
    
    [theTimer release];
	theTimer = nil;
}

- (void)launchSatisfactionSurvey {
    NSLog(@"WRViewController.launchSatisfactionSurvey()");
//    [self beginSatisfactionSurvey:self];
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideCurrentButtonOverlay];
    
    [self.view sendSubviewToBack:currentModalVC.view];
    
    [self resetProgressBar];
    totalSlidesInThisSection = [DynamicContent getPostTreatmentPageCount];

    [self showSatisfactionIntro];
}

- (void)beginSatisfactionSurvey:(id)sender {
    
    NSLog(@"WRViewController.beginSatisfactionSurvey()");
    
    // sandy 10_8_14 I think this should be added here or else just write new value to posttxdurstart
     [self resumeAppAfterTreatmentIntermission];
    // or this
    //    [self storeCurrentUXTimeForPostTreatmentStart];
    nextSettingsButton.alpha = 0.0; //rjl 9/8/14

    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] setActiveViewControllerTo:tbvc];
    [self showMasterButtonOverlay];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showNextButton];
    
//    if (satisfactionSurveyInProgress) {
        [tbvc.view setCenter:CGPointMake(378.0f, 250.0f)];
        [self.view bringSubviewToFront:tbvc.view];
//        [self.view bringSubviewToFront:surveyResourceBack];
//        [self.view bringSubviewToFront:nextSurveyItemButton];
//        [self.view bringSubviewToFront:previousSurveyItemButton];
//        [self.view bringSubviewToFront:voiceAssistButton];
//        [self.view bringSubviewToFront:fontsizeButton];
//        [self.view bringSubviewToFront:returnToMenuButton];
//    }
    
//    CGRect ssIntroFrame = splashImageViewC.frame;
//    ssIntroFrame.origin.y = 2200;
//    CGRect ssIntroLabelFrame = surveyIntroLabel.frame;
//    ssIntroLabelFrame.origin.x = -1000;
//    CGRect ssCubeFrame = aWebView.frame;
//    ssCubeFrame.origin.y = -600;
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        tbvc.view.alpha = 1.0;
//        surveyResourceBack.alpha = 1.0;
//        nextSurveyItemButton.alpha = 1.0;
//        previousSurveyItemButton.alpha = 1.0;
//        voiceAssistButton.alpha = 1.0;
//        fontsizeButton.alpha = 1.0;
//        returnToMenuButton.alpha = 1.0;
        
        beginSurveyButton.alpha = 0.0;
        
        allWhiteBack.alpha = 0.0;
        initialSettingsLabel.alpha = 0.0;
        taperedWhiteLine.alpha = 0.0;
		
//        splashImageViewC.frame = ssIntroFrame;
//        beginSurveyButton.frame = ssIntroFrame;
        
//        surveyIntroLabel.frame = ssIntroLabelFrame;
        surveyIntroLabel.alpha = 0.0;
//        aWebView.frame = ssCubeFrame;
		
	}
	[UIView commitAnimations];
    
    if (!satisfactionSurveyInProgress) {
        [tbvc sayFirstSatisfactionSurveyItem];
    }
    
    satisfactionSurveyInProgress = YES;
    
    [self updateMiniDemoSettings];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(completeBeginSatisfactionSurvey:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)fadeOutSatisfactionSurvey {
    
    NSLog(@"WRViewController.fadeOutSatisfactionSurvey()");
    
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        tbvc.view.alpha = 0.0;
		
	}
	[UIView commitAnimations];
    
 
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(completeFadeOutSatisfactionSurvey:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)completeFadeOutSatisfactionSurvey:(NSTimer*)theTimer {
    NSLog(@"WRViewController.completeFadeOutSatisfactionSurvey()");
    [self.view sendSubviewToBack:tbvc.view];
    
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInRevealSettingsButton];
    [theTimer release];
	theTimer = nil;
}

- (void)completeBeginSatisfactionSurvey:(NSTimer*)theTimer {
    NSLog(@"WRViewController.completeBeginSatisfactionSurvey()");
    [self.view sendSubviewToBack:beginSurveyButton];
    [self.view sendSubviewToBack:allWhiteBack];
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
    [self.view sendSubviewToBack:surveyIntroLabel];
    
    
    [theTimer release];
	theTimer = nil;
}

- (void)whatsNewCompleted {
    
    whatsNewModuleCompleted = YES;
            
//    allWhiteBack.alpha = 0.0;
//    [self.view bringSubviewToFront:allWhiteBack];
    returnToMenuButton.alpha = 0.0;
    [self.view bringSubviewToFront:returnToMenuButton];
//    surveyCompleteLabel.alpha = 0.0;
//    [self.view bringSubviewToFront:surveyCompleteLabel];
    
    
    
    //    CGRect ssIntroFrame = splashImageViewC.frame;
    //    ssIntroFrame.origin.x = 0;
    //    ssIntroFrame.origin.y = 0;
    
    
    
    //    CGRect ssCubeFrame = aWebView.frame;
    //    ssCubeFrame.origin.x = 300;
    //    ssCubeFrame.origin.y = 300;
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewC.frame = ssIntroFrame;
//        allWhiteBack.alpha = 1.0;
        returnToMenuButton.alpha = 1.0;
        
//        surveyCompleteLabel.alpha = 1.0;
        //        aWebView.frame = ssCubeFrame;
		
	}
	[UIView commitAnimations];
    
    //    [aWebView release];
    //    aWebView = nil;
    
    needToReturnToMainMenu = YES;
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(returnToMenuInFiveSeconds:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)surveyCompleted {
    NSLog(@"WRViewController.surveyCompleted()");

    satisfactionSurveyCompleted = YES;
    satisfactionSurveyInProgress = NO;
    
    [self updateMiniDemoSettings];
    
    [self updateBadgeOnSatisfactionSurveyButton];
    
    satisfactionButton.enabled = NO;
    
//    [self returnToMenu];
    
    //rjl 7/15/14 [self launchDynamicSurveyWithAppPage];
    [self showReturnTabletView]; //rjl 7/15/14
    
//    allWhiteBack.alpha = 0.0;
//    [self.view bringSubviewToFront:allWhiteBack];
//    returnToMenuButton.alpha = 0.0;
//    [self.view bringSubviewToFront:returnToMenuButton];
//    surveyCompleteLabel.alpha = 0.0;
//    [self.view bringSubviewToFront:surveyCompleteLabel];
//    
//    
//    
////    CGRect ssIntroFrame = splashImageViewC.frame;
////    ssIntroFrame.origin.x = 0;
////    ssIntroFrame.origin.y = 0;
//    
//    
//    
//    //    CGRect ssCubeFrame = aWebView.frame;
//    //    ssCubeFrame.origin.x = 300;
//    //    ssCubeFrame.origin.y = 300;
//    
//    [UIView beginAnimations:nil context:nil];
//	{
//		[UIView	setAnimationDuration:0.3];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//		
////        splashImageViewC.frame = ssIntroFrame;
//        allWhiteBack.alpha = 1.0;
//        returnToMenuButton.alpha = 1.0;
//        
//        surveyCompleteLabel.alpha = 1.0;
//        //        aWebView.frame = ssCubeFrame;
//		
//	}
//	[UIView commitAnimations];
    
//    [aWebView release];
//    aWebView = nil;
    
//    needToReturnToMainMenu = YES;
//    
//    endOfSplashTimer = [[NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(returnToMenuInFiveSeconds:) userInfo:nil repeats:NO] retain];
//    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Return to Menu Methods

- (void)returnToMenuInFiveSeconds:(NSTimer*)theTimer {
    if (needToReturnToMainMenu) {
        [self returnToMenu];
    }
    [theTimer release];
	theTimer = nil;
}

- (void)returnToMenu {
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutMiniDemoMenu];
    [DynamicSpeech stopSpeaking];
    [mainTTSPlayer stopPlayer];
    [self showMasterButtonOverlayNoButtons];

    [self resetProgressBar];
    totalSlidesInThisSection = [DynamicContent getEdModuleCount];
    [self setProgressBarSlidesCompleted:[DynamicContent edModulesCompletedCount]];
    [self handleReturnToMenuTransitions];
    
    needToReturnToMainMenu = NO;
    
    if ([DynamicContent areAllEdModulesComplete])
        finalBadgeCreated = YES;
    
    [self fadeCurrentEdModuleOut];
//    [self fadeEdModuleOut:2];
//    [self fadeEdModuleOut:3];
//    [self fadeEdModuleOut:4];
//    [self fadeEdModuleOut:5];

    [DynamicContent fadeEdModulePickerIn];
    
    BOOL needToDoFadeIn = usingFullMenu;
    
    if (edModule.playingMovie) {
        [edModule stopMoviePlayback];
    }
    
    if (usingFullMenu) {
        
        [self fadeMenuItemsIn];
        
//        if (!satisfactionSurveyDeclined) {
//            if (satisfactionSurveyCompleted) {
//                [self updateBadgeOnSatisfactionSurveyButton];
//                [self.view bringSubviewToFront:completedBadgeImageView];
//            }
//            if (satisfactionSurveyInProgress) {
//                if (!badgeCreated) {
//                    [self createBadgeOnSatisfactionSurveyButton];
//                } else {
//                    if (!finalBadgeCreated) {
//                        [self updateBadgeOnSatisfactionSurveyButton];
//                    }
//                }
//            }
//        }
        
        if (educationModuleCompleted) {
            tbiEdButton.enabled = NO;
            [self.view bringSubviewToFront:completedBadgeImageViewEdModule];
        }
        
        if (badgeCreated) {
            [self.view bringSubviewToFront:badgeImageView];
        }
        
        if (dynamicEdModuleCompleted) {
            [self.view bringSubviewToFront:completedBadgeImageViewDynEdModule];
        }
        
        if (whatsNewModuleCompleted) {
            [self.view bringSubviewToFront:completedBadgeImageViewWhatsNewModule];
        }
        
    }
    
//    CGRect ssIntroFrame = splashImageViewC.frame;
//    ssIntroFrame.origin.y = 2200;
//    CGRect ssCompletedLabelFrame = surveyCompleteLabel.frame;
//    ssCompletedLabelFrame.origin.x = -1000;
    //    CGRect ssCubeFrame = aWebView.frame;
    //    ssCubeFrame.origin.y = -600;
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        if (needToDoFadeIn) {
            if (educationModuleCompleted) {
                tbiEdButton.enabled = NO;
                [self.view bringSubviewToFront:completedBadgeImageViewEdModule];
                completedBadgeImageViewEdModule.alpha = 1.0;
            }
            badgeImageView.alpha = 1.0;
            completedBadgeImageView.alpha = 1.0;
            if (dynamicEdModuleCompleted) {
                completedBadgeImageViewDynEdModule.alpha = 1.0;
            }
            if (whatsNewModuleCompleted) {
                completedBadgeImageViewWhatsNewModule.alpha = 1.0;
            }
        }
        
        tbvc.view.alpha = 0.0;
        
        surveyResourceBack.alpha = 0.0;
        nextSurveyItemButton.alpha = 0.0;
        previousSurveyItemButton.alpha = 0.0;
        agreeButton.alpha = 0.0;
        disagreeButton.alpha = 0.0;
        nextSettingsButton.alpha = 0.0;
        
        surveyIntroLabel.alpha = 0.0;
        initialSettingsLabel.alpha = 0.0;
        taperedWhiteLine.alpha = 0.0;
        
        returnToMenuButton.alpha = 0.0;
		
        allWhiteBack.alpha = 0.0;
//        splashImageViewC.frame = ssIntroFrame;
//        returnToMenuButton.frame = ssIntroFrame;
        
        surveyCompleteLabel.alpha = 0.0;
        
        edModule.view.alpha = 0.0;
        nextEdItemButton.alpha = 0.0;
        previousEdItemButton.alpha = 0.0;
        edModuleCompleteLabel.alpha = 0.0;
        
        physicianModule.view.alpha = 0.0;
        physicianDetailVC.view.alpha = 0.0;
        nextPhysicianDetailButton.alpha = 0.0;
        previousPhysicianDetailButton.alpha = 0.0;
        
        dynamicEdModule.view.alpha = 0.0;
        
        dynamicSubclinicEdModule.view.alpha = 0.0;
        dynamicWhatsNewModule.view.alpha = 0.0;
        
        surveyResourceBack.alpha = 0.0;
        
//        surveyCompleteLabel.frame = ssCompletedLabelFrame;
        //        aWebView.frame = ssCubeFrame;
		
	}
	[UIView commitAnimations];
    
//    [tbvc saySelectActivity];
    if (!satisfactionSurveyDeclined) {
        if (satisfactionSurveyCompleted) {
            [self.view bringSubviewToFront:completedBadgeImageView];
        }
    }
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(completeReturnToMenu:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)createBadgeOnMiniWhatsNewButton {
    [dynamicSurveyModule showModule2CompletedBadge];
}

- (void)createBadgeOnMiniTBIButton {
    [dynamicSurveyModule showModule1CompletedBadge];
}

- (void)readyForAppointment {
    physicianModuleCompleted = YES;
    dynamicEdModuleCompleted = YES;
    educationModuleCompleted = YES;
    whatsNewModuleCompleted = YES;
    
//    [[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutReadyForAppointmentButton] setEnab
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutReadyForAppointmentButton];
    [self hideMasterButtonOverlay];
    [self fadeCurrentEdModuleOut];
    [self fadeDynamicEdModuleOut];
    [self fadeDynamicSubclinicEdModuleOut];
    [self fadePhysicianDetailOut];
    [self fadePhysicianDetailVCOut];
    [self showModalTreatmentIntermissionView];
//    [self returnToMenu];
}

- (void) handleReturnToMenuTransitions {
    if (physicianModuleCompleted  && [DynamicContent areAllEdModulesComplete] ) {
        
        [self hideMasterButtonOverlay];
        [self showModalTreatmentIntermissionView];
        
    } else if(satisfactionSurveyCompleted || satisfactionSurveyDeclined){
         [self hideMasterButtonOverlay];
         [self showReturnTabletView];
    }
}

- (void)handleReturnToMenuTransitionsOld {
    if (physicianModuleCompleted && dynamicEdModuleCompleted && educationModuleCompleted && [DynamicContent areAllEdModulesComplete] ) {
        
        [self hideMasterButtonOverlay];
        [self showModalTreatmentIntermissionView];
        
    } else if (physicianModuleCompleted && dynamicEdModuleCompleted && educationModuleCompleted ) {
        [self createBadgeOnMiniTBIButton];
        [self launchDynamicSurveyWithChooseModuleWhatsNew];
        //sandy 10-15-14
        //TBD add code to indicate that this module was started in the db
        NSString* addToSelfGuideStatus  = @"TBIModDone";
        
        NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
        NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
        NSLog(@"WRViewController.launchDynamicWhatsNewModule() existing SelfGuideSting%@",existingSelfGuideString);
        int count = [mySelfGuideStatusArray count];
        for (int i = 0; i < count; i++)
            NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
        NSString *appendedSelfGuideStatusString;
        appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
        [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
        [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
        RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
        [rootViewController updateSurveyTextForField:@"selfguideslected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
        
    } else if (physicianModuleCompleted && dynamicEdModuleCompleted && whatsNewModuleCompleted ) {
//        [self hideMasterButtonOverlay];
        [self createBadgeOnMiniWhatsNewButton];
        //sandy 10-15-14
        //TBD add code to indicate that this module was started in the db
        NSString* addToSelfGuideStatus  = @"WhatsNewCompleted";
        NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
        NSString* existingSelfGuideString  = [mySelfGuideStatusArray objectAtIndex:0];
        NSLog(@"WRViewController.launchDynamicWhatsNewModule() existing SelfGuideSting%@",existingSelfGuideString);
        int count = [mySelfGuideStatusArray count];
        for (int i = 0; i < count; i++)
            NSLog (@"%@,", [mySelfGuideStatusArray objectAtIndex: i]);
        NSString *appendedSelfGuideStatusString;
        appendedSelfGuideStatusString = [NSString stringWithFormat:@"%@-%@", existingSelfGuideString  , addToSelfGuideStatus];
        [mySelfGuideStatusArray addObject:addToSelfGuideStatus];
        [mySelfGuideStatusArray insertObject:appendedSelfGuideStatusString atIndex: 0];
        RootViewController_Pad* rootViewController = [RootViewController_Pad getViewController];
        [rootViewController updateSurveyTextForField:@"selfguideselected" withThisText:[NSString stringWithFormat:@"%@",appendedSelfGuideStatusString]];
        
        [self launchDynamicSurveyWithChooseModuleTBI];
    } else if (educationModuleCompleted && (satisfactionSurveyCompleted || satisfactionSurveyDeclined) && dynamicEdModuleCompleted && whatsNewModuleCompleted) {
        [self hideMasterButtonOverlay];
        [self showReturnTabletView];
    }
}

- (void)completeReturnToMenu:(NSTimer*)theTimer {
    [self.view sendSubviewToBack:tbvc.view];
    
    [self.view sendSubviewToBack:surveyResourceBack];
    [self.view sendSubviewToBack:nextSurveyItemButton];
    [self.view sendSubviewToBack:previousSurveyItemButton];
    [self.view sendSubviewToBack:agreeButton];
    [self.view sendSubviewToBack:disagreeButton];
    [self.view sendSubviewToBack:nextSettingsButton];
    
    [self.view sendSubviewToBack:returnToMenuButton];
    
    [surveyIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
    [self.view sendSubviewToBack:surveyIntroLabel];
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
    
    [self.view sendSubviewToBack:returnToMenuButton];
    [self.view sendSubviewToBack:allWhiteBack];
    
    [self.view sendSubviewToBack:surveyCompleteLabel];
    
    [self.view sendSubviewToBack:edModule.view];
    [self.view sendSubviewToBack:nextEdItemButton];
    [self.view sendSubviewToBack:previousEdItemButton];
    [self.view sendSubviewToBack:edModuleCompleteLabel];
    
    [self.view sendSubviewToBack:physicianModule.view];
    [self.view sendSubviewToBack:physicianDetailVC.view];
    [self.view sendSubviewToBack:nextPhysicianDetailButton];
    [self.view sendSubviewToBack:previousPhysicianDetailButton];
    
    [self.view sendSubviewToBack:dynamicEdModule.view];
    
    [self.view sendSubviewToBack:dynamicSubclinicEdModule.view];
    [self.view sendSubviewToBack:dynamicWhatsNewModule.view];
    
    [theTimer release];
	theTimer = nil;
    
    
//    cameFromMainMenu = YES;
}

- (void)showModalSilenceAlarmView {
    NSLog(@"In showModalSilenceAlarmView...");
    
    alarmSounding = YES;
//    
//    [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"treatment_intermission", nil]];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    UIViewController *modalSilenceAlarmView = [[UIViewController alloc] init];
    modalSilenceAlarmView.view.frame = CGRectMake(0, 0, 1024, 768);
    modalSilenceAlarmView.view.alpha = 0.0;
    [modalSilenceAlarmView.view setCenter:CGPointMake(500.0f, 350.0f)];
//    [modalSilenceAlarmView.view setCenter:CGPointMake(350.0f, 500.0f)];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = modalSilenceAlarmView;
    
    UIImageView *newAllWhiteBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
    newAllWhiteBack.frame = CGRectMake(-400, -400, 1500, 2000);
//    newAllWhiteBack.transform = rotateRight;
    [modalSilenceAlarmView.view addSubview:newAllWhiteBack];
    
    KSLabel *treatmentIntermissionLable = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 300)];
    treatmentIntermissionLable.drawBlackOutline = YES;
    treatmentIntermissionLable.drawGradient = YES;
    treatmentIntermissionLable.text = [NSString stringWithFormat:@"Return to Waiting Room"];
    treatmentIntermissionLable.textAlignment = UITextAlignmentCenter;
    treatmentIntermissionLable.font = [UIFont fontWithName:@"Avenir-Medium" size:60];
    treatmentIntermissionLable.numberOfLines = 0;
    [treatmentIntermissionLable setCenter:CGPointMake(512.0f, 150.0f)];
    //    treatmentIntermissionLable.transform = rotateRight;
    [modalSilenceAlarmView.view addSubview:treatmentIntermissionLable];
    
    UIImageView *newTaperedWhiteLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapered_fade_dividing_line-horiz-lrg.png"]];
    newTaperedWhiteLine.frame = CGRectMake(0, 0, 700, 50);
    [newTaperedWhiteLine setCenter:CGPointMake(512.0f, 300.0f)];
    //    taperedWhiteLine.transform = rotateRight;
    [modalSilenceAlarmView.view addSubview:newTaperedWhiteLine];
    
    //    modalTreatmentIntermissionView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    modalSilenceAlarmView.view.transform = rotateRight;
    
    DynamicStartAppButtonView *resumeAppButtonView = [[DynamicStartAppButtonView alloc] initWithFrame:CGRectMake(0, 0, modalSilenceAlarmView.view.frame.size.width, 102) type:kPopRectGreenLarge text:@"SILENCE" target:self selector:@selector(unlockToResume:)  fontsize:50];
    [resumeAppButtonView setCenter:CGPointMake(670.0f, 420.0f)];
    //    resumeAppButtonView.demoButton.enabled = NO;
    //    resumeAppButtonView.transform = rotateRight;
    [modalSilenceAlarmView.view addSubview:resumeAppButtonView];
    
    UILabel *pleaseHoldiPadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 750, 450)];
	pleaseHoldiPadLabel.text = @"Please return this iPad to the waiting room where you received it and ask the receptionist to disable the alarm.";
	pleaseHoldiPadLabel.textAlignment = UITextAlignmentCenter;
	pleaseHoldiPadLabel.textColor = [UIColor blackColor];
    pleaseHoldiPadLabel.numberOfLines = 0;
	pleaseHoldiPadLabel.backgroundColor = [UIColor clearColor];
    pleaseHoldiPadLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	pleaseHoldiPadLabel.opaque = YES;
	[pleaseHoldiPadLabel setCenter:CGPointMake(512.0f, 680.0f)];
    //    pleaseHoldiPadLabel.transform = rotateRight;
    
    keycodeField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 135, 30)];
    keycodeField.borderStyle = UITextBorderStyleBezel;
    keycodeField.textAlignment = UITextAlignmentLeft;
    [keycodeField setCenter:CGPointMake(150.0f, 550.0f)];
    keycodeField.alpha = 0.0;
    [modalSilenceAlarmView.view addSubview:keycodeField];
    
    FPNumberPadView *numberPadView = [[FPNumberPadView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    numberPadView.textField = keycodeField;
    
    [modalSilenceAlarmView.view addSubview:pleaseHoldiPadLabel];
    
    [self.view addSubview:modalSilenceAlarmView.view];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewC.frame = ssIntroFrame;
        modalSilenceAlarmView.view.alpha = 1.0;
        
		
	}
	[UIView commitAnimations];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInRevealSettingsButton];
    //    [self presentModalViewController:modalTreatmentIntermissionView animated:YES];
    //    [modalTreatmentIntermissionView release];
    
}

- (void)silenceAlarm {
    NSLog(@"Silencing the alarm...");
    alarmSounding = NO;
    settingsVC.loopAlarm = NO;
    if (!forceToDemoMode) {
        [mainTTSPlayer forceToHeadphoneOutput];
    }
}

- (void)showModalTreatmentIntermissionView {
    NSLog(@"WRViewController.showModalTreatmentIntermissionView()");
    
    inTreatmentIntermission = YES;
    
    //[self storeCurrentUXTimeForPreTreatment];
    [self storeCurrentUXTimeForSelfGuidedStop];
// TBD sandy 10-12-14 reset to time treatment session
    //record selfguidedsession use
    
    
    [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"treatment_intermission", nil]];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    UIViewController *modalTreatmentIntermissionView = [[UIViewController alloc] init];
    modalTreatmentIntermissionView.view.frame = CGRectMake(0, 0, 1024, 768);
    modalTreatmentIntermissionView.view.alpha = 0.0;
    if ([DynamicContent isProviderAndSubclinicSurveyComplete])
        [modalTreatmentIntermissionView.view setCenter:CGPointMake(280.0f, 350.0f)];
    else
        [modalTreatmentIntermissionView.view setCenter:CGPointMake(512.0f, 350.0f)];

//    [modalTreatmentIntermissionView.view setCenter:CGPointMake(350.0f, 500.0f)];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = modalTreatmentIntermissionView;
    
    UIImageView *newAllWhiteBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
    newAllWhiteBack.frame = CGRectMake(-400, -400, 1500, 2000);
//    newAllWhiteBack.transform = rotateRight;
    [modalTreatmentIntermissionView.view addSubview:newAllWhiteBack];
    
    KSLabel *treatmentIntermissionLable = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 300)];
    treatmentIntermissionLable.drawBlackOutline = YES;
    treatmentIntermissionLable.drawGradient = YES;
    treatmentIntermissionLable.text = [NSString stringWithFormat:@"Treatment Intermission"];
    treatmentIntermissionLable.textAlignment = UITextAlignmentCenter;
    treatmentIntermissionLable.font = [UIFont fontWithName:@"Avenir-Medium" size:60];
    treatmentIntermissionLable.numberOfLines = 0;
    [treatmentIntermissionLable setCenter:CGPointMake(510.0f, 175.0f)];
//    [treatmentIntermissionLable setCenter:CGPointMake(512.0f, 150.0f)];
//    treatmentIntermissionLable.transform = rotateRight;
    [modalTreatmentIntermissionView.view addSubview:treatmentIntermissionLable];
    
    UIImageView *newTaperedWhiteLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapered_fade_dividing_line-horiz-lrg.png"]];
    newTaperedWhiteLine.frame = CGRectMake(0, 0, 700, 50);
    [newTaperedWhiteLine setCenter:CGPointMake(512.0f, 300.0f)];
//    taperedWhiteLine.transform = rotateRight;
    [modalTreatmentIntermissionView.view addSubview:newTaperedWhiteLine];
    
//    modalTreatmentIntermissionView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [subclinicTestCorrect.view setCenter:CGPointMake(512.0f, 500.0f)];
//    modalTreatmentIntermissionView.view.transform = rotateRight;
    
    DynamicStartAppButtonView *resumeAppButtonView = [[DynamicStartAppButtonView alloc] initWithFrame:CGRectMake(0, 0, modalTreatmentIntermissionView.view.frame.size.width, 102) type:kPopRectGreenLarge text:@"UNLOCK" target:self selector:@selector(unlockToResume:)  fontsize:50];
    [resumeAppButtonView setCenter:CGPointMake(800.0f, 420.0f)];
//    [resumeAppButtonView setCenter:CGPointMake(670.0f, 420.0f)];
//    resumeAppButtonView.demoButton.enabled = NO;
//    resumeAppButtonView.transform = rotateRight;
    [modalTreatmentIntermissionView.view addSubview:resumeAppButtonView];
    
    UILabel *pleaseHoldiPadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 750, 450)];
	pleaseHoldiPadLabel.text = @"You will be seen by a treatment provider in a few moments.  Please hold on to this iPad and take it with you into your treatment session.";
	pleaseHoldiPadLabel.textAlignment = UITextAlignmentCenter;
	pleaseHoldiPadLabel.textColor = [UIColor blackColor];
    pleaseHoldiPadLabel.numberOfLines = 0;
	pleaseHoldiPadLabel.backgroundColor = [UIColor clearColor];
    pleaseHoldiPadLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	pleaseHoldiPadLabel.opaque = YES;
	[pleaseHoldiPadLabel setCenter:CGPointMake(512.0f, 680.0f)];
//    pleaseHoldiPadLabel.transform = rotateRight;
    
    keycodeField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 135, 30)];
    keycodeField.borderStyle = UITextBorderStyleBezel;
    keycodeField.textAlignment = UITextAlignmentLeft;
    [keycodeField setCenter:CGPointMake(150.0f, 550.0f)];
    keycodeField.alpha = 0.0;
    [modalTreatmentIntermissionView.view addSubview:keycodeField];
    
    FPNumberPadView *numberPadView = [[FPNumberPadView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    numberPadView.textField = keycodeField;
    
    [modalTreatmentIntermissionView.view addSubview:pleaseHoldiPadLabel];
    
    [self.view addSubview:modalTreatmentIntermissionView.view];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewC.frame = ssIntroFrame;
        modalTreatmentIntermissionView.view.alpha = 1.0;
     
		
	}
	[UIView commitAnimations];
    
//    [self presentModalViewController:modalTreatmentIntermissionView animated:YES];
//    [modalTreatmentIntermissionView release];

}

- (void)showModalUnlockSettingsView {
    NSLog(@"WRViewController.showModalUnlockSettingsView()");
            
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    UIViewController *modalUnlockSettingsView = [[UIViewController alloc] init];
    modalUnlockSettingsView.view.frame = CGRectMake(0, 0, 1024, 768);
    modalUnlockSettingsView.view.alpha = 0.0;
    [modalUnlockSettingsView.view setCenter:CGPointMake(500.0f, 350.0f)];
//    [modalUnlockSettingsView.view setCenter:CGPointMake(350.0f, 500.0f)];
    
    if (currentModalVC) {
        currentModalVC = nil;
    }
    currentModalVC = modalUnlockSettingsView;
    
    
    
    if (completedFinalSurvey) {
//       modalUnlockSettingsView.view.transform = rotateRight;
        
        keycodeField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 135, 30)];
        keycodeField.borderStyle = UITextBorderStyleBezel;
        keycodeField.backgroundColor = [UIColor whiteColor];
        keycodeField.textAlignment = UITextAlignmentLeft;
        // sandy moving this to allow user to see text entry field at end
        // original [keycodeField setCenter:CGPointMake(150.0f, 550.0f)];
        [keycodeField setCenter:CGPointMake(320.0f, 400.0f)];
        keycodeField.alpha = 0.0;
        [modalUnlockSettingsView.view addSubview:keycodeField];
        
        FPNumberPadView *numberPadView = [[FPNumberPadView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        numberPadView.textField = keycodeField;
        
        [returnTabletView.view addSubview:modalUnlockSettingsView.view];
    } else {
//        modalUnlockSettingsView.view.transform = rotateRight;
        
        keycodeField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 135, 30)];
        keycodeField.borderStyle = UITextBorderStyleBezel;
        keycodeField.backgroundColor = [UIColor whiteColor];
        keycodeField.textAlignment = UITextAlignmentLeft;
        [keycodeField setCenter:CGPointMake(150.0f, 550.0f)];
        keycodeField.alpha = 0.0;
        [modalUnlockSettingsView.view addSubview:keycodeField];
        
        FPNumberPadView *numberPadView = [[FPNumberPadView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        numberPadView.textField = keycodeField;
        
        [self.view addSubview:modalUnlockSettingsView.view];
    }
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        modalUnlockSettingsView.view.alpha = 1.0;
        keycodeField.alpha = 1.0;
	}
	[UIView commitAnimations];
    
    [keycodeField becomeFirstResponder];
    
}

- (void)unlockKeypadEnterPressed:(id)sender {
    if (revealSettingsButtonPressed) {
        revealSettingsButtonPressed = NO;
        [self checkIfCorrectUnlockSettingsPassword];
    } else if (alarmSounding) {
        [self checkIfCorrectAlarmPassword];
    } else {
        [self checkIfCorrectPassword];
    }
}

- (void)checkIfCorrectUnlockSettingsPassword {
    NSLog(@"WRViewController.checkIfCorrectUnlockSettingsPassword()");

    if (keycodeField.text.length > 0 &&  [keycodeField.text isEqualToString:@"3801"]) {
        NSLog(@"Keycode correct!");
        
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeOutRevealSettingsButton];
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInMiniDemoMenu];
        
        if (inTreatmentIntermission) {
            
            NSString *currentUniqueIdString = [NSString stringWithFormat:@"%d",tbvc.currentUniqueID];
            int currentUniqueIdLength = [currentUniqueIdString length];
            
            int suffixLengthToDisplay = 5;
            
            int fromIndex = currentUniqueIdLength - suffixLengthToDisplay;
            
            NSString *alertText = [NSString stringWithFormat:@"To resume with this respondent at a later time, enter the following keycode at the Intermission Screen: %@ !", [currentUniqueIdString substringFromIndex:fromIndex]];
            UIAlertView *incorrectKeypadAlert = [[UIAlertView alloc] initWithTitle:@"Resume Alert" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            incorrectKeypadAlert.delegate = self;
            [incorrectKeypadAlert show];
            [incorrectKeypadAlert release];
        }
        
    } else {        
        NSLog(@"Unlock settings keycode incorrect! Please try again");
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInRevealSettingsButton];
    }
//    [self showAlertMsg:[NSString stringWithFormat:@"Password OK"]];
    [self clearTextField];
    [self hideKeypad:self];
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        currentModalVC.view.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)checkIfCorrectAlarmPassword {
    
    if ([keycodeField.text isEqualToString:@"3801"]) {
        NSLog(@"Keycode correct!");
        
        [self silenceAlarm];
        
        [self hideKeypad:self];
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.frame = ssIntroFrame;
            currentModalVC.view.alpha = 0.0;
            
            
        }
        [UIView commitAnimations];
        
    } else {
        
        NSLog(@"Keycode incorrect! Please try again");
        UIAlertView *incorrectKeypadAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect keycode" message:@"Please ask the receptionist to enter the keycode to disable this alarm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        incorrectKeypadAlert.delegate = self;
        [incorrectKeypadAlert show];
        [incorrectKeypadAlert release];
        //        correctTextField.text = @"Try again...";
    }
    
    [self clearTextField];
}

- (void)checkIfCorrectPassword {
    
    BOOL isPasswordValid = NO;
    
    //rjl 7/10/14
    if (keycodeField.text.length > 0 && [keycodeField.text isEqualToString:@"3801"]) {
        NSLog(@"Keycode correct!");
        
        isPasswordValid = YES;
        
//        correctTextField.text = @"Correct!";
        //        [[AppDelegate_Pad sharedAppDelegate] adminShowSendDataButton];
//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminShowSendDataButton];
    } else {
        // rjl 7/10/14 ask Dr. Sills what the uniqueId and matching suffix are
        if (false && keycodeField.text.length > 0 && [tbvc isUniqueIdSuffixInDb:[keycodeField.text intValue]]) {
            // Update uniqueId to id that matches entered suffix
            [tbvc setCurrentUniqueID:[tbvc getUniqueIdWithSuffix:[keycodeField.text intValue]]];
            
            isPasswordValid = YES;
            
            NSString *updatedRespondentType = [tbvc getRespondentTypeForUniqueId:tbvc.currentUniqueID];
            
            if ([updatedRespondentType isEqualToString:@"patient"]) {
                [tbvc updateRespondentToPatient];
            } else if ([updatedRespondentType isEqualToString:@"family"]) {
                [tbvc updateRespondentToFamily];
            } else {
                [tbvc updateRespondentToCaregiver];
            }
            
        } else {
        
            isPasswordValid = NO;
            
        }
        
//        correctTextField.text = @"Try again...";
    }
    
    if (isPasswordValid) {
        [self hideKeypad:self];
        
        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hideReadyForAppointmentButton];
        
        [self transitionToSatisfactionSurvey];
        
        [UIView beginAnimations:nil context:nil];
        {
            [UIView	setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.frame = ssIntroFrame;
            currentModalVC.view.alpha = 0.0;
            
            
        }
        [UIView commitAnimations];
    } else {
        [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"keycode_incorrect_alert", nil]];
        
        NSLog(@"Keycode incorrect! Please try again");
        UIAlertView *incorrectKeypadAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect keycode" message:@"Please ask your treatment provider or the receptionist to unlock this Waiting Room Guide so you can continue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        incorrectKeypadAlert.delegate = self;
        [incorrectKeypadAlert show];
        [incorrectKeypadAlert release];
    }
    
    [self clearTextField];
}

- (void)clearTextField {
    keycodeField.text = @"";
}

- (void)unlockToResume:(id)sender {
    NSLog(@"In unlockToResume...");
    [keycodeField becomeFirstResponder];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        keycodeField.alpha = 1.0;
        
		
	}
	[UIView commitAnimations];
    
//    if (alarmSounding) {
//        settingsVC.loopAlarm = YES;
//    }
}

- (void)hideKeypad:(id)sender {
    [keycodeField resignFirstResponder];
}

- (void)resumeAppAfterTreatmentIntermission {
    // sandy 10-8-14 grabbing the timer setting here  to calculate tx time
    [self storeCurrentUXTimeForTreatmentStop];
    [self resetUXTimer];
    [uxTimer release];
    uxTimer = nil;
    
    secondsDur = 0.0;
    NSLog(@"WRViewController.resumeAppAfterTreatmentIntermission()",secondsDur);
    uxTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:uxTimer forMode:NSDefaultRunLoopMode];
    
//    [currentModalVC dismissModalViewControllerAnimated:YES];
//    [self launchDynamicSurveyWithPreSatisfactionTransition];
}

- (void)showReturnTabletView {
    
    [self storeCurrentUXTimeForPostSurveyStop];
    [self storeTotalTime];
    
    NSString *returnTabletText;
    NSString *returnTabletSoundfile;
    
    [self hideMasterButtonOverlay];

//    if (satisfactionSurveyCompleted) {
        returnTabletText = @"Thank you for your feedback.\nPlease return this iPad tablet to the receptionist.";
        returnTabletSoundfile = @"~thank_you_please_return_ipad-survey_completed";
//    } else {
//        returnTabletText = @"Thank you for taking the time to learn more about your visit today.  Please return your iPad tablet to the receptionist.";
//        returnTabletSoundfile = @"~thank_you_please_return_ipad-survey_declined";
//    }
    
    returnTabletView = [[ReturnTabletViewController alloc] init];
    returnTabletView.textToShow = returnTabletText;
    returnTabletView.view.frame = CGRectMake(0, 20, 364, 512);
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    returnTabletView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [returnTabletView.view setCenter:CGPointMake(500.0f, 512.0f)];
//    [returnTabletView.view setCenter:CGPointMake(512.0f, 500.0f)];
//    returnTabletView.view.transform = rotateRight;
    [self presentModalViewController:returnTabletView animated:YES];
    //[returnTabletView release];
    if ([DynamicSpeech isEnabled]){
        [DynamicSpeech sayReturnTablet];
    }
    else
        [mainTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:returnTabletSoundfile, nil]];
    completedFinalSurvey = true; //rjl 7/16/14
    //TBD sandy 10-12-14
    // update database value
    finishedsurvey = true;
    [tbvc updateSurveyNumberForField:@"finishedsurvey" withThisRatingNum:1];
    [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInRevealSettingsButton];
}

- (BOOL)didSplashAnimationsFinish {
	return splashAnimationsFinished;
}


#pragma mark MySQL Methods

- (BOOL)isPossibleToGetMaxIDFromMySQL {
	BOOL sqlDBreachable = NO;
	
	maxIDFromMySQL = [self getMaxIDFromMySQL];
	
	if (maxIDFromMySQL > 0) {
		sqlDBreachable = YES;
	} else {
		sqlDBreachable = NO;
	}
	
	return sqlDBreachable;
}

- (int)getMaxIDFromMySQL {
	
	int maxIdToReturn = 0;
	BOOL gotMaxIdToReturn = NO;
	
	NSString *mysqlUsername = [NSString stringWithFormat:@"apptest_user"];
	NSString *mysqlPassword = [NSString stringWithFormat:@"apptestpass"];
	NSString *mysqlRequestType;
	
	NSLog(@"Getting maximum id from user table in mysql db...");
	mysqlRequestType = [NSString stringWithFormat:@"getmaxid"];
	
	NSString *post =[NSString stringWithFormat:@"username=%@&password=%@&request_type=%@", mysqlUsername, mysqlPassword, mysqlRequestType];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:@"http://www.mechasounds.com/h1n1trackerapp/php/process_h1n1_db_request.php"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error;
	NSURLResponse *response;
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *mysqlMaxIDString = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	NSLog(@"Return result from MAX row request: %@", mysqlMaxIDString);
    
	NSArray *maxIDComponentsArray = [[NSArray alloc] init];
	
	maxIDComponentsArray = [mysqlMaxIDString componentsSeparatedByString:@"#"];
	int totalComponentsInArray = [maxIDComponentsArray count];
	NSString *currComponentString;
	int maxIDComponentIndex = 0;
    
	for (int i = 0; i <= totalComponentsInArray-1; i++) {
		
		currComponentString = [maxIDComponentsArray objectAtIndex:i];
		
		if ([currComponentString isEqualToString:@"MAX(id)"]) {
			maxIDComponentIndex = i + 1;
			gotMaxIdToReturn = YES;
		}
	}
	
	if (gotMaxIdToReturn) {
		currComponentString = [maxIDComponentsArray objectAtIndex:maxIDComponentIndex];
		maxIdToReturn = [currComponentString intValue];
		
		NSLog(@"Returning Max ID = %d", maxIdToReturn);
		
		return maxIdToReturn;
	} else {
		NSLog(@"Didn't find a max ID...returning 0");
		return 0;
	}
}



#pragma mark SKPSMTPMessage methods

- (void)adminShowSendDataButton {
    [popoverViewController showTheSendDataButton];
}

- (void)adminSendDataButtonPressed:(id)sender {
    NSLog(@"WRViewController.adminSendDataButtonPressed is called");
    //[self showSpinner];
    // sandy uncommenting this to test csv file
    YLViewController* viewController = [YLViewController getViewController];
    // update UI on the main thread
    if (viewController != NULL){
        dispatch_async(dispatch_get_main_queue(), ^{
            viewController.uploadDataStatus.text = @"Saving data...";
        });
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [tbvc writeLocalDbToCSVFile];
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.uploadDataStatus.text = @"Sending data...";
                [self sendEmailWithDataAttached];
            });
        }
        
    });
    
    //    [self removeSpinner];
}


// File Download methods rjl 8/16/14


- (void)adminDownloadDataButtonPressed:(id)sender { // rjl 8/16/14
    NSLog(@"WRViewController.adminDownloadDataButtonPressed()");
    //[self showSpinner];
//    YLViewController* viewController = [YLViewController getViewController];
//    if (viewController != NULL){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            viewController.downloadDataStatus.text = @"working...";
//                        });
//    }
    [DynamicContent downloadAllData];
}





//- (NSArray*) readFile:(NSString*)filename {
//    // rjl 8/16/14
//    // read everything from text
////    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//
//    NSString* fileContents =
//    [NSString stringWithContentsOfFile:filename
//                              encoding:NSUTF8StringEncoding error:nil];
//    
//    // first, separate by new line
//    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
////    [pool release];
//
//    return allLinedStrings;
//}
//
//- (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile{
//    // rjl 8/16/14
////    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    NSString* downloadDir = nil;
//    bool developerEnabled = true;
//    if (developerEnabled){
//        if (isImageFile)
//            downloadDir = @"http://www.brainaid.com/wrtestdev/uploads/";
//        else
//            downloadDir = @"http://www.brainaid.com/wrtestdev/";
//    } else {
//        if (isImageFile)
//            downloadDir = @"http://www.brainaid.com/wrtest/uploads/";
//        else
//            downloadDir = @"http://www.brainaid.com/wrtest/";
//    }
//    NSString* filePath = [NSString stringWithFormat:@"%@%@", downloadDir,filename];
//    NSURL *downloadUrl = [NSURL URLWithString:filePath];
//    NSData *downloadData = [NSData dataWithContentsOfURL:downloadUrl];
//    
//    NSString* result = nil;
//    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString  *documentsDirectory = [paths objectAtIndex:0];
//
//    if ( downloadData ){
//        if (isImageFile){
//            UIImage *img = [UIImage imageWithData:downloadData];
//            [self saveImage:img filename:filename];
//        }
//        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
//        [downloadData writeToFile:filePath atomically:YES];
//        result = filePath;
//    }
//    else {
//        NSString* jpgFilename = [filename stringByReplacingOccurrencesOfString:@".png" withString:@".jpg"];
//        filePath = [NSString stringWithFormat:@"%@%@", downloadDir,jpgFilename];
//        downloadUrl = [NSURL URLWithString:filePath];
//        downloadData = [NSData dataWithContentsOfURL:downloadUrl];
//        if ( downloadData ){
//            if (isImageFile){
//                UIImage *img = [UIImage imageWithData:downloadData];
//                [self saveImage:img filename:filename];
//            }
//            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
//            [downloadData writeToFile:filePath atomically:YES];
//            result = filePath;
//        }
//        else {
//            NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
//            NSString* logMsg = [NSString stringWithFormat:@"WRViewController.downloadFile() %@", errorMsg];
//            NSLog(logMsg);
//            [self showAlertMsg:errorMsg];
//        }
//
//    }
////    [pool release];
//    return result;
//}
//
//
//- (void)saveImage: (UIImage*)image filename:(NSString*)filename{
//    NSLog(@"WRViewController.saveImage() filename: %@", filename);
//    if (image != nil){
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString* path = [documentsDirectory stringByAppendingPathComponent:  filename ];
//        NSData* data = UIImagePNGRepresentation(image);
//        [data writeToFile:path atomically:YES];
//    }
//    
//}
//
//- (UIImage*)loadImage: (NSString*)filename {
//    NSLog(@"WRViewController.loadImage() filename: %@", filename);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString* path = [documentsDirectory stringByAppendingPathComponent: filename];
//    UIImage* image = [UIImage imageWithContentsOfFile:path];
//    //    [self sendAction:path];
//    return image;
//}



//- (void) readClinicianInfo:(NSString*) filePath{
//    NSLog(@"WRViewController.readClinicianInfo()");
////    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    NSMutableArray *allClinicians = [[NSMutableArray alloc] init];
//    NSArray * lines = [self readFile:filePath];
//    for (NSString *line in lines) {
//        NSString* clinicianLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
//
//        if (clinicianLine.length > 0){
//            NSLog(@"WRViewController.readClinicianInfo() line: %@", line);
//            ClinicianInfo * clinicianInfo = [[ClinicianInfo alloc]init];
//            // parse row containing clinician details
//            NSArray* clinicianProperties = [line componentsSeparatedByCharactersInSet:
//                                        [NSCharacterSet characterSetWithCharactersInString:@";"]];
//            for (int i=0; i<[clinicianProperties count]; i++) {
//                NSString* value = clinicianProperties[i];
//                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
//                NSLog(@"WRViewController.readClinicianInfo()%d: %@", i, value);
//                switch (i) {
//                    case 0: [clinicianInfo setClinicianId:value]; break;
//                    case 1: [clinicianInfo setClinics:value]; break;
//                    case 2: [clinicianInfo setFirstName:value]; break;
//                    case 3: [clinicianInfo setLastName:value]; break;
//                    case 4: [clinicianInfo setSalutation:value]; break;
//                    case 5: [clinicianInfo setDegrees:value]; break;
//                    case 6: [clinicianInfo setCredentials:value]; break;
//                    case 7: [clinicianInfo setEdAndAffil:value]; break;
//                    case 8: [clinicianInfo setBackground:value]; break;
//                    case 9: [clinicianInfo setPhilosophy:value]; break;
//                    case 10: [clinicianInfo setPersonalInterests:value]; break;
//                } // end switch
//            } // end for
//            [allClinicians addObject:clinicianInfo];
//        } // end if clinicianLine.length > 0
//    }// end for line in lines
//    
//    NSString* msg = [NSString stringWithFormat:@"Loaded %d clinicians", [allClinicians count]];
//    NSLog(msg);
//    
//    // download the image file for each clinician
//    for (ClinicianInfo* clinician in allClinicians){
//        [clinician writeToLog];
//        NSString* clinicianImageFilename = [clinician getImageFilename];
//        [self downloadFile:clinicianImageFilename isImage:true];
//    }
//    [self showAlertMsg:msg];
////    [pool release];
//}



- (ClinicianInfo*) getCurrentClinician{
    return [DynamicContent getClinician:attendingPhysicianIndex];
//    int originalPhysicianCount = [allClinicPhysiciansBioPLists count];
//    int index = attendingPhysicianIndex;
//    if (attendingPhysicianIndex >= originalPhysicianCount){
//        index = attendingPhysicianIndex-originalPhysicianCount;
//        return [DynamicContent getClinician:index];
//    }
//    else
//        return NULL;
}


- (void)showSpinner {
    splashSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 158.0f, 158.0f)];
	[splashSpinner setCenter:CGPointMake(900.0f, 600.0f)];
	[splashSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	
    
	[self.view addSubview:splashSpinner];
	[splashSpinner startAnimating];
}

- (void)removeSpinner {
    [splashSpinner stopAnimating];
	[splashSpinner removeFromSuperview];
	[splashSpinner release];
}

- (void)sendEmailWithDataAttached {
    
    NSLog(@"attempting to send data via email...");
    // sandy updated to attach csv
    // original BOOL sendCSVFile = NO;
    BOOL sendCSVFile = YES;
    
    BOOL sendSQLFile = YES;
    
    NSString *attachmentFilename;
    
    if (sendCSVFile) {
        attachmentFilename = tbvc.csvpath;
      //  attachmentFilename = tbvc.csvpathCurrentFilename;
    } else if (sendSQLFile) {
        attachmentFilename = tbvc.databaseName;
    }
    
    if ([[AppDelegate_Pad sharedAppDelegate] isConnectivityEstablished]) {
        
        SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
        //testMsg.fromEmail = @"psc.waitingroom.app@gmail.com";
        //testMsg.toEmail = @"dmhorton@gmail.com";
        //testMsg.relayHost = @"smtp.gmail.com";
        //testMsg.requiresAuth = YES;
        //testMsg.login = @"psc.waitingroom.app@gmail.com";
        //testMsg.pass = @"polytrauma3801";
        
        //sandy's edits
        
        testMsg.fromEmail = @"psc.waitingroom.app2014@gmail.com";
        testMsg.toEmail = @"rich@brainaid.com"; //rjl 9/14/15
        //testMsg.toEmail = @"spiraljetty@yahoo.com";
        testMsg.relayHost = @"smtp.gmail.com";
        testMsg.requiresAuth = YES;
        testMsg.login = @"psc.waitingroom.app2014@gmail.com";
        testMsg.pass = @"polytrauma38012014";
        
        testMsg.subject = [NSString stringWithFormat:@"myGuide - Waiting Room App - DB Export from %@",[[UIDevice currentDevice] name]];
        //testMsg.bccEmail = @"dmhorton@gmail.com";
        //sandy edit bcc no longer supported in os7
        //testMsg.bccEmail = @"spiraljetty@yahoo.com";
        testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
        
        // Only do this for self-signed certs!
        // testMsg.validateSSLChain = NO;
        testMsg.delegate = self;
        
        NSString *msgBody = [NSString stringWithFormat:@"Polytrauma Waiting Room App - Please see attached Satisfaction DB data in file: %@. (sent from %@ running App Version: %@)", attachmentFilename, [[UIDevice currentDevice] name], appVersion];
        
        NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                                   msgBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        //        NSString *dataPath = [NSString stringWithFormat:@"%@",tbvc.csvpath];
        //NSString *csvRoot = [documentsDir stringByAppendingPathComponent:tbvc.csvpath];
        //NSString *csvRoot = [documentsDir stringByAppendingPathComponent:tbvc.csvpathCurrentFilename];
        NSString *csvRoot = [documentsDir stringByAppendingPathComponent:tbvc.csvpath];
        
        NSData *csvData = [NSData dataWithContentsOfFile:csvRoot];
        BOOL developerEnabled = YES;
        if (developerEnabled){
            [DynamicContent uploadDataFile:csvData formalFilenameParameter:tbvc.csvpath];
            [self showDataSentAlert];
            [self removeSpinner];
            [settingsVC.soundViewController uploadDataRequestDone];
            return;
        }
        else
            [DynamicContent uploadDataFileOld:csvData formalFilenameParameter:tbvc.csvpath];
        
        //    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"vcf"];
        //    NSData *vcfData = [NSData dataWithContentsOfFile:vcfPath];
        
        //    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"test.vcf\"",kSKPSMTPPartContentTypeKey,
        //                             @"attachment;\r\n\tfilename=\"test.vcf\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        NSDictionary *csvPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"satisfactiondata_9_23_14.csv\"",kSKPSMTPPartContentTypeKey,
                                 @"attachment;\r\n\tfilename=\"satisfactiondata_9_23_14.csv\"",kSKPSMTPPartContentDispositionKey,[csvData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        //NSDictionary *csvPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"satisfactiondata.csv\"",kSKPSMTPPartContentTypeKey,@"attachment;\r\n\tfilename=\"satisfactiondata.csv\"",kSKPSMTPPartContentDispositionKey,[csvData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        NSString *sqlRoot = [documentsDir stringByAppendingPathComponent:tbvc.databaseName];
        NSData *sqlData = [NSData dataWithContentsOfFile:sqlRoot];
        NSString *sqlDictionaryString = [NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"",tbvc.databaseName];
        NSString *sqlAttachmentString = [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"",tbvc.databaseName];
        NSDictionary *sqlPart = [NSDictionary dictionaryWithObjectsAndKeys:sqlDictionaryString,kSKPSMTPPartContentTypeKey,
                                 sqlAttachmentString,kSKPSMTPPartContentDispositionKey,[sqlData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        if (sendCSVFile) {
            //    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
            testMsg.parts = [NSArray arrayWithObjects:plainPart,csvPart,nil];
        } else if (sendSQLFile) {
            testMsg.parts = [NSArray arrayWithObjects:plainPart,sqlPart,nil];
        } else {
            testMsg.parts = [NSArray arrayWithObjects:plainPart,nil];
        }
        
        //rjl 7/9/15 disabling send email (fails with bad username or password, possibly sender account)
        // [testMsg send];
        
    } else {
        NSLog(@"Please connect to WIFI or Cellular signal to send data...");
    }
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    [message release];
    
    NSLog(@"delegate - message sent");
    [self showDataSentAlert];
    [self removeSpinner];
    
    [settingsVC.soundViewController uploadDataRequestDone];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [message release];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
    
    [self showDataSendFailedAlert];
    [self removeSpinner];
    
    [settingsVC.soundViewController uploadDataRequestDone];
}

#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    mViewController = self;
	// Do any additional setup after loading the view.
    NSLog(@"WRViewController.viewDidLoad()");
    if (forceToDemoMode) {
//        [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] fadeInMiniDemoMenu];
        NSLog(@"Forcing mini demo menu to appear...");
//        [self.view bringSubviewToFront:miniDemoVC.view];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] view] bringSubviewToFront:[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] view]];
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] view] setAlpha:1.0];
        
    }
}

- (void)dealloc {
    
//    if (uxTimer) {
//        [uxTimer invalidate];
//    }
    
    if (menuCubeWebView) {
        [menuCubeWebView release];
    }
    
//    if (aWebView) {
//        [aWebView release];
//    }
    
    if (badgeImageView) {
        [badgeImageView release];
    }
    if (completedBadgeImageView) {
        [completedBadgeImageView release];
    }
    if (badgeLabel) {
        [badgeLabel release];
    }
    if (completedBadgeImageViewEdModule){
        [completedBadgeImageViewEdModule release];
    }
    
    [tbvc release];
    [edModule release];
    [allWhiteBack release];
    [clinicSegmentedControl release];
    [specialtyClinicSegmentedControl release];
    [initialSettingsLabel release];
    [clinicSelectionLabel release];
    [taperedWhiteLine release];
    [demoSwitch release];
    [demoModeLabel release];
    [visitSelectionLabel release];
    [splashImageViewB release];
    [splashImageViewBb release];
    [resourceBack release];
    [surveyResourceBack release];
    [splashImageViewC release];
    [readAloudLabel release];
    [respondentLabel release];
    [selectActivityLabel release];
    [surveyIntroLabel release];
    [surveyCompleteLabel release];
    [popoverViewController release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redirectNSLogToDocuments
{ // from: http://stackoverflow.com/questions/7271528/how-to-nslog-into-a-file
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"wr_log.txt"];
    
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void)fadeEdModulePickerOut {
    NSLog(@"WRViewController.fadeEdModulePickerOut()");
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        physicianDetailVC.view.alpha = 0.0;
        physicianModule.view.alpha = 0.0;
        
        nextPhysicianDetailButton.alpha = 0.0;
        previousPhysicianDetailButton.alpha = 0.0;
        
        //        surveyResourceBack.alpha = 1.0;
        //        voiceAssistButton.alpha = 1.0;
        //        fontsizeButton.alpha = 1.0;
        
	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(finishFadePhysicianDetailOut:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

@end
