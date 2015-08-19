//
//  DynamicSurveyViewController_Pad.h
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import <UIKit/UIKit.h>
//#import "RotatingSegue.h"
#import "ReflectingView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MyContentViewController.h"
#import "ZipArchive.h"
#import "PSFileManager.h"
#import "RVRotationViewerController.h"
#import <sqlite3.h>

#import <Foundation/Foundation.h>
#import "DynamicModulePageViewController.h"
#import "DynamicButtonOverlayViewController.h"
#import "DynamicPageDetailViewController.h"

#import "PopoverPlaygroundViewController.h"

#import "SwitchedImageViewController.h"

#import "TTSPlayer.h"

//@protocol DynamicModuleDelegate <NSObject>
//
//@required
////- (void)receivedAudio:(NSMutableData *)data;
////- (void)sentAudioRequest;
//@end

@class QuickMovieViewController;
@class NewPlayerView;

@interface DynamicSurveyViewController_Pad : UIViewController <DynamicModulePageDelegate, DynamicButtonOverlayDelegate> {
    
    TTSPlayer *masterTTSPlayer;
    
    id delegate;
    
    BOOL addPrePostSurveyItems;
    
    BOOL addGoalSurveyItems;
    
    BOOL addMiniSurveyItems;
    
    SwitchedImageViewController *miniSurveyPage1;
    
    NSString *todaysGoal;
    
    NSDictionary *currentPhysicianDetails;
    NSArray *currentPhysicianDetailSectionNames;
    
    UIViewController *currentModalVC;
    
    UINavigationBar *bar;
    UINavigationItem *item;
    
    ReflectingView *backsplash;
    int vcIndex;
    
    int currentFinishingIndex;
    int numberOfPostTreatmentItems;
    
    QuickMovieViewController *movViewController;
    
    UIPageControl *pageControl;
    
    NSTimer *newTimer;
    
    BOOL speakItemsAloud;
    BOOL finishingLastItem;
    
    AVQueuePlayer *mQueuePlayer;
    NewPlayerView *mPlayerView;
    
    MyContentViewController *modalContent;
    
    UIButton *showDefaultButton, *showFlipButton, *showDissolveButton, *showCurlButton;
    
    NSString *respondentType;
    
    // Database variables
    sqlite3 *db;
	NSString *databaseName;
	NSString *databasePath;
    NSString *mainTable;
    NSString *csvpath;
    
    int currentUniqueID;
    
    BOOL playingMovie;
    
    PSFileManager *fileman;
    NSString *animationPath;
    
    RVRotationViewerController *rotationViewController;
    
    NSDictionary *dynModDict;
    NSArray *dynModDictKeys;
    
    NSString *moduleName;
    NSString *moduleType;
    BOOL createModuleDynamically;
    NSString *moduleImageName;
    
    NSString *start_transition_type;
    NSString *end_transition_type;
    NSString *start_transition_origin;
    NSString *end_transition_origin;
    
    NSString *moduleTheme;
    NSString *moduleColor;
    BOOL isModuleMandatory;
    NSMutableArray *recognizeUserSpeechWords;
    NSString *superModule;
    NSMutableArray *subModules;
    NSMutableArray *pages;
    
    NSMutableArray *newChildControllers;
    NSMutableDictionary *ttsSoundFileDict;
    NSMutableArray *labelObjects;
    
    BOOL inSubclinicMode;
    BOOL inWhatsNewMode;
    BOOL inEdModule1;
    BOOL inEdModule2;
    BOOL inEdModule3;
    BOOL inEdModule4;
    BOOL inEdModule5;
    BOOL inEdModule6;
    BOOL inEdModule7;
    BOOL inEdModule8;
    BOOL inEdModule9;
    BOOL inEdModule10;
    
    DynamicButtonOverlayViewController *standardPageButtonOverlay;
    DynamicButtonOverlayViewController *yesNoButtonOverlay;
    
    DynamicPageDetailViewController *dynamicModuleHeader;
    BOOL showModuleHeader;
    
    PopoverPlaygroundViewController *termPopoverViewController;
    UIButton *hiddenPopoverButton;
}
@property int vcIndex;

@property int numberOfPostTreatmentItems;
@property int currentFinishingIndex;

@property BOOL inSubclinicMode;
@property BOOL inWhatsNewMode;

@property BOOL inEdModule1;
@property BOOL inEdModule2;
@property BOOL inEdModule3;
@property BOOL inEdModule4;
@property BOOL inEdModule5;
@property BOOL inEdModule6;
@property BOOL inEdModule7;
@property BOOL inEdModule8;
@property BOOL inEdModule9;
@property BOOL inEdModule10;

@property (nonatomic, retain) NSString *todaysGoal;
@property (nonatomic, retain) SwitchedImageViewController *miniSurveyPage1;

@property (nonatomic, retain) TTSPlayer *masterTTSPlayer;

@property (nonatomic, retain) PopoverPlaygroundViewController *termPopoverViewController;
@property (nonatomic, retain) UIButton *hiddenPopoverButton;

