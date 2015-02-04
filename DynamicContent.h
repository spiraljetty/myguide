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
#import "SwitchedImageViewController.h"
#import "EdModuleInfo.h"
#import "DynamicModuleViewController_Pad.h"

@interface DynamicContent : NSObject

+ (void) downloadAllData;

+ (id) getAllSurveyQuestions;
+ (NSArray*) getAllClinicians;
+ (NSArray*) getAllClinics;
+ (ClinicianInfo*) getClinician:(int)clinicianIndex;
+ (ClinicianInfo*) getCurrentClinician;
+ (NSArray*) getAllGoals;
+ (GoalInfo*) getGoalsForClinic:(NSString*) clinic;
+ (NSMutableArray*) getNewClinicianImages;
+ (NSMutableArray*) getNewClinicianNames;
+ (NSArray*) getSubclinicPhysicians:(NSString*) subclinic;
+ (NSArray*) getSubclinicPhysicianNames:(NSString*) subclinic;
+ (NSArray*) getAllWhatsNewInfo;
+ (NSArray*) getAllEdModules;
+ (NSArray*) getEdModulesForCurrentClinic;

+ (NSString*) getWhatsNewModuleName;
+ (NSString*) getAppVersion;

+ (NSMutableArray*) getClinicNames;
+ (NSMutableArray*) getClinicSubclinicComboNames;
+ (ClinicInfo*) getCurrentClinic;
+ (NSString*) getCurrentClinicName;
+ (NSString*) getCurrentRespondent;

+ (int) getPreTreatmentPageCount;
+ (int) getPostTreatmentPageCount;

+ (void) setCurrentClinic:(NSString*)clinic;
+ (void) setCurrentClinician:(ClinicianInfo*)clinician;
+ (void) setCurrentRespondent:(NSString*) respondent;

+ (ClinicInfo*) getClinic:(NSString*)clinicNameShort;
+ (QuestionList*) getSurveyForRespondentType:(NSString*) respondentType;
+ (QuestionList*) getSurveyForCurrentClinicAndRespondent;

+ (NSArray*) readFile:(NSString*)filename;
+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile;
+ (void)saveImage: (UIImage*)image filename:(NSString*)filename;
+ (UIImage*)loadImage: (NSString*)filename;

+ (void) setProviderTestStrings:(NSArray*)providerStrings;
+ (void) setGoalStrings:(NSArray*)goalStrings;
+ (void) setClinicTestStrings:(NSArray*)providerStrings;
+ (NSMutableArray*) getProviderTestStrings;   // stored provider string values to be displayed to uses
+ (NSMutableArray*) getClinicTestStrings; // stored clinic string values to be displayed to user
+ (NSMutableArray*) getGoalStrings; // stored goal string values to be displayed to user
+ (NSMutableArray*) getTimeSegments;      // timestamps of segments of app as completed
+ (NSMutableArray*) getSelfGuideStatus;  // stores a string that indicates which ed modules were attempted and completed

+ (void) setClinicTestHeaderText:(NSString*) headerText;
+ (void) setClinicianTestHeaderText:(NSString*) headerText;
+ (void) setGoalsHeaderText:(NSString*) headerText;

+ (NSString*) getClinicTestHeaderText;
+ (NSString*) getClinicianTestHeaderText;
+ (NSString*) getGoalsHeaderText;
+ (NSMutableArray*) getGoalsForCurrentClinicAndRespondent:(bool) includeHeader;

+ (void) setClinicianTestNames:(NSArray*)clinicianNames;
+ (void) setClinicTestNames:(NSArray*)clinicianNames;

+ (NSMutableArray*) getClinicianTestNames;
+ (NSMutableArray*) getClinicTestNames;
+ (NSMutableArray*) getPrivacyPolicy;

+ (void) showAlertMsg:(NSString *)msg;
+ (void) showEdModule:(NSString*) moduleName;

+ (SwitchedImageViewController*) getEdModulePicker;
+ (void) setEdModulePicker:(SwitchedImageViewController*) edModulePicker;
+ (void) fadeEdModulePickerIn;
+ (void) fadeEdModulePickerOut;

+ (EdModuleInfo*) getEdModuleAtIndex:(int) moduleIndex;

+ (id) safeObjectAtIndex:(NSArray*) array index:(int)objectIndex;
+ (void) setEdModuleComplete:(int)index;
+ (bool) isEdModuleComplete:(int)index;

+ (int) getTbiEdModuleIndex;
+ (int) getTbiEdModulePageCount;
+ (void) setTbiEdModuleIndex:(int)index;
+ (void) setTbiEdModulePageCount:(int)index;

+ (int) getEdModuleCount;
+ (void) setEdModuleCount:(int)count;

+ (bool) areAllEdModulesComplete;
+ (void) resetEdModuleProgress;
+ (int)  edModulesCompletedCount;

+ (float) cycleFontSizes;
+ (float) currentFontSize;
+ (void) resetFontSize;
+ (void) setCurrentFontSize:(int)fontSize;

+ (void) setCurrentEdModuleViewController:(DynamicModuleViewController_Pad*)edModuleViewController;
+ (DynamicModuleViewController_Pad*) getCurrentEdModuleViewController;

+ (void) disableFontSizeButton;
+ (void) enableFontSizeButton;
+ (void) resetDynamicContent;

+ (void) sendDataToServer:(NSData*)fileData;
+ (void) uploadDataFile:(NSData*)fileData formalFilenameParameter:(NSString*)actualFilenameParameter;

@end
