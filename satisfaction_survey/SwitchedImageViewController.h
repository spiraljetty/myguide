/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> 
#import "RVRotationViewDelegate.h"
#import "RVRotationView.h"

@interface SwitchedImageViewController : UIViewController <RVRotationViewDelegate>
{
    IBOutlet UISwitch *s;
    IBOutlet UIImageView *iv;
    IBOutlet UISegmentedControl *satisfactionRating;
    IBOutlet UILabel *currentSatisfactionLabel;
    IBOutlet UIButton *currentReplayButton;
    
    IBOutlet UILabel *currentPromptLabel;
    NSString *currentPromptString;
    
    MPMoviePlayerController *moviePlayerController;
    
    NSString *imageDirectory;
    

    RVRotationView *rotationView;
    
    UIButton *rotateLeftButton;
    UIButton *rotateRightButton;
    UIButton *startButton;
    UIButton *stopButton;
    UISlider *rotationSpeedSlider;
    
    IBOutlet UIButton *stronglyDisagreeButton;
    IBOutlet UIButton *disagreeButton;
    IBOutlet UIButton *agreeButton;
    IBOutlet UIButton *stronglyAgreeButton;
    IBOutlet UIButton *neutralButton;
    IBOutlet UIButton *doesNotApplyButton;
    
    IBOutlet UISegmentedControl *satisfactionRating1;
    IBOutlet UISegmentedControl *satisfactionRating2;
    IBOutlet UISegmentedControl *satisfactionRating3;
    IBOutlet UISegmentedControl *satisfactionRating4;
    IBOutlet UISegmentedControl *satisfactionRating5;
    IBOutlet UISegmentedControl *satisfactionRating6;
    IBOutlet UISegmentedControl *satisfactionRating7;
    IBOutlet UISegmentedControl *satisfactionRating8;
    IBOutlet UISegmentedControl *satisfactionRating9;
    IBOutlet UISegmentedControl *satisfactionRating10;
    IBOutlet UISegmentedControl *satisfactionRating11;
    IBOutlet UISegmentedControl *satisfactionRating12;
    IBOutlet UISegmentedControl *satisfactionRating13;
    IBOutlet UISegmentedControl *satisfactionRating14;
    IBOutlet UISegmentedControl *satisfactionRating15;
    IBOutlet UISegmentedControl *satisfactionRating16;
    IBOutlet UISegmentedControl *satisfactionRating17;
    IBOutlet UISegmentedControl *satisfactionRating18;
    IBOutlet UISegmentedControl *satisfactionRating19;
    IBOutlet UISegmentedControl *satisfactionRating20;
    IBOutlet UISegmentedControl *satisfactionRating21;
    IBOutlet UISegmentedControl *satisfactionRating22;
    IBOutlet UISegmentedControl *satisfactionRating23;
    IBOutlet UISegmentedControl *satisfactionRating24;
    IBOutlet UISegmentedControl *satisfactionRating25;
    IBOutlet UISegmentedControl *satisfactionRating26;
    IBOutlet UISegmentedControl *satisfactionRating27;
    IBOutlet UISegmentedControl *satisfactionRating28;
}

@property (nonatomic, retain) IBOutlet UILabel *currentPromptLabel;

@property (nonatomic, retain) IBOutlet UIButton *stronglyDisagreeButton;
@property (nonatomic, retain) IBOutlet UIButton *disagreeButton;
@property (nonatomic, retain) IBOutlet UIButton *agreeButton;
@property (nonatomic, retain) IBOutlet UIButton *stronglyAgreeButton;
@property (nonatomic, retain) IBOutlet UIButton *neutralButton;
@property (nonatomic, retain) IBOutlet UIButton *doesNotApplyButton;

@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating1;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating2;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating3;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating4;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating5;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating6;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating7;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating8;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating9;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating10;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating11;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating12;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating13;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating14;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating15;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating16;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating17;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating18;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating19;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating20;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating21;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating22;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating23;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating24;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating25;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating26;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating27;
@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating28;

@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating;

@property (nonatomic, retain) IBOutlet UILabel *currentSatisfactionLabel;
@property (nonatomic, retain) IBOutlet UIButton *currentReplayButton;

@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, retain) RVRotationView *rotationView;

- (IBAction) switchChanged: (UISwitch *) aSwitch;
//- (IBAction)segmentedControlChanged:(id)sender;
- (IBAction)segmentedControlIndexChanged:(UISegmentedControl *)aControl;
- (IBAction)segmentedControlPressedWithIndex:(int)segmentedControlIndex;
- (IBAction)faceButtonPressed:(id)sender;

-(IBAction)stronglyDisagreeFaceButtonPressed:(id)sender;
-(IBAction)disagreeFaceButtonPressed:(id)sender;
-(IBAction)agreeFaceButtonPressed:(id)sender;
-(IBAction)stronglyAgreeFaceButtonPressed:(id)sender;
-(IBAction)neutralFaceButtonPressed:(id)sender;
-(IBAction)doesNotApplyFaceButtonPressed:(id)sender;

-(IBAction)pressedSatisfactionReplayButton:(id)sender;

-(IBAction)playMovie:(id)sender;
-(IBAction)playSecondMovie:(id)sender;
-(IBAction)playThirdMovie:(id)sender;
-(IBAction)playFourthMovie:(id)sender;
-(IBAction)stopMovie:(id)sender;

@property (nonatomic, retain) NSString *imageDirectory;

-(id)initWithImageDirecotry:(NSString *)directoryName;

-(void)reloadImages;

- (void)uniqueRotationViewSetup;

- (void)updateSatisfactionPromptLabelWithString:(NSString*)newText;

@end
