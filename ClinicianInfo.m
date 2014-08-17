//
//  ClinicianInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 8/16/14.
//
//

#import "ClinicianInfo.h"

@implementation ClinicianInfo


-(void) setName:(NSString *)name {
    mName = name;
}

-(void) setClinicianId:(NSString *)clinicianId{
    mClinicianId = clinicianId;
}

-(void) setText1:(NSString *)text {
    mText1 = text;
}

-(void) setText2:(NSString *)text {
    mText2 = text;
}

-(void) setText3:(NSString *)text {
    mText3 = text;
}

-(void) setText4:(NSString *)text {
    mText4 = text;
}

-(void) setImage:(UIImage *)image {
    mImage = image;
}

-(NSString*) getName {
    return mName;
}

-(NSString*) getClinicianId {
    return mClinicianId;
}

-(NSString*) getText1 {
    return mText1;
}

-(NSString*) getText2 {
    return mText2;
}

-(NSString*) getText3 {
    return mText3;
}

-(NSString*) getText4 {
    return mText4;
}

-(NSString*) getImageFilename {
    NSString* imageFilename = [NSString stringWithFormat:@"%@.png", [self getName]];
    return imageFilename;
}


-(NSString*) writeToString {
    NSString* result = [NSString stringWithFormat:@"[clinician: %@, %@, %@, %@, %@]", mClinicianId, mName, mText1, mText2, mText3];
    //NSLog(@"[clinician: %@, %@,%@,%@,%@]", mClinicianId, mName, mText1, mText2, mText3);
    return result;
}

-(Boolean) writeToDB {
    NSString* result = [NSString stringWithFormat:@"[clinician: %@, %@,%@,%@,%@]", mClinicianId, mName, mText1, mText2, mText3];
    //NSLog(@"[clinician: %@, %@,%@,%@,%@]", mClinicianId, mName, mText1, mText2, mText3);
    return true;
}

@end
