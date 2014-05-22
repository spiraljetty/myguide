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

@class QuickMovieViewController;
@class NewPlayerView;

@interface PhysicianViewController_Pad : UIViewController {
    
    NSDictionary *currentPhysicianDetails;
    NSArray *currentPhysicianDetailSectionNames;
    
    UINavigationBar *bar;
    UINavigationItem *item;
    
    NSMutableArray *newChildControllers;

    ReflectingView *backsplash;
    int vcIndex;
    
    QuickMovieViewController *movViewController;
    
    UIPageControl *pageControl;
    
    NSTimer *newTimer;
    
    BOOL speakItemsAloud;
    BOOL finishingLastItem;

    AVQueuePlayer *mQueuePlayer;
    NewPlayerView *mPlayerView;
    
    AVPlayerItem *pt_sound_1_item, *pt_sound_2_item, *pt_sound_3_item, *pt_sound_4_item, *pt_sound_5_item, *pt_sound_6_item, *pt_sound_7_item, *pt_sound_8_item;
    AVPlayerItem *pt_sound_9_item, *pt_sound_10_item, *pt_sound_11_item, *pt_sound_12_item, *pt_sound_13_item, *pt_sound_14_item, *pt_sound_15_item, *pt_sound_16_item;
    
    IBOutlet MyContentViewController *modalContent;
    
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
}


- (void)progress:(id)sender;
- (void)playSound;
- (void)regress:(id)sender;

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

-(IBAction)madeSatisfactionRatingForVC:(id)currentVC withSegmentIndex:(int)selectedIndex;

-(IBAction)turnVoiceOn:(id)sender;
-(IBAction)turnVoiceOff:(id)sender;

-(IBAction)setRespondentToPatient:(id)sender;
-(IBAction)setRespondentToFamily:(id)sender;
-(IBAction)setRespondentToCaregiver:(id)sender;

-(IBAction)nextDone:(id)inSender;

- (IBAction)showDefault:(id)sender;
- (IBAction)showFlip:(id)sender;
- (IBAction)showDissolve:(id)sender;
- (IBAction)showCurl:(id)sender;

- (void)sayWelcomeToApp;
- (void)sayOK;
- (void)sayRespondentTypes;
- (void)saySelectActivity;
- (void)saySurveyIntro;
- (void)saySurveyCompletion;
- (void)sayComingSoon;
- (IBAction)sayDisagree;
- (IBAction)sayAgree;
- (IBAction)sayNA;
- (IBAction)sayNeutral;
- (IBAction)sayStrongAgree;
- (IBAction)sayStrongDisagree;

-(void)sayFirstItem;

- (void)checkAndLoadLocalDatabase;
- (void)writeLocalDbToCSVFile;

-(NSString *)filePath;
-(void)openDB;
-(void)closeDB;
-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value;
-(void)updaterecordInTable:(NSString*)tableName withIDField:(NSString*)IDField IDFieldValue:(NSString*)IDField1Vaue andNewField:(NSString*)newField newFieldValue:(NSString*)newFieldValue;
- (int)getUniqueIDFromCurrentTime;
-(void)createNewRespondentWithRespondentType:(NSString*)currentRespondentType;
-(void)updateSatisfactionRatingForField:(NSString*)satisfactionItem withSelectedIndex:(int)currentIndex;
-(void)putNewRespondentInDB;

- (int)getCurrentMonth;
- (int)getCurrentYear;

- (void)stopMoviePlayback;

-(void)createImageRootInDocDir;

- (void)sayPhysicianDetailIntro;

@end
