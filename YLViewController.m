//
//  YLViewController.m
//  YLProgressBar
//
//  Created by Yannick Loriot on 05/02/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//

#import "YLViewController.h"

#import "YLProgressBar.h"

#import "AppDelegate_Pad.h"
#import "TTSPlayer.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YLViewController ()
@property (nonatomic, SAFE_ARC_PROP_RETAIN) NSTimer*    progressTimer;

@end

@implementation YLViewController
@synthesize progressView;
@synthesize progressValueLabel, progressBarIncrements, voiceSpeedSegmentedControl, voiceTypeSegmentedControl, updateSelectSoundsSwitch, updateSoundsLabel;
@synthesize progressTimer, networkImage, linkImage, networkStatus, loadingFileName, loadingLabel, loadSpinner, linkStatus, wanderSetting;
@synthesize currentScrollView;
@synthesize labelLocationInformation, volumeControlStepper, headphoneImage, soundStatus, volumeNumber, previousVolumeStepperValue, wifiSSIDName, wanderGuardSwitch, uploadDataStatus, uploadDataSpinner, uploadDataButton;
@synthesize mapView;

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    NSLog(@"Mapview didUpdateUserLocation.");
    //
    //    CLLocationCoordinate2D vaCoords = CLLocationCoordinate2DMake(37.40490329864028, -122.1419084072113);
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(vaCoords, 800, 800);
    //    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    //
    //    // Add an annotation
    //    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    //    point.coordinate = vaCoords;
    //    point.title = @"VA Palo Alto Healthcare System";
    //    point.subtitle = @"TBI Research Forum 2013";
    //
    //    [self.mapView addAnnotation:point];
}

- (void)zoomToCoords:(CLLocationCoordinate2D)theseCoords
{
    NSLog(@"Zooming to coordinates. Creating annotation.");
    
    MKCoordinateRegion region;
    region.center = theseCoords;
    region.span = MKCoordinateSpanMake(0.003, 0.003);
    region = [self.mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = theseCoords;
    point.title = @"This iPad";
//    point.title = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deviceName];
    //    point.subtitle = @"VA Palo Alto Healthcare System";
    
    [mapView addAnnotation:point];
}

- (void)zoomToCurrentLocation {
    AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate] ;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    [self zoomToCoords:currentLocation.coordinate];
}

- (void)updateViewWithNewLocationInformation {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setNumUpdates:[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] numUpdates]+1];
    
    AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate] ;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    
    double deltaLat = appDelegate.loaderViewController.currentWRViewController.settingsVC.homeCoords.latitude - currentLocation.coordinate.latitude;
    double deltaLong = appDelegate.loaderViewController.currentWRViewController.settingsVC.homeCoords.longitude - currentLocation.coordinate.longitude;
    
//    self.labelLocationInformation.text=;
    [labelLocationInformation setText:[NSString stringWithFormat:@"latitude: %+.6f\nlongitude: %+.6f\naccuracy: %f\n(Delta: %+.6f, %+.6f)\n(Updates: %d)",
                                       currentLocation.coordinate.latitude,
                                       currentLocation.coordinate.longitude,
                                       currentLocation.horizontalAccuracy,
                                       deltaLat,deltaLong,appDelegate.loaderViewController.currentWRViewController.settingsVC.numUpdates]];
    
//    NSLog(@"YL latitude %+.6f, longitude %+.6f (acc: %1.4f)\n",
//          currentLocation.coordinate.latitude,
//          currentLocation.coordinate.longitude,
//          currentLocation.horizontalAccuracy);
//    NSLog(@"Horizontal Accuracy:%f", currentLocation.horizontalAccuracy);
}

