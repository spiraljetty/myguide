//
//  BigBuckBunnyViewController.m
//  BigBuckBunny

#import "QuickMovieViewController.h"

@implementation QuickMovieViewController

-(IBAction)playMovie:(id)sender
{
	UIButton *playButton = (UIButton *) sender; 
	
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"what_is_tbi" ofType:@"mp4"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlaybackComplete:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayerController];
	
	[moviePlayerController.view setFrame:CGRectMake(playButton.frame.origin.x, 
													playButton.frame.origin.y, 
													playButton.frame.size.width, 
													playButton.frame.size.height)];
    
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    
    moviePlayerController.view.transform = rotateRight;
    
	[self.view addSubview:moviePlayerController.view];
    //moviePlayerController.fullscreen = YES;
	
	//moviePlayerController.scalingMode = MPMovieScalingModeFill;
	
    [moviePlayerController play];
}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayerController];
	
    [moviePlayerController.view removeFromSuperview];
    [moviePlayerController release];
}

- (void)dealloc {
    [super dealloc];
}

@end
