//
//  QuestionList.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface QuestionList : NSObject {
    
    NSString* mClinic;
    NSString* mRespondentType;
    NSString* mClinicInfoRatingQuestion;
    NSString* mClinicianInfoRatingQuestion;
    NSString* mHeader1;
    NSArray*  mQuestionSet1;
    NSString* mHeader2;
    NSArray*  mQuestionSet2;
    NSString* mHeader3;
    NSArray*  mQuestionSet3;
}

- (void) setClinic:(NSString*) clinic;
- (void) setRespondentType:(NSString*) type;
- (void) setClinicInfoRatingQuestion:(NSString*) question;
- (void) setClinicianInfoRatingQuestion:(NSString*) question;
- (void) setHeader1:(NSString*) header;
- (void) setQuestionSet1:(NSArray*) questions;
- (void) setHeader2:(NSString*) header;
- (void) setQuestionSet2:(NSArray*) questions;
- (void) setHeader3:(NSString*) header;
- (void) setQuestionSet3:(NSArray*) questions;

- (NSString*) getClinic;
- (NSString*) getRespondentType;
- (NSString*) getClinicInfoRatingQuestion;
- (NSString*) getClinicianInfoRatingQuestion;
- (NSString*) getHeader1;
- (NSArray*)  getQuestionSet1;
- (NSString*) getHeader2;
- (NSArray*)  getQuestionSet2;
- (NSString*) getHeader3;
- (NSArray*)  getQuestionSet3;

- (void) writeToLog;

@end
