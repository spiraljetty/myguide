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
#import "ClinicInfo.h"
#import "GoalInfo.h"

@interface DynamicContent : NSObject

+ (void) downloadAllData;

+ (id) getAllSurveyQuestions;
+ (NSArray*) getAllClinicians;
+ (ClinicianInfo*) getClinician:(int)clinicianIndex;
+ (GoalInfo*) getAllGoals;
+ (NSMutableArray*) getNewClinicianImages;
+ (NSMutableArray*) getNewClinicianNames;

+ (ClinicInfo*) getClinic:(NSString*)clinicNameShort;
+ (QuestionList*) getSurveyForRespondentType:(NSString*) respondentType;

+ (NSArray*) readFile:(NSString*)filename;
+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile;
+ (void)saveImage: (UIImage*)image filename:(NSString*)filename;
+ (UIImage*)loadImage: (NSString*)filename;

+ (void) showAlertMsg:(NSString *)msg;
+ (void) speakText:(NSString*) text;

@end
