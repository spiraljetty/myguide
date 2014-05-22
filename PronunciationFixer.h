//
//  PronunciationFixer.h
//  satisfaction_survey
//
//  Created by dhorton on 1/30/13.
//
//

#import <Foundation/Foundation.h>

@interface PronunciationFixer : NSObject {

}

- (NSString *)fixSpeechStringForPronunciationMistakes:(NSString *)stringToFix;

@end
