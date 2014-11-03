//
//  WhatsNewInfo.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/2/14.
//
//

#import <Foundation/Foundation.h>


@interface WhatsNewInfo : NSObject {
    NSString* mClinic;
    NSString* mHeader;
    NSString* mBody;
    NSString* mImage;
}

- (void) setClinic:(NSString*) clinic;
- (void) setHeader:(NSString*) header;
- (void) setBody:(NSString*) body;
- (void) setImage:(NSString*) image;

- (NSString*) getClinic;
- (NSString*) getHeader;
- (NSString*) getBody;
- (NSString*) getImage;

- (void) writeToLog;

@end
