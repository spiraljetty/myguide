//
//  DynamicPageSubDetailViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 1/17/13.
//
//

#import "DynamicPageSubDetailViewController.h"

@interface DynamicPageSubDetailViewController ()

@end

@implementation DynamicPageSubDetailViewController

@synthesize dynamicPageHeaderLabel, dynamicPageSubDetailSectionLabel, headerLabelText, subDetailSectionLabelText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dynamicPageHeaderLabel.text = headerLabelText;
        dynamicPageSubDetailSectionLabel.text = subDetailSectionLabelText;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    dynamicPageHeaderLabel.text = headerLabelText;
    dynamicPageSubDetailSectionLabel.text = subDetailSectionLabelText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
