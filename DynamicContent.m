//
//  DynamicContent.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/13/14.
//
//

#import "DynamicContent.h"
#import "QuestionList.h"
#import "ClinicianInfo.h"
#import "GoalInfo.h"
#import "ClinicInfo.h"
#import "WhatsNewInfo.h"
#import "YLViewController.h"
#import "MainLoaderViewController.h"
#import "EdModuleInfo.h"
#import "EdModulePage.h"
#import <AVFoundation/AVFoundation.h>

static NSString* mAppVersion = @"App Version: 11/12/14";

static NSArray* mAllGoals = NULL;
static NSArray* mAllClinics = NULL;
static NSArray* mAllClinicians = NULL;
static NSArray* mAllSurveyQuestions = NULL;
static NSArray* mAllWhatsNew = NULL;
static NSArray* mAllEdModules = NULL;

static NSMutableArray* mProviderTestStrings = NULL;  // for provider test
static NSMutableArray* mClinicTestStrings = NULL;  // for clinic test
static NSMutableArray* mGoalStrings = NULL;  // for clinic test
static NSMutableArray* mTimeSegments = NULL;  // for timers
static NSMutableArray* mSelfGuideStatus = NULL;  // for ed mods attempted

static NSMutableArray* mClinicianTestNames = NULL;  // contains no credentials
static NSMutableArray* mClinicTestNames = NULL;  // contains no credentials

static NSString* mCurrentClinicName = @"at";
static ClinicianInfo* mCurrentClinician = NULL;
static NSString* mCurrentRespondent = @"patient";

static NSString* mClinicTestHeaderText = NULL;
static NSString* mClinicianTestHeaderText = NULL;
static NSString* mGoalsHeaderText = NULL;
static SwitchedImageViewController* mEdModulePickerVC;


@implementation DynamicContent

+ (NSString*) getAppVersion{
    return mAppVersion;
}

+ (NSArray*) getAllClinicians {
    if (mAllClinicians == NULL){
        mAllClinicians = [self readClinicianInfo:false];
    }
    return mAllClinicians;
}

+ (NSArray*) getAllClinics {
    if (mAllClinics == NULL){
        mAllClinics = [self readClinicInfo:false];
    }
    return mAllClinics;
}

+ (id)getAllSurveyQuestions {
    if (mAllSurveyQuestions == NULL){
        mAllSurveyQuestions = [self readQuestionInfo];
    }
    return mAllSurveyQuestions;
}

+ (NSArray*) getAllGoals {
    if (mAllGoals == NULL){
        mAllGoals = [self readGoalInfo];
    }
    return mAllGoals;
}


+ (NSArray*) getAllWhatsNewInfo {
    if (mAllWhatsNew == NULL){
        mAllWhatsNew = [DynamicContent readWhatsNewInfoTest];
    }
    return mAllWhatsNew;
}

+ (NSArray*) getAllEdModules {
    if (mAllEdModules == NULL){
        mAllEdModules = [DynamicContent readEdModules:false];
    }
    return mAllEdModules;
}

+ (NSString*) getCurrentClinicName{
    return mCurrentClinicName;
}

+ (ClinicInfo*) getCurrentClinic{
    NSLog(@"DynamicContent.getCurrentClinic()");
    return [DynamicContent getClinic:mCurrentClinicName];
}

+ (ClinicianInfo*) getCurrentClinician{
    return mCurrentClinician;
}

+ (NSString*) getCurrentRespondent{
    return mCurrentRespondent;
}

+ (void) setCurrentClinic:(NSString*) clinic{
    mCurrentClinicName = clinic;
}

+ (void) setCurrentClinician:(ClinicianInfo*) clinician{
    mCurrentClinician = clinician;
}

+ (void) setCurrentRespondent:(NSString*) respondent{
    mCurrentRespondent = respondent;
}

+ (void) setClinicTestHeaderText:(NSString*) headerText{
    mClinicTestHeaderText = headerText;
}

+ (void) setClinicianTestHeaderText:(NSString*) headerText{
    mClinicianTestHeaderText = headerText;
}

+ (void) setGoalsHeaderText:(NSString*) headerText{
    mGoalsHeaderText = headerText;
}

+ (void) downloadAllData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        YLViewController* viewController = [YLViewController getViewController];
        
        // Clincians
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.downloadDataStatus.text = @"Downloading Clinicians";
            });
        }
        int clinicianCount = [DynamicContent downloadClinicianInfo];
        
        // Clinics
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.downloadDataStatus.text = @"Downloading Clinics";
            });
        }
        int clinicCount = [DynamicContent downloadClinicInfo];
        
        // goals
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.downloadDataStatus.text = @"Downloading Goals";
            });
        }
        [DynamicContent downloadGoalInfo];
        
        //questions
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.downloadDataStatus.text = @"Downloading Questions";
            });
        }
        [DynamicContent downloadQuestionInfo];
        
        //ed modules
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.downloadDataStatus.text = @"Downloading Ed Modules";
            });
        }
        [DynamicContent downloadEdModules];
        
        
        // show "download complete" message
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController downloadDataRequestDone];
            });
        }
        
        NSString* msg = [NSString stringWithFormat:@"Downloaded:\n%d clinics\n%d clinicians", clinicCount, clinicianCount];
        [DynamicContent showAlertMsgAndResetApp:msg];
    
//        // update UI on the main thread
//        if (viewController != NULL){
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                viewController.downloadDataStatus.text = @"Download complete!";
//            //self.title = [[NSString alloc]initWithFormat:@"Result: %d", i];
//            });
//        }
        
    });
}

+ (int) downloadClinicianInfo { // rjl 8/16/14
    int count = 0;
    NSString* filename = @"clinicians.txt";
    NSString* filePath = [DynamicContent downloadFile:filename isImage:false];
    if (filePath){
        mAllClinicians = [DynamicContent readClinicianInfo:true];
        count = [mAllClinicians count];
    }
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicianInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
    return count;
}

+ (int) downloadClinicInfo { // rjl 8/16/14
    int count = 0;
    NSString* filename = @"clinics.txt";
    NSString* filePath = [DynamicContent downloadFile:filename isImage:false];
    if (filePath){
        mAllClinics = [DynamicContent readClinicInfo:true];
        count = [mAllClinics count];
    }
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicInfo() %@", errorMsg];
        NSLog(logMsg);
        [DynamicContent showAlertMsg:errorMsg];
    }
    return count;
}

