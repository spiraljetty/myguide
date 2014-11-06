//
//  SettingsViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import "SettingsViewController.h"
#import "ControlView.h"
#import "YLViewController.h"
#import "ArcTabViewController.h"
#import "Constants.h"
#import "YLProgressBar.h"
#import "AppDelegate_Pad.h"
#import "TTSPlayer.h"
#import "Dynamicspeech.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define kInvisibleButtonExtraWidth 60.f


@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize controlView, invisibleShowHideButton, soundViewController, enableOfflineVoiceModeButton, resetAllOfflineSoundfilesButton;
@synthesize currentlyLoadingSoundFilenamePrefix, soundFilenamesRemaining, allSoundFilenamesToLoad, currentDynamicSoundFilenamesRemainingNum, fixPronunciation, substringFilenamesChunkArray, substringTextChunkArray, onlyDownloadFemaleFastForDebugging;
@synthesize homeCoords, numUpdates, shortWaitTimer, createdSuccessfulLink, shouldDisplayAlertAndPlayWanderAlarm, shouldDisplayHeadsetAlert, headsetPluggedIn, activeAudioRouteString, connectedToWIFI, lastConnectedWIFISSIDName, wanderGuardActivated;

- (void)updateThisLocation:(NSTimer*)theTimer {
    
    [soundViewController updateViewWithNewLocationInformation];
    
//    [theTimer release];
//	theTimer = nil;
    
    shortWaitTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateThisLocation:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)updateThisLink:(NSTimer*)theTimer {
    NSLog(@"SettingsViewController.updateThisLink()");
    shortWaitTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateLinkQuickly) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
//    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    NSLog(@"SettingsViewController.initWithNibName() name: %@", nibNameOrNil);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"SettingsViewController.viewDidLoad()");
    // Do any additional setup after loading the view from its nib.
    
//    controlView = [[ControlView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-[ControlView barHeight],
//                                                                self.view.frame.size.height+20.0f, 550.0f)];
    
//    NSString *quickTest = @"A PM and R specialist, or physiatrist, may use diagnostic tools such as nerve conduction studies (NCS), which measure the nerves’ responses to electrical stimulation, and needle electromyographies (EMGs), which assess the";
//    NSLog(@"========quickTest, Length of:\n%@\nCharacters:\n%d",quickTest,[quickTest length]);
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    createdSuccessfulLink = NO;
    shouldDisplayAlertAndPlayWanderAlarm = NO;
    connectedToWIFI = NO;
    lastConnectedWIFISSIDName = @"None";
    wanderGuardActivated = NO;
    
    shouldDisplayHeadsetAlert = NO;
//    headsetPluggedIn = [self isHeadsetPluggedIn];
    truncateTo99Chars = NO;
    truncateTo199Chars = YES;
    
    onlyDownloadFemaleFastForDebugging = NO;  // OK to change this for faster debugging
    
    loadSoundsForAllSpeedsAndVoices = YES;  // Dont change this
    
    updateSelectSounds = NO;
    
    // Set TTS Defaults
    currentlySelectedVoiceType = usenglishfemale;
    currentlySelectedVoiceSpeed = fastspeed;
    
    fixPronunciation = [[PronunciationFixer alloc] init];
    
    controlView = [[ControlView alloc] initWithFrame:CGRectMake(0.0f, 59.0f,
                                                                self.view.frame.size.height+20.0f, 450.0f)];
	
	// Add controls to control view
	CGRect controlFrame;
	int borderWidth = 5;
	float controlSpacing, currSpacing = [ControlView barHeight];
    float tmpSpacing;
    
    NSArray *labelText = [NSArray arrayWithObjects:@"Network", @"Sound", @"Speech\nRecognition", nil];
	UILabel *label;
    
    int numControls = 3;
	int numDivs = 2 + numControls - 1;
    UISegmentedControl *controls[numControls];
	
	for (int i=0; i < numControls; i++)
	{
		controls[i] = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"None", @"None", @"None", nil]] autorelease];
		[controls[i] setSegmentedControlStyle:UISegmentedControlStyleBar];
		[controls[i] setSelectedSegmentIndex:0];
		controlFrame = controls[i].frame;
		
		if (i == 0) {
			currSpacing += controlSpacing = floorf(([controlView contentHeight] - (controlFrame.size.height * numControls))/numDivs) - 15.0f;
//            tmpSpacing = 50;
        } else {
			currSpacing += controlSpacing + controls[i].frame.size.height;
//            tmpSpacing = currSpacing;
        }
		
		label = [[[UILabel alloc] initWithFrame:CGRectMake(borderWidth,
														   currSpacing,
														   controlView.frame.size.width - (2 * borderWidth) - 50.0f,
														   controls[i].frame.size.height+20.0f)] autorelease];
		label.text = [labelText objectAtIndex:i];
        label.numberOfLines = 0;
		label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
		label.backgroundColor = [UIColor clearColor];
		[controlView addSubview:label];
		

	}
    
    [self.view addSubview:controlView];
    
    // Setup arc tab view controller
//    ArcTabViewController * arcTabViewController = [ArcTabViewController alloc];
//    [arcTabViewController initWithTitle:@"KYArcTab"
//                             tabBarSize:(CGSize){kKYTabBarWdith, kKYTabBarHeight}
//                  tabBarBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:kKYITabBarBackground]]
//                               itemSize:(CGSize){kKYTabBarItemWidth, kKYTabBarItemHeight}
//                                  arrow:[UIImage imageNamed:kKYITabBarArrow]];
////    arcTabViewController.view.frame = CGRectMake(40,150,self.view.frame.size.width,self.view.frame.size.height);
//    arcTabViewController.view.frame = CGRectMake(240,0,640,960);
////    arcTabViewController.view.frame = CGRectMake(240,50,320,480);
//    arcTabViewController.view.transform = rotateLeft;
//    
//    [self.view addSubview:arcTabViewController.view];
//    [arcTabViewController release];
    
    
    
    [self createNetworkMenu];
    [self createSoundMenu];
    [self createGearTab];
    //[self createDownloadTab];
    [self createInvisibleHideShowButton];
    //[self createInvisibleDownloadButton];
    
//    [self checkthatHeadsetIsPluggedIn];
    
    numUpdates = 0;
    shortWaitTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(updateThisLocation:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
    shortWaitTimer = [NSTimer timerWithTimeInterval:3.5 target:soundViewController selector:@selector(zoomToCurrentLocation) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
    
    shortWaitTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(updateThisLink:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)createGearTab {
    UIImage *gearImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gears_settings_image_w_tab2" ofType:@"png"]];
    if (gearImage == nil)
        NSLog(@"Failed to load image for control view");
    
    gearImageView = [[UIImageView alloc] initWithImage:gearImage];
    CGRect gearImageViewFrame = gearImageView.frame;
//    gearImageViewFrame.origin.x = floorf((frame.size.width/2.0f) - (gearImageViewFrame.size.width/2.0f)) - 350.0f;
//    gearImageViewFrame.origin.y = floorf((gBarHeight/2.0f) - (gearImageViewFrame.size.height/2.0f)) - 27.0f;
    gearImageViewFrame.origin.x = 40.0f;
//    gearImageViewFrame.origin.y = -43.0f;
    gearImageViewFrame.origin.y = 17.0f;
    [gearImageView setFrame:gearImageViewFrame];
    
    [self.view addSubview:gearImageView];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(140.0f,
                                                                0.0f,
                                                                100.0f,
                                                                100.0f)] autorelease];
    label.text = @"App\nSettings";
    //        label.text
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Avenir" size:23];
    [self.view addSubview:label];
}

