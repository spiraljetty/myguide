//
//  WRViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import <UIKit/UIKit.h>

#import "RootViewController_Pad.h"
#import "MyViewController.h"
#import "ModalMeViewController.h"
#import "ContentViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "KSLabel.h"
#import "V8HorizontalPickerView.h"
#import "ReflectingView.h"
#import "EdViewController_Pad.h"
#import "SKPSMTPMessage.h"
#import "MasterViewController.h"
#import "PhysicianDetailViewController.h"
#import "PhysicianViewController_Pad.h"
#import "DynamicModuleViewController_Pad.h"
#import "DynamicStartAppView.h"
#import "SettingsViewController.h"

typedef enum {
    kGeneralClinic,
    kPMNRClinic,
    kPNSClinic,
    kNoMainClinic,
} MainClinic;

typedef enum {
    kVAPAHCS,
    kNoInstitution,
} Institution;

@class SMTPSenderViewController;
@class ModalViewExampleViewController;
@class PopoverPlaygroundViewController;
@class DemoViewController;
@class V8HorizontalPickerView;

@interface WRViewController : UIViewController <UIAlertViewDelegate, SKPSMTPMessageDelegate, UIPickerViewDelegate, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource, UISplitViewControllerDelegate> {
    
    BOOL runningAppInDemoMode;
    
    Institution currentInstitution;
    MainClinic currentMainClinic;
    
    DynamicStartAppView *readyScreen;
    
    SettingsViewController *settingsVC;
    
    BOOL skipToSplashIntro, skipToPhysicianDetail, skipToEducationModule, skipToSatisfactionSurvey, skipToMainMenu;
    
    NSString *appVersion;
    NSString *deviceName;
    
    UISwitch *demoSwitch;
    
    NSString *mainClinicName;
    NSString *subClinicName;
    NSString *attendingPhysicianName;
    NSString *attendingPhysicianThumb;
    NSString *attendingPhysicianImage;
    int attendingPhysicianIndex;
    NSString *attendingPhysicianSoundFile;
    
    BOOL isFirstVisit;
    
    //    ReflectingView *backsplashNew;
	
//	IBOutlet UINavigationController *navigationController;
    
    IBOutlet ContentViewController *modalContent;
    
    DemoViewController *keypadViewController;
    
    NSTimer *endOfSplashTimer;
    
    BOOL splashAnimationsFinished;
    
	UIImageView *resourceBack;
    UIImageView *surveyResourceBack;
    UIImageView *allWhiteBack;
    UIWebView *aWebView;
    UIWebView *menuCubeWebView;
	
	UIImageView *splashImageView, *splashImageViewB, *splashImageViewBb, *splashImageViewC;
	UIActivityIndicatorView *splashSpinner;
	UIImageView *tabNAdView;
	UIView *statusViewWhiteBack;
    
	
	BOOL mapViewInitialized, mapTabEnabled;
	
	int lastRowImportedFromUsersDb;
    int maxIDFromMySQL;
    
    RootViewController_Pad *tbvc;
    MyViewController *cubeViewController;
    
    EdViewController_Pad *edModule;
    
    PhysicianViewController_Pad *physicianModule;
    
    DynamicModuleViewController_Pad *dynamicEdModule;
    NSString *currentDynamicClinicEdModuleSpecFilename;
    
    ModalMeViewController *modalViewController;
    
//    IBOutlet ModalViewExampleViewController *newViewController;
    
    IBOutlet PopoverPlaygroundViewController *popoverViewController;
    
    IBOutlet UILabel *readAloudLabel;
    IBOutlet UILabel *respondentLabel;
    IBOutlet UILabel *selectActivityLabel;
    IBOutlet UILabel *surveyIntroLabel;
    IBOutlet UILabel *surveyCompleteLabel;
    
    IBOutlet UILabel *edModuleIntroLabel;
    IBOutlet UILabel *edModuleCompleteLabel;
    
    IBOutlet UILabel *visitSelectionLabel;
    IBOutlet UILabel *selectCliniciansAndLaunchLabel;
    
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    IBOutlet UIButton *patientButton;
    IBOutlet UIButton *familyButton;
    IBOutlet UIButton *caregiverButton;
    IBOutlet UIButton *tbiEdButton;
    IBOutlet UIButton *satisfactionButton;
    IBOutlet UIButton *newsButton;
    IBOutlet UIButton *clinicButton;
    
    IBOutlet UIButton *beginSurveyButton;
    IBOutlet UIButton *returnToMenuButton;
    
    IBOutlet UIButton *firstVisitButton;
    IBOutlet UIButton *returnVisitButton;
    IBOutlet UIButton *readyAppButton;
    IBOutlet UIButton *voiceAssistButton;
    IBOutlet UIButton *fontsizeButton;
    