+ (void) downloadGoalInfo { // rjl 8/16/14
    NSString* filename = @"goals.txt";
    NSString* filePath = [DynamicContent downloadFile:filename isImage:false];
    if (filePath)
        mAllGoals = [DynamicContent readGoalInfo];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadGoalInfo() %@", errorMsg];
        NSLog(logMsg);
        [DynamicContent showAlertMsg:errorMsg];
    }
}

+ (void) downloadQuestionInfo { // rjl 8/16/14
    NSString* filename = @"survey_questions.txt";
    NSString* filePath = [DynamicContent downloadFile:filename isImage:false];
    if (filePath)
        mAllSurveyQuestions = [DynamicContent readQuestionInfo];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadQuestionInfo() %@", errorMsg];
        NSLog(logMsg);
        [DynamicContent showAlertMsg:errorMsg];
    }
}

+ (void) downloadEdModules { // rjl 8/16/14
    int count = 0;
    NSString* filename = @"edmodules.txt";
    NSString* filePath = [DynamicContent downloadFile:filename isImage:false];
    if (filePath){
        mAllWhatsNew = [DynamicContent readEdModules:true];
        count = [mAllWhatsNew count];
    }
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadEdModules() %@", errorMsg];
        NSLog(logMsg);
        if (filePath != NULL)
            [DynamicContent showAlertMsg:errorMsg];
    }
}



+ (GoalInfo*) getGoalsForClinic:(NSString*) clinic {
    NSArray* allGoals = [DynamicContent getAllGoals];
    NSString* clinicLowerCase = [clinic lowercaseString];
    GoalInfo* match = NULL;
    for (GoalInfo* info in allGoals){
        NSString* otherClinicName = [info getClinic];
        if ([clinicLowerCase isEqualToString:otherClinicName]){
            match = info;
            break;
        }
        if ([clinicLowerCase hasPrefix:@"acu"] && [otherClinicName hasPrefix:@"acu"]){
            match = info;
            break;
        }
    }
    if (match != NULL)
        return match;
    else
    if ([allGoals count] > 0)
        return [allGoals objectAtIndex:0];
    else
        return NULL;
}

+ (NSMutableArray*) readClinicianInfo:(BOOL) isDownload{
    YLViewController* viewController = [YLViewController getViewController];
    NSLog(@"DynamicContent.readClinicianInfo() isDownload: %d", isDownload);
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/clinicians.txt", documentsDirectory];
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *allClinicians = [[NSMutableArray alloc] init];
    NSArray * lines = [DynamicContent readFile:filePath];
    int index = 0;
    int total = [lines count];
    for (NSString *line in lines) {
        index++;
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* msg = [NSString stringWithFormat:@"Downloading Clinician %d/%d", index, total];
                viewController.downloadDataStatus.text = msg;
            });
        }
        NSString* clinicianLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        
        if (clinicianLine.length > 0){
            //NSLog(@"%@", line);
            ClinicianInfo * clinicianInfo = [[ClinicianInfo alloc]init];
            // parse row containing clinician details
            NSString* cleanLine = [line stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            cleanLine = [cleanLine stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"];
            NSArray* clinicianProperties = [cleanLine componentsSeparatedByCharactersInSet:
                                            [NSCharacterSet characterSetWithCharactersInString:@";"]];
            for (int i=0; i<[clinicianProperties count]; i++) {
                NSString* value = clinicianProperties[i];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                NSLog(@"%d: %@", i, value);
                switch (i) {
                    case 0: [clinicianInfo setClinicianId:[value copy]]; break;
                    case 1: [clinicianInfo setClinics:[value copy]]; break;
                    case 2: [clinicianInfo setFirstName:[value copy]]; break;
                    case 3: [clinicianInfo setLastName:[value copy]]; break;
                    case 4: [clinicianInfo setSalutation:[value copy]]; break;
                    case 5: [clinicianInfo setDegrees:[value copy]]; break;
                    case 6: [clinicianInfo setCredentials:[value copy]]; break;
                    case 7: [clinicianInfo setEdAndAffil:[value copy]]; break;
                    case 8: [clinicianInfo setBackground:[value copy]]; break;
                    case 9: [clinicianInfo setPhilosophy:[value copy]]; break;
                    case 10: [clinicianInfo setPersonalInterests:[value copy]]; break;
                    case 11: [clinicianInfo setImageFilename:[value copy]]; break;
                    case 12: [clinicianInfo setImageThumbFilename:[value copy]]; break;
                } // end switch
            } // end for
            [allClinicians addObject:clinicianInfo];
        } // end if clinicianLine.length > 0
    }// end for line in lines
    
    NSLog(@"DynamicContent.getAllClinicians() count: %ld", (long)[allClinicians count]);
    if (isDownload){
        //download the image for each clinician
        int index = 0;
        int total = [allClinicians count];
        for (ClinicianInfo* clinician in allClinicians){
            [clinician writeToLog];
            index++;
            if (viewController != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* msg = [NSString stringWithFormat:@"Downloading Clinician Image %d/%d", index, total];
                    viewController.downloadDataStatus.text = msg;
                });
            }
            NSString* clinicianImageFilename = [clinician getImageFilename];
            [DynamicContent downloadFile:clinicianImageFilename isImage:true];
        }
    }
    
    return allClinicians;
    //    [pool release];
}


