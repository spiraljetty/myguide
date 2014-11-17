//
//  DynamicButtonOverlayViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 1/17/13.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ADVPercentProgressBar.h"
#import "ADVViewController.h"

@protocol DynamicButtonOverlayDelegate <NSObject>

@required
- (void)overlayNextPressed;
- (void)overlayPreviousPressed;
- (void)overlayYesPressed;
- (void)overlayNoPressed;
- (void)overlayMenuPressed;
- (void)overlayFontsizePressed;
- (void)overlayVoicePressed;
@end

@interface DynamicButtonOverlayViewController : UIViewController {
    
    id <DynamicButtonOverlayDelegate> delegate;
    
    IBOutlet NSString *buttonOverlayType;
    
    IBOutlet UIButton *nextPageButton;
    IBOutlet UIButton *previousPageButton;
    IBOutlet UIButton *voiceAssistButton;
    IBOutlet UIButton *fontsizeButton;
    IBOutlet UIButton *returnToMenuButton;
    IBOutlet UIImageView *surveyResourceBack;
    
    IBOutlet UIButton *readyForAppointmentButton;
    
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    
    IBOutlet ADVViewController *progressVC;
}
//@property (weak, nonatomic) IBOutlet ADVPercentProgressBar *pbRangePercent;

@property (nonatomic, retain) id <DynamicButtonOverlayDelegate> delegate;

@property (nonatomic, retain) IBOutlet ADVViewController *progressVC;

@property (nonatomic, retain) NSString *buttonOverlayType;

@property (nonatomic, retain) IBOutlet UIButton *nextPageButton;
@property (nonatomic, retain) IBOutlet UIButton *previousPageButton;
@property (nonatomic, retain) IBOutlet UIButton *voiceAssistButton;
@property (nonatomic, retain) IBOutlet UIButton *fontsizeButton;
@property (nonatomic, retain) IBOutlet UIButton *returnToMenuButton;
@property (nonatomic, retain) IBOutlet UIImageView *surveyResourceBack;

@property (nonatomic, retain) IBOutlet UIButton *readyForAppointmentButton;

@property (nonatomic, retain) IBOutlet UIButton *yesButton;
@property (nonatomic, retain) IBOutlet UIButton *noButton;

+ (DynamicButtonOverlayViewController*) getViewController;

- (id)initWithButtonOverlayType:(NSString *)thisButtonOverlayType;
- (void)fadeThisObject:(id)thisObject toAlpha:(CGFloat)newAlpha afterSeconds:(double)fadeSeconds;
- (void)fadeThisObjectIn:(id)thisObject;
- (void)fadeThisObjectOut:(id)thisObject;
- (void)readyForAppointmentButtonPressed;
//- (IBAction)sliderValueChanged:(UISlider *)sender;

- (void)activateDelegateOverlayPreviousPressed;
- (void)activateDelegateOverlayNextPressed;


@end
