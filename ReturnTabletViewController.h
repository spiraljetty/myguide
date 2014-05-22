//
//  ReturnTabletViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 2/7/13.
//
//

#import <UIKit/UIKit.h>

@interface ReturnTabletViewController : UIViewController {
    IBOutlet NSString *textToShow;
    
    IBOutlet UILabel *textLabel;
}

@property (nonatomic, retain) IBOutlet NSString *textToShow;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

@end
