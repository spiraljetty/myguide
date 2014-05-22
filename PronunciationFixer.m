//
//  PronunciationFixer.m
//  satisfaction_survey
//
//  Created by dhorton on 1/30/13.
//
//

#import "PronunciationFixer.h"

@implementation PronunciationFixer


    
- (NSString *)fixSpeechStringForPronunciationMistakes:(NSString *)stringToFix {
    
    NSString *fixedString = [NSString stringWithString:stringToFix];
    
    NSMutableDictionary *itemsToFix = [[NSMutableDictionary alloc] init];
    
    // [itemsToFix setObject:@"CORRECT-PHONETICALLY" forKey:@"FIX-ME"];
    [itemsToFix setObject:@"fisiatry" forKey:@"physiatry"];
    [itemsToFix setObject:@"fisiatry" forKey:@"Physiatry"];
    [itemsToFix setObject:@"fisiatrist" forKey:@"physiatrist"];
    [itemsToFix setObject:@"fisiatrist" forKey:@"Physiatrist"];
    [itemsToFix setObject:@" and " forKey:@"&"];
    [itemsToFix setObject:@"pro vieder" forKey:@"provider"];
    [itemsToFix setObject:@"" forKey:@"~"];
    [itemsToFix setObject:@"" forKey:@"'"];
    [itemsToFix setObject:@"" forKey:@"’"];
    [itemsToFix setObject:@"Wan" forKey:@"Oanh"];
    [itemsToFix setObject:@"V A" forKey:@"VA"];
    [itemsToFix setObject:@"percent" forKey:@"%"];
    [itemsToFix setObject:@"M D" forKey:@"MD"];
    [itemsToFix setObject:@"M P H" forKey:@"MPH"];
    [itemsToFix setObject:@"number one" forKey:@"#1"];
    
//    if ([stringToFix hasSuffix:@"."]) {
//        fixedString = [fixedString substringToIndex:<#(NSUInteger)#>
//    }
    
    for (NSString *thisMispronunciation in [itemsToFix allKeys]) {
        fixedString = [fixedString stringByReplacingOccurrencesOfString:thisMispronunciation withString:[itemsToFix objectForKey:thisMispronunciation]];
    }
    
    return fixedString;
}


@end
