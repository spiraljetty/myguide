//
//  WRViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import "WRViewController.h"

#import "ModalMeViewController.h"
#import "ContentViewController.h"
#import "ModalViewExampleViewController.h"
#import "PopoverPlaygroundViewController.h"
#import "DemoViewController.h"
#import "AppDelegate_Pad.h"
#import "PhysicianCellViewController.h"
#import "MasterViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

@interface WRViewController ()

@end

@implementation WRViewController

@synthesize currentInstitution, currentMainClinic, readyScreen, settingsVC;
@synthesize appVersion, isFirstVisit, deviceName;
@synthesize endOfSplashTimer, splashAnimationsFinished;
@synthesize resourceBack, surveyResourceBack, aWebView, menuCubeWebView, allWhiteBack;
@synthesize splashImageView, splashImageViewB, splashImageViewBb, splashImageViewC, splashSpinner, tabNAdView, statusViewWhiteBack;
@synthesize mapViewInitialized, mapTabEnabled;
@synthesize lastRowImportedFromUsersDb;
@synthesize tbvc, cubeViewController;
//@synthesize navigationController;
@synthesize modalViewController;
@synthesize modalContent;
//@synthesize newViewController;
@synthesize yesButton, noButton, patientButton, familyButton, caregiverButton, tbiEdButton, satisfactionButton, newsButton, clinicButton;
@synthesize beginSurveyButton, returnToMenuButton, nextSurveyItemButton, previousSurveyItemButton;
@synthesize firstVisitButton, returnVisitButton, readyAppButton, voiceAssistButton, fontsizeButton;
@synthesize readAloudLabel, respondentLabel, selectActivityLabel, surveyIntroLabel, surveyCompleteLabel, visitSelectionLabel, selectedClinic, selectedVisit;
@synthesize popoverViewController;
@synthesize taperedWhiteLine, demoSwitch, demoModeLabel, clinicSelectionLabel, clinicPickerView, currentClinicName, currentSubClinicName;
@synthesize educationModuleCompleted, educationModuleInProgress, satisfactionSurveyCompleted, satisfactionSurveyInProgress, cameFromMainMenu, mainMenuInitialized;
@synthesize initialSettingsLabel, clinicSegmentedControl, switchToSectionSegmentedControl, nextSettingsButton, edModule, physicianModule, dynamicEdModule, nextEdItemButton, previousEdItemButton, nextPhysicianDetailButton, previousPhysicianDetailButton;
@synthesize currentDynamicClinicEdModuleSpecFilename;
@synthesize agreeButton, disagreeButton, badgeImageView, badgeLabel, completedBadgeImageView, completedBadgeImageViewEdModule, edModuleCompleteLabel, edModuleIntroLabel, playMovieIcon;
@synthesize odetteButton, calvinButton, lauraButton, clinicianLabel, doctorButton, pscButton, appointmentButton;
@synthesize masterViewController, arrayDetailVCs, allClinicPhysicians, pmnrSubClinicPhysicians, splitViewController, allClinicPhysiciansThumbs, allClinicPhysiciansImages, allClinicPhysiciansBioPLists, attendingPhysicianSoundFile, allClinicPhysiciansSoundFiles;
@synthesize mainClinicName, subClinicName, attendingPhysicianName, attendingPhysicianThumb, attendingPhysicianImage, attendingPhysicianIndex, physicianDetailVC, physicianModuleCompleted, physicianModuleInProgress;

#pragma mark - INIT
NSMutableArray *titleArray;
int indexCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"In WRViewController initWithNibName...");
        runningAppInDemoMode = NO;
        
        currentInstitution = kVAPAHCS;
        currentMainClinic = kNoMainClinic;
        
        skipToSplashIntro = NO;
        skipToPhysicianDetail = NO;
        skipToEducationModule = NO;
        skipToSatisfactionSurvey = NO;
        skipToMainMenu = NO;
        
        
        badgeCreated = NO;
        finalBadgeCreated = NO;
        
        appVersion = @"1.6.5";
        //    deviceName = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] name]];
        
        NSLog(@"Running version %@", appVersion);
        
        splashAnimationsFinished = NO;
        
        currentClinicName = @"Default";
        currentSubClinicName = @"Default";
        
        mainClinicName = @"Default";
        subClinicName = @"Default";
        attendingPhysicianName = @"Default";
        attendingPhysicianThumb = @"Default";
        attendingPhysicianImage = @"Default";
        attendingPhysicianSoundFile = @"Default";
        attendingPhysicianIndex = 0;
        
        currentDynamicClinicEdModuleSpecFilename = @"Default";
        
        mainMenuInitialized = NO;
        educationModuleCompleted = NO;
        educationModuleInProgress = NO;
        satisfactionSurveyCompleted = NO;
        satisfactionSurveyInProgress = NO;
        cameFromMainMenu = NO;
        
        dynamicEdModuleInProgress = NO;
        
        selectedClinic = NO;
        selectedVisit = NO;
        
        titleArray = [[NSMutableArray arrayWithObjects:@"Generic Clinic", @"PM&R Clinic", @"PNS Clinic", nil] retain];
        indexCount = 0;
	    
        [self completeInitialApplicationLaunch];
    }
    return self;
}


- (void)completeInitialApplicationLaunch {
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    [self initSplashView];
    
	tbvc = [[RootViewController_Pad alloc] init];
    
//    self.view.rootViewController = tbvc;
    tbvc.view.alpha = 0.0;
    tbvc.view.transform = rotateRight;
    [self.view addSubview:tbvc.view];
    
    [self.view sendSubviewToBack:tbvc.view]; //CommentMe
    
    edModule = [[EdViewController_Pad alloc] init];
    
    //    self.view.rootViewController = tbvc;
    edModule.view.alpha = 0.0;
    edModule.view.transform = rotateRight;
    [self.view addSubview:edModule.view];
    [self.view sendSubviewToBack:edModule.view];
    
    physicianModule = [[PhysicianViewController_Pad alloc] init];
    
    dynamicEdModule = [[DynamicModuleViewController_Pad alloc] init];
    
    edModule.speakItemsAloud = YES;
    physicianModule.speakItemsAloud = YES;
    dynamicEdModule.speakItemsAloud = YES;
    
    [self prepareAppBeforeSplashView];
    
    popoverViewController = [[PopoverPlaygroundViewController alloc] init];
    
    [self.view addSubview:popoverViewController.view];
    [self.view sendSubviewToBack:popoverViewController.view];
    
//    [self.view makeKeyAndVisible];
    
    NSLog(@"Completed Initial Application Launch");
}

