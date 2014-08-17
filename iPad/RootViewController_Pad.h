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

#import <sqlite3.h>

#import "RJGoogleTTS.h"
#import "TTSPlayer.h"

@class NewPlayerView;
//@interface RootViewController_Pad : UIViewController <RJGoogleTTSDelegate> {
@interface RootViewController_Pad : UIViewController {

    UINavigationBar *bar;
    UINavigationItem *item;
    
    NSMutableArray *newChildControllers;

    ReflectingView *backsplash;
    int vcIndex;
    
    UIPageControl *pageControl;
    
    NSTimer *newTimer;
    
    BOOL speakItemsAloud;
    BOOL finishingLastItem;

    AVQueuePlayer *mQueuePlayer;
    NewPlayerView *mPlayerView;
    
    AVPlayerItem *satisfaction_sound_1_item, *satisfaction_sound_2_item, *satisfaction_sound_3_item, *satisfaction_sound_4_item, *satisfaction_sound_5_item, *satisfaction_sound_6_item, *satisfaction_sound_7_item, *satisfaction_sound_8_item;
    AVPlayerItem *satisfaction_sound_9_item, *satisfaction_sound_10_item, *satisfaction_sound_11_item, *satisfaction_sound_12_item, *satisfaction_sound_13_item, *satisfaction_sound_14_item, *satisfaction_sound_15_item, *satisfaction_sound_16_item;
    AVPlayerItem *satisfaction_sound_17_item, *satisfaction_sound_18_item, *satisfaction_sound_19_item, *satisfaction_sound_20_item, *satisfaction_sound_21_item, *satisfaction_sound_22_item, *satisfaction_sound_23_item, *satisfaction_sound_24_item;
    AVPlayerItem *satisfaction_sound_25_item, *satisfaction_sound_26_item, *satisfaction_sound_27_item, *satisfaction_sound_28_item;
    
    IBOutlet MyContentViewController *modalContent;
    
    UIButton *showDefaultButton, *showFlipButton, *showDissolveButton, *showCurlButton;
    
    NSString *respondentType;
    
    // Database variables
    sqlite3 *db;
	NSString *databaseName;
	NSString *databasePath;
    NSString *mainTable;
    NSString *csvpath;
    NSString *csvpathCurrentFilename;
    
    int currentUniqueID;
    
    int currentFontSize;
    
    NSArray *patientSatisfactionLabelItems;
    NSArray *familySatisfactionLabelItems;
    NSArray *caregiverSatisfactionLabelItems;
    
    NSArray *patientPromptLabelItems;
    NSArray *familyPromptLabelItems;
    NSArray *caregiverPromptLabelItems;
    
    AVPlayerItem *current_satisfaction_sound_item;

    int totalSurveyItems;
    int surveyItemsRemaining;
    int numSurveyItems;
    
    NSString *currentPromptString;
    
    TTSPlayer *masterTTSPlayer;
    
    NSString *currentDeviceName;
}


- (void)progress:(id)sender;
- (void)playSound;
- (void)regress:(id)sender;

@property (nonatomic, retain) NSString *currentDeviceName;

@property (nonatomic, retain) NSMutableArray *newChildControllers;

@property (nonatomic, retain) TTSPlayer *masterTTSPlayer;

@property (nonatomic, retain) NSString *currentPromptString;

@property int currentUniqueID;
@property int currentFontSize;
@property int totalSurveyItems;
@property int surveyItemsRemaining;
@property int numSurveyItems;

@property int vcIndex;

@property BOOL speakItemsAloud;

@property (nonatomic, retain) IBOutlet UIButton *showDefaultButton, *showFlipButton, *showDissolveButton, *showCurlButton;

@property (nonatomic, retain) NSTimer *newTimer;

@property(nonatomic,retain) AVQueuePlayer *queuePlayer;
@property(nonatomic,retain) IBOutlet NewPlayerView *playerView;

@property (nonatomic,retain) MyContentViewController *modalContent;

@property (nonatomic, retain) NSString *respondentType;
@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *databasePath;
@property (nonatomic, retain) NSString *mainTable;
@property (nonatomic, retain) NSString *csvpath;
@property (nonatomic, retain) NSString *csvpathCurrentFilename;

@property (nonatomic, retain) NSArray *patientSatisfactionLabelItems;
@property (nonatomic, retain) NSArray *familySatisfactionLabelItems;
@property (nonatomic, retain) NSArray *caregiverSatisfactionLabelItems;

@property (nonatomic, retain) NSArray *patientPromptLabelItems;
@property (nonatomic, retain) NSArray *familyPromptLabelItems;
@property (nonatomic, retain) NSArray *caregiverPromptLabelItems;

-(IBAction)madeSatisfactionRatingForVC:(id)currentVC withSegmentIndex:(int)selectedIndex;
-(void)madeDynamicSurveyRatingWithSegmentIndex:(int)selectedIndex;

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
- (void)sayAgreeLonger;
- (IBAction)sayNA;
- (IBAction)sayNeutral;
- (IBAction)sayStrongAgree;
- (IBAction)sayStrongDisagree;
- (IBAction)saySurveyAgreement;
- (void)sayThankYouForParticipatingMoveToFirstItem;
- (void)sayEdModuleIntro;
- (void)sayEducationModuleCompletion;



-(void)sayFirstItem;

- (void)checkAndLoadLocalDatabase;
- (void)writeLocalDbToCSVFile;
- (void)writeLogMsg:(NSString*) msg;
- (void)myLog:(NSString*) format, ...;

-(NSString *)filePath;
-(void)openDB;
-(void)closeDB;
-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value;
-(void)updaterecordInTable:(NSString*)tableName withIDField:(NSString*)IDField IDFieldValue:(NSString*)IDField1Vaue andNewField:(NSString*)newField newFieldValue:(NSString*)newFieldValue;
- (int)getUniqueIDFromCurrentTime;
-(void)createNewRespondentWithRespondentType:(NSString*)currentRespondentType;
-(void)updateSatisfactionRatingForField:(NSString*)satisfactionItem withSelectedIndex:(int)currentIndex;
-(void)putNewRespondentInDB;

- (void)updateSurveyNumberForField:(NSString *)surveyItem withThisRatingNum:(int)thisRating;
- (void)updateSurveyTextForField:(NSString *)surveyItem withThisText:(NSString *)thisText;

- (int)getCurrentMonth;
- (int)getCurrentYear;

- (void)cycleFontSizeForAllLabels;

- (BOOL)isCurrentSatisfactionItemLastWithIndex:(int)thisIndex;

- (void)replayCurrentSatisfactionSound;
- (void)showReplayButton;
- (void)hideReplayButton;

- (void)testButtonMethod;

- (void)addNewActionsToButtons;

- (void)highlightStronglyDisagree;
- (void)highlightDisagree;
- (void)highlightNeutral;
- (void)highlightAgree;
- (void)highlightStronglyAgree;
- (void)highlightDoesNotApply;

- (void)setAllSegmentsTo;
- (void)playSoundForIndex:(int)thisPageIndex;

- (UISegmentedControl *)currentActiveSegmentedControlForIndex:(int)currentVCIndex;

- (void)goForward;
- (void)goBackward;
- (NSMutableArray *)getAllUniqueIds;
- (BOOL)isUniqueIdSuffixInDb:(int)thisUniqueIdSuffix;
- (int)getUniqueIdWithSuffix:(int)thisUniqueIdSuffix;
- (void)updateRespondentToPatient;
- (void)updateRespondentToFamily;
- (void)updateRespondentToCaregiver;
- (NSString *)getRespondentTypeForUniqueId:(int)thisUniqueId;

@end
