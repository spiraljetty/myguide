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
+ (NSArray*) getAllGoals;
+ (GoalInfo*) getGoalsForClinic:(NSString*) clinic;
+ (NSMutableArray*) getNewClinicianImages;
+ (NSMutableArray*) getNewClinicianNames;
+ (NSArray*) getSubclinicPhysicians:(NSString*) subclinic;
+ (NSArray*) getSubclinicPhysicianNames:(NSString*) subclinic;

+ (NSString*) getCurrentClinic;
+ (NSString*) getCurrentRespondent;
+ (void) setCurrentClinic:(NSString*)clinic;
+ (void) setCurrentRespondent:(NSString*) respondent;

+ (ClinicInfo*) getClinic:(NSString*)clinicNameShort;
+ (QuestionList*) getSurveyForRespondentType:(NSString*) respondentType;
+ (QuestionList*) getSurveyForCurrentClinicAndRespondent;

+ (NSArray*) readFile:(NSString*)filename;
+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile;
+ (void)saveImage: (UIImage*)image filename:(NSString*)filename;
+ (UIImage*)loadImage: (NSString*)filename;

+ (NSMutableArray*) getProviderStrings;   // stored provider string values to be displayed to uses
+ (NSMutableArray*) getTimeSegments;      // timestamps of segments of app as completed
+ (NSMutableArray*) getClinicTestStrings; // stored clinic string values to be displayed to user
+ (NSMutableArray*) getSelfGuideStatus;  // stores a string that indicates which ed modules were attempted and completed

+ (void) showAlertMsg:(NSString *)msg;
+ (void) speakText:(NSString*) text;

@end
