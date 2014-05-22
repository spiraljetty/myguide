//
//  MyContentViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 11/4/12.
//
//

#import "MyContentViewController.h"

@interface MyContentViewController ()

@end

@implementation MyContentViewController

-(IBAction) hideModal:(id)sender {
//    [[self.parentViewController outputLabel] setText:[sender currentTitle]];
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