//- (void)createDownloadTab {
//    UIImage *downloadImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gears_settings_image_w_tab2" ofType:@"png"]];
//    if (downloadImage == nil)
//        NSLog(@"Failed to load image for control view");
//    
//    downloadImageView = [[UIImageView alloc] initWithImage:downloadImage];
//    downloadImageView.hidden = YES;
//    CGRect downloadImageViewFrame = downloadImageView.frame;
//    //    gearImageViewFrame.origin.x = floorf((frame.size.width/2.0f) - (gearImageViewFrame.size.width/2.0f)) - 350.0f;
//    //    gearImageViewFrame.origin.y = floorf((gBarHeight/2.0f) - (gearImageViewFrame.size.height/2.0f)) - 27.0f;
//    downloadImageViewFrame.origin.x = 340.0f;
//    //    gearImageViewFrame.origin.y = -43.0f;
//    downloadImageViewFrame.origin.y = 17.0f;
//    [downloadImageView setFrame:downloadImageViewFrame];
//    
//    [self.view addSubview:downloadImageView];
//    
//    downloadLabel = [[[UILabel alloc] initWithFrame:CGRectMake(440.0f,
//                                                                0.0f,
//                                                                100.0f,
//                                                                100.0f)] autorelease];
//    downloadLabel.text = @"Download";
//    //        label.text
//    downloadLabel.numberOfLines = 0;
//    downloadLabel.textColor = [UIColor whiteColor];
//    downloadLabel.backgroundColor = [UIColor clearColor];
//    downloadLabel.font = [UIFont fontWithName:@"Avenir" size:20];
//    [self.view addSubview:downloadLabel];
//}

- (void)createInvisibleHideShowButton {
//    CGFloat invisibleButtonExtraWidth = 60.0f;
    buttonOpen = FALSE;
    
    invisibleShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleShowHideButton.frame = CGRectMake(40, 10, 3.5*kInvisibleButtonExtraWidth, 1.5*kInvisibleButtonExtraWidth);
    //    invisibleShowHideButton.showsTouchWhenHighlighted = YES;
    invisibleShowHideButton.backgroundColor = [UIColor clearColor];
//    invisibleShowHideButton.alpha = 0.5;
    //        [invisibleShowHideButton setCenter:CGPointMake(500.0f, 660.0f)];
    [invisibleShowHideButton addTarget:self action:@selector(showHideButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    invisibleShowHideButton.enabled = YES;
    invisibleShowHideButton.hidden = NO;
    invisibleShowHideButton.selected = NO;
    [invisibleShowHideButton retain];
    
    [self.view addSubview:invisibleShowHideButton];
}

//- (void)createInvisibleDownloadButton {
//    //    CGFloat invisibleButtonExtraWidth = 60.0f;
//    buttonOpen = FALSE;
//
//    invisibleDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    invisibleDownloadButton.frame = CGRectMake(340, 10, 3.5*kInvisibleButtonExtraWidth, 1.5*kInvisibleButtonExtraWidth);
//    //    invisibleShowHideButton.showsTouchWhenHighlighted = YES;
//    invisibleDownloadButton.backgroundColor = [UIColor clearColor];
//    //    invisibleShowHideButton.alpha = 0.5;
//    //        [invisibleShowHideButton setCenter:CGPointMake(500.0f, 660.0f)];
//    [invisibleDownloadButton addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    invisibleDownloadButton.enabled = YES;
//    invisibleDownloadButton.hidden = YES;
//    invisibleDownloadButton.selected = NO;
//    [invisibleDownloadButton retain];
//    
//    [self.view addSubview:invisibleDownloadButton];
//}

- (void)createNetworkMenu {
    
    currentConnectionType = kConnectionFailed;
//    
//    networkStatus = [[UILabel alloc] initWithFrame:CGRectMake(160,130,300,50)];
//    networkStatus.text = @"Disconnected";
//    networkStatus.numberOfLines = 0;
//    networkStatus.textColor = [UIColor whiteColor];
//    networkStatus.font = [UIFont fontWithName:@"AvenirNext" size:20];
//    networkStatus.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:networkStatus];
//    
//    networkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network_failed_trim.png"]];
//    networkImage.frame = CGRectMake(networkStatus.frame.origin.x, networkStatus.frame.origin.y - 30, 85, 85);
//    [self.view addSubview:networkImage];
}

- (void)createSoundMenu {
   soundViewController = [[YLViewController alloc] initWithNibName:@"YLViewController_iPad" bundle:nil];
//    soundViewController.view.frame = CGRectMake(80, 200, 500, 200);
    soundViewController.view.frame = CGRectMake(0, kInvisibleButtonExtraWidth, self.view.frame.size.width, self.view.frame.size.height);
//    soundViewController.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:soundViewController.view];
    
    enableOfflineVoiceModeButton = [[DynamicStartAppButtonView alloc] initWithFrame:CGRectMake(36, 275, 150, 51) type:kRoundedRectBlueSpeckled text:@"Enable\nOffline" target:self selector:@selector(loadAllTTSSoundFiles) fontsize:15];
    enableOfflineVoiceModeButton.demoButton.enabled = NO;
//    [enableOfflineVoiceModeButton setCenter:CGPointMake(420.0f, 330.0f)];
//    enableOfflineVoiceModeButton.transform = rotateRight;
    [self.view addSubview:enableOfflineVoiceModeButton];
    
    resetAllOfflineSoundfilesButton = [[DynamicStartAppButtonView alloc] initWithFrame:CGRectMake(36, 330, 150, 51) type:kPopRectOrange text:@"Reset\nSounds" target:self selector:@selector(resetTTSSoundFilesPressed) fontsize:15];
    resetAllOfflineSoundfilesButton.demoButton.enabled = NO;
    //    [enableOfflineVoiceModeButton setCenter:CGPointMake(420.0f, 330.0f)];
    //    enableOfflineVoiceModeButton.transform = rotateRight;
    [self.view addSubview:resetAllOfflineSoundfilesButton];
    
    
}

- (void)TTSVoiceTypeSegmentedControlChanged:(id)sender {
    UISegmentedControl *thisControl = (UISegmentedControl *)sender;
    NSLog(@"Voice Type Segment Changed to Index: %d",thisControl.selectedSegmentIndex);
    if (thisControl.selectedSegmentIndex == 0) {
        currentlySelectedVoiceType = usenglishmale;
        NSLog(@"Voice Type Set to: %@...",@"usenglishmale");
        [DynamicSpeech setVoiceTypeMale];
    } else {
        currentlySelectedVoiceType = usenglishfemale;
        NSLog(@"Voice Type Set to: %@...",@"usenglishfemale");
        [DynamicSpeech setVoiceTypeFemale];
    }
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] setCurrentlyPlayingVoiceType:currentlySelectedVoiceType];
}

- (void)TTSVoiceSpeedSegmentedControlChanged:(id)sender {
    UISegmentedControl *thisControl = (UISegmentedControl *)sender;
    NSLog(@"Voice Speed Segment Changed to Index: %d",thisControl.selectedSegmentIndex);
    if (thisControl.selectedSegmentIndex == 0) {
        currentlySelectedVoiceSpeed = slowspeed;
        NSLog(@"Voice Speed Set to: %@...",@"slowspeed");
    } else if (thisControl.selectedSegmentIndex == 1) {
        currentlySelectedVoiceSpeed = normalspeed;
        NSLog(@"Voice Speed Set to: %@...",@"normalspeed");
    } else if (thisControl.selectedSegmentIndex == 2) {
        currentlySelectedVoiceSpeed = fastspeed;
        NSLog(@"Voice Speed Set to: %@...",@"fastspeed");
    } else {
        currentlySelectedVoiceSpeed = normalspeed;
        NSLog(@"Voice Speed Set to: %@...",@"normalspeed");
    }
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] setCurrentlyPlayingVoiceSpeed:currentlySelectedVoiceSpeed];
}

- (void)resetTTSSoundFilesPressed {
    
    NSLog(@"SettingsViewController.resetTTSSoundFilesPressed()");
    resetAllOfflineSoundfilesButton.demoButton.enabled = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"allTTSSoundFilesLoadedDateAndTime"]) {
        UIAlertView *comingSoonAlert = [[UIAlertView alloc] initWithTitle:@"No Soundfiles Loaded" message:@"No soundfiles loaded to reset..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        comingSoonAlert.delegate = self;
        [comingSoonAlert show];
        [comingSoonAlert release];
    } else {
        [self deleteAllTTSSoundFiles];
    }
}

