//
//  SettingsViewController.m
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import "SettingsViewController.h"
#import "ControlView.h"
#import "YLViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize controlView, invisibleShowHideButton, soundViewController, networkImage, networkStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    controlView = [[ControlView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-[ControlView barHeight],
//                                                                self.view.frame.size.height+20.0f, 550.0f)];
    
    
    
    controlView = [[ControlView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                self.view.frame.size.height+20.0f, 450.0f)];
	
	// Add controls to control view
	CGRect controlFrame;
	int borderWidth = 5;
	float controlSpacing, currSpacing = [ControlView barHeight];
    float tmpSpacing;
    
    NSArray *labelText = [NSArray arrayWithObjects:@"Network", @"Sound", @"Speech\nRecognition", nil];
	UILabel *label;
    
    int numControls = 3;
	int numDivs = 2 + numControls - 1;
    UISegmentedControl *controls[numControls];
	
	for (int i=0; i < numControls; i++)
	{
		controls[i] = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"None", @"None", @"None", nil]] autorelease];
		[controls[i] setSegmentedControlStyle:UISegmentedControlStyleBar];
		[controls[i] setSelectedSegmentIndex:0];
		controlFrame = controls[i].frame;
		
		if (i == 0) {
			currSpacing += controlSpacing = floorf(([controlView contentHeight] - (controlFrame.size.height * numControls))/numDivs) - 15.0f;
            tmpSpacing = 50;
        } else {
			currSpacing += controlSpacing + controls[i].frame.size.height;
            tmpSpacing = currSpacing;
        }
		
		label = [[[UILabel alloc] initWithFrame:CGRectMake(borderWidth,
														   tmpSpacing,
														   controlView.frame.size.width - (2 * borderWidth) - 50.0f,
														   controls[i].frame.size.height+20.0f)] autorelease];
		label.text = [labelText objectAtIndex:i];
        label.numberOfLines = 0;
		label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
		label.backgroundColor = [UIColor clearColor];
		[controlView addSubview:label];
		

	}
    
    [self.view addSubview:controlView];
    
    CGFloat invisibleButtonExtraWidth = 60.0f;
    buttonOpen = FALSE;
    
    invisibleShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleShowHideButton.frame = CGRectMake(60, 0, 3.5*invisibleButtonExtraWidth, invisibleButtonExtraWidth);
    invisibleShowHideButton.showsTouchWhenHighlighted = YES;
    invisibleShowHideButton.backgroundColor = [UIColor clearColor];
    //        [invisibleShowHideButton setCenter:CGPointMake(500.0f, 660.0f)];
    [invisibleShowHideButton addTarget:self action:@selector(showHideButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    invisibleShowHideButton.enabled = YES;
    invisibleShowHideButton.hidden = NO;
    invisibleShowHideButton.selected = NO;
    [invisibleShowHideButton retain];
    
    [self.view addSubview:invisibleShowHideButton];
    
    [self createNetworkMenu];
    [self createSoundMenu];
}

- (void)createNetworkMenu {
    
    currentConnectionType = kConnectionFailed;
    
    networkStatus = [[UILabel alloc] initWithFrame:CGRectMake(160,130,300,50)];
    networkStatus.text = @"Disconnected";
    networkStatus.numberOfLines = 0;
    networkStatus.textColor = [UIColor whiteColor];
    networkStatus.font = [UIFont fontWithName:@"AvenirNext" size:20];
    networkStatus.backgroundColor = [UIColor clearColor];
    [self.view addSubview:networkStatus];
    
    networkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network_failed.png"]];
    networkImage.frame = CGRectMake(networkStatus.frame.origin.x, networkStatus.frame.origin.y - 65, 85, 85);
    [self.view addSubview:networkImage];
}

- (void)createSoundMenu {
    soundViewController = [[YLViewController alloc] initWithNibName:@"YLViewController_iPad" bundle:nil];
    soundViewController.view.frame = CGRectMake(80, 200, 500, 200);
    [self.view addSubview:soundViewController.view];
}

- (void)slideSettingsFrame {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
//    CGRect frame = invisibleShowHideButton.frame;
    CGRect frame = self.view.frame;
    
    if (buttonOpen == FALSE)
    {
        frame.origin.x -= controlView.contentHeight;
//        [_barImageView setTransform:_barImageViewRotation];
        buttonOpen = TRUE;
    }
    else
    {
        frame.origin.x += controlView.contentHeight;
//        [_barImageView setTransform:CGAffineTransformIdentity];
        buttonOpen = FALSE;
    }
    
//    invisibleShowHideButton.frame = frame;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)showHideButtonPressed {
    NSLog(@"showHideButtonPressed...");
    [self slideSettingsFrame];
//    [controlView slideAnimation];
}

- (void)updateNetworkStatusWithConnectionType:(ConnectionType)thisConnectionType {
    switch (thisConnectionType) {
        case kConnected:
            networkStatus.text = @"Connected";
            networkImage.image = [UIImage imageNamed:@"network_connected.png"];
            currentConnectionType = kConnected;
            break;
        case kConnectionPending:
            networkStatus.text = @"Connecting...";
            networkImage.image = [UIImage imageNamed:@"network_pending.png"];
            currentConnectionType = kConnectionPending;
            break;
        case kConnectionFailed:
            networkStatus.text = @"Connection Failed";
            networkImage.image = [UIImage imageNamed:@"network_failed.png"];
            currentConnectionType = kConnectionFailed;
            break;

        default:
            networkStatus.text = @"Not Connected";
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
