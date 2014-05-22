//
//  PhysicianSubDetailViewController.h
//  satisfaction_survey
//
//  Created by David Horton on 1/6/13.
//
//

#import <UIKit/UIKit.h>

@interface PhysicianSubDetailViewController : UIViewController {
    IBOutlet UILabel *physicianHeaderLabel;
    IBOutlet UILabel *physicianSubDetailSectionLabel;
    
    NSString *headerLabelText;
    NSString *subDetailSectionLabelText;
}

@property (nonatomic, retain) IBOutlet UILabel *physicianHeaderLabel;
@property (nonatomic, retain) IBOutlet UILabel *physicianSubDetailSectionLabel;

@property (nonatomic, retain) NSString *headerLabelText;
@property (nonatomic, retain) NSString *subDetailSectionLabelText;

@end
