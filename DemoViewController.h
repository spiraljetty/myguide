/*
 * KeyboardExtension
 *
 * Copyright 2008-2010 Neoos GmbH. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>


@interface DemoViewController : UIViewController <UITextFieldDelegate> {
    UITextField *textField;
    
    UITextField *correctTextField;
    
    IBOutlet UIButton *passwordButton;
}

@property (nonatomic, retain) IBOutlet UIButton *passwordButton;

- (IBAction)passwordPressed:(id)sender;


@end
