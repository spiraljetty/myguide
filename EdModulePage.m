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
    NSString* thisPage = [self getPageNumber];
    NSString* otherPage = [anotherPage getPageNumber];
    int thisPageNumber = thisPage.intValue;
    int otherPageNumber = otherPage.intValue;
    int result = -1;
    if (thisPageNumber > otherPageNumber)
        result = 1;
    else
    if (thisPageNumber == otherPageNumber)
        result = 0;
    NSComparisonResult comparisonResult = result; //[thisPageNumber compare:otherPageNumber];
    NSLog(@"EdModulePage.compareWithAnotherPage() thisPage: %d, otherPage: %d, result: %ld", thisPageNumber, otherPageNumber, comparisonResult);
    return comparisonResult;//[[self getPageNumber] compare:[anotherPage getPageNumber]];
}



@end
