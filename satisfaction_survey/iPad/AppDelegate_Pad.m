//
//  AppDelegate_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "AppDelegate_Pad.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>




@implementation AppDelegate_Pad

@synthesize hostNameToReach;
//completedFirstConnectivityCheck, completedSecondConnectivityCheck, connectivityEstablished, previousReachability, checkingForReachability, waitingForConnection
//@synthesize connectivityImageView, noConnectionAnimation, waitingForConnectionCover;
//@synthesize waitingForConnectionLabel;
@synthesize endOfSplashTimer;
@synthesize loaderViewController;

+ (AppDelegate_Pad *)sharedAppDelegate
{
    return (AppDelegate_Pad *) [UIApplication sharedApplication].delegate;
}


#pragma mark -
#pragma mark Application delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
	
    // Override point for customization after application launch
    completedFirstConnectivityCheck = NO;
	completedSecondConnectivityCheck = NO;
	connectivityEstablished = NO;
	previousReachability = connectivityEstablished;
	
	checkingForReachability = NO;
	waitingForConnection = NO;
    
    loaderViewController = [[MainLoaderViewController alloc] initWithNibName:nil bundle:nil];
    
    [window addSubview:loaderViewController.view];
    
    
    [self startReachabilityNotifier];
    
    [window makeKeyAndVisible];

		
	return YES;
}

#pragma mark Reachability Methods

- (BOOL)isConnectivityEstablished {
	return connectivityEstablished;
}

- (void)setCheckingForReachability:(BOOL)newReachability {
    checkingForReachability = newReachability;
}

- (void)updatePreviousReachabilityToCurrent {
	previousReachability = connectivityEstablished;
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
	Reachability* currentReach = [note object];
	NSParameterAssert([currentReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [currentReach currentReachabilityStatus];
	BOOL connectionRequired = [currentReach connectionRequired];
    NSString* statusString = @"";
    switch (netStatus)
    {
        case NotReachable:
        {
			connectivityEstablished = NO;
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
			connectivityEstablished = YES;
            statusString = @"Reachable WWAN";
            break;
        }
        case ReachableViaWiFi:
        {
			connectivityEstablished = YES;
			statusString= @"Reachable WiFi";
            break;
		}
    }
	
	NSLog(@"Reachability changed to:\n\t- %@\n\t- Connection Required: %d", statusString, connectionRequired);
	
	if (waitingForConnection && connectivityEstablished) {
		waitingForConnection = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[self removeNoConnectionViews];
	}
	if (connectivityEstablished && !previousReachability) {
        
	} else if (!connectivityEstablished && previousReachability) {
        
	}
}

- (void)updateAppForCurrentReachability:(Reachability*)curReach {
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSString* statusString= @"";
	
	if (netStatus == NotReachable) {
		statusString = @"Access to Google Maps (and other web resources) Not Available";
        
		if (!loaderViewController.currentWRViewController.splashAnimationsFinished) {
            
		}
		
	} else {
		statusString = @"Access to Google Maps (and other web resources) Available!";
	}
	
	NSLog(@"%@", statusString);
    
}

- (void)checkForReachability:(NSTimer*)theTimer {
	
	if (!loaderViewController.currentWRViewController.splashAnimationsFinished) {
		checkingForReachability = YES;
		
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        
        NSString* statusString;
        
        if ([reach isReachable]) {
            statusString= @"";
        }
		
		if (netStatus == NotReachable) {
			
			connectivityEstablished = NO;
			statusString = @"Access to Google Maps (and other web resources) NOT Available";
			
			if (!completedFirstConnectivityCheck) {
				completedFirstConnectivityCheck = YES;
				NSLog(@"Completed first connectivity check...");
				endOfSplashTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(checkForReachability:) userInfo:nil repeats:NO] retain];
				[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
				
			} else if (!completedSecondConnectivityCheck) {
				
				completedSecondConnectivityCheck = YES;
				NSLog(@"Completed second connectivity check...");
				endOfSplashTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(checkForReachability:) userInfo:nil repeats:NO] retain];
				[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
				
			} else {
				NSLog(@"Completed third connectivity check...displaying alert.");
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Internet connectivity and location data are required for proper functionality.  Please establish a connection or restart the app to try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert = nil;
                
			}
			
		} else {
			completedFirstConnectivityCheck = YES;
			completedSecondConnectivityCheck = YES;
			
			NSLog(@"Final connectivity check...polling online db for MAX id...");
//			BOOL canConnectToSQLDb = [self isPossibleToGetMaxIDFromMySQL];
            BOOL canConnectToSQLDb = [loaderViewController.currentWRViewController isPossibleToGetMaxIDFromMySQL];
			
			if (canConnectToSQLDb) {
				connectivityEstablished = YES;
				statusString = @"Access to Google Maps (and other web resources) Available!";
                
                // Update network settings
                [loaderViewController.currentWRViewController.settingsVC updateNetworkStatusWithConnectionType:kConnected];
                
                //				[self animateTabBarOnAndStatusBackIn];
//                [self sqlConnectedAnimation];
			} else {
				connectivityEstablished = NO;
				statusString = @"Failed final connectivty check.  Might be on an unsecured wifi network which hasn't authenticated...";
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Internet connectivity and location data are required for proper functionality.  Please establish a connection or restart the app to try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert = nil;
                
                // Update network settings
                [loaderViewController.currentWRViewController.settingsVC updateNetworkStatusWithConnectionType:kConnectionFailed];
                
			}
		}
		
		NSLog(@"%@", statusString);
	}
	
	[theTimer release];
	theTimer = nil;
	
	[self updatePreviousReachabilityToCurrent];
}

