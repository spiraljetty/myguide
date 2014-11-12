//
//  EdModuleInfo.m
//  satisfaction_survey
//
//  Created by Richard Levinson on 11/11/14.
//
//

#import "EdModuleInfo.h"

@implementation EdModuleInfo

-(id)init {
    self = [super init];
    if (self) {
        [self setModuleName:@""];
        mPages = [[NSMutableArray alloc]init];
        mClinics = [[NSMutableArray alloc]init];
    }
    return self;
}
// setters

-(void) setModuleName:(NSString *)moduleName{
    mModuleName = moduleName;
}


-(void) setModuleImage:(NSString *)moduleImage{
    mModuleImage = moduleImage;
}


-(void) setPages:(NSMutableArray *)pages{
    mPages = pages;
}

- (void) addPage:(EdModulePage*) newPage {
    NSLog(@"EdModuleInfo.addPage() module: %@, page: %@", [self  getModuleName], newPage);
    [mPages addObject:newPage];
}

-(void) setClinics:(NSMutableArray *)clinics{
    mClinics = clinics;
}

//- (void) addClinic:(NSDictionary*) newClinic {
//    NSLog(@"EdModuleInfo.addClinic() : %@, page: %@", [self  getModuleName], newClinic);
//    [[self getPages] addObject:newClinic];
//}


// getters
-(NSString*) getModuleName {
    return mModuleName;
}

-(NSMutableArray*) getPages {
    return mPages;
}

-(NSMutableArray*) getClinics {
    return mClinics;
}

-(NSString*) getModuleImage {
    // NSString* imageFilename = [NSString stringWithFormat:@"%@.png", mClinicNameShort];
    return mModuleImage;
}




// writers


- (void) writeToLog {
    NSLog(@"[Ed module: %@", mModuleName);
    NSLog(@"     image: %@", mModuleImage);
    NSLog(@"   clinics: %@", mClinics);
    for (EdModulePage* page in [self  getPages]){
        [page writeToLog];
    }
    NSLog(@"]");
}

- (void) sortPages {
    [mPages sortUsingSelector:@selector(compareWithAnotherPage:)];
}



- (NSMutableDictionary*) writeToDictionary {
    [self writeToLog];
    NSMutableDictionary *rootObj = [NSMutableDictionary dictionaryWithCapacity:25];
    NSString *moduleName = [self getModuleName];
    NSString *moduleImage = [self getModuleImage];
    NSMutableArray *pages = [self getPages];
    NSMutableArray *clinics = [self getClinics];
    
    if (moduleName)
        [rootObj setObject:moduleName forKey:@"name"];
    if (moduleImage)
            [rootObj setObject:moduleImage forKey:@"image"];
    if (pages)
        [rootObj setObject:pages forKey:@"pages"];
    if (clinics)
        [rootObj setObject:clinics forKey:@"clinics"];
    
    return rootObj;
}


@end
