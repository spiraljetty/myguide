//
//  TTSPlayer.m
//  satisfaction_survey
//
//  Created by dhorton on 1/30/13.
//
//

#import "TTSPlayer.h"
#import "AppDelegate_Pad.h"
#import "YLViewController.h"

@implementation TTSPlayer

@synthesize queuePlayer, speakItemsAloud, currentlyPlayingVoiceType, currentlyPlayingVoiceSpeed, currentVolume, desiredVolume;

- (void)stopPlayer {
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
}

- (void)forceToSpeakerOutput {
    printf("Override audio output to speaker\n");
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                           sizeof(sessionCategory),
                                           &sessionCategory);
    // 2. Changing the default output audio route
//	UInt32 doChangeDefaultRoute = 1;
//	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
//    
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    AudioSessionSetActive(TRUE);
    if (err) {
        NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", err);
    }
}

- (void)forceToHeadphoneOutput {
    printf("Override audio output to headphones\n");
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                           sizeof(sessionCategory),
                                           &sessionCategory);
    
    // 2. Changing the default output audio route
	UInt32 doChangeDefaultRoute = 1;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    AudioSessionSetActive(TRUE);
    if (err) {
        NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", err);
    }
}

- (void)fadeToMaxVolume
{
    NSLog(@"Increasing volume...");
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    musicPlayer.volume += 0.05;
    if (musicPlayer.volume < 1.0 ) {
        [self performSelector: @selector(fadeToMaxVolume)
                   withObject: nil
                   afterDelay: 0.1];
    }
}

- (void)increaseVolume {
    float possibleNewVolume = currentVolume += 0.1;
    if (possibleNewVolume >= 1.0) {
        NSLog(@"Volume can't go any higher...ignoring request...");
    } else {
        [self fadeToDesiredVolume:possibleNewVolume];
        [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] soundViewController] volumeNumber] setText:[NSString stringWithFormat:@"%1.2f",possibleNewVolume]];
    }
}

- (void)decreaseVolume {
    float possibleNewVolume = currentVolume -= 0.1;
    if (possibleNewVolume <= 0.0) {
        NSLog(@"Volume can't go any lower...ignoring request...");
    } else {
        [self fadeToDesiredVolume:possibleNewVolume];
        [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] soundViewController] volumeNumber] setText:[NSString stringWithFormat:@"%1.2f",possibleNewVolume]];
    }
}

- (void)fadeToDesiredVolume:(float)thisVolume {
    desiredVolume = thisVolume;
    if (desiredVolume > currentVolume) {
        NSLog(@"Increasing volume ^^^ (desired: %1.2f, current %1.2f)",desiredVolume, currentVolume);
    } else {
        NSLog(@"Decreasing volume VVV (desired: %1.2f, current %1.2f)",desiredVolume, currentVolume);
    }
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    musicPlayer.volume = desiredVolume;
    currentVolume = desiredVolume;
    
//    [self continueVolumeFade];
}

- (void)continueVolumeFade {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];

    if (desiredVolume > currentVolume) {
        NSLog(@"Increasing volume ^^^ (desired: %1.2f, current %1.2f)",desiredVolume, currentVolume);
        musicPlayer.volume += 0.05;
        if (musicPlayer.volume < desiredVolume ) {
            [self performSelector: @selector(continueVolumeFade)
                       withObject: nil
                       afterDelay: 0.1];
        } else {
            currentVolume = desiredVolume;
            NSLog(@"Volume set to: %1.2f",currentVolume);
        }
    } else {
        NSLog(@"Decreasing volume VVV (desired: %1.2f, current %1.2f)",desiredVolume, currentVolume);
        musicPlayer.volume -= 0.05;
        if (musicPlayer.volume > desiredVolume ) {
            [self performSelector: @selector(continueVolumeFade)
                       withObject: nil
                       afterDelay: 0.1];
        } else {
            currentVolume = desiredVolume;
            NSLog(@"Volume set to: %1.2f",currentVolume);
        }
    }
    
}

- (void)restoreVolume {
    [self fadeToDesiredVolume:currentVolume];
}