- (void)dealloc
{
    if (progressTimer && [progressTimer isValid])
    {
        [progressTimer invalidate];
    }
    
    SAFE_ARC_RELEASE (progressTimer);
    SAFE_ARC_RELEASE (progressValueLabel);
    SAFE_ARC_RELEASE (progressView);
    
    SAFE_ARC_SUPER_DEALLOC ();
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    progressView.progressTintColor = [UIColor greenColor];
//    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f 
//                                                           target:self 
//                                                         selector:@selector(changeProgressValue)
//                                                         userInfo:nil
//                                                          repeats:YES];
    progressBarIncrements = 0.01f;
    
    wifiSSIDName.text = @"None";
    
    voiceTypeSegmentedControl.selectedSegmentIndex = 1;
    voiceSpeedSegmentedControl.selectedSegmentIndex = 2;
    
    [currentScrollView setScrollEnabled:YES];
    [currentScrollView setContentSize:CGSizeMake(1000, 1400)];
    
    volumeControlStepper.maximumValue = 10;
    volumeControlStepper.value = 5;
    previousVolumeStepperValue = 5;
    
//    NSLog(@"Setting home coordinates...");
//    homeCoords = CLLocationCoordinate2DMake(37.450275, -122.162034);
//    [self zoomToCoords:homeCoords];
    
//    AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate] ;
//    CLLocation *currentLocation=appDelegate.locationManager.location;
//    
//    [self zoomToCoords:currentLocation.coordinate];
//    
//    double deltaLat = appDelegate.loaderViewController.currentWRViewController.settingsVC.homeCoords.latitude - currentLocation.coordinate.latitude;
//    double deltaLong = appDelegate.loaderViewController.currentWRViewController.settingsVC.homeCoords.longitude - currentLocation.coordinate.longitude;
//    
//    
//    self.labelLocationInformation.text=[NSString stringWithFormat:@"latitude: %+.6f\nlongitude: %+.6f\naccuracy: %f\n(Delta: %+.6f, %+.6f)\n(Updates: %d)",
//                                        currentLocation.coordinate.latitude,
//                                        currentLocation.coordinate.longitude,
//                                        currentLocation.horizontalAccuracy,
//                                        deltaLat,deltaLong,appDelegate.loaderViewController.currentWRViewController.settingsVC.numUpdates];
    
    NSLog(@"Mapview delegate set.");
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    
    AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate];
    [appDelegate.loaderViewController.currentWRViewController.settingsVC updateSoundSettingsBasedOnHeadsetStatus];
}

- (void)updateLinkDisplayWithLinkType:(NetworkStatus)thisNetworkStatus {
    
    BOOL isWanderGuardEnabled = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] wanderGuardActivated];
    
        switch (thisNetworkStatus) {
            case NotReachable:
                linkStatus.text = @"No Link";
//                NSLog(@"====== Updating link type to: NotReachable ========");
//                networkStatus.text = @"Connected";
                linkImage.image = [UIImage imageNamed:@"no_connection_frame1.png"];
                
                wanderSetting.text = @"Wander Guard disabled.";
                
                break;
            case ReachableViaWWAN:
                linkStatus.text = @"3G/4G Link";
//                NSLog(@"====== Updating link type to: ReachableViaWWAN ========");
//                networkStatus.text = @"Connecting...";
                linkImage.image = [UIImage imageNamed:@"WWAN5.png"];
                
                if (isWanderGuardEnabled) {
                    wanderSetting.text = @"Alarm will sound when traveling outside of the current clinic geofence.";
                } else {
                    wanderSetting.text = @"Wander Guard disabled.";
                }
                
                break;
            case ReachableViaWiFi:
                linkStatus.text = @"Wifi Link";
//                NSLog(@"====== Updating link type to: ReachableViaWiFi ========");
//                networkStatus.text = @"Connection Failed";
                linkImage.image = [UIImage imageNamed:@"Airport.png"];
                
                if (isWanderGuardEnabled) {
                    NSString *wanderGuardText = [NSString stringWithFormat:@"Alarm will sound when traveling too far away from WIFI Access Point: %@", [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] lastConnectedWIFISSIDName]];
                    wanderSetting.text = wanderGuardText;
                } else {
                    wanderSetting.text = @"Wander Guard disabled.";
                }
                
                break;
                
            default:
                linkStatus.text = @"No Link";
//                networkStatus.text = @"Not Connected";
                linkImage.image = [UIImage imageNamed:@"no_connection_frame1.png"];
                break;
        }
    
}

- (void)updateNetworkDisplayWithConnectionType:(ConnectionType)thisConnectionType {
    switch (thisConnectionType) {
        case kConnected:            
                networkStatus.text = @"Connected";
            networkImage.image = [UIImage imageNamed:@"network_connected_trim.png"];
            [self enableUploadDataButton];
            break;
        case kConnectionPending:
                networkStatus.text = @"Connecting...";
            networkImage.image = [UIImage imageNamed:@"network_pending_trim.png"];
            [self disableUploadDataButton];
            break;
        case kConnectionFailed :
                networkStatus.text = @"Connection Failed";
            networkImage.image = [UIImage imageNamed:@"network_failed_trim.png"];
            [self disableUploadDataButton];
            break;
            
        default:
                networkStatus.text = @"Not Connected";
            networkImage.image = [UIImage imageNamed:@"network_failed_trim.png"];
            [self disableUploadDataButton];
            break;
    }
    
}

- (void)startLoadingActivityIndicator {
    [loadSpinner startAnimating];
}