+ (NSArray*) readClinicInfo:(BOOL) isDownload{
    NSLog(@"DynamicContent.readClinicInfo() isDownload: %d", isDownload);
    
    YLViewController* viewController = [YLViewController getViewController];

    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/clinics.txt", documentsDirectory];
    NSMutableArray *allClinics = [[NSMutableArray alloc] init];
    NSMutableArray* allImages =  [[NSMutableArray alloc] init];

    //    ClinicInfo * clinicInfo = NULL;
    NSArray * lines = [self readFile:filePath];
    int index = 0;
    int total = [lines count];
    for (NSString *line in lines) {
        index++;
        if (isDownload && viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* msg = [NSString stringWithFormat:@"Downloading Clinic %d/%d", index, total];
                viewController.downloadDataStatus.text = msg;
            });
        }
        NSString* clinicLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        
        if (clinicLine.length > 0){
            NSLog(@"DynamicContent.readClinicInfo() clinics.txt line: %@", line);
            // parse row containing clinic details
            NSString* output = nil;
            if([clinicLine hasPrefix:@"//"]){
                NSLog(@"DynamicContent.readClinicInfo() comment: %@", clinicLine);
            }
            else {
                
                // read clinic page as triple <sub title, content, imagename>
                NSArray* clinicProperties = [line componentsSeparatedByCharactersInSet:
                                             [NSCharacterSet characterSetWithCharactersInString:@";"]];
                
                //find the clinic container for all of the pages from that clinic
                NSString* clinicName    = [clinicProperties objectAtIndex:1];
                NSString* clinicNameShort = [clinicProperties objectAtIndex:2];
                NSString* subclinicName   = [clinicProperties objectAtIndex:3];
                NSString* subclinicNameShort = [clinicProperties objectAtIndex:4];
                NSString* clinicImage = [clinicProperties objectAtIndex:10];
                ClinicInfo* currentClinic = NULL;
                if (allClinics != NULL){
                    for (ClinicInfo* clinic in allClinics){
                        if ([subclinicNameShort length] > 0){
                            // match on subclinic short name
                            NSString* nameToMatch = [clinic getSubclinicNameShort];
                            if ([nameToMatch isEqualToString:subclinicNameShort]){
                                currentClinic = clinic;
                                break;
                            }
                        }
                        else
                        if ([subclinicName length] > 0){
                            // match on subclinic name
                            NSString* nameToMatch = [clinic getSubclinicName];
                            if ([nameToMatch isEqualToString:subclinicName]){
                                currentClinic = clinic;
                                break;
                            }
                        }
                        else
                        if ([clinicNameShort length] > 0){
                            // match on clinic short name
                            NSString* nameToMatch = [clinic getClinicNameShort];
                            if ([nameToMatch isEqualToString:clinicNameShort]){
                                currentClinic = clinic;
                                break;
                            }
                        }
                        else
                        if ([clinicName length] > 0){
                            // match on clinic name
                            NSString* nameToMatch = [clinic getClinicName];
                            if ([nameToMatch isEqualToString:clinicName]){
                                currentClinic = clinic;
                                break;
                            }
                        }
                    }
                }
                //                    int currentClinicIndex = [allClinics indexOfObject:clinicName];
                if (currentClinic == NULL){
                    ClinicInfo* clinicInfo = [[ClinicInfo alloc]init];
                    [clinicInfo setClinicName:[clinicName copy]];
                    [clinicInfo setClinicNameShort: [clinicNameShort copy]];
                    [clinicInfo setSubclinicName:[subclinicName copy]];
                    [clinicInfo setSubclinicNameShort: [subclinicNameShort copy]];
                    [clinicInfo setClinicImage: [clinicImage copy]];
                    [allClinics addObject:clinicInfo];
                    currentClinic = clinicInfo;
                }
                
                
                NSMutableDictionary* page = [[NSMutableDictionary alloc] init];
                NSLog(@"DynamicContent.readClinicInfo() clinic name: %@", clinicName);
                for (int i=0; i<[clinicProperties count]; i++) {
                    NSString* value = clinicProperties[i];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                    NSLog(@"clinic %@ prop %d: %@", [currentClinic getClinicName], i, value);
                    switch (i) {
                        case 0: [page setObject:value forKey:@"clinicId"]; break;
                        case 1: [page setObject:value forKey:@"clinicName"]; break;
                        case 2: [page setObject:value forKey:@"clinicNameShort"]; break;
                        case 3: [page setObject:value forKey:@"subclinicName"]; break;
                        case 4: [page setObject:value forKey:@"subclinicNameShort"]; break;
                        case 5: [page setObject:value forKey:@"pageNumber"]; break;
                        case 6: [page setObject:value forKey:@"pageTitle"]; break;
                        case 7: [page setObject:value forKey:@"pageText"]; break;
                        case 8: [page setObject:value forKey:@"pageImage"];
                            if ([value length] > 0)
                                [allImages addObject:value];
                            break;
                        case 9: [page setObject:value forKey:@"status"]; break;
                        case 10: [page setObject:value forKey:@"clinicIcon"];
                            if ([value length] > 0){
                                if (![allImages containsObject:value])
                                    [allImages addObject:value];
                            }
                            break;
                    } // end switch
                }
                [currentClinic addPage:page];
            }
        } // end if clinicianLine.length > 0
    }// end for line in lines
    
    NSString* msg = [NSString stringWithFormat:@"Loaded %d clinics", [allClinics count]];
    NSLog(msg);
    
    // download the image file for each clinician
    for (ClinicInfo* clinic in allClinics){
        [clinic writeToLog];
    }
    if (isDownload){
        int index = 0;
        int total = [allImages count];
        for (NSString* imageFilename in allImages){
            index++;
            if (viewController != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* msg = [NSString stringWithFormat:@"Downloading Clinic Image %d/%d", index, total];
                    viewController.downloadDataStatus.text = msg;
                });
            }
            [self downloadFile:imageFilename isImage:true];
        }
    }
//    [self showAlertMsg:msg];
    return allClinics;
    //    [pool release];
}

