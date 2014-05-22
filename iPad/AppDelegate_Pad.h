//
//  AppDelegate_Pad.h
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "Reachability.h"
#import "MainLoaderViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CAXException.h"

#import "DSFingerTipWindow.h"

@interface AppDelegate_Pad : AppDelegate_Shared <CLLocationManagerDelegate>  {
    
    Reachability *hostReach;
	NSString *hostNameToReach;
	BOOL completedFirstConnectivityCheck;
    BOOL completedSecondConnectivityCheck;
    BOOL connectivityEstablished;
    BOOL previousReachability;
    BOOL checkingForReachability;
    BOOL waitingForConnection;
	UIImageView *connectivityImageView, *noConnectionAnimation;
	UIView *waitingForConnectionCover;
	UILabel *waitingForConnectionLabel;
	
	NSTimer *endOfSplashTimer;
    
    IBOutlet MainLoaderViewController *loaderViewController;
	
}
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, retain) MainLoaderViewController *loaderViewController;

@property (nonatomic, retain) NSString *hostNameToReach;
//@property BOOL completedFirstConnectivityCheck;
//@property BOOL completedSecondConnectivityCheck;
//@property BOOL previousReachability;
//@property BOOL connectivityEstablished;
//@property BOOL checkingForReachability;
//@property BOOL waitingForConnection;



@property (nonatomic, retain) NSTimer *endOfSplashTimer;

+ (AppDelegate_Pad *)sharedAppDelegate;
- (void)setCheckingForReachability:(BOOL)newReachability;
- (BOOL)isConnectivityEstablished;
- (void)startReachabilityNotifier;
- (void)updateCurrentReachability;

- (NSString *)currentAudioRouteString;

@end

