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
#import "DynamicContent.h"
#import "DynamicSpeech.h"

@interface YLViewController ()
@property (nonatomic, SAFE_ARC_PROP_RETAIN) NSTimer*    progressTimer;

@end

@implementation YLViewController
@synthesize progressView;
@synthesize progressValueLabel, progressBarIncrements, voiceSpeedSegmentedControl, voiceTypeSegmentedControl, updateSelectSoundsSwitch, updateSoundsLabel;
@synthesize progressTimer, networkImage, linkImage, networkStatus, loadingFileName, loadingLabel, loadSpinner, linkStatus, wanderSetting;
@synthesize currentScrollView;
@synthesize labelLocationInformation, volumeControlStepper, pitchControlStepper, speedControlStepper, languageControlStepper, headphoneImage, soundStatus, volumeNumber, pitchNumber, speedNumber, languageText, previousVolumeStepperValue, previousPitchStepperValue, previousSpeedStepperValue, previousLanguageStepperValue, wifiSSIDName, wanderGuardSwitch, uploadDataStatus, uploadDataSpinner, uploadDataButton, downloadDataButton, downloadDataSpinner, downloadDataStatus;
@synthesize mapView;

static YLViewController* mYLViewController = NULL;


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

- (void)viewDidLoad {
    mYLViewController = self;
    [super viewDidLoad];
        AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate];
	NSString *currentAppVersion = [DynamicContent getAppVersion];//appDelegate.loaderViewController.currentWRViewController.appVersion ; //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] appVersion];
    [appVersionLabel setText:currentAppVersion];
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
    
    pitchControlStepper.maximumValue = 60;
    pitchControlStepper.value = 20;
    previousPitchStepperValue = 20;

    speedControlStepper.maximumValue = 60;
    speedControlStepper.value = 30;
    previousSpeedStepperValue = 30;
    
    languageControlStepper.maximumValue = 60;
    languageControlStepper.value = 30;
    previousLanguageStepperValue = 30;

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
    
//    AppDelegate_Pad *appDelegate=(AppDelegate_Pad *)[AppDelegate_Pad sharedAppDelegate];
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
                
                //wanderSetting.text = @"Wander Guard disabled.";
                
                break;
            case ReachableViaWWAN:
                linkStatus.text = @"3G/4G Link";
//                NSLog(@"====== Updating link type to: ReachableViaWWAN ========");
//                networkStatus.text = @"Connecting...";
                linkImage.image = [UIImage imageNamed:@"WWAN5.png"];
                
                if (isWanderGuardEnabled) {
                    wanderSetting.text = @"Alarm will sound when traveling outside of the current clinic geofence.";
                } else {
                   // wanderSetting.text = @"Wander Guard disabled.";
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
                  //  wanderSetting.text = @"Wander Guard disabled.";
                }
                
                break;
                
            default:
                linkStatus.text = @"No Link";
//                networkStatus.text = @"Not Connected";
                linkImage.image = [UIImage imageNamed:@"no_connection_frame1.png"];
                break;
        }
    //    NSLog(@"YLViewController.updateLinkDisplayWithLinkType() link type %u", thisNetworkStatus);
}

