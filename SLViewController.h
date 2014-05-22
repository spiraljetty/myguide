//
//  SLViewController.h
//  SLGlowingTextField
//
//  Created by Aaron Brethorst on 12/4/12.
//  Copyright (c) 2012 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLViewController : UIViewController {
    IBOutlet UITextField *enterGoalTextField;
}

@property (nonatomic, retain) IBOutlet UITextField *enterGoalTextField;

- (IBAction)resignFirstResponder:(id)sender;
@end
