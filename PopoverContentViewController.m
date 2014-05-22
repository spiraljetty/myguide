//
//  PopoverContentViewController.m
//  PopoverPlayground
//
//  Created by John E. Ray on 4/10/10.
//  Copyright 2010 John E. Ray. All rights reserved.
//

#define componentCount 2
#define animalComponent 0
#define soundComponent 1

#import "PopoverContentViewController.h"
#import "AppDelegate_Pad.h"
#import "DemoViewController.h"


@implementation PopoverContentViewController

@synthesize lastAction, adminMenuButton, sendDataButton, appVersionLabel;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return componentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component {
	if (component==animalComponent) {
		return [animalNames count];
	} else {
		return [animalSounds count];
	}
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row 
		  forComponent:(NSInteger)component reusingView:(UIView *)view {
	if (component==animalComponent) {
		return [animalImages objectAtIndex:row];
	} else {
		UILabel *soundLabel;
		soundLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,100,32)];
		[soundLabel autorelease];
		soundLabel.backgroundColor=[UIColor clearColor];
		soundLabel.text=[animalSounds objectAtIndex:row];
		return soundLabel;
	}
}


/*
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component==animalComponent) {
		return [animalNames objectAtIndex:row];
	} else {
		return [animalSounds objectAtIndex:row];
	}

}
*/

