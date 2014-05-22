//
//  DynamicPageDetailViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 1/17/13.
//
//

#import <UIKit/UIKit.h>

@interface DynamicPageDetailViewController : UIViewController {
//    IBOutlet UIImageView *physicianImageView;
    IBOutlet UILabel *dynamicModuleNameLabel;
    NSString *dynamicModuleName;
    
    NSTimer *physicianTimer;
//    IBOutlet UILabel *todayCareHandledByLabel;
}

//@property (nonatomic, retain) IBOutlet UIImageView *physicianImageView;
@property (nonatomic, retain) IBOutlet UILabel *dynamicModuleNameLabel;
@property (nonatomic, retain) NSString *dynamicModuleName;

@property (nonatomic, retain) NSTimer *physicianTimer;
//@property (nonatomic, retain) IBOutlet UILabel *todayCareHandledByLabel;



@end
