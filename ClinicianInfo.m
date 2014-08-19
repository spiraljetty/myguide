//
//  ClinicianInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 8/16/14.
//
//

#import "ClinicianInfo.h"

@implementation ClinicianInfo

-(id)init {
    NSLog(@"ClinicianInfo.init()");
    self = [super init];
    if (self) {
        [self setClinicianId:@""];
        [self setClinics:@""];
        [self setFirstName:@""];
        [self setLastName:@""];
        [self setSalutation:@""];
        [self setDegrees:@""];
        [self setCredentials:@""];
        [self setEdAndAffil:@""];
        [self setBackground:@""];
        [self setPhilosophy:@""];
        [self setPersonalInterests:@""];
    }
    return self;
}

// setters

-(void) setClinicianId:(NSString *)clinicianId{
    mClinicianId = clinicianId;
}

-(void) setClinics:(NSString *)clinics{
    mClinics = clinics;
}

-(void) setFirstName:(NSString *)firstName {
    mFirstName = firstName;
}

-(void) setLastName:(NSString *)lastName {
    mLastName = lastName;
}



-(void) setSalutation:(NSString *)text {
    mSalutation = text;
}

-(void) setDegrees:(NSString *)text {
    mDegrees = text;
}

-(void) setCredentials:(NSString *)text {
    mCredentials = text;
}

-(void) setEdAndAffil:(NSString *)text {
    mEdAndAffil = text;
}


-(void) setBackground:(NSString *)text {
    mBackground = text;
}

-(void) setPhilosophy:(NSString *)text {
    mPhilosophy = text;
}

-(void) setPersonalInterests:(NSString *)text {
    mPersonalInterests = text;
}


-(void) setImage:(UIImage *)image {
    mImage = image;
}

-(void) setImageThumb:(UIImage *)image {
    mImageThumb = image;
}


// getters

-(NSString*) getClinicianId {
    return mClinicianId;
}

-(NSString*) getClinics {
    return mClinics;
}

-(NSString*) getFirstName {
    return mFirstName;
}

-(NSString*) getLastName {
    return mLastName;
}


-(NSString*) getSalutation {
    return mSalutation;
}

-(NSString*) getDegrees {
    return mDegrees;
}

-(NSString*) getCredentials {
    return mCredentials;
}

-(NSString*) getEdAndAffil {
    return mEdAndAffil;
}


-(NSString*) getBackground {
    return mBackground;
}

-(NSString*) getPhilosophy {
    return mPhilosophy;
}

-(NSString*) getPersonalInterests {
    return mPersonalInterests;
}


-(NSString*) getImageFilename {
    NSString* imageFilename = [NSString stringWithFormat:@"%@_%@.png",
                               [[self getFirstName] lowercaseString], [[self getLastName] lowercaseString]];
    return imageFilename;
}

-(NSString*) getImageThumbFilename {
    NSString* imageFilename = [NSString stringWithFormat:@"%@_%@_thumb.png",
                               [[self getFirstName] lowercaseString], [[self getLastName] lowercaseString]];
    return imageFilename;
}


- (void) writeToLog {
    NSLog(@"[Clinician: %@", mClinicianId);
    NSLog(@"   Clinics: %@", mClinics);
    NSLog(@"   First name: %@", mFirstName);
    NSLog(@"   Last  name: %@", mLastName);
    NSLog(@"   Salutation: %@", mSalutation);
    NSLog(@"   Degrees: %@", mDegrees);
    NSLog(@"   Credentials: %@", mCredentials);
    NSLog(@"   Ed and Affil: %@", mEdAndAffil);
    NSLog(@"   Background: %@", mBackground);
    NSLog(@"   Philosophy: %@", mPhilosophy);
    NSLog(@"   Personal  : %@]", mPersonalInterests);
}

- (NSMutableDictionary*) writeToDictionary {
    [self writeToLog];
    NSMutableDictionary *rootObj = [NSMutableDictionary dictionaryWithCapacity:15];
    NSString *credentials = [self getCredentials];
    NSString *edAndAffil = [self getEdAndAffil];
    NSString *background = [self getBackground];
    NSString *philosophy = [self getPhilosophy];
    NSString *personalInterests = [self getPersonalInterests];
        
    if (credentials)
        [rootObj setObject:credentials forKey:@"Credentials"];
    if (edAndAffil)
        [rootObj setObject:edAndAffil forKey:@"Education and Afilliations"];
    if (background)
        [rootObj setObject:background forKey:@"Background"];
    if (philosophy)
        [rootObj setObject:philosophy forKey:@"Philosophy"];
    if (personalInterests)
        [rootObj setObject:personalInterests forKey:@"Personal Interests"];

        return rootObj;
}

-(Boolean) writeToDB {
    NSLog(@"[Clinician: %@, %@, %@, %@, %@, %@", mClinicianId, mClinics, mFirstName, mLastName, mSalutation, mDegrees);
    NSLog(@"   Credentials: %@", mCredentials);
    NSLog(@"   Ed and Affil: %@", mEdAndAffil);
    NSLog(@"   Background: %@", mBackground);
    NSLog(@"   Philosophy: %@", mPhilosophy);
    NSLog(@"   Personal  : %@]", mPersonalInterests);
    return true;
}

@end
