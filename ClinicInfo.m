//
//  ClinicInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 9/4/14.
//
//

#import "ClinicInfo.h"

@implementation ClinicInfo

-(id)init {
    self = [super init];
    if (self) {
        [self setClinicName:@""];
        mClinicPages = [[NSMutableArray alloc]init];
    }
    return self;
}
// setters

-(void) setClinicName:(NSString *)clinicName{
    mClinicName = clinicName;
}

-(void) setClinicNameShort:(NSString *)clinicNameShort{
    mClinicNameShort = clinicNameShort;
}

-(void) setSubclinicName:(NSString *)clinicName{
    mSubclinicName = clinicName;
}

-(void) setSubclinicNameShort:(NSString *)clinicNameShort{
    mSubclinicNameShort = clinicNameShort;
}

-(void) setClinicImage:(NSString *)imageFilename{
    mClinicImage = imageFilename;
}


//-(void) setClinicPages:(NSString *)clinicPages{
//    mClinicPages = clinicPages;
//}

- (void) addPage:(NSDictionary*) clinicPage {
    NSLog(@"ClinicInfo.addPage() clinic: %@, page: %@", [self  getClinicName], clinicPage);
    [[self getClinicPages] addObject:clinicPage];
}


// getters
-(NSString*) getClinicName {
    return mClinicName;
}

-(NSString*) getClinicNameShort {
    return mClinicNameShort;
}

-(NSString*) getSubclinicName {
    return mSubclinicName;
}

-(NSString*) getSubclinicNameShort {
    return mSubclinicNameShort;
}

-(NSString*) getClinicSubclinicComboName {
    NSString* result = NULL;
    if (mSubclinicNameShort != NULL && [mSubclinicNameShort length] > 0){
        result = [NSString stringWithFormat:@"%@-%@", mClinicNameShort, mSubclinicNameShort];
    }
    else
        result = mClinicNameShort;
    return
        result;
}

-(NSMutableArray*) getClinicPages {
    return mClinicPages;
}

-(NSString*) getClinicImage {
   // NSString* imageFilename = [NSString stringWithFormat:@"%@.png", mClinicNameShort];
    return mClinicImage;
}

-(NSString*) getPageImageFilename:(int) pageNumber {
    NSString* clinicNameLowerCase = [mClinicNameShort lowercaseString];
    NSString* imageFilename = [NSString stringWithFormat:@"%@_%d.png", clinicNameLowerCase, pageNumber];
    return imageFilename;
}



// writers


- (void) writeToLog {
    NSLog(@"[Clinic: %@, Clinic short: %@, Subclinic: %@, Subclinic short: %@", mClinicName, mClinicNameShort, mSubclinicName, mSubclinicNameShort);
    int i = 1;
    for (NSDictionary* page in [self  getClinicPages]){
        NSLog(@"  page %d: %@",i++, page);
    }
    NSLog(@"]");
}


-(Boolean) writeToDB {
    NSLog(@"[Clinic: %@", mClinicName);
    int i = 1;
    for (NSString* page in mClinicPages){
        NSLog(@" %d: %@",i++, page);
    }
    NSLog(@"]");
    return true;
}

- (NSMutableDictionary*) writeToDictionary {
    [self writeToLog];
    NSMutableDictionary *rootObj = [NSMutableDictionary dictionaryWithCapacity:15];
    NSString *clinicName = [self getClinicName];
    NSMutableArray *clinicPages = [self getClinicPages];
    
    if (clinicName)
        [rootObj setObject:clinicName forKey:@"Clinic Name"];
    if (clinicPages)
        [rootObj setObject:clinicPages forKey:@"Clinic Pages"];
    
    return rootObj;
}



@end
