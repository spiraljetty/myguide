//
//  QuestionList.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/11/14.
//
//

#import "QuestionList.h"

@implementation QuestionList

-(id)init {
    self = [super init];
    if (self) {
        [self setClinic:@""];
        [self setRespondentType:@""];
        [self setClinicInfoRatingQuestion:@""];
        [self setClinicianInfoRatingQuestion:@""];
        [self setHeader1:@""];
        [self setHeader2:@""];
        [self setHeader3:@""];
        [self setQuestionSet1:NULL];
        [self setQuestionSet2:NULL];
        [self setQuestionSet3:NULL];
    }
    return self;
}

- (void) setClinic:(NSString*) clinic {
    mClinic = clinic;
}

- (void) setRespondentType:(NSString*) type {
    mRespondentType = type;
}

- (void) setClinicInfoRatingQuestion:(NSString*) question {
    mClinicInfoRatingQuestion = question;
}

- (void) setClinicianInfoRatingQuestion:(NSString*) question {
    mClinicianInfoRatingQuestion = question;
}

- (void) setHeader1:(NSString*) header {
    mHeader1 = header;
}

- (void) setHeader2:(NSString*) header {
    mHeader2 = header;
}

- (void) setHeader3:(NSString*) header {
    mHeader3 = header;
}

- (void) setQuestionSet1:(NSArray*) questions {
    mQuestionSet1 = questions;
}

- (void) setQuestionSet2:(NSArray*) questions {
    mQuestionSet2 = questions;
}

- (void) setQuestionSet3:(NSArray*) questions {
    mQuestionSet3 = questions;
}

- (NSString*) getClinic {
    return mClinic;
}

- (NSString*) getRespondentType {
    return mRespondentType;
}

- (NSString*) getClinicInfoRatingQuestion {
    return mClinicInfoRatingQuestion;
}

- (NSString*) getClinicianInfoRatingQuestion {
    return mClinicianInfoRatingQuestion;
}

- (NSString*) getHeader1 {
    return mHeader1;
}

- (NSString*) getHeader2 {
    return mHeader2;
}

- (NSString*) getHeader3{
    return mHeader3;
}

- (NSArray*) getQuestionSet1 {
    return mQuestionSet1;
}

- (NSArray*) getQuestionSet2 {
    return mQuestionSet2;
}

- (NSArray*) getQuestionSet3 {
    return mQuestionSet3;
}

- (void) writeToLog {
    NSLog(@" ");
    NSLog(@"Questions for %@ %@", mClinic, mRespondentType);
    NSLog(@"  Clinic info rating question: %@", mClinicInfoRatingQuestion);
    NSLog(@"  Clinician info rating question: %@", mClinicianInfoRatingQuestion);
    NSLog(@"  Question set 1: header: %@, count (%d) %@", mHeader1, [mQuestionSet1 count], mQuestionSet1);
    NSLog(@"  Question set 2: header: %@, count (%d) %@", mHeader2, [mQuestionSet2 count], mQuestionSet2);
    NSLog(@"  Question set 3: header: %@, count (%d) %@", mHeader3, [mQuestionSet3 count], mQuestionSet3);
    NSLog(@" ");
}

@end