- (void)playItemsWithNames:(NSArray *)arrayOfSoundFileNames {
    NSLog(@"TTSPlayer.playItemsWithNames()");
    
    if (speakItemsAloud) {
        
        BOOL regularSoundfile;
        
        NSString *longTextFilePrefix = @"~";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fullDocumentFilenameWithExtension;
        NSString *currentSoundfilePath;
        NSString *audioExtention = @".mp3";
        
        NSString *voiceTypeMaleSuffix = @"male";
        NSString *voiceTypeFemaleSuffix = @"female";
        
        NSString *voiceSpeedSlowSuffix = @"slow";
        NSString *voiceSpeedNormalSuffix = @"normal";
        NSString *voiceSpeedFastSuffix = @"fast";
        
        NSString *currentSpeedSuffix;
        NSString *currentVoiceTypeSuffix;
        NSString *commonSoundfileSuffix;
        
        NSMutableArray *soundItemArray = [[NSMutableArray alloc] initWithObjects: nil];
        
        //    AVPlayerItem *sound_item;
        
        switch (currentlyPlayingVoiceSpeed) {
            case slowspeed:
                currentSpeedSuffix = voiceSpeedSlowSuffix;
                break;
            case normalspeed:
                currentSpeedSuffix = voiceSpeedNormalSuffix;
                break;
            case fastspeed:
                currentSpeedSuffix = voiceSpeedFastSuffix;
                break;
            default:
                currentSpeedSuffix = voiceSpeedNormalSuffix;
                break;
        }
        switch (currentlyPlayingVoiceType) {
            case usenglishmale:
                currentVoiceTypeSuffix = voiceTypeMaleSuffix;
                break;
            case usenglishfemale:
                currentVoiceTypeSuffix = voiceTypeFemaleSuffix;
                break;
            default:
                currentVoiceTypeSuffix = voiceTypeFemaleSuffix;
                break;
        }

        for (NSString *thisSoundFilename in arrayOfSoundFileNames) {
            
            regularSoundfile = NO;
            
            if ([thisSoundFilename hasPrefix:@"silence"]) {
//            if ([thisSoundFilename isEqualToString:@"silence"]) {
                
                regularSoundfile = NO;
                
                NSString *silence_sound = [[NSBundle mainBundle] pathForResource:thisSoundFilename ofType:@"wav"];
                [soundItemArray addObject:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:silence_sound]]];
                
                NSLog(@"TTSPlayer.playItemsWithName() Playing sound %@ with type %@ at speed %@...",thisSoundFilename,currentVoiceTypeSuffix,currentSpeedSuffix);
                
            } else if ([thisSoundFilename hasPrefix:@"alarm"]) {
                //            if ([thisSoundFilename isEqualToString:@"silence"]) {
                
                regularSoundfile = NO;
                
                NSString *alarm_sound = [[NSBundle mainBundle] pathForResource:thisSoundFilename ofType:@"mp3"];
                [soundItemArray addObject:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:alarm_sound]]];
                
                NSLog(@"TTSPlayer.playItemsWithName() Playing sound %@ with type %@ at speed %@...",thisSoundFilename,currentVoiceTypeSuffix,currentSpeedSuffix);
                
            } else if ([thisSoundFilename hasPrefix:longTextFilePrefix]) {
                
                NSString *checkForRegularSoundfile = [thisSoundFilename substringFromIndex:[longTextFilePrefix length]];
                commonSoundfileSuffix = [NSString stringWithFormat:@"%@_%@%@",currentVoiceTypeSuffix,currentSpeedSuffix,audioExtention];
                fullDocumentFilenameWithExtension = [NSString stringWithFormat:@"%@_%@",checkForRegularSoundfile,commonSoundfileSuffix];
                currentSoundfilePath = [documentsDirectory stringByAppendingPathComponent:fullDocumentFilenameWithExtension];
                if ([[NSFileManager defaultManager] fileExistsAtPath:currentSoundfilePath])
                {
                    regularSoundfile = YES;
                    
                    [soundItemArray addObject:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:currentSoundfilePath]]];
                    
                    NSLog(@"TTSPlayer.playItemsWithName() Playing sound %@ with type %@ at speed %@...",fullDocumentFilenameWithExtension,currentVoiceTypeSuffix,currentSpeedSuffix);
                    
                } else {
                    
                    NSString *substringPartSoundfileSuffix = [NSString stringWithFormat:@"%@_%@",currentVoiceTypeSuffix,currentSpeedSuffix];
                    
                    NSLog(@"TTSPlayer.playItemsWithName() TTSPlayer.Found long sound filename with prefix: %@!",longTextFilePrefix);
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *audioExtension = @".mp3";
                    
                    
                    int currentPossibleFilenameIndex = 1;
                    BOOL stillNeedToCheckForMoreFilenames = YES;
                    NSMutableArray *substringPathsToPlay = [[NSMutableArray alloc] initWithObjects: nil];
                    
                    while (stillNeedToCheckForMoreFilenames) {
                        NSString *fullDocumentFilenameWithExtension = [NSString stringWithFormat:@"%@_%@_%d%@",thisSoundFilename,substringPartSoundfileSuffix,currentPossibleFilenameIndex,audioExtension];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:fullDocumentFilenameWithExtension];
                        
                        NSLog(@"TTSPlayer.playItemsWithName() Looking for file substring part %d (%@)",currentPossibleFilenameIndex, fullDocumentFilenameWithExtension);
                        
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                        {
                            NSLog(@"TTSPlayer.playItemsWithName() Loading substring file part %d (%@)",currentPossibleFilenameIndex, fullDocumentFilenameWithExtension);
                            [substringPathsToPlay addObject:path];
                            stillNeedToCheckForMoreFilenames = YES;
                        } else {
                            stillNeedToCheckForMoreFilenames = NO;
                        }
                        currentPossibleFilenameIndex++;
                    }
                    for (NSString *thisSoundSubstringPath in substringPathsToPlay) {
                        [soundItemArray addObject:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:thisSoundSubstringPath]]];
                    }
                    NSLog(@"TTSPlayer.playItemsWithName() Playing long sound %@ with type %@ at speed %@...",thisSoundFilename,currentVoiceTypeSuffix,currentSpeedSuffix);
                }
            } else {
                commonSoundfileSuffix = [NSString stringWithFormat:@"%@_%@%@",currentVoiceTypeSuffix,currentSpeedSuffix,audioExtention];
                
                fullDocumentFilenameWithExtension = [NSString stringWithFormat:@"%@_%@",thisSoundFilename,commonSoundfileSuffix];
                
                currentSoundfilePath = [documentsDirectory stringByAppendingPathComponent:fullDocumentFilenameWithExtension];
                
                [soundItemArray addObject:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:currentSoundfilePath]]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:currentSoundfilePath])
                    NSLog(@"TTSPlayer.playItemsWithName() Playing sound: %@",fullDocumentFilenameWithExtension);
                else
                    NSLog(@"TTSPlayer.playItemsWithName() file not found! file: %@",fullDocumentFilenameWithExtension);
            }
        }
        
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
    
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:soundItemArray];
    [self.queuePlayer play];
}

}

@end
