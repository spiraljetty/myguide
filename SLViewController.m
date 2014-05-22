//
//  SLViewController.m
//  SLGlowingTextField
//
//  Created by Aaron Brethorst on 12/4/12.
//  Copyright (c) 2012 Structlab. All rights reserved.
//

#import "SLViewController.h"

@interface SLViewController ()

@end

@implementation SLViewController

@synthesize enterGoalTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    enterGoalTextField.borderStyle = UITextBorderStyleNone;
//    enterGoalTextField.clipsToBounds = YES;
//
//		enterGoalTextField.backgroundColor = [UIColor whiteColor];
//
//		UIColor *glowingColor = [UIColor colorWithRed:(82.f / 255.f) green:(168.f / 255.f) blue:(236.f / 255.f) alpha:0.8];
//
//		UIColor *borderColor = [UIColor lightGrayColor];
//	
//    enterGoalTextField.v
//    
//    enterGoalTextField.view.layer.masksToBounds = NO;
//    enterGoalTextField.layer.cornerRadius = 4.f;
//    enterGoalTextField.layer.borderWidth = 1.f;
//    enterGoalTextField.layer.borderColor = enterGoalTextField.glowingColor.CGColor;
//	
//    enterGoalTextField.layer.shadowColor = enterGoalTextField.glowingColor.CGColor;
//    enterGoalTextField.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:enterGoalTextField.bounds cornerRadius:4.f].CGPath;
//    enterGoalTextField.layer.shadowOpacity = 1.0;
//    enterGoalTextField.layer.shadowOffset = CGSizeZero;
//    enterGoalTextField.layer.shadowRadius = 5.f;
//    enterGoalTextField.layer.shouldRasterize = YES;
//    enterGoalTextField.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resignFirstResponder:(id)sender
{
    [self.view endEditing:YES];
    
}

@end
