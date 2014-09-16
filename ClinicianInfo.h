//
//  ClinicianInfo.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 8/16/14.
//
//

#import <Foundation/Foundation.h>

@interface ClinicianInfo : NSObject {

    NSString* mClinicianId;
    NSString* mClinics;
    NSString* mFirstName;
    NSString* mLastName;
    NSString* mSalutation;
    NSString* mDegrees;
    NSString* mCredentials;
    NSString* mEdAndAffil;
    NSString* mBackground;
    NSString* mPhilosophy;
    NSString* mPersonalInterests;
    NSString* mImageFilename;
    NSString* mImageThumbFilename;
}

// setters

- (void) setClinicianId:   (NSString*) clinicianId;
- (void) setClinics: (NSString*) clinics;
- (void) setFirstName: (NSString*) firstName;
- (void) setLastName: (NSString*) lastName;
- (void) setSalutation: (NSString*) text;
- (void) setDegrees: (NSString*) text;
- (void) setCredentials: (NSString*) text;
- (void) setEdAndAffil: (NSString*) text;
- (void) setBackground: (NSString*) text;
- (void) setPhilosophy: (NSString*) text;
- (void) setPersonalInterests: (NSString*) text;
- (void) setImageFilename: (NSString*) imageFilename;
- (void) setImageThumbFilename: (NSString*) imageFilename;


// getters

- (NSString*) getClinicianId;
- (NSString*) getClinics;
- (NSString*) getFirstName;
- (NSString*) getLastName;
- (NSString*) getSalutation;
- (NSString*) getDegrees;
- (NSString*) getCredentials;
- (NSString*) getEdAndAffil;
- (NSString*) getBackground;
- (NSString*) getPhilosophy;
- (NSString*) getPersonalInterests;
- (NSString*) getImageFilename;
- (NSString*) getImageThumbFilename;
- (NSString*) getDisplayName;
- (NSString*) getDbName;

// writers

- (void)    writeToLog;
- (Boolean) writeToDB;
- (NSMutableDictionary*) writeToDictionary;

@end
