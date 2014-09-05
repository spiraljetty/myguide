
#import <Foundation/Foundation.h>

@interface ClinicInfo : NSObject {
    NSString* mClinicName;
    NSString* mClinicNameShort;
    NSMutableArray* mClinicPages;
}

// setters
- (void) setClinicName:  (NSString*) clinicName;
- (void) setClinicNameShort:  (NSString*) clinicNameShort;
- (void) addPage: (NSMutableDictionary*) page;

// getters

- (NSString*) getClinicName;
- (NSString*) getClinicNameShort;
- (NSString*) getClinicImageFilename;
- (NSString*) getPageImageFilename:(int) pageNumber;
- (NSMutableArray*) getClinicPages;


// writers

- (void)    writeToLog;
- (Boolean) writeToDB;
- (NSMutableDictionary*) writeToDictionary;

@end
