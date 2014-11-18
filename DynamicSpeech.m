//
//  DynamicSpeech.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 10/22/14.
//
//
#import "WRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DynamicContent.h"

@implementation DynamicSpeech


static bool mIsSpeechEnabled = true;

static AVSpeechSynthesizer *mSynthesizer = NULL;
/*
 Rate: AVSpeechUtteranceMinimumSpeechRate; Lower values correspond to slower speech
 Pitch: The default pitch is 1.0. Allowed values are in the range from 0.5 (for lower pitch) to 2.0 (for higher pitch).
 Volume: Allowed values are in the range from 0.0 (silent) to 1.0 (loudest). The default volume is 1.0.
 */

static float mDefaultVolume = 0.1;
static float mSpeechRate = 0.20; //0.12
static float mPitchMultiplier = 1.0; //1.5;
static NSString* mLanguage = @"en-US";
//static float mLanguageIndex = 1.0;



+ (float) defaultVolume{
    return mDefaultVolume;
}

+ (bool) isEnabled {
    return true; // must always return true now that we are only using dynamic speech
}

+ (bool) isSpeechEnabled {
    return mIsSpeechEnabled;
}

+ (void) setIsSpeechEnabled:(bool) value {
     mIsSpeechEnabled = value;
}

+ (void) initializeSpeech {
    [DynamicSpeech stopSpeaking];
    mIsSpeechEnabled = true;
//    mDefaultVolume = 1.0;
}


+ (void) stopSpeaking {
    if ([DynamicSpeech isEnabled] && [mSynthesizer isSpeaking]){
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
}

+ (void) speakList:(NSArray*)utterances {
    NSLog(@"DynamicSpeech.speakList() count: %d", [utterances count]);
    if (!mIsSpeechEnabled)
        return;
    for (NSString* ut in utterances) {
        NSLog(ut);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (mSynthesizer == NULL)
            mSynthesizer = [[AVSpeechSynthesizer alloc]init];
        for (NSString *phrase in utterances) {
            NSLog(@"DynamicSpeech.speakList() utterance: %@", phrase);
//            if ([phrase isEqualToString:@"_PAUSE_"]){
//                NSLog(@"DynamicSpeech.speakList() pre pause");
//                [NSThread sleepForTimeInterval:2];
//                NSLog(@"DynamicSpeech.speakList() post pause");
//
//            }
//            else {
            bool isPause = false;
                if ([phrase isEqualToString:@"_PAUSE_"]){
                    phrase = @"   ";
                    isPause = true;
                }
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:phrase];
                //            [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
                [utterance setRate:mSpeechRate];//0.12f];//setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
                [utterance setPitchMultiplier:mPitchMultiplier];
                if (isPause)
                    [utterance setPostUtteranceDelay:.5];
                //[utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
                utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[DynamicSpeech getLanguage]];
                [mSynthesizer speakUtterance:utterance];
//            }
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

+ (float) getSpeed {
    return mSpeechRate;
}


+ (float) getPitch {
    return mPitchMultiplier;
}


+ (NSString*) getLanguage {
    return mLanguage;
}


+ (void) setSpeed:(float) speed{
    NSLog(@"DynamicSpeech.setSpeed() %f", speed);
    mSpeechRate = speed;
}

+ (void) setVoiceTypeFemale{
    [DynamicSpeech setLanguage:@"en-US"];
}

+ (void) setVoiceTypeMale{
    [DynamicSpeech setLanguage:@"en-GB"];
}

+ (void) setLanguage:(NSString*) language{
    NSLog(@"DynamicSpeech.setLanguage() %@", language);
    mLanguage = language;
}

//+ (float) getLanguageIndex {
//    return mLanguageIndex;
//}
//+ (void) setLanguageIndex:(float) languageIndex{
//    NSLog(@"DynamicSpeech.setLanguageIndex() %f", languageIndex);
//    //[DynamicSpeech setLanguage:@"en-GB"];
//    if (0.0 <= languageIndex && languageIndex <= 7.0f){
//        mLanguageIndex = languageIndex;
//        if (mLanguageIndex == 1.0)
//            [DynamicSpeech setLanguage:@"en-US"];
//        else if (mLanguageIndex == 2.0)
//            [DynamicSpeech setLanguage:@"en-GB"];
//        else if (mLanguageIndex == 3.0)
//            [DynamicSpeech setLanguage:@"en-AU"];
//        else if (mLanguageIndex == 4.0)
//            [DynamicSpeech setLanguage:@"en-NZ"];
//        else if (mLanguageIndex == 5.0)
//            [DynamicSpeech setLanguage:@"en-ZA"];
//        else if (mLanguageIndex == 6.0)
//            [DynamicSpeech setLanguage:@"es-MX"];
//        else if (mLanguageIndex == 7.0)
//                [DynamicSpeech setLanguage:@"es-ES"];
//    }
//}


+ (void) setPitch:(float) pitch{
    NSLog(@"DynamicSpeech.setPitch() %f", pitch);
    if (0.5f <= pitch && pitch <= 2.0f)
        mPitchMultiplier = pitch;
}

+ (void) sayWelcomeToApp{
    NSMutableArray* welcomeStrings = [[NSMutableArray alloc] init];
    ClinicInfo* clinic = [DynamicContent getCurrentClinic];
    if (clinic == NULL)
        return;
    NSString* clinicName = [clinic getSubclinicName];
    if (clinicName == NULL || [clinicName length] == 0)
        clinicName = [clinic getClinicName];
   // NSString* welcomeToClinic = [NSString stringWithFormat:@"Welcome to the VA Palo Alto Healthcare System %@", clinicName];
    [welcomeStrings addObject:@"Welcome to the VA Palo Alto Healthcare System"];
    [welcomeStrings addObject:clinicName];
    [welcomeStrings addObject:@"_PAUSE_"];
    [welcomeStrings addObjectsFromArray:[DynamicContent getPrivacyPolicy]];
    [welcomeStrings addObject:@"_PAUSE_"];
    [welcomeStrings addObject:@"Would you like me to read the questions out loud?"];
    
    [DynamicSpeech speakList:welcomeStrings];
}

+ (void) sayPrivacyPolicy{
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    [lines addObjectsFromArray:[DynamicContent getPrivacyPolicy]];
    [DynamicSpeech speakList:lines];
}

+ (void) sayRespondentTypes{
    NSMutableArray* phrases = [[NSMutableArray alloc] init];
    [phrases addObject:@"Are you a patient, a family member or a caregiver?"];
    [DynamicSpeech speakList:phrases];
}

+ (void) sayChooseModule{
    NSMutableArray* phrases = [[NSMutableArray alloc] init];
    [phrases addObject:@"Thank you for this information. Your provider will see you shortly."];
    //[phrases addObject:@"_PAUSE_"];
    [phrases addObject:@"Select a Topic button to learn more while you wait."];
    //[phrases addObject:@"_PAUSE_"];
    [phrases addObject:@"Press the Doctor icon below to skip this section."];
    [DynamicSpeech speakList:phrases];
}

+ (void) sayReturnTablet {
    NSMutableArray* phrases = [[NSMutableArray alloc] init];
    [phrases addObject:@"Thank you for your feedback. Please return this iPad tablet to the receptionist"];
    mIsSpeechEnabled = true;
    [DynamicSpeech speakList:phrases];
}


@end