- (void)deleteTTSSoundFilesInArray:(NSArray *)soundfilenamesToDelete {
            
    NSMutableArray *allCurrentlyLoadedSoundfiles = [[NSMutableArray alloc] initWithArray:soundfilenamesToDelete];
    
    int numSoundfilesToDelete = [allCurrentlyLoadedSoundfiles count];
    
    NSLog(@"Deleting %d sound files from Documents folder...",numSoundfilesToDelete);
    
    NSString *audioExtension = @".mp3";
    NSString *fullSoundfilenameWithExtension;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *path;
    
    soundViewController.loadSpinner.alpha = 1.0;
    soundViewController.loadingFileName.alpha = 1.0;
    [soundViewController startLoadingActivityIndicator];
    
    for (NSString *thisFilePrefix in allCurrentlyLoadedSoundfiles) {
        fullSoundfilenameWithExtension = [NSString stringWithFormat:@"%@%@",thisFilePrefix,audioExtension];
        
        path = [documentsDirectory stringByAppendingPathComponent:fullSoundfilenameWithExtension];
        
        soundViewController.loadingFileName.text = [NSString stringWithFormat:@"Deleting: %@",fullSoundfilenameWithExtension];
        
        if ([fileMgr fileExistsAtPath:path]) {
            if ([fileMgr removeItemAtPath:path error:&error] != YES) {
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            } else {
                NSLog(@"Deleting %@ from Documents...",fullSoundfilenameWithExtension);
            }
        }
    }
    
    soundViewController.loadingFileName.text = [NSString stringWithFormat:@"Soundfiles to update reset!"];
    
    soundViewController.loadSpinner.alpha = 0.0;
    [soundViewController stopLoadingActivityIndicator];
    enableOfflineVoiceModeButton.demoButton.enabled = YES;
}

- (void)deleteAllTTSSoundFiles {
    NSLog(@"SettingsViewController.deleteAllTTSSoundFiles()");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"allTTSSoundFilesLoadedDateAndTime"];
    
    NSMutableArray *allCurrentlyLoadedSoundfiles = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"allTTSSoundFilesLoaded"]];
    
    int numSoundfilesToDelete = [allCurrentlyLoadedSoundfiles count];
    
    NSLog(@"Deleting %d sound files from Documents folder...",numSoundfilesToDelete);
    
    NSString *audioExtension = @".mp3";
    NSString *fullSoundfilenameWithExtension;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *path;
    
    soundViewController.loadSpinner.alpha = 1.0;
    soundViewController.loadingFileName.alpha = 1.0;
    [soundViewController startLoadingActivityIndicator];
    
    for (NSString *thisFilePrefix in allCurrentlyLoadedSoundfiles) {
        fullSoundfilenameWithExtension = [NSString stringWithFormat:@"%@%@",thisFilePrefix,audioExtension];
        
        path = [documentsDirectory stringByAppendingPathComponent:fullSoundfilenameWithExtension];
        
        soundViewController.loadingFileName.text = [NSString stringWithFormat:@"Deleting: %@",fullSoundfilenameWithExtension];
        
        if ([fileMgr fileExistsAtPath:path]) {
            if ([fileMgr removeItemAtPath:path error:&error] != YES) {
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            } else {
                NSLog(@"Deleting %@ from Documents...",fullSoundfilenameWithExtension);
            }
        }
    }
    
    soundViewController.loadingFileName.text = [NSString stringWithFormat:@"Offline Soundfiles Reset!"];
    
    [defaults removeObjectForKey:@"allTTSSoundFilesLoaded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    soundViewController.loadSpinner.alpha = 0.0;
    [soundViewController stopLoadingActivityIndicator];
    enableOfflineVoiceModeButton.demoButton.enabled = YES;
}

- (void)changeUpdateSelectSoundsValueTo:(BOOL)thisBool {
    updateSelectSounds = thisBool;
    
    if (updateSelectSounds) {
        NSLog(@"updateSelectSounds = YES");
    } else {
        NSLog(@"updateSelectSounds = NO");
    }
}

- (void)loadAllTTSSoundFiles {
    NSLog(@"SettingsViewController.loadAllTTSSoundFiles()");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] loadAllWRModuleSoundfiles];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] combineAllSoundfileDicts];
    
    BOOL fileExceededCharacterLimit = NO;
    NSString *longTextFilePrefix = @"~";
    
     NSString *allTTSSoundFilesKey = @"allTTSSoundFilesDict";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if ((![defaults objectForKey:allTTSSoundFilesKey]) || ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentDynamicClinicEdModuleSpecFilename] isEqualToString:@"Default"])) {
		NSLog(@"%@ not found...", allTTSSoundFilesKey);
        
            UIAlertView *comingSoonAlert = [[UIAlertView alloc] initWithTitle:@"Clinic Needed" message:@"Please select a clinic to continue..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            comingSoonAlert.delegate = self;
            [comingSoonAlert show];
            [comingSoonAlert release];
        
	} else {
        
        enableOfflineVoiceModeButton.demoButton.enabled = NO;
        soundViewController.voiceSpeedSegmentedControl.enabled = NO;
        soundViewController.voiceTypeSegmentedControl.enabled = NO;
    
        NSLog(@"Begin loading all TTS sound files for offline use...");
    
//    dynamicEdModule.ttsSoundFileDict
    NSString *dateAndTimeLastLoaded;
    BOOL needToLoadAllTTSFiles = YES;
    
    NSMutableDictionary *currentDynamicSoundFileDict;
    
	if (![defaults objectForKey:@"allTTSSoundFilesLoadedDateAndTime"]) {
        
        currentDynamicSoundFileDict = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:allTTSSoundFilesKey]];
        
	} else {
        
        if (!updateSelectSounds) {
            dateAndTimeLastLoaded = [defaults objectForKey:@"allTTSSoundFilesLoadedDateAndTime"];
            
            NSLog(@"All TTS Sound Files loaded on date and time: %@\nNo need to reload...",dateAndTimeLastLoaded);
            
            //        NSLog(@"===============  CHANGE THIS TO NO ONCE DEBUGGING COMPLETE!!! ===========");
            needToLoadAllTTSFiles = NO;  // CHANGE THIS TO NO ONCE DEBUGGING COMPLETE!!!
            
            soundViewController.loadingFileName.alpha = 1.0;
            soundViewController.loadingFileName.text = [NSString stringWithFormat:@"%@\nLoaded on: %@",@"All files loaded!  Offline mode ready.",dateAndTimeLastLoaded];
            
            resetAllOfflineSoundfilesButton.demoButton.enabled = YES;
            
            soundViewController.voiceSpeedSegmentedControl.enabled = YES;
            soundViewController.voiceTypeSegmentedControl.enabled = YES;
        } else {
            needToLoadAllTTSFiles = YES;
            currentDynamicSoundFileDict = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:allTTSSoundFilesKey]];
        }
	}
    
	if (needToLoadAllTTSFiles) {
        
        if (updateSelectSounds) {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] loadSoundfilesToUpdate];
            
            soundFilenamesRemaining = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"updateTTSSoundFilesKey"] copyItems:YES];
            
            [self deleteTTSSoundFilesInArray:soundFilenamesRemaining];
            
        } else {
            soundFilenamesRemaining = [[NSMutableArray alloc] initWithArray:[currentDynamicSoundFileDict allKeys] copyItems:YES];
        }
        
        currentDynamicSoundFilenamesRemainingNum = [soundFilenamesRemaining count];
        
