//
//  EdModulePage.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/11/14.
//
//

#import "EdModulePage.h"

@implementation EdModulePage

-(id)init {
    self = [super init];
    if (self) {
        [self setModuleName:@""];
        [self setModuleImage:@""];
        [self setHeader:@""];
        [self setBody:@""];
        [self setImage:@""];
        [self setClinics:@""];
        [self setPageNumber:@"0"];
    }
    return self;
}

- (void) setModuleName:(NSString*) moduleName {
    mModuleName = [moduleName copy]; // the module which this page belongs to
}

- (void) setModuleImage:(NSString*) moduleImage {
    mModuleImage = [moduleImage copy]; // the module which this page belongs to
}


- (void) setHeader:(NSString*) header {
    mHeader = [header copy];
}

- (void) setBody:(NSString*) body {
    mBody = [body copy];
}

- (void) setImage:(NSString*) image {
    mImage = [image copy];
}

- (void) setClinics:(NSString*) clinics {
    mClinics = [clinics copy];
}


- (void) setPageNumber:(NSString*) pageNumber {
    mPageNumber = [pageNumber copy];
}


- (NSString*) getHeader {
    return mHeader;
}

- (NSString*) getModuleName {
    return mModuleName;
}

- (NSString*) getModuleImage {
    return mModuleImage;
}

- (NSString*) getBody {
    return mBody;
}

- (NSString*) getImage {
    return mImage;
}

- (NSString*) getClinics {
    return mClinics;
}

- (NSString*) getPageNumber {
    return mPageNumber;
}

- (void) writeToLog {
    NSLog(@"[Ed module %@ page %@:", mModuleName, mPageNumber);
    NSLog(@"  header: %@", mHeader);
    NSLog(@"  body  : %@", mBody);
    NSLog(@"  image : %@", mImage);
    NSLog(@"  moduleImage: %@", mModuleImage);
    NSLog(@"  clincs: %@]", mClinics);
}

- (NSComparisonResult) compareWithAnotherPage:(EdModulePage*) anotherPage{
    return [[self getPageNumber] compare:[anotherPage getPageNumber]];
}



@end
