//
//  GoalInfo.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/8/14.
//
//

#import <Foundation/Foundation.h>

@interface GoalInfo : NSObject {
    NSString* mClinic;
    NSArray* mSelfGoals;
    NSArray* mFamilyGoals;
    NSArray* mCaregiverGoals;
}

- (void) setClinic:(NSString*) clinic;
- (void) setSelfGoals:(NSArray*) goals;
- (void) setFamilyGoals:(NSArray*) goals;
- (void) setCaregiverGoals:(NSArray*) goals;

- (NSString*) getClinic;
- (NSArray*) getSelfGoals;
- (NSArray*) getFamilyGoals;
- (NSArray*) getCaregiverGoals;

- (void) writeToLog;

@end