//        soundViewController.progressBarIncrements = (1.0f / (currentDynamicSoundFilenamesRemainingNum+1)) * 1.0f;
        
        NSLog(@"Current unloaded dictionary contains %d sound filenames:",currentDynamicSoundFilenamesRemainingNum);
        
        int soundFilenamesRemainingIndex = 0;
        
        NSMutableArray *keysToCheck;
        
        if (updateSelectSounds) {
            keysToCheck = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"updateTTSSoundFilesKey"] copyItems:YES];
        } else {
            keysToCheck = [[NSMutableArray alloc] initWithArray:[currentDynamicSoundFileDict allKeys] copyItems:YES];
        }
        
        for (NSString *thisKey in keysToCheck) {
            NSString *thisText = [currentDynamicSoundFileDict objectForKey:thisKey];
            
            BOOL hasLongTextFilePrefixCharacter = [thisKey hasPrefix:longTextFilePrefix];
            
            if (!hasLongTextFilePrefixCharacter) {
                
                int numCharacters = [thisText length];
                if (truncateTo99Chars) {
                    if (numCharacters > 99) {
                        thisText = [thisText substringToIndex:99];
                        numCharacters = [thisText length];
                    }
                } else if (truncateTo199Chars) {
                    if (numCharacters > 179) {
                        
                        NSLog(@"Found long textfile with key missing long textfile prefix (changing key %@ to %@",thisKey,[NSString stringWithFormat:@"%@%@",longTextFilePrefix,thisKey]);
                        [soundFilenamesRemaining replaceObjectAtIndex:soundFilenamesRemainingIndex withObject:[NSString stringWithFormat:@"%@%@",longTextFilePrefix,thisKey]];
                        
//                        fileExceededCharacterLimit = YES;
//                        
//                        NSString *alertText = [NSString stringWithFormat:@"Currently, the app requires that text prompts larger than %d characters contain filenames beginning with a tilde (e.g. '~soundfilename'.  %@ contains %d characters.\n\nPlease fix by prepending with a '~', then reset and run again.",199,thisKey,numCharacters];
//                        
//                        
//                        UIAlertView *characterLimitAlert = [[UIAlertView alloc] initWithTitle:@"TTS Sound Length Exceeds Limit" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        characterLimitAlert.delegate = self;
//                        [characterLimitAlert show];
//                        [characterLimitAlert release];
//                        
//                        thisText = [thisText substringToIndex:199];
//                        numCharacters = [thisText length];
                    }
                }
                NSLog(@"- %@\n==> %@ (%d characters)",thisKey,thisText,numCharacters);
                
//                if (fileExceededCharacterLimit) {
//                    break;
//                }
                
            }
            soundFilenamesRemainingIndex++;
        }
        
        if (!fileExceededCharacterLimit) {
            soundViewController.loadSpinner.alpha = 1.0;
            soundViewController.loadingFileName.alpha = 1.0;
            soundViewController.loadingLabel.alpha = 1.0;
            soundViewController.progressView.alpha = 1.0;
            soundViewController.progressValueLabel.alpha = 1.0;
            [soundViewController startLoadingActivityIndicator];
            
            if (!loadSoundsForAllSpeedsAndVoices) {
                allSoundFilenamesToLoad = [[NSMutableArray alloc] initWithArray:soundFilenamesRemaining copyItems:YES];
                
                currentDynamicSoundFilenamesRemainingNum = [soundFilenamesRemaining count];
                soundViewController.progressBarIncrements = (1.0f / (currentDynamicSoundFilenamesRemainingNum+1)) * 1.0f;
                
                [self loadRemainingSoundFilenamesInArray:soundFilenamesRemaining];
                
            } else {
                NSMutableArray *tmpArrayCopy = [[NSMutableArray alloc] initWithArray:soundFilenamesRemaining copyItems:YES];
                [soundFilenamesRemaining release];
                soundFilenamesRemaining = nil;
                
                soundFilenamesRemaining =[[NSMutableArray alloc] initWithArray:[self soundFilenamesForAllSpeedsAndVoicesWithOriginalArray:tmpArrayCopy] copyItems:YES];
                allSoundFilenamesToLoad = [[NSMutableArray alloc] initWithArray:soundFilenamesRemaining copyItems:YES];
                
                currentDynamicSoundFilenamesRemainingNum = [soundFilenamesRemaining count];
                soundViewController.progressBarIncrements = (1.0f / (currentDynamicSoundFilenamesRemainingNum+1)) * 1.0f;
                
                [self loadRemainingSoundFilenamesInArray:soundFilenamesRemaining];
            }
        }
    }
    }
}

- (NSMutableArray *)soundFilenamesForAllSpeedsAndVoicesWithOriginalArray:(NSMutableArray *)originalSoundFilenameArray {
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    NSString *voiceTypeMaleSuffix = @"male";
    NSString *voiceTypeFemaleSuffix = @"female";
    
    NSString *voiceSpeedSlowSuffix = @"slow";
    NSString *voiceSpeedNormalSuffix = @"normal";
    NSString *voiceSpeedFastSuffix = @"fast";
    
    NSMutableArray *typeSuffixArray;
    NSMutableArray *speedSuffixArray;
    
    if (!onlyDownloadFemaleFastForDebugging) {
        typeSuffixArray = [[NSMutableArray alloc] initWithObjects: voiceTypeMaleSuffix, voiceTypeFemaleSuffix, nil];
        speedSuffixArray = [[NSMutableArray alloc] initWithObjects: voiceSpeedSlowSuffix, voiceSpeedNormalSuffix, voiceSpeedFastSuffix, nil];
    } else {
        typeSuffixArray = [[NSMutableArray alloc] initWithObjects: voiceTypeFemaleSuffix, nil];
        speedSuffixArray = [[NSMutableArray alloc] initWithObjects: voiceSpeedFastSuffix, nil];
    }
    
    for (NSString *thisKey in originalSoundFilenameArray) {
        for (NSString *thisTypeSuffix in typeSuffixArray) {
            for (NSString *thisSpeedSuffix in speedSuffixArray) {
                [returnArray addObject:[NSString stringWithFormat:@"%@_%@_%@",thisKey,thisTypeSuffix,thisSpeedSuffix]];
            }
        }
    }
    
    NSLog(@"Increasing soundfile names from %d to %d items...",[originalSoundFilenameArray count],[returnArray count]);
    
    return returnArray;
}

- (void)loadRemainingSoundFilenamesInArray:(NSMutableArray *)remainingSoundFilenames {
    int numItemsRemaining = [remainingSoundFilenames count];
//    int numItemsRemaining = 0;

    NSLog(@"Items remaining = %d",numItemsRemaining);
    
    BOOL printComparisonsToConsole = NO;
    NSString *longTextFilePrefix = @"~";
    
    NSString *allTTSSoundFilesKey = @"allTTSSoundFilesDict";
    
    if (numItemsRemaining > 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *currentDynamicSoundFileDict = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:allTTSSoundFilesKey]];
        
        NSString *textForKey = [[NSString alloc] initWithString:@""];
        BOOL foundTextForThisKey = NO;
