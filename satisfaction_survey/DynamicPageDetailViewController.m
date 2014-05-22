//
//  DynamicPageDetailViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 1/17/13.
//
//

#import "DynamicPageDetailViewController.h"
#import "AppDelegate_Pad.h"

@interface DynamicPageDetailViewController ()

@end

@implementation DynamicPageDetailViewController

@synthesize dynamicModuleNameLabel, physicianTimer, dynamicModuleName;
//@synthesize physicianImageView, todayCareHandledByLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        dynamicModuleNameLabel.text = dynamicModuleName;
        
//        physicianImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianImage]]];
//        physicianNameLabel.text = [NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    physicianImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianImage]]];
    
    dynamicModuleNameLabel.text = dynamicModuleName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
