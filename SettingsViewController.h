//
//  SettingsViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import "RJGoogleTTS.h"
#import "DynamicStartAppButtonView.h"
#import "PronunciationFixer.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

typedef enum {
    kConnected,
    kConnectionPending,
    kConnectionFailed,
} ConnectionType;

typedef enum {
    kNoLink,
    kWIFILink,
    kCellLink,
} LinkType;

typedef enum {
    usenglishfemale,
    usenglishmale,
} TTSVoiceType;

typedef enum {
    normalspeed,
    slowspeed,
    fastspeed,
} TTSVoiceSpeed;

@class ControlView;
@class YLViewController;

//@interface SettingsViewController : UIViewController <RJGoogleTTSDelegate> {
@interface SettingsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {

    BOOL truncateTo99Chars;
    BOOL truncateTo199Chars;
    
    BOOL onlyDownloadFemaleFastForDebugging;
    
    BOOL loadSoundsForAllSpeedsAndVoices;
    
    BOOL updateSelectSounds;
    
    ControlView *controlView;
    BOOL buttonOpen;
    UIButton *invisibleShowHideButton;
    UIButton *invisibleDownloadButton;
    YLViewController *soundViewController;
    
    ConnectionType currentConnectionType;
    
    UIImageView *gearImageView;
    UIImageView *downloadImageView;
    UILabel *downloadLabel;
    
    DynamicStartAppButtonView *enableOfflineVoiceModeButton;
    DynamicStartAppButtonView *resetAllOfflineSoundfilesButton;
    
    NSString *currentlyLoadingSoundFilenamePrefix;
//    NSMutableArray *coreSoundFilenames;
    NSMutableArray *soundFilenamesRemaining;
    NSMutableArray *allSoundFilenamesToLoad;
    int currentDynamicSoundFilenamesRemainingNum;
    
    NSMutableArray *substringFilenamesChunkArray;
    NSMutableArray *substringTextChunkArray;
    
    TTSVoiceType currentlySelectedVoiceType;
    TTSVoiceSpeed currentlySelectedVoiceSpeed;
    
    PronunciationFixer *fixPronunciation;
    
    CLLocationCoordinate2D homeCoords;
    int numUpdates;
    NSTimer *shortWaitTimer;
    
    BOOL createdSuccessfulLink;
    BOOL connectedToWIFI;
    NSString *lastConnectedWIFISSIDName;
    BOOL shouldDisplayAlertAndPlayWanderAlarm;
    BOOL loopAlarm;
    BOOL shouldDisplayHeadsetAlert;
    BOOL headsetPluggedIn;
    BOOL wanderGuardActivated;
    
    NSString *activeAudioRouteString;
    
}

@property BOOL connectedToWIFI;
@property (nonatomic, retain) NSString *lastConnectedWIFISSIDName;
@property (nonatomic, retain) NSString *activeAudioRouteString;

@property BOOL wanderGuardActivated;
@property BOOL createdSuccessfulLink;
@property BOOL shouldDisplayAlertAndPlayWanderAlarm;
@property BOOL loopAlarm;
@property BOOL shouldDisplayHeadsetAlert;
@property BOOL headsetPluggedIn;

@property (nonatomic, retain) NSTimer *shortWaitTimer;
@property int numUpdates;
@property CLLocationCoordinate2D homeCoords;

@property BOOL onlyDownloadFemaleFastForDebugging;

@property BOOL updateSelectSounds;

@property (nonatomic, retain) PronunciationFixer *fixPronunciation;

@property (nonatomic, retain) ControlView *controlView;
@property (nonatomic, retain) UIButton *invisibleShowHideButton;
@property (strong, nonatomic) YLViewController *soundViewController;
@property (nonatomic, retain) DynamicStartAppButtonView *enableOfflineVoiceModeButton;
@property (nonatomic, retain) DynamicStartAppButtonView *resetAllOfflineSoundfilesButton;

@property (nonatomic, retain) NSString *currentlyLoadingSoundFilenamePrefix;
@property (nonatomic, retain) NSMutableArray *soundFilenamesRemaining;
@property (nonatomic, retain) NSMutableArray *allSoundFilenamesToLoad;
@property int currentDynamicSoundFilenamesRemainingNum;

@property (nonatomic, retain) NSMutableArray *substringFilenamesChunkArray;
@property (nonatomic, retain) NSMutableArray *substringTextChunkArray;

- (void)updateThisLocation:(NSTimer*)theTimer;

- (IBAction)TTSVoiceSpeedSegmentedControlChanged:(id)sender;
- (IBAction)TTSVoiceTypeSegmentedControlChanged:(id)sender;

- (IBAction)resetTTSSoundFilesPressed;
- (void)loadAllTTSSoundFiles;
- (void)deleteTTSSoundFilesInArray:(NSArray *)soundfilenamesToDelete;
- (void)loadRemainingSoundFilenamesInArray:(NSMutableArray *)remainingSoundFilenames;
- (void)loadRemainingSoundFilenamesInSubstringArray:(NSMutableArray *)remainingSubstringSoundFilenames withSubstringTextArray:(NSMutableArray *)remainingSubstringText;
- (NSMutableArray *)soundFilenamesForAllSpeedsAndVoicesWithOriginalArray:(NSMutableArray *)originalSoundFilenameArray;
- (void)sentAudioRequest;
- (void)receivedAudio:(NSMutableData *)data;
- (void)handleFailedRequest;

- (id)initWithFrame:(CGRect)frame;
- (void)showHideButtonPressed;
- (void)updateNetworkStatusWithConnectionType:(ConnectionType)thisConnectionType;
- (void)updateLinkStatusWithLinkType:(NetworkStatus)thisLinkType;
- (NSString *)getTodayDateAndTimeString;
- (void)hideSettingsFrame;
- (void)changeUpdateSelectSoundsValueTo:(BOOL)thisBool;
- (void)updateThisLink:(NSTimer*)theTimer;
- (void)updateLinkQuickly;
- (void)playAlarmInLoop;
- (void)setHeadSetStatusTo:(NSString *)audioRouteString;
- (void)updateSoundSettingsBasedOnHeadsetStatus;
- (void)checkthatHeadsetIsPluggedIn;
- (NSString *)fetchSSIDName;
- (id)fetchSSIDInfo;
- (BOOL)isDifferentSSID;

@end
