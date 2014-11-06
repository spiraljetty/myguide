
#import <Foundation/Foundation.h>

@interface ClinicInfo : NSObject {
    NSString* mClinicName;
    NSString* mClinicNameShort;
    NSString* mSubclinicName;
    NSString* mSubclinicNameShort;
    NSString* mClinicImage;
    NSMutableArray* mClinicPages;
}

// setters
- (void) setClinicName:  (NSString*) clinicName;
- (void) setClinicNameShort:  (NSString*) clinicNameShort;
- (void) setSubclinicName:  (NSString*) subclinicName;
- (void) setSubclinicNameShort:  (NSString*) subclinicNameShort;
- (void) setClinicImage:  (NSString*) clinicIcon;
- (void) addPage: (NSMutableDictionary*) page;

// getters

- (NSString*) getClinicName;
- (NSString*) getClinicNameShort;
- (NSString*) getSubclinicName;
- (NSString*) getSubclinicNameShort;
- (NSString*) getClinicImage;
- (NSString*) getPageImageFilename:(int) pageNumber;
- (NSMutableArray*) getClinicPages;


// writers

- (void)    writeToLog;
- (Boolean) writeToDB;
- (NSMutableDictionary*) writeToDictionary;

@end