+ (NSArray*) readEdModules:(BOOL) isDownload{
    NSLog(@"DynamicContent.readEdModules() isDownload: %d", isDownload);
    
    YLViewController* viewController = [YLViewController getViewController];
    
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/edmodules.txt", documentsDirectory];
    NSMutableArray *allModules = [[NSMutableArray alloc] init];
    NSMutableArray* allImages =  [[NSMutableArray alloc] init];
    
    //    ClinicInfo * clinicInfo = NULL;
    NSArray * lines = [self readFile:filePath];
    int index = 0;
    int total = [lines count];
    for (NSString *line in lines) {
        index++;
        if (isDownload && viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* msg = [NSString stringWithFormat:@"Downloading ed module %d/%d", index, total];
                viewController.downloadDataStatus.text = msg;
            });
        }
        NSString* moduleLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        
        if (moduleLine.length > 0){
            NSLog(@"DynamicContent.readEdModules() edmodules.txt line: %@", line);
            // parse row containing clinic details
            if([moduleLine hasPrefix:@"//"]){
                NSLog(@"DynamicContent.readEdModules() comment: %@", moduleLine);
            }
            else {
                
                // read clinic page as triple <sub title, content, imagename>
                NSArray* edModuleProperties = [line componentsSeparatedByCharactersInSet:
                                             [NSCharacterSet characterSetWithCharactersInString:@";"]];
                
                //find the clinic container for all of the pages from that clinic
                NSString* moduleName  = [edModuleProperties objectAtIndex:1];
                NSString* moduleImage = [edModuleProperties objectAtIndex:2];
                EdModuleInfo* currentModule = NULL;
                if (allModules != NULL){
                    for (EdModuleInfo* edModule in allModules){
                        NSString* nameToMatch = [edModule getModuleName];
                        if ([nameToMatch isEqualToString:moduleName]){
                            currentModule = edModule;
                            break;
                        }
                    }
                }
                //                    int currentClinicIndex = [allClinics indexOfObject:clinicName];
                if (currentModule == NULL){
                    EdModuleInfo* edModuleInfo = [[EdModuleInfo alloc]init];
                    [edModuleInfo setModuleName:[moduleName copy]];
                    [edModuleInfo setModuleImage: [moduleImage copy]];
                    [allModules addObject:edModuleInfo];
                    currentModule = edModuleInfo;
                }
                
                NSLog(@"DynamicContent.readEdModules() module name: %@", moduleName);
                EdModulePage* newPage = [[EdModulePage alloc] init];
                int moduleNameIndex = 1;
                int moduleImageIndex= 2;
                int pageNumberIndex = 3;
                int pageHeaderIndex = 4;
                int pageBodyIndex   = 5;
                int pageImageIndex  = 6;
                int pageClinicsIndex =7;
                NSString* imageName = edModuleProperties[pageImageIndex];
                [newPage setModuleName: edModuleProperties[moduleNameIndex]];
                [newPage setModuleImage: edModuleProperties[moduleImageIndex]];
                [newPage setPageNumber:edModuleProperties[pageNumberIndex]];
                [newPage setHeader: edModuleProperties[pageHeaderIndex]];
                [newPage setBody:edModuleProperties[pageBodyIndex]];
                [newPage setImage:imageName];
                [newPage setClinics:edModuleProperties[pageClinicsIndex]];
                if (imageName != NULL && [imageName length] > 0)
                    [allImages addObject:imageName];
//                NSString* clinicsText = edModuleProperties[pageClinicsIndex];
//                NSArray* clinicList = [clinicsText componentsSeparatedByCharactersInSet:
//                                                                         [NSCharacterSet characterSetWithCharactersInString:@","]];

                [currentModule addPage:newPage];
            } // end if module line does not have prefix "//"
        } // end if line length > 0
    }// end for line in lines
    
    NSString* msg = [NSString stringWithFormat:@"Loaded %d modules", [allModules count]];
    NSLog(msg);
    
    // download the image file for each clinician
    for (EdModuleInfo* edModule in allModules){
        [edModule sortPages];
        EdModuleInfo* page0 = [[edModule getPages] objectAtIndex:0];
        [edModule setModuleName: [page0 getModuleName]];
        [edModule setModuleImage: [page0 getModuleImage]];
        [edModule setClinics: [page0 getClinics]];
        [edModule writeToLog];
    }
    if (isDownload){
        int index = 0;
        int total = [allImages count];
        for (NSString* imageFilename in allImages){
            index++;
            if (viewController != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* msg = [NSString stringWithFormat:@"Downloading ed module image %d/%d", index, total];
                    viewController.downloadDataStatus.text = msg;
                });
            }
            [self downloadFile:imageFilename isImage:true];
        }
    }
    //    [self showAlertMsg:msg];
    
    return allModules;
    //    [pool release];
}

//+ (NSArray*) readWhatsNewInfo:(BOOL) isDownload{
//    NSLog(@"DynamicContent.readWhatsNewInfo() isDownload: %d", isDownload);
//    NSMutableArray*  allPages = [[NSMutableArray alloc] init];
//    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString  *documentsDirectory = [paths objectAtIndex:0];
//    NSString  *filePath = [NSString stringWithFormat:@"%@/whatsNew.txt", documentsDirectory];
//    
//    NSArray * lines = [self readFile:filePath];
//    for (NSString *line in lines) {
//        NSString* whatsNewLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
//        if (whatsNewLine.length > 0){
//            NSLog(@"DynamicContent.readWhatsNewInfo() whatsNew.txt line: %@", whatsNewLine);
//            // parse row containing goal details
//            if([whatsNewLine hasPrefix:@"//"]){
//                NSLog(@"DynamicContent.readWhatsNewInfo() comment: %@", whatsNewLine);
//            }
//            else {
//                if ([whatsNewLine hasSuffix:@";"]){
//                    int index = [whatsNewLine length] -1;
//                    whatsNewLine = [whatsNewLine substringToIndex: index];
//                }
//                NSArray* whatsNewRow = [whatsNewLine componentsSeparatedByCharactersInSet:
//                                    [NSCharacterSet characterSetWithCharactersInString:@";"]];
//                NSString* clinic = [whatsNewRow objectAtIndex:0];
//                NSString* header = [whatsNewRow objectAtIndex:1];
//                NSString* body =   [whatsNewRow objectAtIndex:2];
//                NSString* image =  [whatsNewRow objectAtIndex:3];
//                
//                WhatsNewInfo* whatsNewPage = [[WhatsNewInfo alloc] init];
//                [whatsNewPage setClinic:clinic];
//                [whatsNewPage setHeader:header];
//                [whatsNewPage setBody:body];
//                [whatsNewPage setImage:image];
//                [allPages addObject:whatsNewPage];
//            }
//        }
//     }
//    NSLog(@"Loaded (%d) whatsNew pages", [allPages count]);
//    for (WhatsNewInfo* info in allPages){
//        [info writeToLog];
//    }
//    return allPages;
//}

