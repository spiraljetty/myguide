//
//  PopoverPlaygroundViewController.h
//  PopoverPlayground
//
//  Created by John E. Ray on 4/10/10.
//  Copyright John E. Ray 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverContentViewController.h"


@interface PopoverPlaygroundViewController : UIViewController <UIPopoverControllerDelegate> {
	UIPopoverController *popoverController;
    IBOutlet	PopoverContentViewController *popoverContent;
}

@property (retain,nonatomic) PopoverContentViewController *popoverContent;

-(IBAction)showPopover:(id)sender;
- (void)showTheSendDataButton;
@end

