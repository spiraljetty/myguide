//
//  RootViewController_Pad.h
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

#import "TTSPlayer.h"

@protocol DynamicModuleDelegate <NSObject>

@required
//- (void)receivedAudio:(NSMutableData *)data;
//- (void)sentAudioRequest;
@end

@class QuickMovieViewController;
@class NewPlayerView;

@interface DynamicModuleViewController_Pad : UIViewController <DynamicModulePageDelegate, DynamicButtonOverlayDelegate> {
    
    TTSPlayer *masterTTSPlayer;
    
    id <DynamicModuleDelegate> delegate;
    
    NSDictionary *currentPhysicianDetails;
    NSArray *currentPhysicianDetailSectionNames;
    
    UIViewController *currentModalVC;
    
    UINavigationBar *bar;
    UINavigationItem *item;
    
    ReflectingView *backsplash;
    int vcIndex;
    
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

@property (nonatomic, retain) TTSPlayer *masterTTSPlayer;

@property (nonatomic, retain) PopoverPlaygroundViewController *termPopoverViewController;
@property (nonatomic, retain) UIButton *hiddenPopoverButton;

@property (nonatomic, retain) id <DynamicModuleDelegate> delegate;

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

+ (DynamicModuleViewController_Pad*) getViewController;

- (void)setupClinicContent;
- (void)setupWhatsNewContent;
- (void)setupEdModule:(int)moduleIndex;
- (id)initWithPropertyList:(NSString *)propertyListName;
- (void)setupWithPropertyList:(NSString *)propertyListName;
- (void)loadPages;

- (void)startingFirstPage;
//- (void)startingFirstMiniSurveyPage;
//- (void)startingFinalSurveyPage;

- (void)showButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;
- (void)hideButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;

- (void)progress:(id)sender;
- (void)playSound;
- (void)regress:(id)sender;

-(IBAction)nextDone:(id)inSender;

- (void)stopMoviePlayback;

-(void)createImageRootInDocDir;

+ (DynamicModuleViewController_Pad*) getViewController;
- (void) updateViewContents;
- (void)showTempPopover;
- (void)playSoundForPage:(DynamicModulePageViewController *)currentPage;

//- (void)showModalSubclinicTestCorrectView;
//- (void)showModalSubclinicTestIncorrectView;
//- (void)dismissCurrentModalVC;

- (void)goForward;
- (void)goBackward;

- (void) setCurrentPage:(int)pageIndex;
- (void)cycleFontSizeForAllLabels;

@end
