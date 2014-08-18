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
    UIImage * mImage;
    UIImage * mImageThumb;
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
- (void) setImage: (UIImage*) image;
- (void) setImageThumb: (UIImage*) image;


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


// writers

- (void)    writeToLog;
- (Boolean) writeToDB;

@end