//        BOOL textForThisKeyIsNull
        int numCharsInFoundText = 0;
        NSString *currentKey = [remainingSoundFilenames objectAtIndex:numItemsRemaining-1];
        
        BOOL hasLongTextFilePrefixCharacter = [currentKey hasPrefix:longTextFilePrefix];
        
        NSMutableArray *allStringTokens = [[NSMutableArray alloc] initWithArray:[currentKey componentsSeparatedByString:@"_"] copyItems:YES];
        int numTokens = [allStringTokens count];
        
        NSString *currentFileVoiceTypeString = [allStringTokens objectAtIndex:numTokens-2];
        NSString *currentFileVoiceSpeedString = [allStringTokens objectAtIndex:numTokens-1];
        
        NSLog(@"Current voicetypestring = %@, voicespeedstring = %@...",currentFileVoiceTypeString,currentFileVoiceSpeedString);
        [allStringTokens removeLastObject];
        [allStringTokens removeLastObject];
        NSString *currentCoreKey = [allStringTokens componentsJoinedByString:@"_"];
        
        if (loadSoundsForAllSpeedsAndVoices) {
            for (NSString *thisCoreKey in [currentDynamicSoundFileDict allKeys]) {
                
                if (printComparisonsToConsole) {
                    NSLog(@"Comparing %@ to %@...",thisCoreKey, currentCoreKey);
                }
                
                if ([thisCoreKey isEqualToString:currentCoreKey]) {
                    textForKey = [currentDynamicSoundFileDict objectForKey:thisCoreKey];
                    if (printComparisonsToConsole) {
                        NSLog(@"Connecting file %@ to text %@...",currentKey,textForKey);
                        foundTextForThisKey = YES;
                    }
                    break;
                }
            }
            if (!foundTextForThisKey ) {
                numCharsInFoundText = [textForKey length];
                if ((textForKey) && (numCharsInFoundText > 0)) {
                    foundTextForThisKey = YES;
                } else {
                    if (hasLongTextFilePrefixCharacter) {
                        // If can't find text with key using ~, try by removing ~ (in case it was added programatically)
                        NSString *fixedKey = [currentCoreKey substringFromIndex:[longTextFilePrefix length]];
                        NSLog(@"Looking for text using fixedKey: %@...",fixedKey);
                        textForKey = [NSString stringWithFormat:@"%@",[currentDynamicSoundFileDict objectForKey:fixedKey]];
                        numCharsInFoundText = [textForKey length];
                        if ((textForKey) && (numCharsInFoundText > 0)) {
                            foundTextForThisKey = YES;
                            NSLog(@"FINALLY found text by removing %@: %@",longTextFilePrefix,textForKey);
                        }
                    }
                }
            }
        } else {
            textForKey = [NSString stringWithFormat:@"%@",[currentDynamicSoundFileDict objectForKey:currentKey]];
            numCharsInFoundText = [textForKey length];
            if ((textForKey) && (numCharsInFoundText > 0)) {
                foundTextForThisKey = YES;
            } else {
                if (hasLongTextFilePrefixCharacter) {
                    // If can't find text with key using ~, try by removing ~ (in case it was added programatically)
                    NSString *fixedKey = [currentCoreKey substringFromIndex:[longTextFilePrefix length]];
                    NSLog(@"Looking for text using fixedKey: %@...",fixedKey);
                    textForKey = [NSString stringWithFormat:@"%@",[currentDynamicSoundFileDict objectForKey:fixedKey]];
                    numCharsInFoundText = [textForKey length];
                    if ((textForKey) && (numCharsInFoundText > 0)) {
                        foundTextForThisKey = YES;
                        NSLog(@"FINALLY found text by removing %@: %@",longTextFilePrefix,textForKey);
                    }
                }
            }
        }
        
        if (!foundTextForThisKey) {
           // NSString *missingTextAlert = [NSString stringWithFormat:@"Can't find the text associated with the key %@.  Aborting...", currentKey];
            NSLog(@"Can't find the text associated with the key .%@", currentKey);
//            UIAlertView *characterLimitAlert = [[UIAlertView alloc] initWithTitle:@"Unable to Find Text" message:missingTextAlert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            characterLimitAlert.delegate = self;
//            [characterLimitAlert show];
//            [characterLimitAlert release];
            textForKey = @" ";
            NSLog(@"Assigning blank string%@ ..", textForKey);
            //return;
        } else {
            numCharsInFoundText = [textForKey length];
            if ((numCharsInFoundText < 1) || (numCharsInFoundText > 999)) {
                NSString *missingTextAlert = [NSString stringWithFormat:@"Something wrong with text (%@) associated with the key %@.  Aborting...", textForKey, currentKey];
                UIAlertView *characterLimitAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:missingTextAlert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                characterLimitAlert.delegate = self;
                [characterLimitAlert show];
                [characterLimitAlert release];
                
                return;
            }
        }
        
        currentlyLoadingSoundFilenamePrefix = currentKey;
        
        //        textForKey = [textForKey stringByReplacingOccurrencesOfString:@"&" withString:@" and "];
        textForKey = [fixPronunciation fixSpeechStringForPronunciationMistakes:textForKey];
        
        int numCharacters = [textForKey length];
        //        if (truncateTo99Chars) {
        //            if (numCharacters > 99) {
        //                textForKey = [textForKey substringToIndex:99];
        //                numCharacters = [textForKey length];
        //            }
        //        }
        if (hasLongTextFilePrefixCharacter) {
            int substringIndex = 1;
            int substringPieces = 1;
            int substringCharacterLimit = 179;
            BOOL substringCharactersOverLimit = YES;
            
            NSMutableArray *substringArray = [[NSMutableArray alloc] initWithObjects: nil];
            
            NSMutableArray *allSubstringTokens = [[NSMutableArray alloc] initWithArray:[textForKey componentsSeparatedByString:@" "] copyItems:YES];
            
            int numSubstringTokens;
            int numSubTokensPerChunk = 12;
            NSString *newHalfSubstring;
            int substringCharacters;
            
            while (substringCharactersOverLimit) {
                numSubstringTokens = [allSubstringTokens count];
//                numSubTokensPerChunk = floor(numSubstringTokens/2);
                newHalfSubstring = [[allSubstringTokens objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numSubTokensPerChunk-1)]] componentsJoinedByString:@" "];
                substringCharacters = [newHalfSubstring length];
                if (substringCharacters > substringCharacterLimit) {
                    substringCharactersOverLimit = YES;
                } else {
                    substringCharactersOverLimit = NO;
                }
                if (substringCharactersOverLimit) {
//                    allSubstringTokens = [allSubstringTokens objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numSubTokensPerChunk)]];
                    numSubTokensPerChunk = numSubTokensPerChunk - 1;
                }
            }
            
            NSMutableArray *substringTokensToSplit = [[NSMutableArray alloc] initWithArray:[textForKey componentsSeparatedByString:@" "] copyItems:YES];
            int totalTokensInAllChunks = [substringTokensToSplit count];
            
            substringFilenamesChunkArray = [[NSMutableArray alloc] initWithObjects: nil];
            substringTextChunkArray = [[NSMutableArray alloc] initWithObjects: nil];
            int currentStartingTokenIndex = 0;
            int currentNumTokensPerChunk = numSubTokensPerChunk;
            int tokensRemaining = 0;
            int tokensCollected = 0;
            int currentFilenameNum = 1;
            BOOL stillTokensRemaining = YES;
            
            BOOL printAdditionalItemsToConsole = YES;
            
            NSLog(@"Splittling long text: %@",textForKey);
            
            while (stillTokensRemaining) {
                NSString *currentChunkFilename = [NSString stringWithFormat:@"%@_%d",currentKey,currentFilenameNum];
                NSString *currentChunkText = [[substringTokensToSplit objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(currentStartingTokenIndex, currentNumTokensPerChunk)]] componentsJoinedByString:@" "];
                
                currentStartingTokenIndex = currentStartingTokenIndex + currentNumTokensPerChunk;
                
                [substringFilenamesChunkArray addObject:currentChunkFilename];
                [substringTextChunkArray addObject:currentChunkText];
                
                tokensCollected = tokensCollected + currentNumTokensPerChunk;
                tokensRemaining = totalTokensInAllChunks - tokensCollected;
                
                NSLog(@"- Setting chunk %@ to substring: %@ (%d remain)",currentChunkFilename,currentChunkText,tokensRemaining);
                
                if (tokensRemaining > 0) {
                    stillTokensRemaining = YES;
                    if (currentNumTokensPerChunk <= tokensRemaining) {
                        //Nada
                    } else {
                        currentNumTokensPerChunk = tokensRemaining;
                    }
                    
                    currentFilenameNum++;
                } else {
                    stillTokensRemaining = NO;
                }
                
        if (printAdditionalItemsToConsole) {
            NSLog(@"- totalTokensInAllChunks = %d\n- (next)currentStartingTokenIndex = %d\n- tokensCollected = %d\n- tokensRemaining = %d\ncurrentNumTokensPerChunk = %d", totalTokensInAllChunks, currentStartingTokenIndex, tokensCollected, tokensRemaining, currentNumTokensPerChunk);
        }
            
            }
            
            [self loadRemainingSoundFilenamesInSubstringArray:substringFilenamesChunkArray withSubstringTextArray:substringTextChunkArray];
    
        } else {
            
            
            RJGoogleTTS *googleTTSObject = [[RJGoogleTTS alloc] init];
            googleTTSObject.delegate = self;
            
            NSString *voiceTypeString;
            NSString *voiceSpeedString;
            
            if (loadSoundsForAllSpeedsAndVoices) {
                if ([currentFileVoiceTypeString isEqualToString:@"male"]) {
                    voiceTypeString = @"usenglishmale";
                } else {
                    voiceTypeString = @"usenglishfemale";
                }
                if ([currentFileVoiceSpeedString isEqualToString:@"slow"]) {
                    voiceSpeedString = @"slowspeed";
                } else if ([currentFileVoiceSpeedString isEqualToString:@"fast"]) {
                    voiceSpeedString = @"fastspeed";
                } else {
                    voiceSpeedString = @"normalspeed";
                }
            } else {
                switch (currentlySelectedVoiceType) {
                    case usenglishmale:
                        voiceTypeString = @"usenglishmale";
                        break;
                    case usenglishfemale:
                        voiceTypeString = @"usenglishfemale";
                        break;
                    default:
                        voiceTypeString = @"usenglishfemale";
                        break;
                }
                switch (currentlySelectedVoiceSpeed) {
                    case slowspeed:
                        voiceSpeedString = @"slowspeed";
                        break;
                    case normalspeed:
                        voiceSpeedString = @"normalspeed";
                        break;
                    case fastspeed:
                        voiceSpeedString = @"fastspeed";
                        break;
                    default:
                        voiceSpeedString = @"normalspeed";
                        break;
                }
            }
            //        [googleTTSObject convertTextToSpeech:textForKey];
            
            [googleTTSObject convertTextToSpeech:textForKey withVoiceType:voiceTypeString andThisSpeedType:voiceSpeedString];
            
            NSLog(@"Converting %@ with text:\n%@ (%d characters)",currentKey,textForKey,numCharacters);
            
            soundViewController.loadingFileName.text = [NSString stringWithFormat:@"%@.mp3",currentKey];
            
        }
        
    } else {
        NSLog(@"FINISHED LOADING ALL SOUNDFILENAMES!");
        [soundViewController stopLoadingActivityIndicator];
        
        [soundViewController changeProgressValue];
        soundViewController.loadingFileName.text = @"All files loaded!  Offline mode ready.";
        soundViewController.loadSpinner.alpha = 0.0;
        soundViewController.loadingLabel.alpha = 0.0;
        soundViewController.progressView.alpha = 0.5;
        soundViewController.progressView.animated = NO;
        
        resetAllOfflineSoundfilesButton.demoButton.enabled = YES;
        soundViewController.voiceSpeedSegmentedControl.enabled = YES;
        soundViewController.voiceTypeSegmentedControl.enabled = YES;
        
        if (updateSelectSounds) {
            updateSelectSounds = NO;
            [soundViewController.updateSelectSoundsSwitch setOn:NO animated:YES];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *dateAndTimeLastLoaded = [self getTodayDateAndTimeString];
		[defaults setObject:dateAndTimeLastLoaded forKey:@"allTTSSoundFilesLoadedDateAndTime"];
        
        [defaults setObject:allSoundFilenamesToLoad forKey:@"allTTSSoundFilesLoaded"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"Finished loading all TTS Sound Files for date and time: %@",dateAndTimeLastLoaded);
    }
}

