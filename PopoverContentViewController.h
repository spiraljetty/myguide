//
//  PopoverContentViewController.h
//  PopoverPlayground
//
//  Created by John E. Ray on 4/10/10.
//  Copyright 2010 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoViewController;


@interface PopoverContentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	NSArray *animalNames;
	NSArray *animalSounds;
	NSArray *animalImages;
	IBOutlet UILabel *lastAction;
    IBOutlet UIButton *adminMenuButton;
    IBOutlet UIButton *sendDataButton;
    DemoViewController *keyboardViewController;
    UILabel *appVersionLabel;
}

@property (nonatomic, retain) UILabel *appVersionLabel;
@property (nonatomic, retain) UILabel *lastAction;
@property (nonatomic, retain) IBOutlet UIButton *adminMenuButton;
@property (nonatomic, retain) IBOutlet UIButton *sendDataButton;

- (void)adminButtonPressed:(id)sender;
- (void)sendDataButtonPressed:(id)sender;
- (void)showSendDataButton:(id)sender;

@end