+ (NSArray*) readWhatsNewInfoTest {
    NSLog(@"DynamicContent.readWhatsNewInfoTest() ");
    NSMutableArray*  allPages = [[NSMutableArray alloc] init];
    
    // page 1
    NSString* clinic = @"PNS";
    NSString* header = @"A note from Odette Harris, MD, MPH";
    NSString* body = @"Welcome to Fiscal Year 2013 Quarter 4 at the VA Palo Alto Health Care System, Polytrauma System of Care (PSC). The focus of this edition of our Newsletter, “38 Miles…Palo Alto to Livermore” is on Innovation and Technology initiatives in our PSC. Outstanding clinical care remains our #1 priority and is driven by our commitment to continuous improvement.  We are fortunate that Innovation and Research continue to be integral to our operation and thus significantly drive and benefit our clinical care.";
    NSString* image = @"psc_whatsnew_odette_harris.png";
    WhatsNewInfo* whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    //page 2
    header = @"A note ...(cont.)";
    body = @"Our outcomes are outstanding and the benefits/impact to our patients and families is undeniable.  This is in direct support of our overall mission. This edition of our newsletter highlights the exemplary accomplishments of the PSC in the realm of Innovation and Technology. We thank you for continued support in making the VA Palo Alto Healthcare System an exceptional rehabilitation program.";
    image = @"psc_logo_withwords.png";
    whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    //page 3
    header = @"Strategic Planning Update";
    body = @"In an effort to incorporate all stakeholder feedback gathered during a 9-month strategic planning process, Polytrauma System of Care (PSC) leadership is moving forward with a planned expansion of the Assistive Technology Center to include a Center for Innovation and Technology (CIT).  The expanded organizational structure will provide a design, learning, and development pathway for new health care technologies while maintaining the current service delivery of assistive technologies within the PSC.";
    image = @"psc_whatsnew_2013q4_page1.png";
    whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    //page 4
    header = @"Strategic Planning Update..(cont.)";
    body = @"The new Center signals a commitment to thoughtful creativity, collaborative entrepreneurialism, new project development and incubation, and continuous performance improvement in patient care. Jonathan Sills, PhD, Program Director of Assistive Technology and the main force behind the 2013-2015 strategic plan that included the conceptualization of the Center for Innovation and Technology (CIT) within the Polytrauma System of Care, will oversee the new center.";
    image = @"at_icon.png";
    whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    //page 5
    header = @"Setting the pace with Tech Projects!";
    body = @"Along with the IntelaCare Project featured in this issue of the PSC newsletter, the VAPAHCS IPad Waiting Room project was recently recognized by CARF (Commission on Accreditation of Rehabilitation Facilities) International as an exemplary program during the May 2013 accreditation survey. The CARF framework encompasses rehabilitation, with an evaluation of effectiveness, efficiency, access, and patient satisfaction.";
    image = @"psc_whatsnew_2013q4_section2_1.png";
    whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    //page 6
    header = @"Setting the pace...(cont.)";
    body = @"In total, the PSC received the following awards after a thorough review of clinical and administrative standards of which CARF has established.";
    image = @"psc_whatsnew_2013q4_section2_1.png";
    whatsNewPage = [[WhatsNewInfo alloc] init];
    [whatsNewPage setClinic:clinic];
    [whatsNewPage setHeader:header];
    [whatsNewPage setBody:body];
    [whatsNewPage setImage:image];
    [allPages addObject:whatsNewPage];
    
    NSLog(@"Loaded (%d) whatsNew pages", [allPages count]);
    for (WhatsNewInfo* info in allPages){
        [info writeToLog];
    }
    return allPages;
}

+ (NSString*) getWhatsNewModuleName{
    return @"What's New at the Polytrauma System of Care";
}

+ (NSArray*) readGoalInfo {
    NSLog(@"DynamicContent.readGoalInfo()");
    NSMutableArray*  allGoals = [[NSMutableArray alloc] init];
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/goals.txt", documentsDirectory];
    
    NSArray * lines = [self readFile:filePath];
    for (NSString *line in lines) {
        NSString* goalLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        if (goalLine.length > 0){
            NSLog(@"DynamicContent.readGoalInfo() goals.txt line: %@", goalLine);
            // parse row containing goal details
            if([goalLine hasPrefix:@"//"]){
                NSLog(@"DynamicContent.readGoalInfo() comment: %@", goalLine);
            }
            else {
                if ([goalLine hasSuffix:@";"]){
                    int index = [goalLine length] -1;
                    goalLine = [goalLine substringToIndex: index];
                }
                NSArray* goalRow = [goalLine componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@";"]];
                NSString* clinic = [goalRow objectAtIndex:0];
                
                NSString* respondent = [goalRow objectAtIndex:1];
                NSMutableArray* selfGoals = [[NSMutableArray alloc] init];
                NSMutableArray* familyGoals =  [[NSMutableArray alloc] init];
                NSMutableArray* caregiverGoals =  [[NSMutableArray alloc] init];
                for (int i=2; i<[goalRow count]; i++) {
                    NSString* goal = goalRow[i];
                    goal = [goal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                    NSLog(@"goal %@ prop %d: %@", respondent, i, goal);
                    
                    if ([respondent isEqualToString:@"self"] || [respondent isEqualToString:@"patient"])
                        [selfGoals addObject:goal];
                    else
                    if ([respondent isEqualToString:@"family"])
                        [familyGoals addObject:goal];
                    else
                    if ([respondent isEqualToString:@"caregiver"])
                        [caregiverGoals addObject:goal];
                }
                
                //find the goalInfo for the clinic on this row
                GoalInfo* goalInfo = NULL;
                for (GoalInfo* info in allGoals){
                    if ([clinic isEqualToString:[info getClinic]]){
                        goalInfo = info;
                        break;
                    }
                }
                if (goalInfo == NULL){
                    goalInfo = [[GoalInfo alloc]init];
                    [goalInfo setClinic:clinic];
                    [allGoals addObject:goalInfo];
                }
                if ([respondent isEqualToString:@"self"] || [respondent isEqualToString:@"patient"])
                    [goalInfo setSelfGoals:selfGoals];
                else
                if ([respondent isEqualToString:@"family"])
                    [goalInfo setFamilyGoals:familyGoals];
                else
                if ([respondent isEqualToString:@"caregiver"])
                    [goalInfo setCaregiverGoals:caregiverGoals];
            }
        }
    }
    NSLog(@"Loaded (%d) goals", [allGoals count]);
    for (GoalInfo* info in allGoals){
        [info writeToLog];
    }
    return allGoals;
}