- (void)loadRemainingSoundFilenamesInSubstringArray:(NSMutableArray *)remainingSubstringSoundFilenames withSubstringTextArray:(NSMutableArray *)remainingSubstringText {
    
    int numItemsRemaining = [remainingSubstringSoundFilenames count];
    NSLog(@"Items remaining in substring array  = %d",numItemsRemaining);
    
    if (numItemsRemaining > 0) {
        
        NSString *currentText = [[NSString alloc] initWithString:[remainingSubstringText objectAtIndex:numItemsRemaining-1]];
        NSString *currentFilename = [[NSString alloc] initWithString:[remainingSubstringSoundFilenames objectAtIndex:numItemsRemaining-1]];
        int numCharacters = [currentText length];
        
        RJGoogleTTS *googleTTSObject = [[RJGoogleTTS alloc] init];
        googleTTSObject.delegate = self;
        
        NSString *voiceTypeString;
        NSString *voiceSpeedString;
        
        NSMutableArray *allStringTokens = [[NSMutableArray alloc] initWithArray:[currentFilename componentsSeparatedByString:@"_"] copyItems:YES];
        int numTokens = [allStringTokens count];
        
        NSString *currentFileVoiceTypeString = [allStringTokens objectAtIndex:numTokens-3];
        NSString *currentFileVoiceSpeedString = [allStringTokens objectAtIndex:numTokens-2];
        
        if (loadSoundsForAllSpeedsAndVoices) {
            if ([currentFileVoiceTypeString isEqualToString:@"male"]) {
                voiceTypeString = @"usenglishmale";
            } else {
                voiceTypeString = @"usenglishfemale";
            }
            if ([currentFileVoiceSpeedString isEqualToString:@"slow"]) {
                voiceSpeedString = @"slowspeed";
            } else if ([currentFileVoiceSpeedString isEqualToString:@"fast"]) {
                voiceSpeedString = @"fastspeed";
            } else {
                voiceSpeedString = @"normalspeed";
            }
        } else {
            switch (currentlySelectedVoiceType) {
                case usenglishmale:
                    voiceTypeString = @"usenglishmale";
                    break;
                case usenglishfemale:
                    voiceTypeString = @"usenglishfemale";
                    break;
                default:
                    voiceTypeString = @"usenglishfemale";
                    break;
            }
            switch (currentlySelectedVoiceSpeed) {
                case slowspeed:
                    voiceSpeedString = @"slowspeed";
                    break;
                case normalspeed:
                    voiceSpeedString = @"normalspeed";
                    break;
                case fastspeed:
                    voiceSpeedString = @"fastspeed";
                    break;
                default:
                    voiceSpeedString = @"normalspeed";
                    break;
            }
        }
        //        [googleTTSObject convertTextToSpeech:textForKey];
        
        [googleTTSObject convertTextToSpeech:currentText withVoiceType:voiceTypeString andThisSpeedType:voiceSpeedString];
        
        NSLog(@"Converting %@ with substring text:\n%@ (%d characters)",currentFilename,currentText,numCharacters);
        
        soundViewController.loadingFileName.text = [NSString stringWithFormat:@"%@.mp3",currentFilename];
        
    } else {
        NSLog(@"Finished loading current split substring chunks!");
        [soundViewController changeProgressValue];
        
        [soundFilenamesRemaining removeLastObject];
        [self loadRemainingSoundFilenamesInArray:soundFilenamesRemaining];
        
    }
}

#pragma mark RJGoogleTTSDelegate Methods

- (void)handleFailedRequest {
    NSLog(@"Handling TTS request failure...");
    
    int itemsLeftToRetrieve = [soundFilenamesRemaining count];
    
    if (itemsLeftToRetrieve > 0) {
        NSLog(@"Restarting download where last one left off...");
        
        [self loadRemainingSoundFilenamesInArray:soundFilenamesRemaining];
    }
}

- (void)sentAudioRequest {
    NSLog(@"Sent TTS request...");
}

