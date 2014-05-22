//
//  PopoverPlaygroundViewController.m
//  PopoverPlayground
//
//  Created by John E. Ray on 4/10/10.
//  Copyright John E. Ray 2010. All rights reserved.
//

#import "PopoverPlaygroundViewController.h"
#import "PopoverContentViewController.h"


@implementation PopoverPlaygroundViewController

@synthesize popoverContent;


-(IBAction)showPopover:(id)sender {
	if (popoverController==nil) {
		popoverController=[[UIPopoverController alloc] initWithContentViewController:popoverContent];
        [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		popoverController.delegate=self;
	}
}


- (void)showTheSendDataButton {
//    [popoverController
    [popoverContent showSendDataButton:self];
}


-(void)popoverControllerDidDismissPopover:(UIPopoverController *)controller {
	[popoverController release];
	popoverController=nil;
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[popoverContent release];
    [super dealloc];
}

@end