- (void)updateNetworkDisplayWithConnectionType:(ConnectionType)thisConnectionType {
    switch (thisConnectionType) {
        case kConnected:            
                networkStatus.text = @"Connected";
            networkImage.image = [UIImage imageNamed:@"network_connected_trim.png"];
            [self enableUploadDataButton];
            [self enableDownloadDataButton];
            break;
        case kConnectionPending:
                networkStatus.text = @"Connecting...";
            networkImage.image = [UIImage imageNamed:@"network_pending_trim.png"];
            [self disableUploadDataButton];
            [self disableDownloadDataButton];
            break;
        case kConnectionFailed :
                networkStatus.text = @"Connection Failed";
            networkImage.image = [UIImage imageNamed:@"network_failed_trim.png"];
            [self disableUploadDataButton];
            [self disableDownloadDataButton];
            break;
            
        default:
                networkStatus.text = @"Not Connected";
            networkImage.image = [UIImage imageNamed:@"network_failed_trim.png"];
            [self disableUploadDataButton];
            [self disableDownloadDataButton];
            break;
    }
    NSLog(@"YLViewController.updateNetworkDisplayWithConnectionType() connection status %@", networkStatus.text);
    
    //[tbvc myLog:@"YLViewController.updateNetworkDisplayWithConnectionType() networkStatus: %@", networkStatus.text];
//    [tbvc writeLogMsg:msg];//[NSString stringWithFormat:@"Password OK"]];
    
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
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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

- (IBAction)pitchControlStepperChanged:(id)sender {
    UIStepper *thisControl = (UIStepper *)sender;
    float newValue = pitchControlStepper.value;
    float previousValue = previousPitchStepperValue;
    NSLog(@"YLViewController.pitchControlStepperChanged() value: %1.2f oldValue: %1.2f", newValue, previousValue);
    if (newValue > previousValue) {
        previousPitchStepperValue = newValue;
        newValue = [DynamicSpeech getPitch]  + 0.05f;
        [DynamicSpeech setPitch:newValue];
    } else if (newValue < previousValue) {
        previousPitchStepperValue = newValue;
        newValue = [DynamicSpeech getPitch]  - 0.05f;
        [DynamicSpeech setPitch:newValue];
    } else {
        NSLog(@"No change in pitch");
    }
    [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] soundViewController] pitchNumber] setText:[NSString stringWithFormat:@"%1.2f",newValue]];
}

- (IBAction)speedControlStepperChanged:(id)sender {
    UIStepper *thisControl = (UIStepper *)sender;
    float newValue = speedControlStepper.value;
    float previousValue = previousSpeedStepperValue;
    if (newValue > previousValue) {
        previousSpeedStepperValue = newValue;
        newValue = [DynamicSpeech getSpeed]  + 0.05f;
        [DynamicSpeech setSpeed:newValue];
    } else if (newValue < previousValue) {
        previousSpeedStepperValue = newValue;
        newValue = [DynamicSpeech getSpeed]  - 0.05f;
        [DynamicSpeech setSpeed:newValue];
    } else {
        NSLog(@"No change in speed");
    }
    [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] soundViewController] speedNumber] setText:[NSString stringWithFormat:@"%1.2f",newValue]];
}

- (IBAction)languageControlStepperChanged:(id)sender {
    UIStepper *thisControl = (UIStepper *)sender;
    float newValue = languageControlStepper.value;
    float previousValue = previousLanguageStepperValue;
    NSLog(@"YLViewController.languageControlStepperChanged() value: %1.2f oldValue: %1.2f", newValue, previousValue);
    if (newValue > previousValue) {
        previousLanguageStepperValue = previousLanguageStepperValue +1;
        newValue = [DynamicSpeech getLanguageIndex]  + 1.0f;
        [DynamicSpeech setLanguageIndex:newValue];
    } else if (newValue < previousValue) {
        previousLanguageStepperValue = previousLanguageStepperValue -1;
        newValue = [DynamicSpeech getLanguageIndex]  - 1.0f;
        [DynamicSpeech setLanguageIndex:newValue];
    } else {
        NSLog(@"No change in language");
    }
    [[[[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] soundViewController] languageText] setText:[DynamicSpeech getLanguage]];
}

- (IBAction)voiceTypeButtonTapped:(id)sender {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] TTSVoiceTypeSegmentedControlChanged:sender];
}

- (IBAction)testSpeechButtonTapped:(id)sender {
    NSLog(@"YLViewController.testSpeechButtonTapped()");
    [DynamicSpeech speakText:@"How does this sound?"];
}

- (IBAction)voiceSpeedButtonTapped:(id)sender {
    [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] TTSVoiceSpeedSegmentedControlChanged:sender];
}