- (void)receivedAudio:(NSMutableData *)data {
    NSUInteger currentAudioLength = [data length];
    NSUInteger removeAdBytesWithLength = 11000;    
    NSString *longTextFilePrefix = @"~";

    if ([currentlyLoadingSoundFilenamePrefix hasPrefix:longTextFilePrefix]) {
        
        NSUInteger removeStartBytesWithLength = 10;
        removeAdBytesWithLength = removeAdBytesWithLength + 1500;
        
        if (currentAudioLength > removeAdBytesWithLength) {
            NSUInteger newAudioLengthWithoutAd = currentAudioLength - removeAdBytesWithLength;
            NSLog(@"Audio request received (data length:%d, removing ad with %d bytes)", [data length], removeAdBytesWithLength);
            [data setLength:newAudioLengthWithoutAd];
            currentAudioLength = [data length];
            NSUInteger newTruncatedLength = currentAudioLength - removeStartBytesWithLength;
//            data = [data subdataWithRange:NSMakeRange(removeStartBytesWithLength, newTruncatedLength)];
        } else {
            NSLog(@"Audio request received (data length:%d)", [data length]);
        }
        
        int currentSubstringCount = [substringFilenamesChunkArray count];
        
        NSString *currentSubstringFilename = [substringFilenamesChunkArray objectAtIndex:currentSubstringCount-1];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *audioExtension = @".mp3";
        NSString *fullDocumentFilenameWithExtension = [NSString stringWithFormat:@"%@%@",currentSubstringFilename,audioExtension];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:fullDocumentFilenameWithExtension];
        [data writeToFile:path atomically:YES];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSLog(@"======== SUCCESSFULLY SYNTHESIZED MP3 ========\n%@",fullDocumentFilenameWithExtension);
            
            [substringFilenamesChunkArray removeLastObject];
            [substringTextChunkArray removeLastObject];
            [self loadRemainingSoundFilenamesInSubstringArray:substringFilenamesChunkArray withSubstringTextArray:substringTextChunkArray];
            
        } else {
            NSLog(@"======== FAILED TO RETRIEVE SYNTHESIZED MP3========\n%@",fullDocumentFilenameWithExtension);
        }
        
    } else {
        
        NSUInteger removeStartBytesWithLength = 10;
        removeAdBytesWithLength = removeAdBytesWithLength + 1000;
        
        if (currentAudioLength > removeAdBytesWithLength) {
            NSUInteger newAudioLengthWithoutAd = currentAudioLength - removeAdBytesWithLength;
            NSLog(@"Audio request received (data length:%d, removing ad with %d bytes)", [data length], removeAdBytesWithLength);
            [data setLength:newAudioLengthWithoutAd];
            currentAudioLength = [data length];
            NSUInteger newTruncatedLength = currentAudioLength - removeStartBytesWithLength;
//            data = [data subdataWithRange:NSMakeRange(removeStartBytesWithLength, newTruncatedLength)];
        } else {
            NSLog(@"Audio request received (data length:%d)", [data length]);
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *audioExtension = @".mp3";
        NSString *fullDocumentFilenameWithExtension = [NSString stringWithFormat:@"%@%@",currentlyLoadingSoundFilenamePrefix,audioExtension];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:fullDocumentFilenameWithExtension];
        [data writeToFile:path atomically:YES];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSLog(@"======== SUCCESSFULLY SYNTHESIZED MP3 ========\n%@",fullDocumentFilenameWithExtension);
            
            [soundViewController changeProgressValue];
            
            [soundFilenamesRemaining removeLastObject];
            [self loadRemainingSoundFilenamesInArray:soundFilenamesRemaining];
            
        } else {
            NSLog(@"======== FAILED TO RETRIEVE SYNTHESIZED MP3========\n%@",fullDocumentFilenameWithExtension);
        }
    }
}

- (NSString *)getTodayDateAndTimeString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
//    NSLog(@"\n"
//          "theDate: |%@| \n"
//          "theTime: |%@| \n"
//          , theDate, theTime);
    
    NSString *todaysDateAndTime = [[NSString alloc] initWithFormat:@"%@ at %@",theDate,theTime];
    
    [dateFormat autorelease];
    [timeFormat autorelease];
    [now autorelease];
    
    return todaysDateAndTime;
}

- (void)slideSettingsFrame {
    NSLog(@"SettingsViewController.slideSettingsFrame()");

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
//    CGRect frame = invisibleShowHideButton.frame;
    CGRect frame = self.view.frame;
    
    if (buttonOpen == FALSE)
    {
//        frame.origin.x -= (controlView.contentHeight * 2);
        frame.origin.x -= (768 - 65);
//        [_barImageView setTransform:_barImageViewRotation];
        buttonOpen = TRUE;
        //downloadImageView.hidden = NO;
        //invisibleDownloadButton.hidden = NO;
//        [YLViewController downloadDataButton];
    }
    else
    {
//        frame.origin.x += (controlView.contentHeight * 2);
        frame.origin.x += (768 - 65);
//        [_barImageView setTransform:CGAffineTransformIdentity];
        buttonOpen = FALSE;
        //downloadImageView.hidden = YES;
        //invisibleDownloadButton.hidden = YES;
    }
    
//    invisibleShowHideButton.frame = frame;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)hideSettingsFrame {
    NSLog(@"SettingsViewcontroller.hideSettingsFrame()");
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    {
    
    //    CGRect frame = invisibleShowHideButton.frame;
    CGRect frame = self.view.frame;
    
//    frame.origin.x += (controlView.contentHeight * 2);
        frame.origin.x += (768 - 65);

    self.view.frame = frame;
    }
    [UIView commitAnimations];
}

- (void)showHideButtonPressed {
    NSLog(@"SettingsViewController.showHideButtonPressed()");
    [self slideSettingsFrame];
//    [controlView slideAnimation];
}

- (void)downloadButtonPressed {
    NSLog(@"SettingsViewController.downloadButtonPressed()");
    downloadLabel.text = @"working...";
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminDownloadDataButtonPressed:self];
    NSLog(@"SettingsViewController.downloadButtonPressed() download complete");
    downloadLabel.text = @"Download";
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    //    [controlView slideAnimation];
}

#pragma mark Audio Route Methods

- (void)setHeadSetStatusTo:(NSString *)audioRouteString {
    NSLog(@"Setting headset status and audio route to: %@...",audioRouteString);
//    headsetPluggedIn = [self isHeadsetPluggedIn];
//    BOOL connectedToAHeadset;
//    activeAudioRouteString = [[AppDelegate_Pad sharedAppDelegate] currentAudioRouteString];
    
    activeAudioRouteString = audioRouteString;
    
    NSRange headphoneRange = [activeAudioRouteString rangeOfString : @"Head"];
    if (headphoneRange.location != NSNotFound) {
        headsetPluggedIn = YES;
    } else {
        headsetPluggedIn = NO;
    }
    
    [self updateSoundSettingsBasedOnHeadsetStatus];
}

- (void)updateSoundSettingsBasedOnHeadsetStatus {
    if (loopAlarm) {
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] fadeToMaxVolume];
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] forceToSpeakerOutput];
    } else {
        if (![[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] forceToDemoMode]) {
            NSLog(@"Not in demo mode, audio session for headphone use only...");
            if (headsetPluggedIn) {
                if (![[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] speakItemsAloud]) {
                    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
                    soundViewController.headphoneImage.image = [UIImage imageNamed:@"headphones_green_icon.png"];
                    soundViewController.soundStatus.text = @"Enabled - Headset Connected";
                }
            } else {
                if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] speakItemsAloud]) {
                    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
                    soundViewController.headphoneImage.image = [UIImage imageNamed:@"headphones_red_icon.png"];
                    soundViewController.soundStatus.text = @"Disabled - Connect Headset";
                }
                if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] underUserControl]) {
                    [self checkthatHeadsetIsPluggedIn];
                }
            }
        } else {
            NSLog(@"In demo mode, defaulting to automatic audio output...");
            if (headsetPluggedIn) {
                soundViewController.headphoneImage.image = [UIImage imageNamed:@"headphones_green_icon.png"];
                soundViewController.soundStatus.text = @"Enabled - Headset Connected";
            } else {
                soundViewController.headphoneImage.image = [UIImage imageNamed:@"headphones_red_icon.png"];
                soundViewController.soundStatus.text = @"Enabled - Headset Disconnected";
            }
        }
        
        
    }
}

