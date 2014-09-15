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
#import "YLViewController.h"

#import <AVFoundation/AVFoundation.h>

static NSArray* mAllSurveyQuestions = NULL;
static NSArray* mAllClinicians = NULL;
static NSArray* mAllClinics = NULL;
static GoalInfo* mAllGoals = NULL;

@implementation DynamicContent

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
        
        if (viewController != NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController downloadDataRequestDone];
            });
        }
        
        NSString* msg = [NSString stringWithFormat:@"Downloaded:\n%d clinics\n%d clinicians", clinicCount, clinicianCount];
        [DynamicContent showAlertMsg:msg];
    
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
    NSString* filePath = [self downloadFile:@"clinicians.txt" isImage:false];
    if (filePath)
        count = [[self readClinicianInfo:true] count];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicianInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
    return count;
}

+ (int) downloadClinicInfo { // rjl 8/16/14
    int count = 0;
    NSString* filePath = [self downloadFile:@"clinics.txt" isImage:false];
    if (filePath)
        count = [[self readClinicInfo:true] count];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
    return count;
}

+ (void) downloadGoalInfo { // rjl 8/16/14
    NSString* filePath = [self downloadFile:@"goals.txt" isImage:false];
    if (filePath)
        [self readGoalInfo];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadGoalInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
}

+ (void) downloadQuestionInfo { // rjl 8/16/14
    NSString* filePath = [self downloadFile:@"survey_questions.txt" isImage:false];
    if (filePath)
        [self readQuestionInfo];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadQuestionInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
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


+ (GoalInfo*) getAllGoals {
    if (mAllGoals == NULL){
        mAllGoals = [self readGoalInfo];
    }
    return mAllGoals;
}

+ (id)getAllSurveyQuestions {
    if (mAllSurveyQuestions == NULL){
        mAllSurveyQuestions = [self readQuestionInfo];
    }
    return mAllSurveyQuestions;
}

+ (NSMutableArray*) readClinicianInfo:(BOOL) isDownload{
    YLViewController* viewController = [YLViewController getViewController];
    NSLog(@"DynamicContent.getAllClinicians() isDownload: %d", isDownload);
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/clinicians.txt", documentsDirectory];
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *allClinicians = [[NSMutableArray alloc] init];
    NSArray * lines = [self readFile:filePath];
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
            NSArray* clinicianProperties = [line componentsSeparatedByCharactersInSet:
                                            [NSCharacterSet characterSetWithCharactersInString:@";"]];
            for (int i=0; i<[clinicianProperties count]; i++) {
                NSString* value = clinicianProperties[i];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                //NSLog(@"%d: %@", i, value);
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
//            [clinician writeToLog];
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
        if (viewController != NULL){
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
                NSString* clinicName = [clinicProperties objectAtIndex:4]; // try subclinicNameShort
                if ([clinicName length] == 0)
                    clinicName = [clinicProperties objectAtIndex:2];
                if ([clinicName length] == 0)
                    clinicName = [clinicProperties objectAtIndex:1];
                ClinicInfo* currentClinic = NULL;
                if (allClinics != NULL){
                    for (ClinicInfo* clinic in allClinics){
                        NSString* name = [clinic getClinicName];
                        if ([name isEqualToString:clinicName]){
                            currentClinic = clinic;
                            break;
                        }
                    }
                }
                //                    int currentClinicIndex = [allClinics indexOfObject:clinicName];
                if (currentClinic == NULL){
                    ClinicInfo* clinicInfo = [[ClinicInfo alloc]init];
                    [clinicInfo setClinicName:clinicName];
                    //                    [clinicInfo setClinicNameShort: [clinicProperties objectAtIndex:2]];
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
                        case 10: [page setObject:value forKey:@"clinicIcon"]; break;
                            
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

+ (GoalInfo*) readGoalInfo {
    NSLog(@"DynamicContent.readGoalInfo()");
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/goals.txt", documentsDirectory];
    
    NSMutableArray* selfGoals = [[NSMutableArray alloc] init];
    NSMutableArray* familyGoals =  [[NSMutableArray alloc] init];
    NSMutableArray* caregiverGoals =  [[NSMutableArray alloc] init];
    
    GoalInfo* goalInfo = [[GoalInfo alloc]init];
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
                NSString* type = [goalRow objectAtIndex:0];
                for (int i=1; i<[goalRow count]; i++) {
                    NSString* goal = goalRow[i];
                    goal = [goal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                    NSLog(@"goal %@ prop %d: %@", type, i, goal);
                    
                    if ([type isEqualToString:@"self"] || [type isEqualToString:@"patient"])
                        [selfGoals addObject:goal];
                    else
                        if ([type isEqualToString:@"family"])
                            [familyGoals addObject:goal];
                        else
                            if ([type isEqualToString:@"caregiver"])
                                [caregiverGoals addObject:goal];
                }
            }
        }
    }
    [goalInfo setSelfGoals:selfGoals];
    [goalInfo setFamilyGoals:familyGoals];
    [goalInfo setCaregiverGoals:caregiverGoals];
    
    NSLog(@"Loaded all goals");
    [goalInfo writeToLog];
    
    return goalInfo;
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

+ (ClinicInfo*) getClinic:(NSString*)clinicNameShort{
    NSLog(@"DynamicContent.getClinic() clinicNameShort: %@", clinicNameShort);
    NSArray* allClinics = [self getAllClinics];
    for (ClinicInfo* clinic in allClinics){
        if ([[clinic getClinicNameShort] isEqualToString:clinicNameShort])
            return clinic;
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
        NSString  *name = [NSString stringWithFormat:@"%@ %@ %@ %@", [clinician getSalutation], [clinician getFirstName], [clinician getLastName], [clinician getDegrees]];
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



// utilities


+ (NSString*) downloadFile:(NSString*)filename isImage:(BOOL) isImageFile{
    // rjl 8/16/14
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString* downloadDir = nil;
    bool developerEnabled = true;
    if (developerEnabled){
        if (isImageFile)
            downloadDir = @"http://www.brainaid.com/wrtestdev/uploads/";
        else
            downloadDir = @"http://www.brainaid.com/wrtestdev/";
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

- (void) readFileLineByLine:(NSString*) filename { // rjl 8/16/14
    // from: http://stackoverflow.com/questions/1044334/objective-c-reading-a-file-line-by-line
    const char *filenameChars = [filename UTF8String];
    FILE *file = fopen(filenameChars, "r");
    // check for NULL
    while(!feof(file))
    {
        NSString *line = readLineAsNSString(file);
        NSLog(line);
        // do stuff with line; line is autoreleased, so you should NOT release it (unless you also retain it beforehand)
    }
    fclose(file);
}

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
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    //    [self sendAction:path];
    return image;
}

+ (void)showAlertMsg:(NSString *)msg {
    //    [tbvc sayComingSoon];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@",msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        msgAlert.delegate = self;
        [msgAlert show];
        [msgAlert release];
    });
}

+ (void) speakText:(NSString*) text {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
        [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en"];
        [synthesizer speakUtterance:utterance];
    });
}


@end