    IBOutlet UIButton *nextSurveyItemButton;
    IBOutlet UIButton *previousSurveyItemButton;
    
    IBOutlet UIButton *nextEdItemButton;
    IBOutlet UIButton *previousEdItemButton;
    
    IBOutlet UIButton *nextPhysicianDetailButton;
    IBOutlet UIButton *previousPhysicianDetailButton;
    
    IBOutlet UIButton *agreeButton;
    IBOutlet UIButton *disagreeButton;
    
    UIImageView *taperedWhiteLine;
    
    KSLabel *initialSettingsLabel;
    
    IBOutlet UILabel *demoModeLabel;
    IBOutlet UILabel *clinicSelectionLabel;
    IBOutlet V8HorizontalPickerView *clinicPickerView;
    UISegmentedControl *clinicSegmentedControl;
    UISegmentedControl *switchToSectionSegmentedControl;
    IBOutlet UIButton *nextSettingsButton;
    
    NSString *currentClinicName;
    NSString *currentSubClinicName;
    NSString *seeingClinician;
    
    BOOL mainMenuInitialized;
    BOOL educationModuleCompleted;
    BOOL educationModuleInProgress;
    BOOL satisfactionSurveyCompleted;
    BOOL satisfactionSurveyInProgress;
    BOOL physicianModuleCompleted;
    BOOL physicianModuleInProgress;
    BOOL cameFromMainMenu;
    
    BOOL dynamicEdModuleInProgress;
    
    BOOL selectedClinic;
    BOOL selectedVisit;
    
    UIImageView *badgeImageView;
    UIImageView *completedBadgeImageView;
    UIImageView *completedBadgeImageViewEdModule;
    UILabel *badgeLabel;
    BOOL badgeCreated;
    BOOL finalBadgeCreated;
    
    UIImageView *playMovieIcon;
    
    IBOutlet UIButton *odetteButton;
    IBOutlet UIButton *calvinButton;
    IBOutlet UIButton *lauraButton;
    
    UILabel *clinicianLabel;
    
    IBOutlet UIButton *doctorButton;
    IBOutlet UIButton *pscButton;
    IBOutlet UIButton *appointmentButton;
    
    MasterViewController *masterViewController;
    UISplitViewController *splitViewController;
    NSArray *arrayDetailVCs;
    NSArray *allClinicPhysicians;
    NSArray *pmnrSubClinicPhysicians;
    NSArray *allClinicPhysiciansThumbs;
    NSArray *allClinicPhysiciansImages;
    NSArray *allClinicPhysiciansSoundFiles;
    PhysicianDetailViewController *physicianDetailVC;
    NSArray *allClinicPhysiciansBioPLists;
}

@property (nonatomic, retain) SettingsViewController *settingsVC;

@property (nonatomic, readonly) Institution currentInstitution;
@property (nonatomic, readonly) MainClinic currentMainClinic;
@property (nonatomic, retain) DynamicStartAppView *readyScreen;

@property (nonatomic, retain) IBOutlet UIButton *doctorButton;
@property (nonatomic, retain) IBOutlet UIButton *pscButton;
@property (nonatomic, retain) IBOutlet UIButton *appointmentButton;

@property (nonatomic, retain) UILabel *clinicianLabel;

@property (nonatomic, retain) IBOutlet UIButton *odetteButton;
@property (nonatomic, retain) IBOutlet UIButton *calvinButton;
@property (nonatomic, retain) IBOutlet UIButton *lauraButton;

@property (nonatomic, retain) UIImageView *playMovieIcon;

@property (nonatomic, retain) IBOutlet UILabel *edModuleIntroLabel;
@property (nonatomic, retain) IBOutlet UILabel *edModuleCompleteLabel;

@property (nonatomic, retain) UIImageView *badgeImageView;
@property (nonatomic, retain) UIImageView *completedBadgeImageView;
@property (nonatomic, retain) UIImageView *completedBadgeImageViewEdModule;
@property (nonatomic, retain) UILabel *badgeLabel;

@property (nonatomic, retain) NSString *appVersion;
@property (nonatomic, retain) NSString *deviceName;

@property (nonatomic, retain) UISwitch *demoSwitch;
@property (nonatomic, retain) UILabel *demoModeLabel;
@property (nonatomic, retain) UILabel *clinicSelectionLabel;
@property (nonatomic, retain) V8HorizontalPickerView *clinicPickerView;
@property (nonatomic, retain) UISegmentedControl *clinicSegmentedControl;
@property (nonatomic, retain) UISegmentedControl *switchToSectionSegmentedControl;
@property (nonatomic, retain) UIButton *nextSettingsButton;

@property (nonatomic, retain) NSString *currentClinicName;
@property (nonatomic, retain) NSString *currentSubClinicName;
@property (nonatomic, retain) NSString *seeingClinician;