- (void)checkthatHeadsetIsPluggedIn {
//    BOOL isHeadsetCurrentlyPluggedIn = [self isHeadsetPluggedIn];
//    
//    if (isHeadsetCurrentlyPluggedIn) {
//        NSLog(@"Headset plugged in...");
//    } else {
//        NSLog(@"Headset unplugged...");
//    }
//    
    if (!shouldDisplayHeadsetAlert && !headsetPluggedIn) {
        if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] speakItemsAloud]) {
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
        }
//        if (!isHeadsetCurrentlyPluggedIn) {
            shouldDisplayHeadsetAlert = YES;
            UIAlertView *lostConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Connect Headphones" message:@"Please plug a headset in to hear sound." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            lostConnectionAlert.delegate = self;
            [lostConnectionAlert show];
            [lostConnectionAlert release];
        
        shouldDisplayHeadsetAlert = NO;
//        }
    }
    
//    headsetPluggedIn = isHeadsetCurrentlyPluggedIn;
//    
//    shortWaitTimer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(checkthatHeadsetIsPluggedIn) userInfo:nil repeats:NO];
//	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (BOOL)isHeadsetPluggedIn {
//    UInt32 routeSize = sizeof (CFStringRef);
//    CFStringRef route;
//    
//    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
//                                              &routeSize,
//                                              &route);
//    
//    /* Known values of route:
//     * "Headset"
//     * "Headphone"
//     * "Speaker"
//     * "SpeakerAndMicrophone"
//     * "HeadphonesAndMicrophone"
//     * "HeadsetInOut"
//     * "ReceiverAndMicrophone"
//     * "Lineout"
//     */
//    
//    if (!error && (route != NULL)) {
//        
//        NSString* routeStr = (NSString*)route;
//        
//        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
//        
//        if (headphoneRange.location != NSNotFound) return YES;
//        
//    }
//    
//    return NO;
    BOOL connectedToAHeadset;
    activeAudioRouteString = [[AppDelegate_Pad sharedAppDelegate] currentAudioRouteString];
    
    NSRange headphoneRange = [activeAudioRouteString rangeOfString : @"Head"];
    if (headphoneRange.location != NSNotFound) {
        connectedToAHeadset = YES;
    } else {
        connectedToAHeadset = NO;
    }
    NSLog(@"ACTIVE AUDIO ROUTE STRING: %@", activeAudioRouteString);
    return connectedToAHeadset;
}

#pragma mark WIFI Methods

- (NSString *)fetchSSIDName
{
    NSString *infoString;
    
    #if TARGET_IPHONE_SIMULATOR
    {
        //Simulator
//        NSLog(@"RUNNING ON THE SIMULATOR!!");
        infoString = [[NSString alloc] initWithFormat:@"%@",@"Simulator"];
    }
    #else
    {
        // Device
//        NSLog(@"RUNNING ON AN ACTUAL DEVICE!!");
        CFArrayRef myArray = CNCopySupportedInterfaces();
        
        CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
//        NSLog(@"Information of the network we're connected to: %@", captiveNtwrkDict);
        NSDictionary *dict = (NSDictionary*) captiveNtwrkDict;
        NSString* ssid = [dict objectForKey:@"SSID"];
//        NSLog(@"network name: %@",ssid);
        
        infoString = [[NSString alloc] initWithFormat:@"%@",ssid];
    }
    #endif
    
//    NSString *model = [[UIDevice currentDevice] model];
//    if ([model isEqualToString:@"iPhone Simulator"]) {
//        //device is simulator
//        infoString = [[NSString alloc] initWithFormat:@"%@",@"Simulator"];
//    } else {
//        CFArrayRef myArray = CNCopySupportedInterfaces();
//        
//        CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
//        NSLog(@"Information of the network we're connected to: %@", captiveNtwrkDict);
//        NSDictionary *dict = (NSDictionary*) captiveNtwrkDict;
//        NSString* ssid = [dict objectForKey:@"SSID"];
//        NSLog(@"network name: %@",ssid);
//        
//        infoString = [[NSString alloc] initWithFormat:@"%@",ssid];
//    }
    return infoString;
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

- (void)updateNetworkStatusWithConnectionType:(ConnectionType)thisConnectionType {
    NSLog(@"SettingsViewController.updateNetworkStatusWithConnectionType()");
    currentConnectionType = thisConnectionType;
    [soundViewController updateNetworkDisplayWithConnectionType:thisConnectionType];
    
    NSLog(@"SSID Name:\n%@...", [self fetchSSIDName]);
}

- (void)updateLinkQuickly {
     //NSLog(@"SettingsViewController.updateLinkQuickly()");
    
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    [self updateLinkStatusWithLinkType:netStatus];
    
    shortWaitTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateLinkQuickly) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateLinkStatusWithLinkType:(NetworkStatus)thisLinkType {
//    NSLog(@"SettingsViewController.updateStatusWithLinkType()");
    switch (thisLinkType) {
        case ReachableViaWiFi:
            createdSuccessfulLink = YES;
            connectedToWIFI = YES;
            
            
            if (wanderGuardActivated) {
                if ([self isDifferentSSID]) {
                    if (!loopAlarm) {
                        shouldDisplayAlertAndPlayWanderAlarm = YES;
                        [self lostSuccessfulLinkConnection];
                    }
                }
            } else {
                loopAlarm = NO;
                shouldDisplayAlertAndPlayWanderAlarm = NO;
            }
            
            lastConnectedWIFISSIDName = [self fetchSSIDName];
            soundViewController.wifiSSIDName.text = lastConnectedWIFISSIDName;
            
            break;
        case ReachableViaWWAN:
            createdSuccessfulLink = YES;
            connectedToWIFI = NO;
            if (wanderGuardActivated) {
                
            } else {
                loopAlarm = NO;
                shouldDisplayAlertAndPlayWanderAlarm = NO;
            }
            
            break;
        case NotReachable:
            if (createdSuccessfulLink) {
                createdSuccessfulLink = NO;
                if (wanderGuardActivated) {
                    if (!loopAlarm) {
                        shouldDisplayAlertAndPlayWanderAlarm = YES;
                        [self lostSuccessfulLinkConnection];
                    }
                }
            } else {
                
            }
            break;
        default:
            break;
    }
            
    [soundViewController updateLinkDisplayWithLinkType:thisLinkType];
}

#pragma mark Wander Guard Methods

- (BOOL)isDifferentSSID {
    NSString *currentSSIDName = [NSString stringWithString:[self fetchSSIDName]];
    
    BOOL ssidChanged = [currentSSIDName isEqualToString:lastConnectedWIFISSIDName];
    ssidChanged = !ssidChanged;
    
    return ssidChanged;
}

- (void)lostSuccessfulLinkConnection {
    if (shouldDisplayAlertAndPlayWanderAlarm) {
        NSLog(@"Just lost previously successful link connection...");
        loopAlarm = YES;
        shouldDisplayAlertAndPlayWanderAlarm = NO;
        [self displayAlertAndLoopAlarmSound];
    }
}

- (void)displayAlertAndLoopAlarmSound {
//    UIAlertView *lostConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Important Notice" message:@"You have left the range of your clinic.  Please return to the clinic waiting room immediately." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    lostConnectionAlert.delegate = self;
//    [lostConnectionAlert show];
//    [lostConnectionAlert release];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] showModalSilenceAlarmView];
    
    if (![[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] tbvc] speakItemsAloud]) {
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
    }
    
//        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
//        [self.view addSubview: volumeView];
//        [volumeView release];
    
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] fadeToMaxVolume];
    
    if (![[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] forceToDemoMode]) {
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] forceToSpeakerOutput];
    }
    
    [self playAlarmInLoop];
    
}

- (void)playAlarmInLoop {
    //    while (loopAlarm) {
    if (wanderGuardActivated && loopAlarm && [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] alarmSounding]) {
        NSLog(@"Looping alarm...");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] playItemsWithNames:[NSArray arrayWithObjects:@"alarm_high_pitched_beep", @"silence_half_second", nil]];
        
        shortWaitTimer = [NSTimer timerWithTimeInterval:1.7 target:self selector:@selector(playAlarmInLoop) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
    }
    //    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
