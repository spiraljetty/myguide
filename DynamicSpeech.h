//
//  DynamicSpeech.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 10/22/14.
//
//

#import <Foundation/Foundation.h>

@interface DynamicSpeech : NSObject

+ (void) speakList:(NSArray*)utterances;
+ (void) speakText:(NSString*) text;
+ (float) defaultVolume;
+ (bool) isEnabled; // this should always be true now that we are only using dynamic speech
+ (bool) isSpeechEnabled; // this is true only if user choose speech option
+ (void) setIsSpeechEnabled:(bool)value;
+ (void) stopSpeaking;
+ (void) setVoiceTypeFemale;
+ (void) setVoiceTypeMale;

+ (float) getSpeed;
+ (float) getPitch;
+ (float) getLanguageIndex;
+ (NSString*) getLanguage;
+ (void)  setSpeed:(float) speed;
+ (void)  setPitch:(float) pitch;
+ (void)  setLanguageIndex:(float) languageIndex;
+ (void)  sayWelcomeToApp;
+ (void) sayRespondentTypes;
+ (void) sayChooseModule;
+ (void) sayPrivacyPolicy;
+ (void) sayReturnTablet;

@end
