//
//  PhysicianSubDetailViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 1/6/13.
//
//

#import "PhysicianSubDetailViewController.h"

@interface PhysicianSubDetailViewController ()

@end

@implementation PhysicianSubDetailViewController

@synthesize physicianHeaderLabel, physicianSubDetailSectionLabel, headerLabelText, subDetailSectionLabelText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *longSectionPrefix = @"~";
        if ([headerLabelText hasPrefix:longSectionPrefix]) {
            physicianHeaderLabel.text = [headerLabelText substringFromIndex:[longSectionPrefix length]];
        } else {
            physicianHeaderLabel.text = headerLabelText;
        }
        
        physicianHeaderLabel.text = headerLabelText;
        
        physicianSubDetailSectionLabel.text = subDetailSectionLabelText;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    physicianHeaderLabel.text = headerLabelText;
    physicianSubDetailSectionLabel.text = subDetailSectionLabelText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
