//
//  ReturnTabletViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 2/7/13.
//
//

#import "ReturnTabletViewController.h"

@interface ReturnTabletViewController ()

@end

@implementation ReturnTabletViewController

@synthesize textToShow, textLabel;

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
    
    textLabel.text = textToShow;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
