//
//  PhysicianDetailViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 1/5/13.
//
//

#import "PhysicianDetailViewController.h"
#import "AppDelegate_Pad.h"
#import "ClinicianInfo.h"

@interface PhysicianDetailViewController ()

@end

@implementation PhysicianDetailViewController

@synthesize physicianImageView, physicianNameLabel, physicianTimer, todayCareHandledByLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        physicianImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianImage]]];
//        physicianNameLabel.text = [NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName]];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"PhysicianDetailViewController.viewDidLoad()");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ClinicianInfo *currentClinician = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController]
     getCurrentClinician];
    if (currentClinician){
        NSString *filename = [currentClinician getImageFilename];
        physicianImageView.image = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] loadImage:filename];
    }
    else
        physicianImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianImage]]];
    physicianNameLabel.text = [NSString stringWithFormat:@"%@",[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName]];
}

- (void)beginFadeOutOfCareHandledByLabel {
    
    double beginFadeOutInSeconds = 3.5;
    
    NSLog(@"PhysicianDetailViewController.beginFadeOutOfCareHandledByLabel() in %1.2f seconds",beginFadeOutInSeconds);
    
    physicianTimer = [[NSTimer timerWithTimeInterval:beginFadeOutInSeconds target:self selector:@selector(continueFadeOutOfCareHandledByLabel:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:physicianTimer forMode:NSDefaultRunLoopMode];
}

- (void)continueFadeOutOfCareHandledByLabel:(NSTimer*)theTimer {
    
    NSLog(@"PhysicianDetailViewController.continueFadeOutOfCareHandledByLabel()");
    
    [UIView beginAnimations:nil context:nil];
	{
		[UIView	setAnimationDuration:4.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        todayCareHandledByLabel.alpha = 0.0;
        
	}
	[UIView commitAnimations];
    
    [theTimer release];
	theTimer = nil;
    
    physicianTimer = [[NSTimer timerWithTimeInterval:4.2 target:self selector:@selector(finishFadeOutOfCareHandledByLabel:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:physicianTimer forMode:NSDefaultRunLoopMode];
}

- (void)finishFadeOutOfCareHandledByLabel:(NSTimer*)theTimer {
    
    NSLog(@"PhysicianDetailViewController.finishFadeOutOfCareHandledByLabel()");
    
    [self.view sendSubviewToBack:todayCareHandledByLabel];
    
    [theTimer release];
	theTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
