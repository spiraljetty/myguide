//
//  SettingsViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kConnected,
    kConnectionPending,
    kConnectionFailed,
} ConnectionType;

@class ControlView;
@class YLViewController;

@interface SettingsViewController : UIViewController {
    ControlView *controlView;
    BOOL buttonOpen;
    UIButton *invisibleShowHideButton;
    YLViewController *soundViewController;
    UIImageView *networkImage;
    UILabel *networkStatus;
    ConnectionType currentConnectionType;
}

@property (nonatomic, retain) ControlView *controlView;
@property (nonatomic, retain) UIButton *invisibleShowHideButton;
@property (strong, nonatomic) YLViewController *soundViewController;
@property (nonatomic, retain) UIImageView *networkImage;
@property (nonatomic, retain) UILabel *networkStatus;


- (id)initWithFrame:(CGRect)frame;
- (void)showHideButtonPressed;
- (void)updateNetworkStatusWithConnectionType:(ConnectionType)thisConnectionType;

@end
