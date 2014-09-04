
#import <Foundation/Foundation.h>

@interface ClinicInfo : NSObject {
    NSString* mClinicName;
    NSMutableArray* mClinicPages;
}

// setters

- (void) setClinicName:  (NSString*) clinicName;
- (void) addPage: (NSString*) page;

// getters

- (NSString*) getClinicName;
- (NSMutableArray*) getClinicPages;


// writers

- (void)    writeToLog;
- (Boolean) writeToDB;
- (NSMutableDictionary*) writeToDictionary;

@end
