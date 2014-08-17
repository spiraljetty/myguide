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

- (void) print;
- (void) setName: (NSString*) name;
- (void) setClinicianId:   (NSString*) clinicianId;
- (void) setText1: (NSString*) text;
- (void) setText2: (NSString*) text;
- (void) setText3: (NSString*) text;
- (void) setText4: (NSString*) text;
- (void) setImage: (UIImage*) image;

@end