@property (nonatomic, retain) id delegate;

@property (nonatomic, retain) NSDictionary *dynModDict;
@property (nonatomic, retain) NSArray *dynModDictKeys;

@property (nonatomic, retain) NSString *moduleName;
@property (nonatomic, retain) NSString *moduleType;
@property BOOL createModuleDynamically;
@property (nonatomic, retain) NSString *moduleImageName;

@property (nonatomic, retain) NSString *start_transition_type;
@property (nonatomic, retain) NSString *end_transition_type;
@property (nonatomic, retain) NSString *start_transition_origin;
@property (nonatomic, retain) NSString *end_transition_origin;

@property (nonatomic, retain) NSString *moduleTheme;
@property (nonatomic, retain) NSString *moduleColor;
@property BOOL isModuleMandatory;
@property (nonatomic, retain) NSMutableArray *recognizeUserSpeechWords;
@property (nonatomic, retain) NSString *superModule;
@property (nonatomic, retain) NSMutableArray *subModules;
@property (nonatomic, retain) NSMutableArray *pages;

@property (nonatomic, retain) NSMutableArray *newChildControllers;
@property (nonatomic, retain) NSMutableDictionary *ttsSoundFileDict;
@property (nonatomic, retain) NSMutableArray *labelObjects;

@property (nonatomic, retain) DynamicButtonOverlayViewController *standardPageButtonOverlay;
@property (nonatomic, retain) DynamicButtonOverlayViewController *yesNoButtonOverlay;

@property (nonatomic, retain) DynamicPageDetailViewController *dynamicModuleHeader;
@property BOOL showModuleHeader;

@property (nonatomic, retain) NSDictionary *currentPhysicianDetails;
@property (nonatomic, retain) NSArray *currentPhysicianDetailSectionNames;

@property (nonatomic, retain) RVRotationViewerController *rotationViewController;

@property (nonatomic, retain) IBOutlet QuickMovieViewController *movViewController;

@property BOOL speakItemsAloud;
@property BOOL playingMovie;

@property (nonatomic, retain) IBOutlet UIButton *showDefaultButton, *showFlipButton, *showDissolveButton, *showCurlButton;

@property (nonatomic, retain) NSString *animationPath;

@property (nonatomic, retain) NSTimer *newTimer;

@property(nonatomic,retain) AVQueuePlayer *queuePlayer;
@property(nonatomic,retain) IBOutlet NewPlayerView *playerView;

@property (nonatomic,retain) MyContentViewController *modalContent;

@property (nonatomic, retain) NSString *respondentType;
@property (nonatomic, retain) NSString *databasePath;
@property (nonatomic, retain) NSString *mainTable;
@property (nonatomic, retain) NSString *csvpath;

+ (DynamicSurveyViewController_Pad*) getViewController;
+ (void) setProviderHelpfulText:(NSString*) text;
+ (void) setClinicHelpfulText:(NSString*) text;

+ (void) setMiniSurveyPage2HeaderText:(NSString*) text;
+ (void) setMiniSurveyPage2Text:(NSString*) text;
+ (void) setMiniSurveyPage3Text:(NSString*) text;
+ (void) setMiniSurveyPage4Text:(NSString*) text;

- (void)loadAllSurveyPages;


- (id)initWithPropertyList:(NSString *)propertyListName;
- (void)setupWithPropertyList:(NSString *)propertyListName;
- (void)loadPages;

- (void)startingFirstPage;
- (void)startingFirstMiniSurveyPage;
- (void)startingFinalSurveyPage;
- (void)startOnSurveyPageWithIndex:(int)pageIndex;
- (void)startOnSurveyPageWithIndex:(int)pageIndex withFinishingIndex:(int)finishingPageIndex;
- (void)playSoundForCurrentSurveyPage;

- (void)showButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;
- (void)hideButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;

- (void)progress:(id)sender;
- (void)playSound;
- (void)regress:(id)sender;

-(IBAction)nextDone:(id)inSender;

- (void)stopMoviePlayback;

-(void)createImageRootInDocDir;

- (void)showTempPopover;
- (void)playSoundForSurveyPage:(SwitchedImageViewController *)currentSurveyPage;

- (void)showModalProviderTestCorrectView;
- (void)showModalProviderTestIncorrectView;
- (void)showModalSubclinicTestCorrectView;
- (void)showModalSubclinicTestIncorrectView;
- (void)dismissCurrentModalVC;
- (void)updateGoalRatingText;

- (NSMutableArray *)createArrayOfAllSurveyPages;

- (void)goForward;
- (void)goBackward;

- (void)showModule1CompletedBadge;
- (void)showModule2CompletedBadge;

- (void)hideOverlayNextButton;
- (void)hideOverlayPreviousButton;
- (void)showOverlayNextButton;
- (void)showOverlayPreviousButton;

- (void) setCurrentPage:(int)pageIndex;

- (void)cycleFontSizeForAllLabels;

@end