@property BOOL mainMenuInitialized;
@property BOOL educationModuleCompleted;
@property BOOL educationModuleInProgress;
@property BOOL satisfactionSurveyCompleted;
@property BOOL satisfactionSurveyInProgress;
@property BOOL physicianModuleCompleted;
@property BOOL physicianModuleInProgress;
@property BOOL cameFromMainMenu;

@property BOOL dynamicEdModuleInProgress;

@property BOOL selectedClinic;
@property BOOL selectedVisit;

//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet ModalViewExampleViewController *newViewController;

@property (nonatomic, retain) IBOutlet ModalMeViewController *modalViewController;
@property (nonatomic,retain) ContentViewController *modalContent;

@property (nonatomic, retain) IBOutlet PopoverPlaygroundViewController *popoverViewController;

@property (nonatomic, retain) KSLabel *initialSettingsLabel;

@property (nonatomic, retain) IBOutlet UIButton *agreeButton;
@property (nonatomic, retain) IBOutlet UIButton *disagreeButton;

@property (nonatomic, retain) UILabel *readAloudLabel;
@property (nonatomic, retain) UILabel *respondentLabel;
@property (nonatomic, retain) UILabel *selectActivityLabel;
@property (nonatomic, retain) UILabel *surveyIntroLabel;
@property (nonatomic, retain) UILabel *surveyCompleteLabel;

@property (nonatomic, retain)  UILabel *visitSelectionLabel;
@property (nonatomic, retain)  UILabel *selectCliniciansAndLaunchLabel;

@property (nonatomic, retain) IBOutlet UIButton *yesButton;
@property (nonatomic, retain) IBOutlet UIButton *noButton;
@property (nonatomic, retain) IBOutlet UIButton *patientButton;
@property (nonatomic, retain) IBOutlet UIButton *familyButton;
@property (nonatomic, retain) IBOutlet UIButton *satisfactionButton;
@property (nonatomic, retain) IBOutlet UIButton *caregiverButton;
@property (nonatomic, retain) IBOutlet UIButton *tbiEdButton;
@property (nonatomic, retain) IBOutlet UIButton *newsButton;
@property (nonatomic, retain) IBOutlet UIButton *clinicButton;

@property (nonatomic, retain) IBOutlet UIButton *beginSurveyButton;
@property (nonatomic, retain) IBOutlet UIButton *returnToMenuButton;

@property (nonatomic, retain) IBOutlet UIButton *firstVisitButton;
@property (nonatomic, retain) IBOutlet UIButton *returnVisitButton;
@property (nonatomic, retain) IBOutlet UIButton *readyAppButton;
@property (nonatomic, retain) IBOutlet UIButton *voiceAssistButton;
@property (nonatomic, retain) IBOutlet UIButton *fontsizeButton;

@property (nonatomic, retain) IBOutlet UIButton *nextSurveyItemButton;
@property (nonatomic, retain) IBOutlet UIButton *previousSurveyItemButton;
@property (nonatomic, retain) IBOutlet UIButton *nextEdItemButton;
@property (nonatomic, retain) IBOutlet UIButton *previousEdItemButton;
@property (nonatomic, retain) IBOutlet UIButton *nextPhysicianDetailButton;
@property (nonatomic, retain) IBOutlet UIButton *previousPhysicianDetailButton;


@property (nonatomic, retain) RootViewController_Pad *tbvc;
@property (nonatomic, retain) EdViewController_Pad *edModule;
@property (nonatomic, retain) PhysicianViewController_Pad *physicianModule;
@property (nonatomic, retain) DynamicModuleViewController_Pad *dynamicEdModule;

@property (nonatomic, retain) NSString *currentDynamicClinicEdModuleSpecFilename;

@property (nonatomic, retain) MyViewController *cubeViewController;

@property BOOL isFirstVisit;

@property (nonatomic, retain) UIWebView *aWebView;
@property (nonatomic, retain) UIWebView *menuCubeWebView;

@property (nonatomic, retain) UIImageView *connectivityImageView;
@property (nonatomic, retain) UIImageView *noConnectionAnimation;
@property (nonatomic, retain) UIView *waitingForConnectionCover;
@property (nonatomic, retain) UILabel *waitingForConnectionLabel;

@property (nonatomic, retain) NSTimer *endOfSplashTimer;

@property BOOL splashAnimationsFinished;

@property (nonatomic, retain) UIImageView *resourceBack;
@property (nonatomic, retain) UIImageView *surveyResourceBack;
@property (nonatomic, retain) UIImageView *allWhiteBack;

@property (nonatomic, retain) UIImageView *tabNAdView;
@property (nonatomic, retain) UIView *statusViewWhiteBack;

