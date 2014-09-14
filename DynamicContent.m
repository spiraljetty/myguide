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
#import <AVFoundation/AVFoundation.h>

static NSArray* mAllSurveyQuestions = NULL;
static NSArray* mAllClinicians = NULL;
static GoalInfo* mAllGoals = NULL;

@implementation DynamicContent

+ (void) downloadAllData {
    [DynamicContent downloadClinicianInfo];
    [DynamicContent downloadClinicInfo];
    [DynamicContent downloadGoalInfo];
    [DynamicContent downloadQuestionInfo];
}

+ (void) downloadClinicianInfo { // rjl 8/16/14
    NSString* filePath = [self downloadFile:@"clinicians.txt" isImage:false];
    if (filePath)
        [self readClinicianInfo];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicianInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
}

+ (void) downloadClinicInfo { // rjl 8/16/14
    NSString* filePath = [self downloadFile:@"clinics.txt" isImage:false];
    if (filePath)
        [self readClinicInfo:filePath];
    else{
        NSString* errorMsg = [NSString stringWithFormat:@"Failed to download file: %@", filePath];
        NSString* logMsg = [NSString stringWithFormat:@"DynamicContent.downloadClinicInfo() %@", errorMsg];
        NSLog(logMsg);
        [self showAlertMsg:errorMsg];
    }
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

+ (NSArray*) getAllClinicians {
    //NSLog(@"DynamicContent.getAllClinicians() mAllClinicians: %@", mAllClinicians);
    
    if (mAllClinicians == NULL){
        //NSLog(@"DynamicContent.getAllClinicians() mAllClinicians is null");
        mAllClinicians = [self readClinicianInfo];
    }
    return mAllClinicians;
}

+ (NSMutableArray*) readClinicianInfo {
    NSLog(@"DynamicContent.getAllClinicians()");
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/clinicians.txt", documentsDirectory];
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *allClinicians = [[NSMutableArray alloc] init];
    NSArray * lines = [self readFile:filePath];
    for (NSString *line in lines) {
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
    
    NSLog(@"DynamicContent.getAllClinicians() count: %d", [allClinicians count]);
    
    
    return allClinicians;
    //    [pool release];
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

+ (NSArray*) readClinicInfo:(NSString*) filePath{
    NSLog(@"DynamicContent.readClinicInfo()");
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *allClinics = [[NSMutableArray alloc] init];
    NSMutableArray* allImages =  [[NSMutableArray alloc] init];
    
    //    ClinicInfo * clinicInfo = NULL;
    NSArray * lines = [self readFile:filePath];
    for (NSString *line in lines) {
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
                        case 8: [page setObject:value forKey:@"pageImage"]; [allImages addObject:value]; break;
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
    for (NSString* imageFilename in allImages){
        [self downloadFile:imageFilename isImage:true];
    }
    [self showAlertMsg:msg];
    return allClinics;
    //    [pool release];
}


//- (ClinicianInfo*) getClinicianOld:(int)clinicianIndex{
//    NSLog(@"DynamicContent.getClinician() index: %d", clinicianIndex);
//    if (clinicianIndex > 100000){
//        NSString* errMsg = [NSString stringWithFormat:@"ERROR: index out of bounds: %d", clinicianIndex];
//        NSLog(@"DynamicContent.getClinician() %@", errMsg);
//        [self showAlertMsg:errMsg];
//        return NULL;
//    }
//    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString  *documentsDirectory = [paths objectAtIndex:0];
//    NSString  *filePath = [NSString stringWithFormat:@"%@/clinicians.txt", documentsDirectory];
//    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    NSMutableArray *allClinicians = [[NSMutableArray alloc] init];
//    NSArray * lines = [self readFile:filePath];
//    for (NSString *line in lines) {
//        ClinicianInfo * clinicianInfo = [[ClinicianInfo alloc]init];
//        NSString* clinicianLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
//        
//        if (clinicianLine.length > 0){
//            if ([clinicianLine hasSuffix:@";"]){
//                int index = [clinicianLine length] -1;
//                clinicianLine = [clinicianLine substringToIndex: index];
//            }
//            //NSLog(@"%@", line);
//            // parse row containing clinician details
//            NSArray* clinicianProperties = [clinicianLine componentsSeparatedByCharactersInSet:
//                                            [NSCharacterSet characterSetWithCharactersInString:@";"]];
//            for (int i=0; i<[clinicianProperties count]; i++) {
//                NSString* value = clinicianProperties[i];
//                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
//                //NSLog(@"%d: %@", i, value);
//                if ([value length] > 0){
//                    switch (i) {
//                        case 0: [clinicianInfo setClinicianId:value]; break;
//                        case 1: [clinicianInfo setClinics:value]; break;
//                        case 2: [clinicianInfo setFirstName:value]; break;
//                        case 3: [clinicianInfo setLastName:value]; break;
//                        case 4: [clinicianInfo setSalutation:value]; break;
//                        case 5: [clinicianInfo setDegrees:value]; break;
//                        case 6: [clinicianInfo setCredentials:value]; break;
//                        case 7: [clinicianInfo setEdAndAffil:value]; break;
//                        case 8: [clinicianInfo setBackground:value]; break;
//                        case 9: [clinicianInfo setPhilosophy:value]; break;
//                        case 10: [clinicianInfo setPersonalInterests:value]; break;
//                    } // end switch
//                }
//            } // end for
//            [allClinicians addObject:clinicianInfo];
//        } // end if clinicianLine.length > 0
//    }// end for line in lines
//    
//    NSLog(@"Loaded %d clinicians", [allClinicians count]);
//    ClinicianInfo* matchingClinician = NULL;
//    //int adjustedClinicianIndex = clinicianIndex - [allClinicPhysicians count];
//    //if (adjustedClinicianIndex >= 0) //rjl 8/19/14 indexOffset Bug
//     //   matchingClinician = [allClinicians objectAtIndex:adjustedClinicianIndex];
//    
//    NSLog(@"WRViewController.getNewClinicianNames() matching clinician:");
//    [matchingClinician writeToLog];
//    
//    return matchingClinician;
//    //    [pool release];
//}


+ (id)getAllSurveyQuestions {
    //NSLog(@"DynamicContent.getAllSurveyQuestions() mAllSurveyQuestions: %@", mAllSurveyQuestions);

    if (mAllSurveyQuestions == NULL){
        //NSLog(@"DynamicContent.getAllSurveyQuestions() mAllSurveyQuestions is null");
        mAllSurveyQuestions = [self readQuestionInfo];
    }
    return mAllSurveyQuestions;
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


+ (GoalInfo*) getAllGoals {
    //NSLog(@"DynamicContent.getAllClinicians() mAllClinicians: %@", mAllClinicians);
    
    if (mAllGoals == NULL){
        //NSLog(@"DynamicContent.getAllClinicians() mAllClinicians is null");
        mAllGoals = [self readGoalInfo];
    }
    return mAllGoals;
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

+ (GoalInfo*) getGoalInfo {
    NSLog(@"DynamicContent.getoalInfo()");
    NSMutableArray* selfGoals = [[NSMutableArray alloc] init];
    NSMutableArray* familyGoals =  [[NSMutableArray alloc] init];
    NSMutableArray* caregiverGoals =  [[NSMutableArray alloc] init];
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/goals.txt", documentsDirectory];
    
    
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
    
    NSLog(@"Read all goals");
    [goalInfo writeToLog];
    
    return goalInfo;
}


// utilities


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
            NSString* logMsg = [NSString stringWithFormat:@"WRViewController.downloadFile() %@", errorMsg];
            NSLog(logMsg);
            [self showAlertMsg:errorMsg];
        }
        
    }
    //    [pool release];
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
    UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@",msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    msgAlert.delegate = self;
    [msgAlert show];
    [msgAlert release];
}

+ (void) speakText:(NSString*) text {
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];//1.1f];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en"];
    [synthesizer speakUtterance:utterance];
}


@end
