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


@interface MainLoaderViewController : UIViewController <UIAlertViewDelegate> {
    
    IBOutlet WRViewController *currentWRViewController;
    
    MiniDemoViewController *miniDemoVC;
    UIActivityIndicatorView *waitSpinner;
	UIView *waitBlack;
    UILabel *waitLabel;
    
    NSTimer *shortWaitTimer;
    
}

@property (nonatomic, retain) WRViewController *currentWRViewController;
@property (nonatomic, retain) MiniDemoViewController *miniDemoVC;
@property (nonatomic, retain) UIActivityIndicatorView *waitSpinner;
@property (nonatomic, retain) UIView *waitBlack;
@property (nonatomic, retain) UILabel *waitLabel;

@property (nonatomic, retain) NSTimer *shortWaitTimer;

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

@end
