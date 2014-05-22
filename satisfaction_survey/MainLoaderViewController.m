//
//  MainLoaderViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import "MainLoaderViewController.h"

#import "AppDelegate_Pad.h"

@interface MainLoaderViewController ()

@end

@implementation MainLoaderViewController

@synthesize currentWRViewController;
@synthesize miniDemoVC, waitSpinner, waitBlack, waitLabel, shortWaitTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        
        // Custom initialization
        NSLog(@"In MainLoaderViewController initWithNibName...");
        
        [self createNewWaitingRoomViewController];
        
        miniDemoVC = [[MiniDemoViewController alloc] initWithNibName:nil bundle:nil];
        miniDemoVC.view.alpha = 0.0;
        miniDemoVC.view.frame = CGRectMake(200, 200, 410, 262);
        miniDemoVC.view.backgroundColor = [UIColor clearColor];
        [miniDemoVC.view setCenter:CGPointMake(-80.0f, 1109.0f)];
        miniDemoVC.view.transform = rotateRight;
        
        [self.view addSubview:miniDemoVC.view];
        [self.view sendSubviewToBack:miniDemoVC.view];
        
        waitBlack = [[UIView alloc] initWithFrame:self.view.frame];
        waitBlack.backgroundColor = [UIColor blackColor];
        waitBlack.alpha = 0.0;
//        waitBlack.transform = rotateRight;
        
        waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        waitLabel.text = @"Resetting...";
        waitLabel.textAlignment = UITextAlignmentCenter;
        waitLabel.textColor = [UIColor whiteColor];
        waitLabel.font = [UIFont fontWithName:@"Avenir" size:45];
        waitLabel.backgroundColor = [UIColor clearColor];
        waitLabel.opaque = YES;
        [waitLabel sizeToFit];
        [waitLabel setCenter:CGPointMake(412.0f, 512.0f)];
        waitLabel.alpha = 0.0;
        waitLabel.transform = rotateRight;
        
        waitSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
        [waitSpinner setCenter:CGPointMake(412.0f, 712.0f)];
        [waitSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitSpinner.transform = rotateRight;
        waitSpinner.alpha = 0.0;
        
        [self.view addSubview:waitBlack];
        [self.view addSubview:waitLabel];
        [self.view addSubview:waitSpinner];

        
    }
    return self;
}

- (void)createNewWaitingRoomViewController {
    currentWRViewController = [[WRViewController alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview:currentWRViewController.view];
}

- (void)createNewWaitingRoomViewControllerAfterDelay:(NSTimer*)theTimer {
    currentWRViewController = [[WRViewController alloc] initWithNibName:nil bundle:nil];
    currentWRViewController.view.alpha = 0.0;
    [self.view addSubview:currentWRViewController.view];
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideWaitScreen:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)destroyCurrentWaitingRoomViewController:(NSTimer*)theTimer {
    [currentWRViewController release];
    currentWRViewController = nil;
    NSLog(@"currentWRViewController destroyed...");
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(createNewWaitingRoomViewControllerAfterDelay:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)performAppReset {
    NSLog(@"Resetting app...");
    
    [miniDemoVC menuButtonPressed];
    [self showWaitScreen];
    [self fadeOutWRVC];
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(destroyCurrentWaitingRoomViewController:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)fadeInMiniDemoMenu {
    [self.view bringSubviewToFront:miniDemoVC.view];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        miniDemoVC.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
}

- (void)fadeOutMiniDemoMenu {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        miniDemoVC.view.alpha = 0.0;
        
    }
    [UIView commitAnimations];
}

- (void)showMiniDemoMenu {
    CGRect miniFrame = miniDemoVC.view.frame;
    miniFrame.origin.x = miniFrame.origin.x + miniDemoVC.view.frame.size.width - 50;
    miniFrame.origin.y = miniFrame.origin.y - miniDemoVC.view.frame.size.height + 130;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        miniDemoVC.view.frame = miniFrame;
        miniDemoVC.view.backgroundColor = [UIColor whiteColor];
    }
    [UIView commitAnimations];
}

- (void)hideMiniDemoMenu {
    CGRect miniFrame = miniDemoVC.view.frame;
    miniFrame.origin.x = miniFrame.origin.x - miniDemoVC.view.frame.size.width + 50;
    miniFrame.origin.y = miniFrame.origin.y + miniDemoVC.view.frame.size.height - 130;
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        miniDemoVC.view.frame = miniFrame;
        miniDemoVC.view.backgroundColor = [UIColor clearColor];
    }
    [UIView commitAnimations];
}

- (void)fadeOutWRVC {
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationDuration:.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        currentWRViewController.view.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)showWaitScreen {
    [self.view bringSubviewToFront:waitBlack];
    [self.view bringSubviewToFront:waitLabel];
    [self.view bringSubviewToFront:waitSpinner];
    
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        waitBlack.alpha = 0.7;
        waitLabel.alpha = 1.0;
        waitSpinner.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    [waitSpinner startAnimating];
}

- (void)hideWaitScreen:(NSTimer*)theTimer {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        waitBlack.alpha = 0.0;
        waitLabel.alpha = 0.0;
        waitSpinner.alpha = 0.0;
        currentWRViewController.view.alpha = 1.0;
        
    }
    [UIView commitAnimations];
    
    [theTimer release];
	theTimer = nil;
    
    shortWaitTimer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(sendWaitScreenToBack:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:shortWaitTimer forMode:NSDefaultRunLoopMode];
}

- (void)sendWaitScreenToBack:(NSTimer*)theTimer {
    [self.view sendSubviewToBack:waitSpinner];
    [self.view sendSubviewToBack:waitBlack];
    [self.view sendSubviewToBack:waitLabel];
    [waitSpinner stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)dealloc {
    [currentWRViewController release];
    [miniDemoVC release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
