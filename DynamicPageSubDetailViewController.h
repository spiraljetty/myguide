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
    
    BOOL needsImage;
    IBOutlet UIImageView *dynamicImageView;
    NSString *currentImageFilename;
    
    NSString *headerLabelText;
    NSString *subDetailSectionLabelText;
}

@property BOOL needsImage;
@property (nonatomic, retain) NSString *currentImageFilename;

@property (nonatomic, retain) IBOutlet UIImageView *dynamicImageView;

@property (nonatomic, retain) IBOutlet UILabel *dynamicPageHeaderLabel;
@property (nonatomic, retain) IBOutlet UILabel *dynamicPageSubDetailSectionLabel;

@property (nonatomic, retain) NSString *headerLabelText;
@property (nonatomic, retain) NSString *subDetailSectionLabelText;

@end
