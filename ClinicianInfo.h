//
//  ClinicianInfo.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 8/16/14.
//
//

#import <Foundation/Foundation.h>

@interface ClinicianInfo : NSObject

{ NSString* mName;
    NSString* mClinicianId;
    NSString* mText1;
    NSString* mText2;
    NSString* mText3;
    NSString* mText4;
    UIImage * mImage;
}

- (void) setName: (NSString*) name;
- (void) setClinicianId:   (NSString*) clinicianId;
- (void) setText1: (NSString*) text;
- (void) setText2: (NSString*) text;
- (void) setText3: (NSString*) text;
- (void) setText4: (NSString*) text;
- (void) setImage: (UIImage*) image;

- (NSString*) getName;
- (NSString*) getImageFilename;
- (NSString*) getText1;
- (NSString*) getText2;
- (NSString*) getText3;
- (NSString*) getText4;

- (NSString*) writeToString;
- (Boolean)   writeToDB;

@end