- (void)prepareAppBeforeSplashView {
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    allWhiteBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
    allWhiteBack.frame = CGRectMake(0, 0, 768, 1024);
    [self.view addSubview:allWhiteBack];
    
    //    firstVisitButton, returnVisitButton, readyAppButton, voiceAssistButton, fontsizeButton

    clinicSegmentedControl = [[UISegmentedControl alloc] initWithItems:titleArray];
    clinicSegmentedControl.frame = CGRectMake(35, 200, 650, 50);
    clinicSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
//    clinicSegmentedControl.selectedSegmentIndex = 1;
    [clinicSegmentedControl addTarget:self action:@selector(clinicSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [clinicSegmentedControl setCenter:CGPointMake(350.0f, 612.0f)];
    clinicSegmentedControl.transform = rotateRight;
    [clinicSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    // DISABLING 'GENERIC CLINIC' AND 'PNS' UNTIL CONTENT IS READY
    [clinicSegmentedControl setEnabled:NO forSegmentAtIndex:0];
    [clinicSegmentedControl setEnabled:NO forSegmentAtIndex:2];
    [self.view addSubview:clinicSegmentedControl];
    
    initialSettingsLabel = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)];
    initialSettingsLabel.drawBlackOutline = YES;
    initialSettingsLabel.drawGradient = YES;
    initialSettingsLabel.text = @"Launch Settings";
    initialSettingsLabel.textAlignment = UITextAlignmentCenter;
    initialSettingsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:60];
    [initialSettingsLabel setCenter:CGPointMake(100.0f, 512.0f)];
    initialSettingsLabel.transform = rotateRight;
    [self.view addSubview:initialSettingsLabel];
    
    clinicSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 700, 250)];
	clinicSelectionLabel.text = @"Please select the appropriate clinic:";
	clinicSelectionLabel.textAlignment = UITextAlignmentCenter;
	clinicSelectionLabel.textColor = [UIColor blackColor];
	clinicSelectionLabel.backgroundColor = [UIColor clearColor];
    clinicSelectionLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	clinicSelectionLabel.opaque = YES;
	[clinicSelectionLabel setCenter:CGPointMake(270.0f, 750.0f)];
    clinicSelectionLabel.transform = rotateRight;
    
    [self.view addSubview:clinicSelectionLabel];
    
    clinicianLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 700, 250)];
	clinicianLabel.text = @"Selected:";
	clinicianLabel.textAlignment = UITextAlignmentCenter;
	clinicianLabel.textColor = [UIColor blackColor];
	clinicianLabel.backgroundColor = [UIColor clearColor];
    clinicianLabel.font = [UIFont fontWithName:@"Avenir" size:25];
    clinicianLabel.numberOfLines = 0;
	clinicianLabel.opaque = YES;
	[clinicianLabel setCenter:CGPointMake(650.0f, 419.0f)];
    clinicianLabel.alpha = 0.0;
    clinicianLabel.transform = rotateRight;
    
    [self.view addSubview:clinicianLabel];
    [self.view sendSubviewToBack:clinicianLabel];
    
    taperedWhiteLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapered_fade_dividing_line-horiz-lrg.png"]];
    taperedWhiteLine.frame = CGRectMake(0, 0, 700, 50);
    [taperedWhiteLine setCenter:CGPointMake(200.0f, 512.0f)];
    taperedWhiteLine.transform = rotateRight;
    [self.view addSubview:taperedWhiteLine];
    
    demoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 26.0)];
    [demoSwitch addTarget:self action:@selector(demoSwitchFlipped:) forControlEvents:UIControlEventTouchUpInside];
    [demoSwitch setOn:NO];
    [demoSwitch setCenter:CGPointMake(600.0f, 700.0f)];
    [demoSwitch setBackgroundColor:[UIColor clearColor]];
    demoSwitch.transform = rotateRight;
    [self.view addSubview:demoSwitch];
    
    demoModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
	demoModeLabel.text = @"Demo Mode:";
	demoModeLabel.textAlignment = UITextAlignmentCenter;
	demoModeLabel.textColor = [UIColor blackColor];
	demoModeLabel.backgroundColor = [UIColor clearColor];
    demoModeLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	demoModeLabel.opaque = YES;
	[demoModeLabel setCenter:CGPointMake(600.0f, 900.0f)];
    demoModeLabel.transform = rotateRight;
    
    [self.view addSubview:demoModeLabel];
    
    nextSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextSettingsButton.frame = CGRectMake(0, 0, 150, 139);
	nextSettingsButton.showsTouchWhenHighlighted = YES;
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image.png"] forState:UIControlStateNormal];
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[nextSettingsButton setImage:[UIImage imageNamed:@"next_button_image_pressed.png"] forState:UIControlStateSelected];
	nextSettingsButton.backgroundColor = [UIColor clearColor];
    [nextSettingsButton setCenter:CGPointMake(685.0f, 80.0f)];
	[nextSettingsButton addTarget:self action:@selector(slideVisitButtonsOut) forControlEvents:UIControlEventTouchUpInside];
	nextSettingsButton.enabled = NO;
	nextSettingsButton.hidden = NO;
	[nextSettingsButton retain];
    nextSettingsButton.transform = rotateRight;
    [self.view addSubview:nextSettingsButton];
    
    visitSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
	visitSelectionLabel.text = @"Patient's first visit or a return visit?";
	visitSelectionLabel.textAlignment = UITextAlignmentCenter;
	visitSelectionLabel.textColor = [UIColor blackColor];
	visitSelectionLabel.backgroundColor = [UIColor clearColor];
    visitSelectionLabel.font = [UIFont fontWithName:@"Avenir" size:30];
	visitSelectionLabel.opaque = YES;
	[visitSelectionLabel setCenter:CGPointMake(430.0f, 755.0f)];
    visitSelectionLabel.transform = rotateRight;
    
    [self.view addSubview:visitSelectionLabel];
    
    //firstVisitButton - decide if patient's first visit
	firstVisitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	firstVisitButton.frame = CGRectMake(0, 0, 113, 76);
	firstVisitButton.showsTouchWhenHighlighted = YES;
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image.png"] forState:UIControlStateNormal];
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[firstVisitButton setImage:[UIImage imageNamed:@"first_visit_button_image_pressed.png"] forState:UIControlStateSelected];
	firstVisitButton.backgroundColor = [UIColor clearColor];
	[firstVisitButton setCenter:CGPointMake(500.0f, 860.0f)];
	[firstVisitButton addTarget:self action:@selector(visitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	firstVisitButton.enabled = YES;
	firstVisitButton.hidden = NO;
    firstVisitButton.selected = YES;
    //    firstVisitButton.alpha = 0.0;
	[firstVisitButton retain];
    firstVisitButton.transform = rotateRight;
    
    [self.view addSubview:firstVisitButton];
    
    switchToSectionSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Skip to Splash", @"Skip to Physician", @"Skip to Ed", @"Skip to Survey", @"Skip to Menu", nil]];
    switchToSectionSegmentedControl.frame = CGRectMake(35, 200, 800, 50);
    switchToSectionSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
//    switchToSectionSegmentedControl.selectedSegmentIndex = 1;
    [switchToSectionSegmentedControl addTarget:self action:@selector(skipToSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [switchToSectionSegmentedControl setCenter:CGPointMake(675.0f, 612.0f)];
    [switchToSectionSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    switchToSectionSegmentedControl.transform = rotateRight;
    switchToSectionSegmentedControl.alpha = 0.0;
    [self.view addSubview:switchToSectionSegmentedControl];
    [self.view sendSubviewToBack:switchToSectionSegmentedControl];
    
    //returnVisitButton - decide if patient's followup/return visit
	returnVisitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnVisitButton.frame = CGRectMake(0, 0, 113, 76);
	returnVisitButton.showsTouchWhenHighlighted = YES;
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image.png"] forState:UIControlStateNormal];
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[returnVisitButton setImage:[UIImage imageNamed:@"return_visit_button_image_pressed.png"] forState:UIControlStateSelected];
	returnVisitButton.backgroundColor = [UIColor clearColor];
	[returnVisitButton setCenter:CGPointMake(500.0f, 660.0f)];
	[returnVisitButton addTarget:self action:@selector(visitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	returnVisitButton.enabled = YES;
	returnVisitButton.hidden = NO;
    returnVisitButton.selected = YES;
    //    returnVisitButton.alpha = 0.0;
	[returnVisitButton retain];
    returnVisitButton.transform = rotateRight;
    
    [self.view addSubview:returnVisitButton];
    
    settingsVC = [[SettingsViewController alloc] init];
    settingsVC.view.frame = CGRectMake(0, 0, 1024, 650);
    settingsVC.view.backgroundColor = [UIColor clearColor];
//    [settingsVC.view setCenter:CGPointMake(270.0f, 640.0f)];
    [settingsVC.view setCenter:CGPointMake(1050.0f, 512.0f)];
    settingsVC.view.transform = rotateRight;
    [self.view addSubview:settingsVC.view];
    
    [self createClinicSplitViewController];
    splitViewController.view.transform = rotateRight;
    splitViewController.view.alpha = 0.0;
    [self.view addSubview:splitViewController.view];
    [self.view sendSubviewToBack:splitViewController.view];
    
    //readyAppButton - launch splashView images and prompts once staff have been selected
	readyAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
	readyAppButton.frame = CGRectMake(0, 0, 258, 182);
	readyAppButton.showsTouchWhenHighlighted = YES;
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button.png"] forState:UIControlStateNormal];
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button_pressed.png"] forState:UIControlStateHighlighted];
	[readyAppButton setImage:[UIImage imageNamed:@"ready_button_pressed.png"] forState:UIControlStateSelected];
	readyAppButton.backgroundColor = [UIColor clearColor];
	[readyAppButton setCenter:CGPointMake(670.0f, 130.0f)];
	[readyAppButton addTarget:self action:@selector(readyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	readyAppButton.enabled = NO;
	readyAppButton.hidden = NO;
    readyAppButton.alpha = 0.0;
	[readyAppButton retain];
    readyAppButton.transform = rotateRight;
    
    [self.view addSubview:readyAppButton];
    [self.view sendSubviewToBack:readyAppButton];
    
    
    NSLog(@"Prepared pre-splash items");
}

#pragma mark - clinic and provider/physician picker

- (void)createClinicSplitViewController {
    masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
    
    allClinicPhysicians = [@[@"Lawrence Huang, M.D.",
                           @"Steven Chao, M.D., Ph.D.",
                           @"Ninad Karandikar, M.D.",
                           @"Wade Kingery, M.D.",
                           @"Roger Klima, M.D.",
                           @"Oanh Mandal, M.D.",
                           @"Ted Scott, M.D.",
                           @"Kamala Shankar, M.D.",
                           @"Jeff Teraoka, M.D."] mutableCopy];
    
    allClinicPhysiciansThumbs = [@[@"pmnr_huang_thumb.png",
                                 @"pmnr_chao_thumb.png",
                           @"pmnr_karandikar_thumb.png",
                           @"pmnr_kingery_thumb.png",
                           @"pmnr_klima_thumb.png",
                           @"pmnr_mandal_thumb.png",
                           @"pmnr_scott_thumb.png",
                           @"pmnr_shankar_thumb.png",
                           @"pmnr_teraoka_thumb.png"] mutableCopy];
    
    allClinicPhysiciansImages = [@[@"pmnr_huang.png",
                                 @"pmnr_chao.png",
                                 @"pmnr_karandikar.png",
                                 @"pmnr_kingery.png",
                                 @"pmnr_klima.png",
                                 @"pmnr_mandal.png",
                                 @"pmnr_scott.png",
                                 @"pmnr_shankar.png",
                                 @"pmnr_teraoka.png"] mutableCopy];
        
    pmnrSubClinicPhysicians = [[NSArray alloc] initWithObjects:allClinicPhysicians,
                               [NSArray arrayWithObjects:@"Lawrence Huang, M.D.",
                                @"Ninad Karandikar, M.D.",
                                @"Wade Kingery, M.D.",
                                @"Roger Klima, M.D.",
                                @"Oanh Mandal, M.D.",
                                @"Kamala Shankar, M.D.",nil],
                               [NSArray arrayWithObjects:@"Ninad Karandikar, M.D.",
                                @"Wade Kingery, M.D.",
                                @"Roger Klima, M.D.",
                                @"Ted Scott, M.D.",
                                @"Jeff Teraoka, M.D.",nil],
                               [NSArray arrayWithObjects:@"Steven Chao, M.D., Ph.D.",
                                @"Oanh Mandal, M.D.",nil],
                               [NSArray arrayWithObjects:@"Jeff Teraoka, M.D.", nil], nil];
    
    allClinicPhysiciansBioPLists = [@[@"pmnr_huang_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_scott_bio",
                                    @"pmnr_placeholder_bio",
                                    @"pmnr_teraoka_bio"] mutableCopy];
    
    allClinicPhysiciansSoundFiles = [@[@"pmnr_huang",
                                     @"pmnr_chao",
                                     @"pmnr_karandikar",
                                     @"pmnr_kingery",
                                     @"pmnr_klima",
                                     @"pmnr_mandal",
                                     @"pmnr_scott",
                                     @"pmnr_shankar",
                                     @"pmnr_teraoka"] mutableCopy];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    PhysicianCellViewController *newDetailViewController0 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController1 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController2 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController3 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    PhysicianCellViewController *newDetailViewController4 = [[PhysicianCellViewController alloc] initWithCollectionViewLayout:layout];
    
    arrayDetailVCs = [[NSArray alloc]initWithObjects:newDetailViewController0, newDetailViewController1, newDetailViewController2, newDetailViewController3, newDetailViewController4, nil];
    
    masterViewController.myDetailViewController = newDetailViewController0;
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = @[
    [[UINavigationController alloc] initWithRootViewController:masterViewController],
    [[UINavigationController alloc] initWithRootViewController:newDetailViewController0]
    ];
    splitViewController.delegate = self;
}

- (void)setNewDetailVCForRow:(int)newRow {
    
    NSArray *newVCs = [NSArray arrayWithObjects:[splitViewController.viewControllers objectAtIndex:0], [arrayDetailVCs objectAtIndex:newRow], nil];
    
    splitViewController.viewControllers = newVCs;
    
    NSLog(@"Updated detail VC for master VC row: %d",newRow);
}

#pragma mark HorizontalPickerView DataSource Methods

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	return [titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
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
    if (clinicSegmentedControl.selectedSegmentIndex == 0) {
        currentClinicName = @"Generic Clinic";
        currentMainClinic = kGeneralClinic;
    } else if (clinicSegmentedControl.selectedSegmentIndex == 1) {
        currentClinicName = @"PM&R Clinic";
        currentMainClinic = kPMNRClinic;
    } else {
        currentClinicName = @"PNS Clinic";
        currentMainClinic = kPNSClinic;
    }
    initialSettingsLabel.text = [NSString stringWithFormat:@"%@ App - Launch Settings",currentClinicName];
    
    mainClinicName = currentClinicName;
    
    [self updateMiniDemoSettings];
    
    selectedClinic = YES;
    
    if (selectedVisit) {
        nextSettingsButton.enabled = YES;
    }
    
    [self setDynamicEdClinicSpecFileForClinicName:currentClinicName];
}

- (void)setDynamicEdClinicSpecFileForClinicName:(NSString *)thisClinicName {
    if ([thisClinicName isEqualToString:@"PM&R Clinic"]) {
        currentDynamicClinicEdModuleSpecFilename = @"pmnr_education_module_test1";
    }
}

- (void)demoSwitchFlipped:(id)sender {
    if (demoSwitch.isOn) {
        runningAppInDemoMode = YES;
        NSLog(@"Demo Mode ON");
        [self.view bringSubviewToFront:switchToSectionSegmentedControl];
        
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
        NSLog(@"Demo Mode OFF");
        
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
    
    if (runningAppInDemoMode) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setDemoText:@"Yes"];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setDemoText:@"No"];
    }
    
//    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setClinicText:currentClinicName];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setClinicText:[NSString stringWithFormat:@"%@",currentClinicName]];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setSubClinicText:[NSString stringWithFormat:@"%@",currentSubClinicName]];
    
    if (isFirstVisit) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setVisitText:@"First"];
    } else {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] miniDemoVC] setVisitText:@"Return"];
    }
    
    if (satisfactionSurveyCompleted) {
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
    int currentPhysicianIndex;
    int physicianArrayIndex = 0;
    
    for (NSString *thisPhysicianName in allClinicPhysicians)
            {
                if ([thisPhysicianName isEqualToString:selectedPhysicianName]) {
                    currentPhysicianIndex = physicianArrayIndex;
                }
                physicianArrayIndex++;
            }
    NSLog(@"Selected index: %d",currentPhysicianIndex);
    
    attendingPhysicianName = selectedPhysicianName;
    attendingPhysicianImage = [allClinicPhysiciansImages objectAtIndex:currentPhysicianIndex];
    attendingPhysicianThumb = [allClinicPhysiciansThumbs objectAtIndex:currentPhysicianIndex];
    attendingPhysicianIndex = currentPhysicianIndex;
    attendingPhysicianSoundFile = [allClinicPhysiciansSoundFiles objectAtIndex:currentPhysicianIndex];
    
    [self updateMiniDemoSettings];
}

- (void)visitButtonPressed:(id)sender {
    
    if (sender == firstVisitButton) {
		NSLog(@"firstVisitButton Pressed - setup for welcome for initial visit");
        isFirstVisit = YES;
        firstVisitButton.selected = NO;
        returnVisitButton.selected = YES;
        firstVisitButton.alpha = 1.0;
        returnVisitButton.alpha = 0.5;
	} else if (sender == returnVisitButton) {
		NSLog(@"returnVisitButton Pressed - setup for welcome for return visit");
        isFirstVisit = NO;
        firstVisitButton.selected = YES;
        returnVisitButton.selected = NO;
        firstVisitButton.alpha = 0.5;
        returnVisitButton.alpha = 1.0;
    }
    
    [self updateMiniDemoSettings];
    
    selectedVisit = YES;
    
    if (selectedClinic) {
        nextSettingsButton.enabled = YES;
    }
}

- (void)slideVisitButtonsOut {
    CGRect firstVisitFrame = firstVisitButton.frame;
    CGRect returnVisitFrame = returnVisitButton.frame;
    CGRect labelFrame = visitSelectionLabel.frame;
    firstVisitFrame.origin.y = 1500;
    returnVisitFrame.origin.y = -500;
    labelFrame.origin.x = 1500;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        firstVisitButton.frame = firstVisitFrame;
        returnVisitButton.frame = returnVisitFrame;
        visitSelectionLabel.frame = labelFrame;
        
        clinicSegmentedControl.alpha = 0.0;
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
    
    [self.view bringSubviewToFront:splitViewController.view];
    
    [self.view bringSubviewToFront:readyAppButton];

    
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
    NSLog(@"APP READY");
    
    // Have selected a clinician/physician at this point
    [self updateMiniDemoSettings];
    
    [self slideClinicianSelectorAndReadyButtonOut];

    [self initializeReadyScreen];
    [self fadeInReadyScreen];
    
    [self initializePhysicianDetailView];
    [self initializeDynamicEducationModule];
    
}

- (void)startButtonPressed:(id)sender {
    NSLog(@"START APP");
    
//    [self launchAppWithSplashView];
    
    [self fadeThisObjectOut:readyScreen];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(beginToLaunchApp:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
}

#pragma mark - Physician/Provider Detail Module Methods

- (void)initializePhysicianDetailView {
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    physicianDetailVC = [[PhysicianDetailViewController alloc] initWithNibName:nil bundle:nil];
    physicianDetailVC.view.alpha = 0.0;
//    physicianDetailVC.view.frame = CGRectMake(0, 0, 1024, 233);
    physicianDetailVC.view.backgroundColor = [UIColor clearColor];
    [physicianDetailVC.view setCenter:CGPointMake(500.0f, 384.0f)];
    physicianDetailVC.view.transform = rotateRight;
    
    [self.view addSubview:physicianDetailVC.view];
    [self.view sendSubviewToBack:physicianDetailVC.view];
    
    [self setUpPhysicianViewContentsFromPropertyList];
    
    NSLog(@"Physician Detail Initialized...");
}

- (void)setUpPhysicianViewContentsFromPropertyList {
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
//    physicianModule = [[PhysicianViewController_Pad alloc] init];
//    [nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
//    [previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *currentPhysicianPListName = [allClinicPhysiciansBioPLists objectAtIndex:attendingPhysicianIndex];
    
    NSData *tmp = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:currentPhysicianPListName withExtension:@"plist"] options:NSDataReadingMappedIfSafe error:nil];
    physicianModule.currentPhysicianDetails = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
    physicianModule.currentPhysicianDetailSectionNames = [[physicianModule.currentPhysicianDetails allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    physicianModule.view.alpha = 0.0;
    physicianModule.view.transform = rotateRight;
    [self.view addSubview:physicianModule.view];
    [self.view sendSubviewToBack:physicianModule.view];
    
//    [nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
//    [previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];


}

- (void)fadePhysicianDetailVCIn {
    
    NSLog(@"Fading in physician Detail");
    
    physicianModuleInProgress = YES;
    
    physicianModule.view.alpha = 0.0;
        
    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:physicianModule.view];
    
    [self.view bringSubviewToFront:physicianDetailVC.view];
    
    [self.view bringSubviewToFront:nextPhysicianDetailButton];
    [self.view bringSubviewToFront:previousPhysicianDetailButton];
    
//    [self.view bringSubviewToFront:voiceAssistButton];
//    [self.view bringSubviewToFront:fontsizeButton];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

        physicianDetailVC.view.alpha = 1.0;
        physicianModule.view.alpha = 1.0;
        
        nextPhysicianDetailButton.alpha = 1.0;
        previousPhysicianDetailButton.alpha = 1.0;
        
        surveyResourceBack.alpha = 1.0;
//        voiceAssistButton.alpha = 1.0;
//        fontsizeButton.alpha = 1.0;

	}
	[UIView commitAnimations];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:physicianModule selector:@selector(sayPhysicianDetailIntro) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:physicianDetailVC selector:@selector(beginFadeOutOfCareHandledByLabel) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
//    [physicianModule sayPhysicianDetailIntro];
}

- (void)fadePhysicianDetailOut {
    NSLog(@"Fading out physician Detail");
    
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
    
    [self.view sendSubviewToBack:physicianDetailVC.view];
    [self.view sendSubviewToBack:physicianModule.view];
    [self.view sendSubviewToBack:nextPhysicianDetailButton];
    [self.view sendSubviewToBack:previousPhysicianDetailButton];
    
    [theTimer release];
	theTimer = nil;
    
    NSLog(@"Finished fading out physician Detail");
}

#pragma mark - Dynamic Clinic Education Module Methods

- (void)initializeDynamicEducationModule {
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
//    dynamicEdModule = [[DynamicModuleViewController_Pad alloc] initWithPropertyList:currentDynamicClinicEdModuleSpecFilename];
    [dynamicEdModule setupWithPropertyList:currentDynamicClinicEdModuleSpecFilename];
//    dynamicEdModule.speakItemsAloud = YES;
    
    dynamicEdModule.view.alpha = 0.0;
    dynamicEdModule.view.transform = rotateRight;
    [self.view addSubview:dynamicEdModule.view];
    [self.view sendSubviewToBack:dynamicEdModule.view];
    
    NSLog(@"Dynamic Clinic Education Module Initialized with spec file: %@.plist",currentDynamicClinicEdModuleSpecFilename);
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
    
    NSLog(@"Fading in dynamic ed module");
    
    dynamicEdModuleInProgress = YES;
    
    dynamicEdModule.view.alpha = 0.0;
    
//    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:dynamicEdModule.view];
    
//    [self.view bringSubviewToFront:physicianDetailVC.view];
    
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

- (void)slideClinicianSelectorAndReadyButtonOut {
    CGRect launchFrame = readyAppButton.frame;
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
    NSLog(@"Initializing ready screen...");
    
    
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
    
    switch (currentMainClinic) {
        case kGeneralClinic:
            currentMainClinicText = @"";
            break;
        case kPMNRClinic:
            if ([currentSubClinicName isEqualToString:@"PM&R"]) {
                currentMainClinicText = @"";
                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic",currentSubClinicName];
            } else if ([currentSubClinicName isEqualToString:@"All"]) {
                currentMainClinicText = @"PM&R";
                currentSubClinicText = @"Clinic";
            } else {
                currentMainClinicText = @"PM&R";
                currentSubClinicText = [NSString stringWithFormat:@"%@ Clinic",currentSubClinicName];
            }
            break;
        case kPNSClinic:
            currentMainClinicText = @"PNS";
            break;
        case kNoMainClinic:
            currentMainClinicText = @"";
            break;
        default:
            currentMainClinicText = @"";
            break;
    }
    
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
        [tbvc sayWelcomeToApp];
        [self animateTabBarOnAndStatusBackIn];
    }
}

- (void)initSplashView {
    
    splashImageViewB = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_launch-ipad_landscape.png"]];
    
    splashImageViewBb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_prc_splash1-ipad_landscape2.png"]];
	
    
    splashImageViewB.alpha = 0.0;
    splashImageViewBb.alpha = 0.0;
    
    [self.view addSubview:splashImageViewB];
    [self.view addSubview:splashImageViewBb];
    [self.view sendSubviewToBack:splashImageViewB];
    [self.view sendSubviewToBack:splashImageViewBb];
    
    NSLog(@"Initialized splash views");
	
}

- (void)selectedSatisfactionWithVC:(id)sender andSegmentIndex:(int)selectedIndex {
    [tbvc madeSatisfactionRatingForVC:sender withSegmentIndex:selectedIndex];
}

- (BOOL)isAppRunningInDemoMode {
    
    return runningAppInDemoMode;
}



- (void)animateTabBarOnAndStatusBackIn {
	NSLog(@"SPLASH 2...");
    
    [self.view bringSubviewToFront:splashImageViewB];
    
//	self.checkingForReachability = NO;
    [[AppDelegate_Pad sharedAppDelegate] setCheckingForReachability:NO];

    
    [UIView beginAnimations:@"animateTabBarOnAndButtonsIn" context:nil];
	{
		[UIView	setAnimationDuration:1.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        //        splashImageView.alpha = 0.0;
        
    }
	[UIView commitAnimations];
	
	[UIView beginAnimations:@"animateTabBarOnAndButtonsIn" context:nil];
	{
		[UIView	setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //		[tabNAdView setTransform:CGAffineTransformIdentity];
        //            tabNAdView.alpha = 0.0;
        splashImageViewB.alpha = 1.0;
	}
	[UIView commitAnimations];
	
	endOfSplashTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(finishSplashAnimation:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishSplashAnimation:(NSTimer*)theTimer {
    
	[self.view bringSubviewToFront:splashImageViewBb];

    [self.view sendSubviewToBack:odetteButton];
    [self.view sendSubviewToBack:calvinButton];
    [self.view sendSubviewToBack:lauraButton];
    [self.view sendSubviewToBack:clinicianLabel];
    
    
	[UIView beginAnimations:@"fadeSplashOut" context:nil];
	{
		[UIView	setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        //        splashImageViewBb.alpha = 1.0;
        
        splashImageViewB.alpha = 0.0;
		
	}
	[UIView commitAnimations];
	
	[theTimer release];
	theTimer = nil;
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(fadeSplashOutAndSlideButtonsIn:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)sqlConnectedAnimation {
    
}

- (void)fadeSplashOutAndSlideButtonsIn:(NSTimer*)theTimer {
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //    resourceBack.alpha = 1.0;
    
    if (!skipToPhysicianDetail) {
        
        
        
        [self.view sendSubviewToBack:splashImageViewB];
        
        [UIView beginAnimations:@"fadeSplashOut" context:nil];
        {
            [UIView	setAnimationDuration:1.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            //        splashImageViewC.alpha = 1.0;
            
            splashImageViewBb.alpha = 1.0;
            
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
	[nextSurveyItemButton setCenter:CGPointMake(685.0f, 80.0f)];
	[nextSurveyItemButton addTarget:tbvc action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextSurveyItemButton.enabled = YES;
	nextSurveyItemButton.hidden = NO;
    nextSurveyItemButton.alpha = 0.0;
	[nextSurveyItemButton retain];
    nextSurveyItemButton.transform = rotateRight;
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
	[previousSurveyItemButton setCenter:CGPointMake(685.0f, 945.0f)];
	[previousSurveyItemButton addTarget:tbvc action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousSurveyItemButton.enabled = NO;
	previousSurveyItemButton.hidden = NO;
    previousSurveyItemButton.alpha = 0.0;
	[previousSurveyItemButton retain];
    previousSurveyItemButton.transform = rotateRight;
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
	[nextEdItemButton setCenter:CGPointMake(685.0f, 80.0f)];
	[nextEdItemButton addTarget:self action:@selector(beginEducationModule:) forControlEvents:UIControlEventTouchUpInside];
//    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextEdItemButton.enabled = YES;
	nextEdItemButton.hidden = NO;
    nextEdItemButton.alpha = 0.0;
	[nextEdItemButton retain];
    nextEdItemButton.transform = rotateRight;
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
	[previousEdItemButton setCenter:CGPointMake(685.0f, 945.0f)];
	[previousEdItemButton addTarget:edModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousEdItemButton.enabled = NO;
	previousEdItemButton.hidden = NO;
    previousEdItemButton.alpha = 0.0;
	[previousEdItemButton retain];
    previousEdItemButton.transform = rotateRight;
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
	[nextPhysicianDetailButton setCenter:CGPointMake(685.0f, 80.0f)];
//	[nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    //    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    [nextPhysicianDetailButton addTarget:physicianModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
	nextPhysicianDetailButton.enabled = YES;
	nextPhysicianDetailButton.hidden = NO;
    nextPhysicianDetailButton.alpha = 0.0;
	[nextPhysicianDetailButton retain];
    nextPhysicianDetailButton.transform = rotateRight;
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
	[previousPhysicianDetailButton setCenter:CGPointMake(685.0f, 945.0f)];
//	[previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
    [previousPhysicianDetailButton addTarget:physicianModule action:@selector(progress:) forControlEvents:UIControlEventTouchUpInside];
	previousPhysicianDetailButton.enabled = NO;
	previousPhysicianDetailButton.hidden = NO;
    previousPhysicianDetailButton.alpha = 0.0;
	[previousPhysicianDetailButton retain];
    previousPhysicianDetailButton.transform = rotateRight;
    [self.view addSubview:previousPhysicianDetailButton];
    [self.view sendSubviewToBack:previousPhysicianDetailButton];
    
//    splashImageViewC = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_SS_splash2-new_ipad_landscape3_sml2.png"]];
//    splashImageViewC = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
//    splashImageViewC.alpha = 0.0;
	
//	[self.view addSubview:splashImageViewC];
//    [self.view sendSubviewToBack:splashImageViewC];
	
	[theTimer release];
	theTimer = nil;
	
	endOfSplashTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(removeSplashView:) userInfo:nil repeats:NO] retain];
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
	NSLog(@"Removing the splash view, tabNAdview, statusViewWhiteBack, splashSpinner and stopping the spinner...");
    
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
	[readAloudLabel setCenter:CGPointMake(670.0f, 512.0f)];
    readAloudLabel.transform = rotateRight;
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
	[respondentLabel setCenter:CGPointMake(670.0f, 512.0f)];
    respondentLabel.transform = rotateRight;
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
	[selectActivityLabel setCenter:CGPointMake(65.0f, 512.0f)];
    selectActivityLabel.transform = rotateRight;
	selectActivityLabel.alpha = 0.0;
    
    [self.view addSubview:selectActivityLabel];
    [self.view sendSubviewToBack:selectActivityLabel];
    
    surveyIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    surveyIntroLabel.numberOfLines = 0;
	surveyIntroLabel.text = @"Your participation in this survey is voluntary, and anonymous. Your responses will not be given to your physician or any other clinic staff. In addition, your responses will not influence the services you receive at this clinic. By agreeing to participate, you can help us provide a better rehabilitation experience.";
	surveyIntroLabel.textColor = [UIColor blackColor];
	surveyIntroLabel.backgroundColor = [UIColor clearColor];
    surveyIntroLabel.font = [UIFont fontWithName:@"Avenir" size:34];
	surveyIntroLabel.opaque = YES;
	[surveyIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
    surveyIntroLabel.transform = rotateRight;
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
	[surveyCompleteLabel setCenter:CGPointMake(300.0f, 525.0f)];
    surveyCompleteLabel.transform = rotateRight;
	surveyCompleteLabel.alpha = 0.0;
    
    [self.view addSubview:surveyCompleteLabel];
    [self.view sendSubviewToBack:surveyCompleteLabel];
    
    edModuleIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    edModuleIntroLabel.numberOfLines = 0;
	edModuleIntroLabel.text = @"In the next few sections, you will be presented with information and media related to TBI and the Brain.\n\nYou can go at your own pace, and move ahead when you want to. If you see a green icon like the one below, tap it, and a movie will begin.\n\nPress next to continue.";
	edModuleIntroLabel.textColor = [UIColor blackColor];
	edModuleIntroLabel.backgroundColor = [UIColor clearColor];
    edModuleIntroLabel.font = [UIFont fontWithName:@"Avenir" size:34];
	edModuleIntroLabel.opaque = YES;
	[edModuleIntroLabel setCenter:CGPointMake(400.0f, 512.0f)];
    edModuleIntroLabel.transform = rotateRight;
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
	[edModuleCompleteLabel setCenter:CGPointMake(300.0f, 525.0f)];
    edModuleCompleteLabel.transform = rotateRight;
	edModuleCompleteLabel.alpha = 0.0;
    
    [self.view addSubview:edModuleCompleteLabel];
    [self.view sendSubviewToBack:edModuleCompleteLabel];
    
    //playMovieIcon
    playMovieIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_play_icon.png"]];
    playMovieIcon.frame = CGRectMake(0, 0, 176, 176);
    playMovieIcon.transform = rotateRight;
    [playMovieIcon setCenter:CGPointMake(670.0f, 512.0f)];
    playMovieIcon.alpha = 0.0;
    
    [self.view addSubview:playMovieIcon];
    [self.view sendSubviewToBack:playMovieIcon];
    
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
	[yesButton setCenter:CGPointMake(380.0f, 760.0f)];
	[yesButton addTarget:self action:@selector(yesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
	yesButton.enabled = YES;
	yesButton.hidden = NO;
    yesButton.alpha = 0.0;
	[yesButton retain];
    yesButton.transform = rotateRight;
    
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
	[noButton setCenter:CGPointMake(380.0f, 264.0f)];
    [noButton addTarget:self action:@selector(yesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
	noButton.enabled = YES;
	noButton.hidden = NO;
    noButton.alpha = 0.0;
	[noButton retain];
    noButton.transform = rotateRight;
    
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
	[patientButton setCenter:CGPointMake(380.0f, 853.0f)];
    [patientButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	patientButton.enabled = YES;
	patientButton.hidden = NO;
    patientButton.alpha = 0.0;
	[patientButton retain];
    patientButton.transform = rotateRight;
    
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
	[familyButton setCenter:CGPointMake(380.0f, 512.0f)];
    [familyButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	familyButton.enabled = YES;
	familyButton.hidden = NO;
    familyButton.alpha = 0.0;
	[familyButton retain];
    familyButton.transform = rotateRight;
    
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
	[caregiverButton setCenter:CGPointMake(380.0f, 171.0f)];
    [caregiverButton addTarget:self action:@selector(respondentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	caregiverButton.enabled = YES;
	caregiverButton.hidden = NO;
    caregiverButton.alpha = 0.0;
	[caregiverButton retain];
    caregiverButton.transform = rotateRight;
    
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
	[tbiEdButton setCenter:CGPointMake(227.0f, 728.0f)];
    [tbiEdButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	tbiEdButton.enabled = YES;
	tbiEdButton.hidden = NO;
    tbiEdButton.alpha = 0.0;
	[tbiEdButton retain];
    tbiEdButton.transform = rotateRight;
    
    [self.view addSubview:tbiEdButton];
    [self.view sendSubviewToBack:tbiEdButton];
    
    //satisfactionButton
    satisfactionButton = [UIButton buttonWithType:UIButtonTypeCustom];
	satisfactionButton.frame = CGRectMake(0, 0, 318, 214);
	satisfactionButton.showsTouchWhenHighlighted = YES;
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey.png"] forState:UIControlStateNormal];
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey_pressed.png"] forState:UIControlStateHighlighted];
	[satisfactionButton setImage:[UIImage imageNamed:@"satisfaction_survey_pressed.png"] forState:UIControlStateSelected];
	satisfactionButton.backgroundColor = [UIColor clearColor];
	[satisfactionButton setCenter:CGPointMake(227.0f, 296.0f)];
    [satisfactionButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	satisfactionButton.enabled = YES;
	satisfactionButton.hidden = NO;
    satisfactionButton.alpha = 0.0;
	[satisfactionButton retain];
    satisfactionButton.transform = rotateRight;
    
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
	[newsButton setCenter:CGPointMake(521.0f, 296.0f)];
    [newsButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	newsButton.enabled = YES;
	newsButton.hidden = NO;
    newsButton.alpha = 0.0;
	[newsButton retain];
    newsButton.transform = rotateRight;
    
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
	[clinicButton setCenter:CGPointMake(521.0f, 728.0f)];
    [clinicButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	clinicButton.enabled = YES;
	clinicButton.hidden = NO;
    clinicButton.alpha = 0.0;
	[clinicButton retain];
    clinicButton.transform = rotateRight;
    
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
	[doctorButton setCenter:CGPointMake(521.0f, 728.0f)];
    [doctorButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	doctorButton.enabled = YES;
	doctorButton.hidden = NO;
    doctorButton.alpha = 0.0;
	[doctorButton retain];
    doctorButton.transform = rotateRight;
    
    [self.view addSubview:clinicButton];
    [self.view sendSubviewToBack:clinicButton];
    
    agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	agreeButton.frame = CGRectMake(0, 0, 299, 200);
	agreeButton.showsTouchWhenHighlighted = YES;
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image.png"] forState:UIControlStateNormal];
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[agreeButton setImage:[UIImage imageNamed:@"agree_button_image_pressed.png"] forState:UIControlStateSelected];
	agreeButton.backgroundColor = [UIColor clearColor];
    [agreeButton setCenter:CGPointMake(580.0f, 760.0f)];
	[agreeButton addTarget:self action:@selector(agreeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	agreeButton.enabled = YES;
	agreeButton.hidden = NO;
    agreeButton.alpha = 0.0;
	[agreeButton retain];
    agreeButton.transform = rotateRight;
    [self.view addSubview:agreeButton];
    
    disagreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	disagreeButton.frame = CGRectMake(0, 0, 299, 200);
	disagreeButton.showsTouchWhenHighlighted = YES;
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image.png"] forState:UIControlStateNormal];
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image_pressed2.png"] forState:UIControlStateHighlighted];
	[disagreeButton setImage:[UIImage imageNamed:@"disagree_button_image_pressed2.png"] forState:UIControlStateSelected];
	disagreeButton.backgroundColor = [UIColor clearColor];
    [disagreeButton setCenter:CGPointMake(580.0f, 264.0f)];
	[disagreeButton addTarget:self action:@selector(disagreeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	disagreeButton.enabled = YES;
	disagreeButton.hidden = NO;
    disagreeButton.alpha = 0.0;
	[disagreeButton retain];
    disagreeButton.transform = rotateRight;
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
	[beginSurveyButton setCenter:CGPointMake(600.0f, 200.0f)];
    [beginSurveyButton addTarget:self action:@selector(beginSatisfactionSurvey:) forControlEvents:UIControlEventTouchUpInside];
	beginSurveyButton.enabled = YES;
	beginSurveyButton.hidden = NO;
    beginSurveyButton.alpha = 0.0;
	[beginSurveyButton retain];
    beginSurveyButton.transform = rotateRight;
    
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
	[returnToMenuButton setCenter:CGPointMake(725.0f, 500.0f)];
    [returnToMenuButton addTarget:self action:@selector(returnToMenu) forControlEvents:UIControlEventTouchUpInside];
	returnToMenuButton.enabled = YES;
	returnToMenuButton.hidden = NO;
    returnToMenuButton.alpha = 0.0;
	[returnToMenuButton retain];
    returnToMenuButton.transform = rotateRight;
    
    [self.view addSubview:returnToMenuButton];
    [self.view sendSubviewToBack:returnToMenuButton];
    
    //    [self.view bringSubviewToFront:tbvc.view]; // Uncommentme
    
    if (skipToMainMenu) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
        [self fadeMenuItemsIn];

    } else if (skipToSatisfactionSurvey) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
        
    } else if (skipToEducationModule) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        
    } else if (skipToPhysicianDetail) {
        
        [self setDefaultPhysician];
        [self setDefaultSubClinic];
        [self initializePhysicianDetailView];
        [self initializeDynamicEducationModule];
        [self updateMiniDemoSettings];
        [self fadePhysicianDetailVCIn];
        
    } else {
        
        if (skipToSplashIntro) {
            [self setDefaultPhysician];
            [self setDefaultSubClinic];
            [self initializePhysicianDetailView];
            [self initializeDynamicEducationModule];
            [self updateMiniDemoSettings];
        }
        // Not skipping anywhere, run as usual
        [self.view bringSubviewToFront:yesButton];
        [self.view bringSubviewToFront:noButton];
        [self.view bringSubviewToFront:readAloudLabel];
        
        
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
            
        }
        [UIView commitAnimations];
    }
    
	
	[self.view sendSubviewToBack:splashSpinner];
    
    //    [self.view bringSubviewToFront:modalViewController.view];
    //    [self.view bringSubviewToFront:newViewController.view];
    
    
	
	[theTimer release];
	theTimer = nil;
}

- (void)setDefaultPhysician {
    [self storeAttendingPhysicianSettingsForPhysicianName:[allClinicPhysicians objectAtIndex:0]];
}

- (void)setDefaultSubClinic {
    [masterViewController setSubClinicNameTo:[masterViewController.subClinicNames objectAtIndex:1]];
}

- (void)createBadgeOnSatisfactionSurveyButton {
    
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
    
    badgeImageView.transform = rotateRight;
    [badgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
    
    [self.view addSubview:badgeImageView];
    
    badgeCreated = YES;
    
//    
//    [badgeImageView release];
//    [badgeLabel release];
}

- (void)updateBadgeOnSatisfactionSurveyButton {
    if (satisfactionSurveyCompleted) {
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
        badgeLabel.alpha = 0.0;
        
        [badgeImageView release];
        badgeImageView = nil;
        
        badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        badgeImageView.frame = CGRectMake(0, 0, 57, 58);
        badgeImageView.transform = rotateRight;
        [badgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
        badgeImageView.alpha = 0.0;
        
        [self.view addSubview:badgeImageView];
        
        completedBadgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        completedBadgeImageView.frame = CGRectMake(0, 0, 57, 58);
        completedBadgeImageView.transform = rotateRight;
        [completedBadgeImageView setCenter:CGPointMake(115.0f, 165.0f)];
        completedBadgeImageView.alpha = 0.0;
        
        [self.view addSubview:completedBadgeImageView];
        
        finalBadgeCreated = YES;
        
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
    
    [self returnToMenu];
}

- (void)clinicButtonOptionPressed:(id)sender {
    if (sender == doctorButton) {
        
    } else if (sender == pscButton) {
        
    } else {
        
    }
}

- (void)voiceassistButtonPressed:(id)sender {
    
    if (tbvc.speakItemsAloud) {
		NSLog(@"voiceassistButton Pressed - turning voice OFF");
        [tbvc turnVoiceOff:sender];
        voiceAssistButton.selected = YES;
        edModule.speakItemsAloud = NO;
        physicianModule.speakItemsAloud = NO;
        dynamicEdModule.speakItemsAloud = NO;
		
	} else  {
		NSLog(@"voiceassistButton Pressed - turning voice ON");
        [tbvc turnVoiceOn:sender];
        voiceAssistButton.selected = NO;
        edModule.speakItemsAloud = YES;
        physicianModule.speakItemsAloud = YES;
        dynamicEdModule.speakItemsAloud = YES;
    }
    
    
}

- (void)yesNoPressed:(id)sender {
    
    if (sender == yesButton) {
		NSLog(@"yesButton Pressed - keeping voice ON");
        [tbvc sayOK];
		[tbvc turnVoiceOn:sender];
        edModule.speakItemsAloud = YES;
        physicianModule.speakItemsAloud = YES;
        dynamicEdModule.speakItemsAloud = YES;
		
	} else if (sender == noButton) {
        [tbvc sayOK];
        [tbvc turnVoiceOff:sender];
        edModule.speakItemsAloud = NO;
        physicianModule.speakItemsAloud = NO;
        dynamicEdModule.speakItemsAloud = NO;
    }
    
    [self slideYesNoOutAndRespondentTypeButtonsIn];
    
}

- (void)fontsizeButtonPressed:(id)sender {
//    [self showComingSoonAlert];
    [tbvc cycleFontSizeForAllLabels];
    NSLog(@"fontsizeButton Pressed - current font size: %d",tbvc.currentFontSize);
}

- (void)respondentButtonPressed:(id)sender {
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
    
    [self slideRespondentsOut];
    
    [self fadePhysicianDetailVCIn];
    
    [self updateMiniDemoSettings];
}

#pragma mark - TBI Education Module Methods

- (void)setUpEducationModuleForFirstTime {
    //        [self showComingSoonAlert];
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    edModule.view.alpha = 0.0;
    
    [self.view bringSubviewToFront:edModule.view];
    
    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:nextEdItemButton];
    [self.view bringSubviewToFront:previousEdItemButton];
    
    [self.view bringSubviewToFront:voiceAssistButton];
    [self.view bringSubviewToFront:fontsizeButton];
    [self.view bringSubviewToFront:returnToMenuButton];
    
    completedBadgeImageViewEdModule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
    completedBadgeImageViewEdModule.frame = CGRectMake(115, 700, 58, 58);
    completedBadgeImageViewEdModule.alpha = 0.0;
    completedBadgeImageViewEdModule.transform = rotateRight;
    [completedBadgeImageViewEdModule setCenter:CGPointMake(115.0f, 600.0f)];
    [self.view addSubview:completedBadgeImageViewEdModule];
    [self.view sendSubviewToBack:completedBadgeImageViewEdModule];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        edModule.view.alpha = 1.0;
        nextEdItemButton.alpha = 1.0;
        previousEdItemButton.alpha = 1.0;
        
        surveyResourceBack.alpha = 1.0;
        returnToMenuButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    educationModuleInProgress = YES;
}

- (void)reshowEducationModule {
    //        [self showComingSoonAlert];
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    edModule.view.alpha = 0.0;
    
    [self.view bringSubviewToFront:edModule.view];
    
    [self.view bringSubviewToFront:surveyResourceBack];
    
    [self.view bringSubviewToFront:nextEdItemButton];
    [self.view bringSubviewToFront:previousEdItemButton];
    
    [self.view bringSubviewToFront:voiceAssistButton];
    [self.view bringSubviewToFront:fontsizeButton];
    [self.view bringSubviewToFront:returnToMenuButton];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        edModule.view.alpha = 1.0;
        nextEdItemButton.alpha = 1.0;
        previousEdItemButton.alpha = 1.0;
        
        surveyResourceBack.alpha = 1.0;
        returnToMenuButton.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)showEducationModuleIntro {
    
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
    
    initialSettingsLabel.alpha = 0.0;
    taperedWhiteLine.alpha = 0.0;
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
		
	}
	[UIView commitAnimations];
    
    [tbvc sayEdModuleIntro];
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
    
    NSLog(@"In beginEducationModule...");
    [tbvc sayOK];
    
    [nextEdItemButton removeTarget:self action:@selector(beginEducationModule:) forControlEvents:UIControlEventTouchUpInside];
    [nextEdItemButton addTarget:edModule action:@selector(regress:) forControlEvents:UIControlEventTouchUpInside];
    
    //    if (satisfactionSurveyInProgress) {
    
    edModule.view.alpha = 0.0;
    surveyResourceBack.alpha = 0.0;
    previousEdItemButton.alpha = 0.0;
    voiceAssistButton.alpha = 0.0;
    fontsizeButton.alpha = 0.0;
    returnToMenuButton.alpha = 0.0;
    
    [self.view bringSubviewToFront:edModule.view];
    [self.view bringSubviewToFront:surveyResourceBack];
    [self.view bringSubviewToFront:nextEdItemButton];
    [self.view bringSubviewToFront:previousEdItemButton];
    [self.view bringSubviewToFront:voiceAssistButton];
    [self.view bringSubviewToFront:fontsizeButton];
    [self.view bringSubviewToFront:returnToMenuButton];
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
        surveyResourceBack.alpha = 1.0;
        nextEdItemButton.alpha = 1.0;
        previousEdItemButton.alpha = 1.0;
        voiceAssistButton.alpha = 1.0;
        fontsizeButton.alpha = 1.0;
        returnToMenuButton.alpha = 1.0;
        
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
    
    [self.view sendSubviewToBack:playMovieIcon];
    [self.view sendSubviewToBack:allWhiteBack];
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
    [self.view sendSubviewToBack:edModuleIntroLabel];
    
    
    [theTimer release];
	theTimer = nil;
}

- (void)launchEducationModule {
    if (educationModuleInProgress) {
        [self reshowEducationModule];
    } else {
        [self setUpEducationModuleForFirstTime];
        [self showEducationModuleIntro];
    }
}

- (void)edModuleFinished {
    
    if (cameFromMainMenu) {
        [tbvc sayEducationModuleCompletion];
        
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
        
        endOfSplashTimer = [[NSTimer timerWithTimeInterval:13.0 target:self selector:@selector(returnToMenuInFiveSeconds:) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
        
    } else {
        // Didn't come from main menu, so still on track to auto-load satisfaction survey
        [self launchSatisfactionSurvey];
        
    }
}

- (void)menuButtonPressed:(id)sender {
    if (sender == tbiEdButton) {
        if (educationModuleInProgress) {
            [self reshowEducationModule];
        } else {
            [self setUpEducationModuleForFirstTime];
            [self showEducationModuleIntro];
        }
        
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
        
        [self showComingSoonAlert];
        
    } else if (sender == clinicButton) {
        
//        [self showComingSoonAlert];
        [self fadeDynamicEducationModuleIn];
    }
}

- (void)showAdminKeypad {
    //    keypadViewController = [[DemoViewController alloc] init];
    //    keypadViewController.view.frame = CGRectMake(0, 0, 500, 500);
    //    [self.view addSubview:keypadViewController.view];
}

- (void)showComingSoonAlert {
    [tbvc sayComingSoon];
    UIAlertView *comingSoonAlert = [[UIAlertView alloc] initWithTitle:@"Feature Unavailable" message:@"This Feature is coming soon!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    comingSoonAlert.delegate = self;
    [comingSoonAlert show];
    [comingSoonAlert release];
}

- (void)showDataSentAlert {
    UIAlertView *dataSentAlert = [[UIAlertView alloc] initWithTitle:@"Send Data Results" message:@"Datafile successfully emailed to: david.horton3@va.gov." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    [tbvc sayRespondentTypes];
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
	[voiceAssistButton setCenter:CGPointMake(725.0f, 770.0f)];
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
    voiceAssistButton.transform = rotateRight;
    
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
	[fontsizeButton addTarget:self action:@selector(fontsizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	fontsizeButton.enabled = YES;
	fontsizeButton.hidden = NO;
    fontsizeButton.alpha = 0.0;
	[fontsizeButton retain];
    fontsizeButton.transform = rotateRight;
    
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
    
    beginSurveyButton.alpha = 0.0;
    tbvc.view.alpha = 0.0;
    [self.view bringSubviewToFront:tbvc.view];
    
    [self.view bringSubviewToFront:surveyResourceBack];
    [self.view bringSubviewToFront:nextSurveyItemButton];
    [self.view bringSubviewToFront:previousSurveyItemButton];
    [self.view bringSubviewToFront:voiceAssistButton];
    [self.view bringSubviewToFront:fontsizeButton];
    [self.view bringSubviewToFront:returnToMenuButton];
    
    allWhiteBack.alpha = 0.0;
    
    //    [self.view bringSubviewToFront:splashImageViewC];
    [self.view bringSubviewToFront:allWhiteBack];
    [self.view bringSubviewToFront:beginSurveyButton];
    [self.view bringSubviewToFront:surveyIntroLabel];
    
    
    [nextSettingsButton removeTarget:self action:@selector(slideVisitButtonsOut) forControlEvents:UIControlEventTouchUpInside];
    [nextSettingsButton addTarget:self action:@selector(fadeToNextSurveyPrompt:) forControlEvents:UIControlEventTouchUpInside];
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
    
    surveyIntroLabel.text = @"Please tap, agree, if you would like to complete the survey, or disagree, if you would like to return to the main menu.";
    [surveyIntroLabel setCenter:CGPointMake(300.0f, 512.0f)];
    
    [tbvc saySurveyAgreement];
    
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
//    [self beginSatisfactionSurvey:self];
    [self showSatisfactionIntro];
}

- (void)beginSatisfactionSurvey:(id)sender {
    
    NSLog(@"In beginSatisfactionSurvey...");
    
    if (satisfactionSurveyInProgress) {
        [self.view bringSubviewToFront:tbvc.view];
        [self.view bringSubviewToFront:surveyResourceBack];
        [self.view bringSubviewToFront:nextSurveyItemButton];
        [self.view bringSubviewToFront:previousSurveyItemButton];
        [self.view bringSubviewToFront:voiceAssistButton];
        [self.view bringSubviewToFront:fontsizeButton];
        [self.view bringSubviewToFront:returnToMenuButton];
    }
    
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
        surveyResourceBack.alpha = 1.0;
        nextSurveyItemButton.alpha = 1.0;
        previousSurveyItemButton.alpha = 1.0;
        voiceAssistButton.alpha = 1.0;
        fontsizeButton.alpha = 1.0;
        returnToMenuButton.alpha = 1.0;
        
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
        [tbvc sayFirstItem];
    }
    
    satisfactionSurveyInProgress = YES;
    
    [self updateMiniDemoSettings];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(completeBeginSatisfactionSurvey:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

- (void)completeBeginSatisfactionSurvey:(NSTimer*)theTimer {
    
    [self.view sendSubviewToBack:beginSurveyButton];
    [self.view sendSubviewToBack:allWhiteBack];
    [self.view sendSubviewToBack:initialSettingsLabel];
    [self.view sendSubviewToBack:taperedWhiteLine];
    [self.view sendSubviewToBack:surveyIntroLabel];
    
    
    [theTimer release];
	theTimer = nil;
}

- (void)surveyCompleted {
    
    satisfactionSurveyCompleted = YES;
    [self updateMiniDemoSettings];
    
    [self updateBadgeOnSatisfactionSurveyButton];
    
    satisfactionButton.enabled = NO;
    
    allWhiteBack.alpha = 0.0;
    [self.view bringSubviewToFront:allWhiteBack];
    returnToMenuButton.alpha = 0.0;
    [self.view bringSubviewToFront:returnToMenuButton];
    surveyCompleteLabel.alpha = 0.0;
    [self.view bringSubviewToFront:surveyCompleteLabel];
    
    
    
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
        
        surveyCompleteLabel.alpha = 1.0;
        //        aWebView.frame = ssCubeFrame;
		
	}
	[UIView commitAnimations];
    
//    [aWebView release];
//    aWebView = nil;
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:12.0 target:self selector:@selector(returnToMenuInFiveSeconds:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Return to Menu Methods

- (void)returnToMenuInFiveSeconds:(NSTimer*)theTimer {
    [self returnToMenu];
    [theTimer release];
	theTimer = nil;
}

- (void)returnToMenu {
    
    [self fadeMenuItemsIn];
    
    if (edModule.playingMovie) {
        [edModule stopMoviePlayback];
    }
    
    if (satisfactionSurveyCompleted) {
        [self updateBadgeOnSatisfactionSurveyButton];
        [self.view bringSubviewToFront:completedBadgeImageView];
    }
    if (satisfactionSurveyInProgress) {
        if (!badgeCreated) {
            [self createBadgeOnSatisfactionSurveyButton];
        } else {
            if (!finalBadgeCreated) {
                [self updateBadgeOnSatisfactionSurveyButton];
            }
        }
    }
    
    if (educationModuleCompleted) {
        tbiEdButton.enabled = NO;
        [self.view bringSubviewToFront:completedBadgeImageViewEdModule];
    }
    
    if (badgeCreated) {
        [self.view bringSubviewToFront:badgeImageView];
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
        
        if (educationModuleCompleted) {
            tbiEdButton.enabled = NO;
            [self.view bringSubviewToFront:completedBadgeImageViewEdModule];
            completedBadgeImageViewEdModule.alpha = 1.0;
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
        
        badgeImageView.alpha = 1.0;
        completedBadgeImageView.alpha = 1.0;
        
        edModule.view.alpha = 0.0;
        nextEdItemButton.alpha = 0.0;
        previousEdItemButton.alpha = 0.0;
        edModuleCompleteLabel.alpha = 0.0;
        
        physicianModule.view.alpha = 0.0;
        physicianDetailVC.view.alpha = 0.0;
        nextPhysicianDetailButton.alpha = 0.0;
        previousPhysicianDetailButton.alpha = 0.0;
        
        dynamicEdModule.view.alpha = 0.0;
        
        surveyResourceBack.alpha = 0.0;
        
//        surveyCompleteLabel.frame = ssCompletedLabelFrame;
        //        aWebView.frame = ssCubeFrame;
		
	}
	[UIView commitAnimations];
    
//    [tbvc saySelectActivity];
    
    if (satisfactionSurveyCompleted) {
        [self.view bringSubviewToFront:completedBadgeImageView];
    }
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(completeReturnToMenu:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
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
    
    [theTimer release];
	theTimer = nil;
    
//    cameFromMainMenu = YES;
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
    [self showSpinner];
    [tbvc writeLocalDbToCSVFile];
    [self sendEmailWithDataAttached];
    
    //    [self removeSpinner];
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
    
    if ([[AppDelegate_Pad sharedAppDelegate] isConnectivityEstablished]) {
        
        SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
        testMsg.fromEmail = @"psc.waitingroom.app@gmail.com";
        testMsg.toEmail = @"dhorton@paloaltou.edu";
        testMsg.relayHost = @"smtp.gmail.com";
        testMsg.requiresAuth = YES;
        testMsg.login = @"psc.waitingroom.app@gmail.com";
        testMsg.pass = @"polytrauma3801";
        testMsg.subject = @"SendTest: Polytrauma Waiting Room App - Satisfaction DB";
        testMsg.bccEmail = @"david.horton3@va.gov";
        testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
        
        // Only do this for self-signed certs!
        // testMsg.validateSSLChain = NO;
        testMsg.delegate = self;
        
        NSString *msgBody = [NSString stringWithFormat:@"Polytrauma Waiting Room App - Please see attached Satisfaction DB data in file: satisfactiondata.csv. (sent from %@ running App Version: %@)", [[UIDevice currentDevice] name], appVersion];
        
        NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                                   msgBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        //        NSString *dataPath = [NSString stringWithFormat:@"%@",tbvc.csvpath];
        NSString *csvRoot = [documentsDir stringByAppendingPathComponent:tbvc.csvpath];
        NSData *csvData = [NSData dataWithContentsOfFile:csvRoot];
        
        //    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"vcf"];
        //    NSData *vcfData = [NSData dataWithContentsOfFile:vcfPath];
        
        //    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"test.vcf\"",kSKPSMTPPartContentTypeKey,
        //                             @"attachment;\r\n\tfilename=\"test.vcf\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        NSDictionary *csvPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"satisfactiondata.csv\"",kSKPSMTPPartContentTypeKey,
                                 @"attachment;\r\n\tfilename=\"satisfactiondata.csv\"",kSKPSMTPPartContentDispositionKey,[csvData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
        
        //    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
        testMsg.parts = [NSArray arrayWithObjects:plainPart,csvPart,nil];
        
        
        [testMsg send];
        
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
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [message release];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}

#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)dealloc {
    
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

@end
