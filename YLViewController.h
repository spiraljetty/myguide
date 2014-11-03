//
//  YLViewController.h
//  YLProgressBar
//
//  Created by Yannick Loriot on 05/02/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ARCMacro.h"
#import "SettingsViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class YLProgressBar;

@interface YLViewController : UIViewController <MKMapViewDelegate>
{
    IBOutlet UIImageView *networkImage;
    IBOutlet UILabel *networkStatus;
    IBOutlet UILabel *linkStatus;
    IBOutlet UIImageView *linkImage;
    IBOutlet UILabel *wanderSetting;
    
    IBOutlet UILabel *wifiSSIDName;
    IBOutlet UISwitch *wanderGuardSwitch;
    
    IBOutlet UIActivityIndicatorView *loadSpinner;
    IBOutlet UILabel *loadingFileName;
    IBOutlet UILabel *loadingLabel;
    
    CGFloat progressBarIncrements;
    
    IBOutlet UISegmentedControl *voiceTypeSegmentedControl;
    IBOutlet UISegmentedControl *voiceSpeedSegmentedControl;
    IBOutlet UIStepper *volumeControlStepper;
    IBOutlet UIStepper *pitchControlStepper;
    IBOutlet UIStepper *speedControlStepper;
    int previousVolumeStepperValue;
    int previousPitchStepperValue;
    int previousSpeedStepperValue;
    
    IBOutlet UIImageView *headphoneImage;
    IBOutlet UILabel *soundStatus;
    IBOutlet UILabel *volumeNumber;
    IBOutlet UILabel *pitchNumber;
    IBOutlet UILabel *speedNumber;
    
    IBOutlet UISwitch *allowSpeakerSwitch;
    
    IBOutlet UISwitch *updateSelectSoundsSwitch;
    IBOutlet UILabel *updateSoundsLabel;
    
    IBOutlet UIScrollView *currentScrollView;
    IBOutlet UILabel *labelLocationInformation;
    
    IBOutlet UILabel *uploadDataStatus;
    IBOutlet UIActivityIndicatorView *uploadDataSpinner;
    IBOutlet UIButton *uploadDataButton;
    
    IBOutlet UILabel *downloadDataStatus;
    IBOutlet UIActivityIndicatorView *downloadDataSpinner;
    IBOutlet UIButton *downloadDataButton;
    
    IBOutlet UILabel *appVersionLabel;

@protected
    NSTimer*    progressTimer;
}

@property (nonatomic, retain) IBOutlet UILabel *wifiSSIDName;
@property (nonatomic, retain) IBOutlet UISwitch *wanderGuardSwitch;

@property (nonatomic, SAFE_ARC_PROP_RETAIN) IBOutlet YLProgressBar* progressView;
@property (nonatomic, SAFE_ARC_PROP_RETAIN) IBOutlet UILabel*       progressValueLabel;

@property (nonatomic, retain) UIScrollView *currentScrollView;
@property (nonatomic, SAFE_ARC_PROP_RETAIN) IBOutlet MKMapView *mapView;
@property (nonatomic, SAFE_ARC_PROP_RETAIN) IBOutlet UILabel *labelLocationInformation;

@property (nonatomic, retain) IBOutlet UILabel *linkStatus;
@property (nonatomic, retain) IBOutlet UILabel *wanderSetting;
@property (nonatomic, retain) IBOutlet UIImageView *networkImage;
@property (nonatomic, retain) IBOutlet UIImageView *linkImage;
@property (nonatomic, retain) IBOutlet UILabel *networkStatus;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadSpinner;
@property (nonatomic, retain) IBOutlet UILabel *loadingFileName;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;

@property (nonatomic, retain) IBOutlet UISwitch *updateSelectSoundsSwitch;
@property (nonatomic, retain) IBOutlet UILabel *updateSoundsLabel;

@property CGFloat progressBarIncrements;

@property (nonatomic, retain) UISegmentedControl *voiceTypeSegmentedControl;
@property (nonatomic, retain) UISegmentedControl *voiceSpeedSegmentedControl;
@property (nonatomic, retain) IBOutlet UIStepper *volumeControlStepper;
@property (nonatomic, retain) IBOutlet UIStepper *pitchControlStepper;
@property (nonatomic, retain) IBOutlet UIStepper *speedControlStepper;
@property int previousVolumeStepperValue;
@property int previousSpeedStepperValue;
@property int previousPitchStepperValue;

@property (nonatomic, retain) IBOutlet UIImageView *headphoneImage;
@property (nonatomic, retain) IBOutlet UILabel *soundStatus;
@property (nonatomic, retain) IBOutlet UILabel *volumeNumber;
@property (nonatomic, retain) IBOutlet UILabel *pitchNumber;
@property (nonatomic, retain) IBOutlet UILabel *speedNumber;

@property (nonatomic, retain) IBOutlet UILabel *uploadDataStatus;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *uploadDataSpinner;
@property (nonatomic, retain) IBOutlet UIButton *uploadDataButton;

@property (nonatomic, retain) IBOutlet UILabel *downloadDataStatus;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *downloadDataSpinner;
@property (nonatomic, retain) IBOutlet UIButton *downloadDataButton;

#pragma mark Constructors - Initializers

#pragma mark Public Methods

+ (YLViewController*) getViewController;

- (void)updateViewWithNewLocationInformation;
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;
- (void)zoomToCurrentLocation;

- (IBAction)colorButtonTapped:(id)sender;
- (void)updateNetworkDisplayWithConnectionType:(ConnectionType)thisConnectionType;
- (void)startLoadingActivityIndicator;
- (void)stopLoadingActivityIndicator;

- (void)changeProgressValue;

- (IBAction)voiceTypeButtonTapped:(id)sender;
- (IBAction)voiceSpeedButtonTapped:(id)sender;

- (IBAction)updateSelectSoundsSwitchFlipped:(id)sender;

- (IBAction)increaseMasterVolume:(id)sender;
- (IBAction)decreaseMasterVolume:(id)sender;

- (void)updateLinkDisplayWithLinkType:(NetworkStatus)thisNetworkStatus;

- (IBAction)volumeControlStepperChanged:(id)sender;
- (IBAction)pitchControlStepperChanged:(id)sender;
- (IBAction)speedControlStepperChanged:(id)sender;
- (IBAction)wanderGuardSwitchFlipped:(id)sender;

- (IBAction)uploadDataToCloudButtonPressed:(id)sender;
- (void)uploadDataRequestDone;
- (void)disableUploadDataButton;
- (void)enableUploadDataButton;

- (IBAction)downloadDataFromCloudButtonPressed:(id)sender;
- (void)downloadDataRequestDone;
- (void)disableDownloadDataButton;
- (void)enableDownloadDataButton;


@end
