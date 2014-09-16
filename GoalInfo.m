//
//  GoalInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/8/14.
//
//

#import "GoalInfo.h"

@implementation GoalInfo

-(id)init {
    self = [super init];
    if (self) {
        [self setClinic:@""];
        [self setSelfGoals:NULL];
        [self setFamilyGoals:NULL];
        [self setCaregiverGoals:NULL];
    }
    return self;
}

- (void) setClinic:(NSString*) clinic {
    mClinic = [clinic copy];
}

- (void) setSelfGoals:(NSArray*) goals {
    mSelfGoals = goals;
}

- (void) setFamilyGoals:(NSArray*) goals {
    mFamilyGoals = goals;
}

- (void) setCaregiverGoals:(NSArray*) goals {
    mCaregiverGoals = goals;
}

- (NSString*) getClinic {
    return mClinic;
}

- (NSArray*) getSelfGoals {
    return mSelfGoals;
}

- (NSArray*) getFamilyGoals {
    return mFamilyGoals;
}

- (NSArray*) getCaregiverGoals {
    return mCaregiverGoals;
}

- (void) writeToLog {
    NSLog(@"[Goals for %@:", mClinic);
    NSLog(@"  Self Goals (%d): %@", [mSelfGoals count],  mSelfGoals);
    NSLog(@"  Family Goals (%d): %@", [mFamilyGoals count], mFamilyGoals);
    NSLog(@"  Caregiver Goals (%d): %@", [mCaregiverGoals count], mCaregiverGoals);
}


@end