@property (nonatomic, retain) UIImageView *splashImageView;
@property (nonatomic, retain) UIImageView *splashImageViewB;
@property (nonatomic, retain) UIImageView *splashImageViewBb;
@property (nonatomic, retain) UIImageView *splashImageViewC;

@property (nonatomic, retain) UIImageView *taperedWhiteLine;

@property (nonatomic, retain) UIActivityIndicatorView *splashSpinner;

//@property (nonatomic, retain) UINavigationController *navController;

@property BOOL mapViewInitialized;
@property BOOL mapTabEnabled;

@property int lastRowImportedFromUsersDb;

@property (nonatomic, retain) MasterViewController *masterViewController;
@property (nonatomic, retain) NSArray *arrayDetailVCs;
@property (nonatomic, retain) NSArray *allClinicPhysicians;
@property (nonatomic, retain) NSArray *pmnrSubClinicPhysicians;
@property (nonatomic, retain) NSArray *allClinicPhysiciansThumbs;
@property (nonatomic, retain) NSArray *allClinicPhysiciansImages;
@property (nonatomic, retain) NSArray *allClinicPhysiciansSoundFiles;
@property (nonatomic, retain) UISplitViewController *splitViewController;

@property (nonatomic, retain) NSString *mainClinicName;
@property (nonatomic, retain) NSString *subClinicName;
@property (nonatomic, retain) NSString *attendingPhysicianName;
@property (nonatomic, retain) NSString *attendingPhysicianThumb;
@property (nonatomic, retain) NSString *attendingPhysicianImage;
@property int attendingPhysicianIndex;
@property (nonatomic, retain) NSString *attendingPhysicianSoundFile;
@property (nonatomic, retain) NSArray *allClinicPhysiciansBioPLists;

@property (nonatomic, retain) PhysicianDetailViewController *physicianDetailVC;

- (void)createClinicSplitViewController;

- (void)setNewDetailVCForRow:(int)newRow;

- (void)demoSwitchFlipped:(id)sender;

- (void)yesNoPressed:(id)sender;
- (void)visitButtonPressed:(id)sender;
- (void)readyButtonPressed:(id)sender;
- (void)startButtonPressed:(id)sender;
- (void)respondentButtonPressed:(id)sender;
- (void)menuButtonPressed:(id)sender;
- (void)voiceassistButtonPressed:(id)sender;
- (void)fontsizeButtonPressed:(id)sender;

- (void)beginSatisfactionSurvey:(id)sender;
- (void)requestSurveyAgreement:(NSTimer*)theTimer;


- (void)surveyCompleted;
- (BOOL)isPossibleToGetMaxIDFromMySQL;

- (BOOL)isAppRunningInDemoMode;

- (void)returnToMenu;

- (void)selectedSatisfactionWithVC:(id)sender andSegmentIndex:(int)selectedIndex;

- (void)sendEmailWithDataAttached;

- (void)updateMiniDemoSettings;

- (void)showAdminKeypad;

- (void)adminSendDataButtonPressed:(id)sender;
- (void)adminShowSendDataButton;

- (void)activateSurveyBackButton;
- (void)deactivateSurveyBackButton;

- (void)activateEdBackButton;
- (void)deactivateEdBackButton;

- (void)agreeButtonPressed;
- (void)disagreeButtonPressed;

- (void)fadeToNextSurveyPrompt:(id)sender;
- (void)fadeToLastSurveyPrompt:(id)sender;
- (void)lastSurveyPrompt:(NSTimer*)theTimer;
- (void)completeReturnToMenu:(NSTimer*)theTimer;
- (void)completeBeginSatisfactionSurvey:(NSTimer*)theTimer;

- (void)createBadgeOnSatisfactionSurveyButton;
- (void)updateBadgeOnSatisfactionSurveyButton;

- (void)setUpEducationModuleForFirstTime;
- (void)reshowEducationModule;
- (void)fadeToEducationModuleStart:(id)sender;
- (void)showEducationModuleIntro;
- (void)beginEducationModule:(id)sender;
- (void)completeBeginEducationModule:(NSTimer*)theTimer;
- (void)edModuleFinished;

- (void)clinicianSelectedWith:(id)sender;
- (void)storeAttendingPhysicianSettingsForPhysicianName:(NSString *)selectedPhysicianName;

- (void)activateLaunchButton;
- (void)deactivateLaunchButton;

- (void)initializePhysicianDetailView;
- (void)fadePhysicianDetailVCIn;

- (void)activatePhysicianBackButton;
- (void)deactivatePhysicianBackButton;

- (void)launchEducationModule;
- (void)fadePhysicianDetailOut;
- (void)finishFadePhysicianDetailOut:(NSTimer*)theTimer;

- (void)fadeDynamicEdModuleOut;
- (void)finishFadeDynamicEdModuleOut:(NSTimer*)theTimer;

- (void)launchSatisfactionSurvey;

@end
