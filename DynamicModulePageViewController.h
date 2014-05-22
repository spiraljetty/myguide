//
//  DynamicModulePageViewController.h
//  satisfaction_survey
//
//  Created by David Horton on 1/17/13.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DynamicPageDetailViewController.h"
#import "DynamicPageSubDetailViewController.h"

@protocol DynamicModulePageDelegate <NSObject>

@required
//- (void)receivedAudio:(NSMutableData *)data;
//- (void)sentAudioRequest;
@end

@interface DynamicModulePageViewController : UIViewController {
    
    id <DynamicModulePageDelegate> delegate;
    
    BOOL isSurveyPage;
    
    NSString *name;
    NSString *type;
    BOOL imagePage;
    NSString *imageFilename;
    BOOL showHeader;
    UIColor *headerColor;
    NSString *headerText;
    NSString *headerTTSFilenamePrefix;
    NSString *showButtonsFor;
    NSString *text;
    NSString *TTSFilenamePrefix;
    BOOL containsTerminology;
    NSMutableArray *terminologyButtons;
    
    DynamicPageDetailViewController *dynamicPageHeader;
    DynamicPageSubDetailViewController *dynamicPageSubDetail;
}
@property BOOL isSurveyPage;

@property (nonatomic, retain) id <DynamicModulePageDelegate> delegate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property BOOL imagePage;
@property (nonatomic, retain) NSString *imageFilename;
@property BOOL showHeader;
@property (nonatomic, retain) UIColor *headerColor;
@property (nonatomic, retain) NSString *headerText;
@property (nonatomic, retain) NSString *headerTTSFilenamePrefix;
@property (nonatomic, retain) NSString *showButtonsFor;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *TTSFilenamePrefix;
@property BOOL containsTerminology;
@property (nonatomic, retain) NSMutableArray *terminologyButtons;

@property (nonatomic, retain) DynamicPageDetailViewController *dynamicPageHeader;
@property (nonatomic, retain) DynamicPageSubDetailViewController *dynamicPageSubDetail;

- (id)initWithDictionary:(NSDictionary *)pageDictionary;
- (void)setPageHeaderColorTo:(UIColor *)thisColor;
- (void)setHeaderContent;
- (void)setSubDetailContent;

@end
