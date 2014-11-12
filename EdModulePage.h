//
//  EdModulePage.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/11/14.
//
//

#import <Foundation/Foundation.h>

@interface EdModulePage : NSObject {
    NSString* mModuleName; // the module this page belongs to
    NSString* mModuleImage; // the image for the module this page belongs to
    NSString* mHeader;
    NSString* mBody;
    NSString* mImage; // page image
    NSString* mClinics;
    NSString* mPageNumber;
}

- (void) setModuleName:(NSString*) moduleName;
- (void) setModuleImage:(NSString*) moduleImage;
- (void) setHeader:(NSString*) header;
- (void) setBody:(NSString*) body;
- (void) setImage:(NSString*) image;
- (void) setClinics:(NSString*) clinics;
- (void) setPageNumber:(NSString*) pageNumber;

- (NSString*) getModuleName;
- (NSString*) getModuleImage;
- (NSString*) getHeader;
- (NSString*) getBody;
- (NSString*) getImage;
- (NSString*) getClinics;
- (NSString*) getPageNumber;

- (NSComparisonResult) compareWithAnotherPage:(EdModulePage*) anotherPage;
- (void) writeToLog;

@end