- (CGFloat)pickerView:(UIPickerView *)pickerView 
rowHeightForComponent:(NSInteger)component {
	return 55.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	if (component==animalComponent) {
		return 75.0;
	} else {
		return 150.0;
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row 
	   inComponent:(NSInteger)component {
	NSString *actionMessage;
	
	if (component==animalComponent) {
		actionMessage=[[NSString alloc] 
					   initWithFormat:@"You selected the animal named '%@'",
                       [animalNames objectAtIndex:row]];
	} else {
		actionMessage=[[NSString alloc] 
					   initWithFormat:@"You selected the animal sound '%@'",
					   [animalSounds objectAtIndex:row]];
	}
		
	lastAction.text=actionMessage;
	
	[actionMessage release];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//    animalNames=[[NSArray alloc]initWithObjects:
//				 @"Mouse",@"Goose",@"Cat",@"Dog",@"Snake",@"Bear",@"Pig",nil];
//	animalSounds=[[NSArray alloc]initWithObjects:
//				  @"Oink",@"Rawr",@"Ssss",@"Roof",@"Meow",@"Honk",@"Squeak",nil];
//	animalImages=[[NSArray alloc]initWithObjects:
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mouse.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goose.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dog.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snake.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bear.png"]],
//                  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pig.png"]],
//                  nil
//				  ];
//    lastAction = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 150)];
//    lastAction.frame = CGRectMake(50, 50, 250, 75);
//    lastAction.text=[NSString stringWithFormat:@"Polytrauma Waiting Room App v%@",[[AppDelegate_Pad sharedAppDelegate] appVersion]];
//	lastAction.textAlignment = UITextAlignmentCenter;
//	lastAction.textColor = [UIColor blackColor];
//	lastAction.backgroundColor = [UIColor clearColor];
//    lastAction.font = [UIFont fontWithName:@"Arial" size:20];
//	lastAction.opaque = YES;
//    //	[readAloudLabel sizeToFit];
//    //    [readAloudLabel adjustsFontSizeToFitWidth];
////	[lastAction setCenter:CGPointMake(670.0f, 512.0f)];
//    [self.view addSubview:lastAction];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    //adminMenuButton
    adminMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	adminMenuButton.frame = CGRectMake(100, 100, 258, 182);
	adminMenuButton.showsTouchWhenHighlighted = YES;
	[adminMenuButton setImage:[UIImage imageNamed:@"admin_button_image.png"] forState:UIControlStateNormal];
	[adminMenuButton setImage:[UIImage imageNamed:@"admin_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[adminMenuButton setImage:[UIImage imageNamed:@"admin_button_image_pressed.png"] forState:UIControlStateSelected];
	adminMenuButton.backgroundColor = [UIColor clearColor];
	[adminMenuButton setCenter:CGPointMake(200.0f, 200.0f)];
    [adminMenuButton addTarget:self action:@selector(adminButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	adminMenuButton.enabled = YES;
	adminMenuButton.hidden = NO;
//    adminMenuButton.alpha = 0.0;
	[adminMenuButton retain];
//    adminMenuButton.transform = rotateRight;
    
    [self.view addSubview:adminMenuButton];
    
    //appVersionLabel
    appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
//	appVersionLabel.text = @"Waiting for connection...";
    appVersionLabel.text = [NSString stringWithFormat:@"Polytrauma Waiting Room App v%@\nRunning on %@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] appVersion],[[UIDevice currentDevice] name]];	appVersionLabel.textAlignment = UITextAlignmentCenter;
    appVersionLabel.numberOfLines = 0;
	appVersionLabel.textColor = [UIColor blackColor];
	appVersionLabel.backgroundColor = [UIColor clearColor];
	appVersionLabel.opaque = YES;
//	[appVersionLabel sizeToFit];
	[appVersionLabel setCenter:CGPointMake(200.0f, 350.0f)];
	appVersionLabel.alpha = 1.0;
    
    [self.view addSubview:appVersionLabel];
    
    //sendDataButton
    sendDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendDataButton.frame = CGRectMake(100, 100, 258, 182);
	sendDataButton.showsTouchWhenHighlighted = YES;
	[sendDataButton setImage:[UIImage imageNamed:@"senddata_button_image.png"] forState:UIControlStateNormal];
	[sendDataButton setImage:[UIImage imageNamed:@"senddata_button_image_pressed.png"] forState:UIControlStateHighlighted];
	[sendDataButton setImage:[UIImage imageNamed:@"senddata_button_image_pressed.png"] forState:UIControlStateSelected];
	sendDataButton.backgroundColor = [UIColor clearColor];
    //	[adminMenuButton setCenter:CGPointMake(100.0f, 171.0f)];
    [sendDataButton addTarget:self action:@selector(sendDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	sendDataButton.enabled = YES;
	sendDataButton.hidden = NO;
    sendDataButton.alpha = 0.0;
	[sendDataButton retain];
    //    adminMenuButton.transform = rotateRight;
    
    [self.view addSubview:sendDataButton];
    [self.view sendSubviewToBack:sendDataButton];
    
	self.contentSizeForViewInPopover=CGSizeMake(400.0,400.0);
    [super viewDidLoad];
}

- (void)adminButtonPressed:(id)sender {
    NSLog(@"Admin Button Pressed...");
//    [[AppDelegate_Pad sharedAppDelegate] showAdminKeypad];
    float angle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(angle);
    keyboardViewController = [[DemoViewController alloc] init];
    keyboardViewController.view.frame = CGRectMake(0, 0, 400, 400);
//    keyboardViewController.view.transform = rotateLeft;
    keyboardViewController.view.alpha = 0.0;
    [self.view addSubview:keyboardViewController.view];
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        adminMenuButton.alpha = 0.0;
        keyboardViewController.view.alpha = 1.0;
		
	}
	[UIView commitAnimations];
}

- (void)showSendDataButton:(id)sender {
    
    [self.view bringSubviewToFront:sendDataButton];

    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
        sendDataButton.alpha = 1.0;
		
	}
	[UIView commitAnimations];
}

- (void)sendDataButtonPressed:(id)sender {
    sendDataButton.enabled = NO;
//    [[AppDelegate_Pad sharedAppDelegate] adminSendDataButtonPressed:sender];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminSendDataButtonPressed:sender];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [animalNames release];
	[animalSounds release];
	[animalImages release];
	[lastAction release];
    [super dealloc];
}


@end
