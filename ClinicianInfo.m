//
//  ClinicianInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 8/16/14.
//
//

#import "ClinicianInfo.h"

@implementation ClinicianInfo

-(void) print {
    NSLog(@"[clinician: %@, %@,%@,%@,%@]", mClinicianId, mName, mText1, mText2, mText3);
}

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

@end
