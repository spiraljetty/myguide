/*
 * KeyboardExtension
 *
 * Copyright 2008-2010 Neoos GmbH. All rights reserved.
 *
 */

#import "DemoViewController.h"
#import "PopoverContentViewController.h"
#import "AppDelegate_Pad.h"


@implementation DemoViewController

@synthesize passwordButton;

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
	passwordButton.frame = CGRectMake(0, 0, 150, 60);
	passwordButton.showsTouchWhenHighlighted = YES;
    [passwordButton setTitle:@"Try Keycode" forState:UIControlStateNormal];
    passwordButton.titleLabel.textColor = [UIColor whiteColor];
//    [passwordButton setImage:[UIImage imageNamed:@"yes_button_image.png"] forState:UIControlStateNormal];
//	[passwordButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateHighlighted];
//	[passwordButton setImage:[UIImage imageNamed:@"yes_button_image_pressed2.png"] forState:UIControlStateSelected];
	passwordButton.backgroundColor = [UIColor redColor];
	[passwordButton setCenter:CGPointMake(200.0f, 100.0f)];
	[passwordButton addTarget:self action:@selector(passwordPressed:) forControlEvents:UIControlEventTouchUpInside];
	passwordButton.enabled = YES;
	passwordButton.hidden = NO;
//    passwordButton.alpha = 0.0;
	[passwordButton retain];
//    passwordButton.transform = rotateRight;
    
    [self.view addSubview:passwordButton];
    
    correctTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 160, 200, 26)];
    correctTextField.borderStyle = UITextBorderStyleNone;
//    correctTextField.keyboardType = UIKeyboardTypeNumberPad;
//    correctTextField.returnKeyType = UIReturnKeyDone;
    correctTextField.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:correctTextField];

    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 26)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = UITextAlignmentLeft;
    textField.text = @"";
    [self.view addSubview:textField];
    
	// add observer for the respective notifications (depending on the os version)
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardDidShow:) 
													 name:UIKeyboardDidShowNotification 
												   object:nil];		
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
	}
    
//    textField.delegate=self;
    [textField becomeFirstResponder];
    correctTextField.text = @"Enter admin keycode...";
	
}

- (void)addButtonToKeyboard {
	// create custom button
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0, 163, 106, 53);
	doneButton.adjustsImageWhenHighlighted = NO;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
		[doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
	} else {        
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
	}
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
	// locate keyboard view
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
				[keyboard addSubview:doneButton];
		} else {
			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
				[keyboard addSubview:doneButton];
		}
	}
}

- (void)keyboardWillShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
//		[self addButtonToKeyboard];
	}
}

- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//		[self addButtonToKeyboard];
    }
}


- (void)doneButton:(id)sender {
	NSLog(@"doneButton");
    NSLog(@"Input: %@", textField.text);
    [textField resignFirstResponder];
    
    [self checkIfCorrectPassword];
}

- (void)checkIfCorrectPassword {
    
    if ([textField.text isEqualToString:@"3801"]) {
        correctTextField.text = @"Correct!";
//        [[AppDelegate_Pad sharedAppDelegate] adminShowSendDataButton];
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminShowSendDataButton];
    } else {
        correctTextField.text = @"Try again...";
    }
    
    [self clearTextField];
}

- (void)clearTextField {
    textField.text = @"";
}

- (void)passwordPressed:(id)sender {
//    textField.editable = YES;
//    textField.
//    NSLog(@"password button");
//    [textField becomeFirstResponder];
    
    NSLog(@"Input: %@", textField.text);
    [textField resignFirstResponder];
    
    [self checkIfCorrectPassword];
    
//    correctTextField.text = @"Pending...";
    
}

#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *validRegEx =@"^[0-9]*$"; //change this regular expression as your requirement
    NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
    if (myStringMatchesRegEx)
        return YES;
    else
        return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textField release];
    [super dealloc];
}


@end
