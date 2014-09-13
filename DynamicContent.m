//
//  DynamicContent.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/13/14.
//
//

#import "DynamicContent.h"

static NSMutableArray* allSurveyQuestions = nil;

@implementation DynamicContent

+ (id)allSurveyQuestions {
    if (allSurveyQuestions == nil)
        allSurveyQuestions = [[NSMutableArray alloc] init];
    return allSurveyQuestions;
}

@end