+ (NSArray*) readQuestionInfo {
    NSLog(@"DynamicContent.readQuestionInfo()");
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/survey_questions.txt", documentsDirectory];
    NSMutableArray* allQuestions = [[NSMutableArray alloc] init];
    QuestionList* questionInfo = [[QuestionList alloc] init];
    NSArray * lines = [self readFile:filePath];
    for (NSString *line in lines) {
        NSString* cleanLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        if (cleanLine.length > 0){
            NSLog(@"DynamicContent.readQuestionInfo() survey_questions.txt line: %@", cleanLine);
            if([cleanLine hasPrefix:@"//"]){
                NSLog(@"DynamicContent.readQuestionInfo() comment: %@", cleanLine);
            }
            else {
                if ([cleanLine hasSuffix:@";"]){
                    int index = [cleanLine length] -1;
                    cleanLine = [cleanLine substringToIndex: index];
                }
                NSArray* row = [cleanLine componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@";"]];
                
                NSString* clinic = [[row objectAtIndex:0]
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSString* respondent = [[row objectAtIndex:1]
                                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                // pre-survey header plus 3 questions
                NSString* header1 = [[row objectAtIndex:2]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSMutableArray* questionList1 = [[NSMutableArray alloc] init];
                for (int i=3; i<6; i++) {
                    NSString* question = row[i];
                    question = [question stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [questionList1 addObject:question];
                }
                
                // info rating questions
                NSString* clinicianInfoRatingQuestion = [[row objectAtIndex:6]
                                                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* clinicInfoRatingQuestion = [[row objectAtIndex:7]
                                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                // post-survey header plus 15 questions
                NSString* header2 = [[row objectAtIndex:8]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSMutableArray* questionList2 = [[NSMutableArray alloc] init];
                for (int i=9; i<24; i++) {
                    NSString* question = row[i];
                    question = [question stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [questionList2 addObject:question];
                }
                
                // mini post-survey header plus 10 questions
                NSString* header3 = [[row objectAtIndex:24]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSMutableArray* questionList3 = [[NSMutableArray alloc] init];
                for (int i=25; i<35; i++) {
                    NSString* question = row[i];
                    question = [question stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [questionList3 addObject:question];
                }
                
                questionInfo = [[QuestionList alloc] init];
                //NOTE: the copies created below should be released somewhere,
                //             but autorelease causes values to be GC'd
                [questionInfo setClinic: [clinic copy]];
                [questionInfo setRespondentType: [respondent copy]];
                [questionInfo setClinicInfoRatingQuestion: [clinicInfoRatingQuestion copy]];
                [questionInfo setClinicianInfoRatingQuestion: [clinicianInfoRatingQuestion copy]];
                [questionInfo setHeader1: [header1 copy]];
                [questionInfo setHeader2: [header2 copy]];
                [questionInfo setHeader3: [header3 copy]];
                [questionInfo setQuestionSet1: questionList1];
                [questionInfo setQuestionSet2: questionList2];
                [questionInfo setQuestionSet3: questionList3];
                [allQuestions addObject:questionInfo];
            }
        }
    }

    NSLog(@"Loaded questions (%d)", [allQuestions count]);
    for (QuestionList* info in allQuestions){
        [info writeToLog];
    }
    return allQuestions;
}

+ (ClinicianInfo*) getClinician:(int)clinicianIndex{
    NSLog(@"DynamicContent.getClinician() index: %d", clinicianIndex);
    if (clinicianIndex > 100000){
        NSString* errMsg = [NSString stringWithFormat:@"ERROR: index out of bounds: %d", clinicianIndex];
        NSLog(@"DynamicContent.getClinician() %@", errMsg);
        [self showAlertMsg:errMsg];
        return NULL;
    }
    NSArray* allClinicians = [self getAllClinicians];
    if (clinicianIndex < [allClinicians count])
        return [allClinicians objectAtIndex:clinicianIndex];
    else
        return NULL;
}

+ (NSMutableArray*) getClinicNames{
    NSLog(@"DynamicContent.getClinicNames()");
    NSArray* allClinics = [self getAllClinics];
    NSMutableArray* clinicNames = [[NSMutableArray alloc] init];
    for (ClinicInfo* clinic in allClinics){
        NSString* clinicName = [clinic getSubclinicName];
        if (clinicName == NULL || [clinicName length] == 0)
             clinicName =[clinic getClinicName];
        
        if (clinicName != NULL && [clinicName length] > 0)
            [clinicNames addObject:clinicName];
    }
    return clinicNames;
}

+ (ClinicInfo*) getClinic:(NSString*)clinicName{
    NSLog(@"DynamicContent.getClinic() clinicName: %@", clinicName);
    NSString* clinicNameLowerCase = [clinicName lowercaseString];
    NSArray* allClinics = [self getAllClinics];
    for (ClinicInfo* clinic in allClinics){
        if ([[clinic getSubclinicName] isEqualToString:clinicName] ||
            [[clinic getSubclinicName] isEqualToString:clinicNameLowerCase] ||
            [[clinic getSubclinicNameShort] isEqualToString:clinicName] ||
            [[clinic getSubclinicNameShort] isEqualToString:clinicNameLowerCase])
            return clinic;
        if ([[clinic getClinicName] isEqualToString:clinicName] ||
            [[clinic getClinicName] isEqualToString:clinicNameLowerCase] ||
            [[clinic getClinicNameShort] isEqualToString:clinicName] ||
            [[clinic getClinicNameShort] isEqualToString:clinicNameLowerCase])
            return clinic;
        if ([clinicNameLowerCase hasPrefix:@"acu"] &&
            [[clinic getClinicNameShort] hasPrefix:@"acu"])
            return clinic;
        if ([clinicNameLowerCase hasPrefix:@"acu"] &&
            [[clinic getSubclinicNameShort] hasPrefix:@"acu"])
            return clinic;
    }
    return NULL;
}

+ (QuestionList*) getSurveyForCurrentClinicAndRespondent {
    NSArray* questions = [self getAllSurveyQuestions];
    for (QuestionList* info in questions){
            if ([mCurrentClinicName isEqualToString:[info getClinic]] &&
                [mCurrentRespondent isEqualToString:[info getRespondentType]]) {
            return info;
        }
    }
    return NULL;
}

+ (QuestionList*) getSurveyForRespondentType:(NSString*) respondentType{
    NSArray* questions = [self getAllSurveyQuestions];
    for (QuestionList* info in questions){
        if ([respondentType isEqualToString:[info getRespondentType]]) {
            return info;
        }
    }
    return NULL;
}

+ (NSMutableArray*) getNewClinicianNames{
    NSLog(@"DynamicContent.getNewClinicianNames()");
    NSArray *allClinicians = [DynamicContent getAllClinicians];
    NSMutableArray *allClinicianNames = [[NSMutableArray alloc] init];
    
    // download the image file for each clinician
    for (ClinicianInfo* clinician in allClinicians){
        //[clinician writeToLog];
        NSString  *name = [clinician getDisplayName];
        [allClinicianNames addObject:name];
    }
    NSLog(@"DynamicContent.getNewClinicianNames() exit");
    
    return allClinicianNames;
    //    [pool release];
}

+ (NSMutableArray*) getNewClinicianImages{
    NSLog(@"DynamicContent.getNewClinicianImages()");
    NSArray *allClinicians = [DynamicContent getAllClinicians];
    NSMutableArray *allClinicianImages = [[NSMutableArray alloc] init];
    
    // download the image file for each clinician
    for (ClinicianInfo* clinician in allClinicians){
        //[clinician writeToLog];
        NSString* imageName = [clinician getImageFilename];
        [allClinicianImages addObject:imageName];
    }
    
    return allClinicianImages;
    //    [pool release];
}

+ (NSArray*) getSubclinicPhysicians:(NSString*) subclinic{
    NSMutableArray* subclinicPhysicians =[[NSMutableArray alloc] init];
    NSArray *allClinicians = [DynamicContent getAllClinicians];
    
    for (ClinicianInfo* clinician in allClinicians){
        NSArray* subclinics = [[clinician getClinics] componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@","]];
        for (NSString* clinic in subclinics){
            if ([subclinic isEqualToString:clinic]){
                [subclinicPhysicians addObject:clinician];
                break;
            }
        }
    }
    return subclinicPhysicians;
}

+ (NSArray*) getSubclinicPhysicianNames:(NSString*) subclinic{
    NSLog(@"DynamicContent.getSubclinicPhysicianNames() subclinic: %@", subclinic);

    NSMutableArray* subclinicPhysicians =[[NSMutableArray alloc] init];
    NSArray *allClinicians = [DynamicContent getAllClinicians];
    
    for (ClinicianInfo* clinician in allClinicians){
        NSLog(@"DynamicContent.getSubclinicPhysicianNames() clinician:");
        [clinician writeToLog];

        NSArray* subclinics = [[clinician getClinics] componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@","]];
        for (NSString* clinic in subclinics){
            if ([subclinic isEqualToString:clinic]){
                [subclinicPhysicians addObject:[clinician getDisplayName]];
                break;
            }
        }
    }
    return subclinicPhysicians;
}

// utilities


+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile{
    // rjl 8/16/14
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString* downloadDir = nil;
    bool developerEnabled = true;
    if (developerEnabled){
//        if (isImageFile)
//            downloadDir = @"http://www.brainaid.com/wrtestdev/uploads/";
//        else
//        downloadDir = @"http://www.brainaid.com/wrtestdev/";
        downloadDir = @"http://www.brainaid.com/waitingroom/dir/files/uploads/";
    } else {
        if (isImageFile)
            downloadDir = @"http://www.brainaid.com/wrtest/uploads/";
        else
            downloadDir = @"http://www.brainaid.com/wrtest/";
    }
    NSString* filePath = [NSString stringWithFormat:@"%@%@", downloadDir,filename];
    NSURL *downloadUrl = [NSURL URLWithString:filePath];
    NSData *downloadData = [NSData dataWithContentsOfURL:downloadUrl];
    
    NSString* result = nil;
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    if ( downloadData ){
        if (isImageFile){
            UIImage *img = [UIImage imageWithData:downloadData];
            [self saveImage:img filename:filename];
        }
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
        [downloadData writeToFile:filePath atomically:YES];
        result = filePath;
    }
    else {
        NSString* jpgFilename = [filename stringByReplacingOccurrencesOfString:@".png" withString:@".jpg"];
        filePath = [NSString stringWithFormat:@"%@%@", downloadDir,jpgFilename];
        downloadUrl = [NSURL URLWithString:filePath];
        downloadData = [NSData dataWithContentsOfURL:downloadUrl];
        if ( downloadData ){
            if (isImageFile){
                UIImage *img = [UIImage imageWithData:downloadData];
                [self saveImage:img filename:filename];
            }
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
            [downloadData writeToFile:filePath atomically:YES];
            result = filePath;
        }
        else {
            NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filename];
            NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadFile() %@", errorMsg];
            NSLog(logMsg);
//            [self showAlertMsg:errorMsg];
        }
        
    }
    //    [pool release];
    return result;
}

+ (NSArray*) readFile:(NSString*)filename {
    // rjl 8/16/14
    // read everything from text
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSFileManager* fileManager =[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filename]){
        NSString* errorMsg = [NSString stringWithFormat:@"File not found: %@",filename];
        NSLog(errorMsg);
        [self showAlertMsg:errorMsg];
        return NULL;
    }
    NSString* fileContents =
    [NSString stringWithContentsOfFile:filename
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    //    [pool release];
    
    return allLinedStrings;
}

//- (void) readFileLineByLine:(NSString*) filename { // rjl 8/16/14
//    // from: http://stackoverflow.com/questions/1044334/objective-c-reading-a-file-line-by-line
//    const char *filenameChars = [filename UTF8String];
//    FILE *file = fopen(filenameChars, "r");
//    // check for NULL
//    while(!feof(file))
//    {
//        NSString *line = readLineAsNSString(file);
//       // NSLog(line);
//        // do stuff with line; line is autoreleased, so you should NOT release it (unless you also retain it beforehand)
//    }
//    fclose(file);
//}

NSString *readLineAsNSString(FILE *file) // rjl 8/16/14
{   // from: http://stackoverflow.com/questions/1044334/objective-c-reading-a-file-line-by-line
    char buffer[4096];
    
    // tune this capacity to your liking -- larger buffer sizes will be faster, but
    // use more memory
    NSMutableString *result = [NSMutableString stringWithCapacity:256];
    
    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);
    
    return result;
}


+ (void)saveImage: (UIImage*)image filename:(NSString*)filename{
    NSLog(@"WRViewController.saveImage() filename: %@", filename);
    if (image != nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:  filename ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
    
}

+ (UIImage*)loadImage: (NSString*)filename {
    NSLog(@"WRViewController.loadImage() filename: %@", filename);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: filename];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    bool fileExists = [fileManager fileExistsAtPath:path];
    NSLog(@"WRViewController.loadImage file path %@ exists %d", path, fileExists);
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    //    [self sendAction:path];
    return image;
}

+ (void)showAlertMsg:(NSString *)msg {
    //    [tbvc sayComingSoon];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@",msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [msgAlert show];
        [msgAlert release];
    });
}

+ (void)showAlertMsgAndResetApp:(NSString *)msg {
    //    [tbvc sayComingSoon];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Download complete!" message:[NSString stringWithFormat:@"%@",msg] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        msgAlert.delegate = self;
        [msgAlert show];
        [msgAlert release];
    });
}

+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"WRViewController.alertView.clickedButtonAtIndex() index: %d", buttonIndex);
    MainLoaderViewController* viewController = [MainLoaderViewController getViewController];
    if (viewController != NULL)
        [viewController performAppReset];
}



