//
//  DynamicSpeech.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 10/22/14.
//
//
#import "WRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DynamicSpeech.h"

@implementation DynamicSpeech

static bool  mIsEnabled = true;
static float mDefaultVolume = 0.1;
static AVSpeechSynthesizer *mSynthesizer = NULL;
/*
 Rate: AVSpeechUtteranceMinimumSpeechRate; Lower values correspond to slower speech
 Pitch: The default pitch is 1.0. Allowed values are in the range from 0.5 (for lower pitch) to 2.0 (for higher pitch).
 Volume: Allowed values are in the range from 0.0 (silent) to 1.0 (loudest). The default volume is 1.0.
 */

static float mSpeechRate = 0.20; //0.12
static float mPitchMultiplier = 1.75; //1.5;
static NSString* mLanguage = @"en";



+ (float) defaultVolume{
    return mDefaultVolume;
}

+ (bool) isEnabled {
    return mIsEnabled;
}

+ (void) setIsEnabled:(bool)value {
    mIsEnabled = value;
}


+ (void) stopSpeaking {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"DynamicSpeech.stopSpeaking()");
        // from: http://stackoverflow.com/questions/19672814/an-issue-with-avspeechsynthesizer-any-workarounds
        [mSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@""];
        [mSynthesizer speakUtterance:utterance];
        [mSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        mSynthesizer = NULL;
    });


}

+ (void) speakList:(NSArray*)utterances {
    NSLog(@"DynamicSpeech.speakList()");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (mSynthesizer == NULL)
            mSynthesizer = [[AVSpeechSynthesizer alloc]init];
        for (NSString *phrase in utterances) {
            NSLog(@"DynamicSpeech.speakList() utterance: %@", phrase);
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:phrase];
            //            [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
            [utterance setRate:mSpeechRate];//0.12f];//setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
            [utterance setPitchMultiplier:mPitchMultiplier];
            //[utterance setPostUtteranceDelay:20];
            //[utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:mLanguage];
            [mSynthesizer speakUtterance:utterance];
        }
        NSLog(@"DynamicSpeech.speakList() EXIT");
    });
}

+ (void) speakText:(NSString*) text {
    NSLog(@"DynamicSpeech.speakText() text: %@", text);
    NSMutableArray* utterances = [[NSMutableArray alloc] init];
    [utterances addObject:text];
    [self speakList:utterances];
}


@end
