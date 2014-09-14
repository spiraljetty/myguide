//
//  DynamicContent.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/13/14.
//
//

#import <Foundation/Foundation.h>
#import "QuestionList.h"
#import "ClinicianInfo.h"
#import "GoalInfo.h"

@interface DynamicContent : NSObject

+ (id) getAllSurveyQuestions;
+ (NSArray*) getAllClinicians;
+ (ClinicianInfo*) getClinician:(int)clinicianIndex;
+ (GoalInfo*) getAllGoals;

+ (void) downloadAllData;

+ (NSArray*) readFile:(NSString*)filename;
+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile;
+ (void)saveImage: (UIImage*)image filename:(NSString*)filename;
+ (UIImage*)loadImage: (NSString*)filename;
+ (QuestionList*) getSurveyForRespondentType:(NSString*) respondentType;

+ (void) showAlertMsg:(NSString *)msg;
+ (void) speakText:(NSString*) text;

@end
