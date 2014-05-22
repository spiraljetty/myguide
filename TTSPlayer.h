//
//  TTSPlayer.h
//  satisfaction_survey
//
//  Created by dhorton on 1/30/13.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SettingsViewController.h"

@interface TTSPlayer : NSObject {
    BOOL speakItemsAloud;
    
    float currentVolume;
    float desiredVolume;
    
    AVQueuePlayer *queuePlayer;
    TTSVoiceType currentlyPlayingVoiceType;
    TTSVoiceSpeed currentlyPlayingVoiceSpeed;
}
@property float currentVolume;
@property float desiredVolume;
@property (nonatomic, retain) AVQueuePlayer *queuePlayer;
@property BOOL speakItemsAloud;
@property TTSVoiceSpeed currentlyPlayingVoiceSpeed;
@property TTSVoiceType currentlyPlayingVoiceType;

- (void)stopPlayer;
- (void)forceToSpeakerOutput;
- (void)forceToHeadphoneOutput;
- (void)playItemsWithNames:(NSArray *)arrayOfSoundFileNames;
- (void)fadeToMaxVolume;
- (void)fadeToDesiredVolume:(float)thisVolume;
- (void)continueVolumeFade;
- (void)increaseVolume;
- (void)decreaseVolume;

@end
