//
//  AppDelegate_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "AppDelegate_Pad.h"
#import "MainLoaderViewController.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import "YLViewController.h"
#import "SettingsViewController.h"

@implementation AppDelegate_Pad

@synthesize hostNameToReach;
//completedFirstConnectivityCheck, completedSecondConnectivityCheck, connectivityEstablished, previousReachability, checkingForReachability, waitingForConnection
//@synthesize connectivityImageView, noConnectionAnimation, waitingForConnectionCover;
//@synthesize waitingForConnectionLabel;
@synthesize endOfSplashTimer;
@synthesize loaderViewController;

#pragma mark -Audio Session Interruption Listener

static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	AppDelegate_Pad *THIS = (AppDelegate_Pad *)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        // session is already set to not active so if we're playing stop
        //        [THIS->myViewController stopForInterruption];
    }
}

#pragma mark -Audio Session Property Listener

static void propertyListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
    AppDelegate_Pad *THIS = (AppDelegate_Pad *)inClientData;
    
	if (inID == kAudioSessionProperty_AudioRouteChange) {
//		try {
            CFDictionaryRef	routeChangeDictionary = (CFDictionaryRef)inData;
            
            UInt32 routeChangeReason;
            CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
            CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
            printf("Audio Route Change, Reason: %d\n", routeChangeReason);
            
            CFStringRef routeChangeOldRouteRef = (CFStringRef)CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
            printf("Old Route: ");
            CFShow(routeChangeOldRouteRef);
            
			CFStringRef newRoute;
			UInt32 size = sizeof(newRoute);
//			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
			AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
			if (newRoute) {
                printf("New Route: ");
				CFShow(newRoute);
            }
//		} catch (CAXException e) {
//			char buf[256];
//			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//		}
        
        if (routeChangeReason < 11) {
            [THIS.loaderViewController.currentWRViewController.settingsVC setHeadSetStatusTo:[NSString stringWithString:(NSString *)newRoute]];
//            updateNewAudioRoute(newRoute);
//            [self updateNewAudioRoute:]
        }
	}
}



@synthesize locationManager=_locationManager;

+ (AppDelegate_Pad *)sharedAppDelegate
{
    return (AppDelegate_Pad *) [UIApplication sharedApplication].delegate;
}

#pragma mark - CLLocationManagerDelegate Methods
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"in LM didUpdateToLocation");
    
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
        //Location timestamp is within the last 5.0 seconds, let's use it!
        if(newLocation.horizontalAccuracy<50.0){
            //Location seems pretty accurate, let's use it!
            NSLog(@"LM: latitude %+.6f, longitude %+.6f (acc: %f)\n",
                  newLocation.coordinate.latitude,
                  newLocation.coordinate.longitude,
                  newLocation.horizontalAccuracy);
//            NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
            
            //Optional: turn off location services once we've gotten a good location
            //            [manager stopUpdatingLocation];
        }
    }
}

#pragma mark -
#pragma mark Application delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];    
    application.idleTimerDisabled = YES;
    
	
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

    //If object has not been created, create it.
    if(self.locationManager==nil){
        _locationManager=[[CLLocationManager alloc] init];
        //I'm using ARC with this project so no need to release
        
        _locationManager.delegate=self;
        
        //Included in the prompt to use location services
        _locationManager.purpose = @"We will try to tell you where you are if you get lost";
        
        
        //The desired accuracy that you want, not guaranteed though
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        //The distance in meters a device must move before an update event is triggered
        _locationManager.distanceFilter=5;
        self.locationManager=_locationManager;
    }
    
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
    
//    if (!loaderViewController.currentWRViewController.forceToDemoMode) {
//        NSLog(@"Not in demo mode, initializing audio session for headphone use only...");
        [self initAudioSessionWithListener];
//    } else {
//        NSLog(@"In demo mode, defaulting to automatic audio output...");
//    }
//    [loaderViewController.currentWRViewController.settingsVC setHeadSetStatus];
		
	return YES;
}

- (void)updateNewAudioRoute:(NSString *)updatedAudioRouteString
{
    [loaderViewController.currentWRViewController.settingsVC setHeadSetStatusTo:[NSString stringWithString:updatedAudioRouteString]];
}

- (void)initAudioSessionWithListener {
//    try {
        // Initialize and configure the audio session
//        XThrowIfError(AudioSessionInitialize(NULL, NULL, interruptionListener, self), "couldn't initialize audio session");
        AudioSessionInitialize(NULL, NULL, interruptionListener, self);
        
        UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
//        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
//        XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propertyListener, self), "couldn't set property listener");
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propertyListener, self);
        
        Float32 preferredBufferSize = .005;
//        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
        AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
        
        Float64 hwSampleRate = 44100.0;
//        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(hwSampleRate), &hwSampleRate), "couldn't set hw sample rate");
        AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(hwSampleRate), &hwSampleRate);
        
//        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        AudioSessionSetActive(true);
        
        UInt32 size = sizeof(hwSampleRate);
//        XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
        AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate);
        printf("Hardware Sample Rate: %f\n", hwSampleRate);
    
    CFStringRef currentRoute;

    UInt32 routeSize = sizeof(currentRoute);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &currentRoute);
    if (currentRoute) {
        printf("Current Active Route: ");
        CFShow(currentRoute);
        
        [loaderViewController.currentWRViewController.settingsVC setHeadSetStatusTo:[NSString stringWithString:(NSString *)currentRoute]];
        
    }
    
//    } catch (CAXException e) {
//        char buf[256];
//        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//    }
}

- (NSString *)currentAudioRouteString {
    CFStringRef currentRoute;
    
//    try {

        
        UInt32 size = sizeof(currentRoute);
//        XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &currentRoute), "couldn't get current audio route");
        AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &currentRoute);
        if (currentRoute) {
            printf("Current Route: ");
//            CFShow(currentRoute);
        }
//    } catch (CAXException e) {
//        char buf[256];
//        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//    }
    
    NSString *aNSString = [NSString stringWithString:(NSString *)currentRoute];
    
    return aNSString;
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

- (void)updateCurrentLinkType {
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    [loaderViewController.currentWRViewController.settingsVC updateLinkStatusWithLinkType:netStatus];
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
        
        [loaderViewController.currentWRViewController.settingsVC updateLinkStatusWithLinkType:netStatus];
		
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
			}
			
		} else {
			completedFirstConnectivityCheck = YES;
			completedSecondConnectivityCheck = YES;
			
//			NSLog(@"Final connectivity check...polling online db for MAX id...");
//            BOOL canConnectToSQLDb = [loaderViewController.currentWRViewController isPossibleToGetMaxIDFromMySQL];
//			
//			if (canConnectToSQLDb) {
//				connectivityEstablished = YES;
//				statusString = @"Access to Google Maps (and other web resources) Available!";
//                
                // Update network settings
                [loaderViewController.currentWRViewController.settingsVC updateNetworkStatusWithConnectionType:kConnected];
            
                loaderViewController.currentWRViewController.settingsVC.enableOfflineVoiceModeButton.demoButton.enabled = YES;
//                [loaderViewController.currentWRViewController.settingsVC.soundViewController.updateL
//			} else {
//				connectivityEstablished = NO;
//                
//                // Update network settings
//                [loaderViewController.currentWRViewController.settingsVC updateNetworkStatusWithConnectionType:kConnectionFailed];
//                
//			}
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
    animateSplashDelay = 3.0;
    
    
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

