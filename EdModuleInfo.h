//
//  EdModuleInfo.h
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/11/14.
//
//

#import <Foundation/Foundation.h>
#import "EdMOdulePage.h"

@interface EdModuleInfo : NSObject {
    NSString* mModuleName;
    NSString* mModuleImage;
    NSString* mClinics;
    NSMutableArray* mPages;
}

// setters
- (void) setModuleName:  (NSString*) moduleName;
- (void) setModuleImage:  (NSString*) moduleImage;
- (void) setClinics:  (NSString*) clinics;
- (void) addPage: (EdModulePage*) page;

// getters

- (NSString*) getModuleName;
- (NSString*) getModuleImage;
- (NSString*) getClinics;
- (NSMutableArray*) getPages;


// writers
- (void) sortPages;
- (void) writeToLog;
- (NSMutableDictionary*) writeToDictionary;
@end
