//
//  WhatsNewInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/2/14.
//
//

#import "WhatsNewInfo.h"

@implementation WhatsNewInfo

-(id)init {
    self = [super init];
    if (self) {
        [self setClinic:@""];
        [self setHeader:@""];
        [self setBody:@""];
        [self setImage:@""];
    }
    return self;
}

- (void) setClinic:(NSString*) clinic {
    mClinic = [clinic copy];
}

- (void) setHeader:(NSString*) header {
    mHeader = header;
}

- (void) setBody:(NSString*) body {
    mBody = body;
}

- (void) setImage:(NSString*) image {
    mImage = image;
}

- (NSString*) getClinic {
    return mClinic;
}

- (NSString*) getHeader {
    return mHeader;
}

- (NSString*) getBody {
    return mBody;
}

- (NSString*) getImage {
    return mImage;
}

- (void) writeToLog {
    NSLog(@"[Whats New Page for %@:", mClinic);
    NSLog(@"  header: %@", mHeader);
    NSLog(@"  body  : %@", mBody);
    NSLog(@"  image : %@", mImage);
}


@end
