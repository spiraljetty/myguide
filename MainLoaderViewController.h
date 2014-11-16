//
//  MainLoaderViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 12/7/12.
//
//

#import <UIKit/UIKit.h>
#import "WRViewController.h"
#import "MiniDemoViewController.h"
#import "DynamicButtonOverlayViewController.h"

#import "SLViewController.h"

@interface MainLoaderViewController : UIViewController <UIAlertViewDelegate, DynamicButtonOverlayDelegate> {
    
    IBOutlet WRViewController *currentWRViewController;
    
    MiniDemoViewController *miniDemoVC;
    UIActivityIndicatorView *waitSpinner;
	UIView *waitBlack;
    UILabel *waitLabel;
    
    NSTimer *shortWaitTimer;
    
    DynamicButtonOverlayViewController *standardPageButtonOverlay;
    UIViewController *activeViewController;
    
    IBOutlet UIButton *readyForAppointmentButton;
    BOOL shouldShowReadyButton;
    SwitchedImageViewController *modalConfirmReadyForAppointment;
    
    SwitchedImageViewController *modalEnterGoal;
    
    UIButton *revealSettings;
}

@property (nonatomic, retain) UIButton *revealSettings;
@property (nonatomic, retain) WRViewController *currentWRViewController;
@property (nonatomic, retain) MiniDemoViewController *miniDemoVC;
@property (nonatomic, retain) UIActivityIndicatorView *waitSpinner;
@property (nonatomic, retain) UIView *waitBlack;
@property (nonatomic, retain) UILabel *waitLabel;

@property (nonatomic, retain) NSTimer *shortWaitTimer;

@property (nonatomic, retain) IBOutlet UIButton *readyForAppointmentButton;

@property (nonatomic, retain) DynamicButtonOverlayViewController *standardPageButtonOverlay;

@property (nonatomic, retain) SwitchedImageViewController *modalConfirmReadyForAppointment;

@property (nonatomic, retain) SwitchedImageViewController *modalEnterGoal;

+ (MainLoaderViewController*) getViewController;

-(IBAction)fadeInMiniDemoMenu;
-(IBAction)fadeOutMiniDemoMenu;
-(IBAction)showMiniDemoMenu;
-(IBAction)hideMiniDemoMenu;

- (IBAction)showWaitScreen;
- (void)hideWaitScreen:(NSTimer*)theTimer;

- (void)createNewWaitingRoomViewController;
- (void)destroyCurrentWaitingRoomViewController:(NSTimer*)theTimer;

- (IBAction)performAppReset;
- (void)fadeOutWRVC;
- (void)createNewWaitingRoomViewControllerAfterDelay:(NSTimer*)theTimer;

- (void)setActiveViewControllerTo:(UIViewController *)thisVC;
- (void)showButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;
- (void)hideButtonOverlay:(DynamicButtonOverlayViewController *)thisButtonOverlay;
- (void)showCurrentButtonOverlay;
- (void)showCurrentButtonOverlayNoButtons;
- (void)hideCurrentButtonOverlay;
- (void)finishHideButtonOverlay:(NSTimer*)theTimer;
- (void)showNextButton;
- (void)hideNextButton;
- (void)showPreviousButton;
- (void)hidePreviousButton;
- (void)fadeInReadyForAppointmentButton;
- (void)fadeOutReadyForAppointmentButton;
- (void)hideReadyForAppointmentButton;
- (void)unhideReadyForAppointmentButton;

- (void)hideModalConfirmReady;
- (void)finishHideModalConfirmReady:(NSTimer*)theTimer;
- (void)modalYesPressedInSender:(UIViewController *)senderVC;
- (void)modalNoPressedInSender:(UIViewController *)senderVC;

- (void)showModalAreYouSureView;
- (void)revealSettingsButtonPressed;
- (void)fadeOutRevealSettingsButton;
- (void)fadeInRevealSettingsButton;

- (void)showModalEnterGoalView;
- (void)hideModalEnterGoalView;

@end
