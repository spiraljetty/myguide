//
//  DynamicPageSubDetailViewController.h
//  satisfaction_survey
//
//  Created by David Horton on 1/17/13.
//
//

#import <UIKit/UIKit.h>

@interface DynamicPageSubDetailViewController : UIViewController {
    IBOutlet UILabel *dynamicPageHeaderLabel;
    IBOutlet UILabel *dynamicPageSubDetailSectionLabel;
    
    NSString *headerLabelText;
    NSString *subDetailSectionLabelText;
}

@property (nonatomic, retain) IBOutlet UILabel *dynamicPageHeaderLabel;
@property (nonatomic, retain) IBOutlet UILabel *dynamicPageSubDetailSectionLabel;

@property (nonatomic, retain) NSString *headerLabelText;
@property (nonatomic, retain) NSString *subDetailSectionLabelText;

@end