- (void)stopLoadingActivityIndicator {
    [loadSpinner stopAnimating];
}

- (void)viewDidUnload
{
    [self setProgressValueLabel:nil];
    [self setProgressView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else
    {
        return YES;
    }
}

#pragma mark -
#pragma mark YLViewController Public Methods

- (void)changeProgressValue
{
    float progressValue = progressView.progress;
    
    progressValue       += progressBarIncrements;
//    if (progressValue > 1)
//    {
//        progressValue = 0;
//    }
    
    
    [progressValueLabel setText:[NSString stringWithFormat:@"%.0f%%", (progressValue * 100)]];
    [progressView setProgress:progressValue];
}

- (IBAction)colorButtonTapped:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    switch (seg.selectedSegmentIndex) {
        case 0:
            progressView.progressTintColor = [UIColor purpleColor];
            break;
        case 1:
            progressView.progressTintColor = [UIColor redColor];
            break;
        case 2:
            progressView.progressTintColor = [UIColor cyanColor];
            break;
        case 3:
            progressView.progressTintColor = [UIColor greenColor];
            break;
        case 4:
            progressView.progressTintColor = [UIColor yellowColor];
            break;
            
        default:
            break;
    }
}

- (IBAction)volumeControlStepperChanged:(id)sender {
    UIStepper *thisControl = (UIStepper *)sender;
    
    if (volumeControlStepper.value > previousVolumeStepperValue) {
        NSLog(@"Volume Up");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] increaseVolume];
        previousVolumeStepperValue = volumeControlStepper.value;
    } else if (volumeControlStepper.value < previousVolumeStepperValue) {
        NSLog(@"Volume Down");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] decreaseVolume];
        previousVolumeStepperValue = volumeControlStepper.value;
    } else {
        NSLog(@"No change in volume");
    }
    
//    NSLog(@"Volume Control Changed to Index: %d",thisControl.selectedSegmentIndex);
//    if (thisControl.selectedSegmentIndex == 0) {
//        NSLog(@"Volume Down");
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] decreaseVolume];
//    } else {
//        NSLog(@"Volume Up");
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] mainTTSPlayer] increaseVolume];
//    }

}

- (IBAction)voiceTypeButtonTapped:(id)sender {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] TTSVoiceTypeSegmentedControlChanged:sender];
    
}
- (IBAction)voiceSpeedButtonTapped:(id)sender {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] TTSVoiceSpeedSegmentedControlChanged:sender];
}

- (void)updateSelectSoundsSwitchFlipped:(id)sender {
    if (updateSelectSoundsSwitch.on) {
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setUpdateSelectSounds:YES];
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] changeUpdateSelectSoundsValueTo:YES];
        NSLog(@"Setting updateSelectSounds to YES...");
//        resetAllOfflineSoundfilesButton
        [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] resetAllOfflineSoundfilesButton] demoButton] setEnabled:NO];
        [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] enableOfflineVoiceModeButton] demoButton] setEnabled:NO];
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] loadAllTTSSoundFiles];
    } else {
//        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setUpdateSelectSounds:YES];
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] changeUpdateSelectSoundsValueTo:NO];
        NSLog(@"Setting updateSelectSounds to NO...");
    }
}

- (void)wanderGuardSwitchFlipped:(id)sender {
    if (wanderGuardSwitch.isOn) {
        NSLog(@"Turning wander guard ON");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setWanderGuardActivated:YES];
        
    } else {
        NSLog(@"Turning wander guard OFF");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setWanderGuardActivated:NO];
    }
}

- (void)uploadDataToCloudButtonPressed:(id)sender {
    
    [self disableUploadDataButton];
    
    uploadDataStatus.alpha = 1.0;
    uploadDataStatus.text = @"Working...";
    
    uploadDataSpinner.alpha = 1.0;
    [uploadDataSpinner startAnimating];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminSendDataButtonPressed:self];
    
}

- (void)enableUploadDataButton {
    
    NSLog(@"enabling uploaddata button...");
    
    uploadDataButton.enabled = YES;
    uploadDataButton.alpha = 1.0;
}

- (void)disableUploadDataButton {
    NSLog(@"disabling uploaddata button...");
    
    uploadDataButton.enabled = NO;
    uploadDataButton.alpha = 0.5;
}

- (void)uploadDataRequestDone {
    
    NSLog(@"uploadDataRequestDone...");
    
    [self enableUploadDataButton];
    
    uploadDataStatus.text = @"Data uploaded successfully";
    
    uploadDataSpinner.alpha = 0.0;
    [uploadDataSpinner stopAnimating];
}

#pragma mark YLViewController Private Methods

@end