+ (NSMutableArray*) getProviderTestStrings {
    return mProviderTestStrings;
}

+ (void) setProviderTestStrings:(NSArray*)providerTestStrings {
    if (mProviderTestStrings == NULL)
        mProviderTestStrings = [[NSMutableArray alloc] init];
    [mProviderTestStrings addObjectsFromArray:providerTestStrings];
}

+ (NSMutableArray*) getClinicTestStrings {
    return mClinicTestStrings;
}

+ (void) setClinicTestStrings:(NSArray*)clinicTestStrings {
    if (mClinicTestStrings == NULL)
        mClinicTestStrings = [[NSMutableArray alloc] init];
    [mClinicTestStrings addObjectsFromArray:clinicTestStrings];
}



+ (NSMutableArray*) getClinicianTestNames {
    // used for speech synthesis
    if (mClinicianTestNames == NULL){
        mClinicianTestNames = [[NSMutableArray alloc] init];
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if (mClinicianTestHeaderText != NULL)
        [result addObject: mClinicianTestHeaderText];
    [result addObjectsFromArray:mClinicianTestNames];
    return result;
}

+ (void) setClinicianTestNames:(NSArray*)clinicianTestNames {
    // used for speech synthesis
    if (mClinicianTestNames == NULL)
        mClinicianTestNames = [[NSMutableArray alloc] init];
    [mClinicianTestNames addObjectsFromArray:clinicianTestNames];
}

+ (NSMutableArray*) getClinicTestNames {
    if (mClinicTestNames == NULL){
        mClinicTestNames = [[NSMutableArray alloc] init];
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if (mClinicTestHeaderText != NULL)
        [result addObject: mClinicTestHeaderText];
    [result addObjectsFromArray:mClinicTestNames];
    return result;
}

+ (void) setClinicTestNames:(NSArray*)clinicTestNames {
    // used for speech synthesis
    if (mClinicTestNames == NULL)
        mClinicTestNames = [[NSMutableArray alloc] init];
    [mClinicTestNames addObjectsFromArray:clinicTestNames];
}

+ (NSMutableArray*) getGoalStrings {
    if (mGoalStrings == NULL){
        mGoalStrings = [[NSMutableArray alloc] init];
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if (mGoalsHeaderText != NULL)
        [result addObject: mGoalsHeaderText];
    [result addObjectsFromArray:mGoalStrings];
    return result;
}

+ (void) setGoalStrings:(NSArray*)goalStrings {
    if (mGoalStrings == NULL)
        mGoalStrings = [[NSMutableArray alloc] init];
    [mGoalStrings addObjectsFromArray:goalStrings];
}

+ (NSString*) getClinicTestHeaderText{
    return mClinicTestHeaderText;
}

+ (NSString*) getClinicianTestHeaderText{
    return mClinicianTestHeaderText;
}

+ (NSString*) getGoalsHeaderText{
    return mGoalsHeaderText;
}

+ (NSMutableArray*) getTimeSegments {
    if (mTimeSegments == NULL){
        mTimeSegments = [[NSMutableArray alloc] init];
    }
    // access as:
    // NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    // [myTimeSegmentsArray addObject:@"ha"];
    return mTimeSegments;
}
+ (NSMutableArray*) getSelfGuideStatus {
    if (mSelfGuideStatus == NULL){
        mSelfGuideStatus = [[NSMutableArray alloc] init];
    }
    // access as:
    // NSMutableArray* myTimeSegmentsArray = [DynamicContent getTimeSegments];
    // [myTimeSegmentsArray addObject:@"ha"];
    return mSelfGuideStatus;
}

+(NSMutableArray*) getPrivacyPolicy {
   NSMutableArray* lines = [[NSMutableArray alloc] init];
    [lines addObject:@"Your participation in this survey is anonymous."];
    [lines addObject:@"_PAUSE_"];
    [lines addObject:@"Your responses will not be given to your treatment provider or any other clinic staff."];
    [lines addObject:@"_PAUSE_"];
    [lines addObject:@"Your responses will not influence the services you receive at this clinic."];
    return lines;
}

+ (void) showEdModule:(NSString*) moduleName{
    NSLog(@"DynamicContent.showEdModule() %@", moduleName);
    WRViewController* viewController = [WRViewController getViewController];
    if ([moduleName hasPrefix:@"What's New"]){
        [viewController launchDynamicWhatsNewModule];
    } else if ([moduleName hasPrefix:@"Learn about"]){
        [viewController launchTbiEdModule];
    } else if ([moduleName hasPrefix:@"Back to School"]){
        [viewController launchEdModule1];
    } else if ([moduleName hasSuffix:@"Recreation"]){
        [viewController launchEdModule2];
    }
}

+ (SwitchedImageViewController*) getEdModulePicker {
    return mEdModulePickerVC;
}

+ (void) setEdModulePicker:(SwitchedImageViewController*) edModulePicker{
    mEdModulePickerVC = edModulePicker;
}

+ (void) fadeEdModulePickerIn{
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        [DynamicContent getEdModulePicker].view.alpha = 1.0;
		
	}
	[UIView commitAnimations];
}

+ (void) fadeEdModulePickerOut{
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        [DynamicContent getEdModulePicker].view.alpha = 0.0;
		
	}
	[UIView commitAnimations];
}

//+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

+ (id) safeObjectAtIndex:(NSArray*) array index:(int)objectIndex{
    if ([array count] > objectIndex)
        return [array objectAtIndex:objectIndex];
    else return NULL;
}



@end