- (BOOL)isHostReachable:(Reachability*)thisReach {
	
	BOOL hostIsReachable = NO;
	
	NSParameterAssert([thisReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [thisReach currentReachabilityStatus];
	BOOL connectionRequired = [thisReach connectionRequired];
    NSString* statusString = @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
			hostIsReachable = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
			hostIsReachable = YES;
            break;
        }
        case ReachableViaWiFi:
        {
			statusString= @"Reachable WiFi";
			hostIsReachable = YES;
            break;
		}
    }
	
	if (connectionRequired) {
		return NO;
	} else {
		return hostIsReachable;
	}
}

- (void)startReachabilityNotifier {
    
    // Update network settings
    [loaderViewController.currentWRViewController.settingsVC updateNetworkStatusWithConnectionType:kConnectionPending];
    
    double animateSplashDelay;
    animateSplashDelay = 8.0;
    
    
    NSLog(@"STARTING REACH in %f seconds...", animateSplashDelay);
    
    //    // Assuming it's the first run, set this to 0 (and update it if necessary)
//	self.lastRowImportedFromUsersDb = 0;
    
    // Check to see if this is the first time the app has been run since being installed
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:@"firstRun"]) {
		[defaults setObject:[NSDate date] forKey:@"firstRun"];
		NSLog(@"First run...");
//		[defaults setObject:[NSNumber numberWithInt:lastRowImportedFromUsersDb] forKey:@"lastRowImported"];
	} else {
		[defaults setObject:[NSDate date] forKey:@"thisRun"];
//		self.lastRowImportedFromUsersDb = [[defaults objectForKey:@"lastRowImported"] intValue];
//		NSLog(@"Subsequent run... (last online db row imported = %d)", lastRowImportedFromUsersDb);
	}
    
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    endOfSplashTimer = [[NSTimer timerWithTimeInterval:animateSplashDelay target:self selector:@selector(checkForReachability:) userInfo:nil repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:endOfSplashTimer forMode:NSDefaultRunLoopMode];
    
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
	hostNameToReach = [[NSString alloc] initWithString:@"www.apple.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server your monitoring
	Reachability *reach = [Reachability reachabilityWithHostname:hostNameToReach];
    
    [reach startNotifier];
}

- (void)initializeNoConnectionAnimation {
	
	NSLog(@"Initializing noConnectionAnimation...");
	
	waitingForConnectionCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
	waitingForConnectionCover.backgroundColor = [UIColor blackColor];
	waitingForConnectionCover.alpha = 0.0;
	
	waitingForConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
	waitingForConnectionLabel.text = @"Waiting for connection...";
	waitingForConnectionLabel.textAlignment = UITextAlignmentCenter;
	waitingForConnectionLabel.textColor = [UIColor whiteColor];
	waitingForConnectionLabel.backgroundColor = [UIColor clearColor];
	waitingForConnectionLabel.opaque = YES;
	[waitingForConnectionLabel sizeToFit];
	[waitingForConnectionLabel setCenter:CGPointMake(380.0f, 415.0f)];
	waitingForConnectionLabel.alpha = 0.0;
	
	NSString *connectionTypeImageString;
	if ([Reachability isReachableViaWiFi]) {
		connectionTypeImageString = @"Airport.png";
	} else {
		connectionTypeImageString = @"WWAN5.png";
	}
	connectivityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:connectionTypeImageString]];
	connectivityImageView.frame = CGRectMake(0, 0, 32, 32);
	[connectivityImageView setCenter:CGPointMake(380.0f, 415.0f)];
	connectivityImageView.alpha = 0.0;
	
	double noConnectionAnimationDuration = 0.7;
	NSMutableArray *noConnectionAnimationFrames = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"no_connection_frame1.png"], [UIImage imageNamed:@"no_connection_frame2.png"], nil];
	noConnectionAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
	noConnectionAnimation.animationImages = noConnectionAnimationFrames;
	noConnectionAnimation.animationDuration = noConnectionAnimationDuration;
	noConnectionAnimation.animationRepeatCount = 1000;
	noConnectionAnimation.alpha = 0.0;
	[noConnectionAnimation setCenter:CGPointMake(380.0f, 415.0f)];
    
	
	[waitingForConnectionCover release];
	[waitingForConnectionLabel release];
	[connectivityImageView release];
	[noConnectionAnimation release];
	[noConnectionAnimationFrames release];
	
}

- (void)removeNoConnectionViews {
	[noConnectionAnimation stopAnimating];
	[waitingForConnectionCover removeFromSuperview];
	[waitingForConnectionLabel removeFromSuperview];
	[connectivityImageView removeFromSuperview];
	[noConnectionAnimation removeFromSuperview];
}

- (void)fadeInNoConnectionViews {
	NSLog(@"Fading in no connection views...");
	
	[noConnectionAnimation startAnimating];
    
	[UIView beginAnimations:@"fadeInNoConnectionViews" context:nil];
	{
		[UIView	setAnimationDuration:0.8];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
		waitingForConnectionCover.alpha = 0.5;
		waitingForConnectionLabel.alpha = 1.0;
		connectivityImageView.alpha = 1.0;
		noConnectionAnimation.alpha = 1.0;
		
	}
	[UIView commitAnimations];
}




/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {

    [loaderViewController release];
    [window release];
	[super dealloc];
}


@end

