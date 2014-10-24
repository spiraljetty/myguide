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
+ (bool) isEnabled;
+ (void) setIsEnabled:(bool)value;
+ (void) stopSpeaking;

@end