- (void)updateSelectSoundsSwitchFlipped:(id)sender {
    NSLog(@"YLViewController.updateSelectSoundsSwitchFlipped()");
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
        NSLog(@"YLViewController.wanderGuardSwitchFlipped() Turning wander guard ON");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setWanderGuardActivated:YES];
        wanderSetting.text = @"Wander Guard is ON.";
    } else {
        NSLog(@"YLViewController.wanderGuardSwitchFlipped() Turning wander guard OFF");
        [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] setWanderGuardActivated:NO];
        wanderSetting.text = @"Wander Guard is OFF.";
    }
    bool wanderGuard =         [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] wanderGuardActivated];
    NSLog(@"YLViewController.wanderGuardSwitchFlipped() wanderGuard: %d", wanderGuard);
}

- (void) setUploadDataStatusText:(NSString*) text{
    uploadDataStatus.alpha = 1.0;
    uploadDataStatus.text = text;
}

- (void) setDownloadDataStatusText:(NSString*) text{
    downloadDataStatus.alpha = 1.0;
    downloadDataStatus.text = text;
}

- (void)uploadDataToCloudButtonPressed:(id)sender {
    NSLog(@"YLViewController.uploadDataToCloudButtonPressed()");
    [self disableUploadDataButton];
    
//    [self performSelectorOnMainThread:@selector(setUploadDataStatusText:) withObject:@"Working now..." waitUntilDone:YES];
    [self setUploadDataStatusText:@"Working..."];
    
    uploadDataSpinner.alpha = 1.0;
    [uploadDataSpinner startAnimating];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminSendDataButtonPressed:self];
    
}


 - (void)downloadDataFromCloudButtonPressed:(id)sender { // rjl 8/16/14
    NSLog(@"YLViewController.downloadDataFromCloudButtonPressed()");
    [self disableDownloadDataButton];
//     [self performSelectorOnMainThread:@selector(setDownloadDataStatusText:) withObject:@"Working now..." waitUntilDone:YES];
     dispatch_async(dispatch_get_main_queue(), ^{
         downloadDataStatus.text = @"working...";
         downloadDataStatus.alpha = 1.0;
         downloadDataSpinner.alpha = 1.0;
         [downloadDataSpinner startAnimating];
     });
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] adminDownloadDataButtonPressed:self];
}
 

- (void)enableUploadDataButton {
    NSLog(@"YLViewController.enableUploadDataButton()");
    
    uploadDataButton.enabled = YES;
    uploadDataButton.alpha = 1.0;
}

- (void)disableUploadDataButton {
    NSLog(@"YLViewController.disableUploadDataButton()");
    
    //sandy changed to yes and it crashed because it depends on the network connection
    //uploadDataButton.enabled = YES;
    uploadDataButton.enabled = NO;
    uploadDataButton.alpha = 0.5;
}

- (void)uploadDataRequestDone {
    NSLog(@"YLViewController.uploadDataRequestDone()");
    
    [self enableUploadDataButton];
    
    uploadDataStatus.text = @"Data uploaded successfully";
    
    uploadDataSpinner.alpha = 0.0;
    [uploadDataSpinner stopAnimating];
}

- (void)enableDownloadDataButton {
    NSLog(@"YLViewController.enableDownloadDataButton()");
    
    downloadDataButton.enabled = YES;
    downloadDataButton.alpha = 1.0;
}

- (void)disableDownloadDataButton {
    NSLog(@"YLViewController.disableDownloadDataButton()");
    
    //sandy changed to yes and it crashed because it depends on the network connection
    //uploadDataButton.enabled = YES;
    downloadDataButton.enabled = NO;
    downloadDataButton.alpha = 0.5;
}

 - (void)downloadDataRequestDone {
    NSLog(@"YLViewController.downloadDataRequestDone()");
    [self setDownloadDataStatusText: @"Data downloaded successfully!"];
//    [mYLViewController performSelectorOnMainThread:@selector(setDownloadDataStatusText:) withObject:newStatus waitUntilDone:YES];
    
    [mYLViewController enableDownloadDataButton];
    
    mYLViewController.downloadDataSpinner.alpha = 0.0;
    [mYLViewController.downloadDataSpinner stopAnimating];
}

+ (YLViewController*) getViewController{
    return mYLViewController;
}

#pragma mark YLViewController Private Methods

@end
