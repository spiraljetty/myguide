//
//  ModalMeViewController.m
//  ModalMe
//
//  Created by John Ray on 5/5/10.
//  Copyright Poisontooth Enterprises 2010. All rights reserved.
//

#import "ModalMeViewController.h"

@implementation ModalMeViewController

@synthesize modalContent;
@synthesize presentationStyle;
@synthesize transitionStyle;
@synthesize outputLabel;

-(IBAction) showModal:(id)sender {
    outputLabel.text=@"Nothing Chosen";
    switch (transitionStyle.selectedSegmentIndex) {
        case 0:
            modalContent.modalTransitionStyle=
                        UIModalTransitionStyleCoverVertical;
            break;
        case 1:
            modalContent.modalTransitionStyle=
                        UIModalTransitionStyleFlipHorizontal;
            break;
        case 2:
            modalContent.modalTransitionStyle=
                        UIModalTransitionStyleCrossDissolve;
            break;
        default:
            modalContent.modalTransitionStyle=
                        UIModalTransitionStylePartialCurl;
            break;
    }
    switch (presentationStyle.selectedSegmentIndex) {
        case 0:
            modalContent.modalPresentationStyle=
                        UIModalPresentationFullScreen;
            break;
        case 1:
            modalContent.modalPresentationStyle=
                        UIModalPresentationPageSheet;
            break;
        default:
            modalContent.modalPresentationStyle=
                        UIModalPresentationFormSheet;
            break;
    }
	[self presentModalViewController:modalContent animated:YES];
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
    [modalContent release];
    [presentationStyle release];
    [transitionStyle release];
    [outputLabel release];
    [super dealloc];
}

@end
