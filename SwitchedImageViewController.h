/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RVRotationViewDelegate.h"
#import "RVRotationView.h"
#import "SLGlowingTextField.h"

typedef enum {
    kAgreementPainScale,
    kAgreeDisagree,
    kYesNo,
    kChooseGoal,
    kRateGoalPainScale,
    kProviderTest,
    kSubclinicTest,
    kHelpfulPainScale,
    kOk,
    kGeneralSurveyPage,
    kChooseModule,
    kEnterGoal
} SurveyPageType;

@interface SwitchedImageViewController : UIViewController <RVRotationViewDelegate>
{
    IBOutlet UISwitch *s;
    IBOutlet UIImageView *iv;
    
    BOOL hideNextButton;
    BOOL hidePreviousButton;
    
    id delegate;
    int surveyPageIndex;
    
    BOOL isSurveyPage;
    
    MPMoviePlayerController *moviePlayerController;
    
    NSString *imageDirectory;
    
    RVRotationView *rotationView;
    
    UIButton *rotateLeftButton;
    UIButton *rotateRightButton;
    UIButton *startButton;
    UIButton *stopButton;
    UISlider *rotationSpeedSlider;
    
    SurveyPageType currentSurveyPageType;
    
    // Ok iVars
    IBOutlet UIButton *okButton;
    
    // Satisfaction Rating - Inverted Pain Scale iVars
    IBOutlet UISegmentedControl *satisfactionRating;
    IBOutlet UILabel *currentSatisfactionLabel;
    IBOutlet UIButton *currentReplayButton;
    
    IBOutlet UILabel *currentPromptLabel;
    NSString *currentPromptString;
    
    IBOutlet NSString *currentSatisfactionString;
    
    IBOutlet UIButton *stronglyDisagreeButton;
    IBOutlet UIButton *disagreeButton;
    IBOutlet UIButton *agreeButton;
    IBOutlet UIButton *stronglyAgreeButton;
    IBOutlet UIButton *neutralButton;
    IBOutlet UIButton *doesNotApplyButton;
    
    // Agree-Disagree iVars
    IBOutlet UIButton *newDisagreeButton;
    IBOutlet UIButton *newAgreeButton;
    IBOutlet UILabel *newAgreeDisagreeLabel;
    IBOutlet NSString *newAgreeDisagreeText;
    
    // Yes-No iVars
    IBOutlet UIButton *newNoButton;
    IBOutlet UIButton *newYesButton;
    IBOutlet UILabel *newYesNoLabel;
    IBOutlet NSString *newYesNoText;
    IBOutlet UILabel *extraYesLabel;
    IBOutlet UILabel *extraNoLabel;
    IBOutlet NSString *extraYesText;
    IBOutlet NSString *extraNoText;
    
    // Provider Test iVars
    IBOutlet NSString *provider1Text;
    IBOutlet NSString *provider2Text;
    IBOutlet NSString *provider3Text;
    IBOutlet NSString *provider4Text;
    IBOutlet NSString *provider1ImageThumb;
    IBOutlet UIButton *provider1ImageButton;
    IBOutlet UIButton *provider1TextButton;
    IBOutlet NSString *provider2ImageThumb;
    IBOutlet UIButton *provider2ImageButton;
    IBOutlet UIButton *provider2TextButton;
    IBOutlet NSString *provider3ImageThumb;
    IBOutlet UIButton *provider3ImageButton;
    IBOutlet UIButton *provider3TextButton;
    IBOutlet NSString *provider4ImageThumb;
    IBOutlet UIButton *provider4ImageButton;
    IBOutlet UIButton *provider4TextButton;
    
    IBOutlet UIButton *provider5ImageButton;
    IBOutlet UIButton *provider5TextButton;
    
    IBOutlet UILabel *providerTestLabel;
    IBOutlet NSString *providerTestText;
    
    // Subclinic Test iVars
    IBOutlet NSString *subclinic1Text;
    IBOutlet NSString *subclinic2Text;
    IBOutlet NSString *subclinic3Text;
    IBOutlet NSString *subclinic4Text;
    IBOutlet UIButton *subclinic1TextButton;
    IBOutlet UIButton *subclinic2TextButton;
    IBOutlet UIButton *subclinic3TextButton;
    IBOutlet UIButton *subclinic4TextButton;
    
    IBOutlet UIButton *subclinic5TextButton;
    
    IBOutlet UILabel *subclinicTestLabel;
    IBOutlet NSString *subclinicTestText;
    
    // Helpful iVars
    IBOutlet UILabel *helpfulLabel;
    IBOutlet NSString *helpfulText;
    IBOutlet UISegmentedControl *helpfulRating;
    
    // Choose Goal iVars
    
    int goalsSelected;
    
    IBOutlet NSString *goal1Text;
    IBOutlet NSString *goal2Text;
    IBOutlet NSString *goal3Text;
    IBOutlet NSString *goal4Text;
    IBOutlet NSString *goal5Text;
    IBOutlet UIButton *goal1TextButton;
    IBOutlet UIButton *goal2TextButton;
    IBOutlet UIButton *goal3TextButton;
    IBOutlet UIButton *goal4TextButton;
    IBOutlet UIButton *goal5TextButton;
    IBOutlet NSString *goal6Text;
    IBOutlet NSString *goal7Text;
    IBOutlet NSString *goal8Text;
    IBOutlet NSString *goal9Text;
    IBOutlet NSString *goal10Text;
    IBOutlet UIButton *goal6TextButton;
    IBOutlet UIButton *goal7TextButton;
    IBOutlet UIButton *goal8TextButton;
    IBOutlet UIButton *goal9TextButton;
    IBOutlet UIButton *goal10TextButton;
    IBOutlet UILabel *goalChooseLabel;
    IBOutlet NSString *goalChooseText;
    
    // Rate Goal iVars
    IBOutlet UISegmentedControl *goalRating;
    IBOutlet UILabel *goalRateLabel;
    IBOutlet NSString *goalRateText;
    
    // Choose Module iVars
    IBOutlet UIButton *module1Button;
    IBOutlet UIButton *module2Button;
    IBOutlet UILabel *chooseModuleLabel;
    IBOutlet NSString *chooseModuleText;
    IBOutlet UILabel *extraModule1Label;
    IBOutlet UILabel *extraModule2Label;
    IBOutlet NSString *extraModule1Text;
    IBOutlet NSString *extraModule2Text;
    
    IBOutlet UIImageView *module1Badge;
    IBOutlet UIImageView *module2Badge;
    
    IBOutlet UITextField *enterGoalTextField;
    IBOutlet NSString *userEnteredGoalText;
    
}

@property BOOL isSurveyPage;

@property BOOL hideNextButton;
@property BOOL hidePreviousButton;

@property (nonatomic, retain) id delegate;
@property int surveyPageIndex;

@property (nonatomic) SurveyPageType currentSurveyPageType;

@property (nonatomic, retain) IBOutlet UIButton *okButton;

// Satisfaction Rating - Inverted Pain Scale iVars
@property (nonatomic, retain) IBOutlet UILabel *currentPromptLabel;
@property (nonatomic, retain) NSString *currentPromptString;

@property (nonatomic, retain) IBOutlet UIButton *stronglyDisagreeButton;
@property (nonatomic, retain) IBOutlet UIButton *disagreeButton;
@property (nonatomic, retain) IBOutlet UIButton *agreeButton;
@property (nonatomic, retain) IBOutlet UIButton *stronglyAgreeButton;
@property (nonatomic, retain) IBOutlet UIButton *neutralButton;
@property (nonatomic, retain) IBOutlet UIButton *doesNotApplyButton;


@property (nonatomic, retain) IBOutlet UISegmentedControl *satisfactionRating;

@property (nonatomic, retain) IBOutlet UILabel *currentSatisfactionLabel;
@property (nonatomic, retain) IBOutlet UIButton *currentReplayButton;

@property (nonatomic, retain) NSString *currentSatisfactionString;

// Agree-Disagree iVars
@property (nonatomic, retain) IBOutlet UIButton *newDisagreeButton;
@property (nonatomic, retain) IBOutlet UIButton *newAgreeButton;
@property (nonatomic, retain) IBOutlet UILabel *newAgreeDisagreeLabel;
@property (nonatomic, retain) IBOutlet NSString *newAgreeDisagreeText;

// Yes-No iVars
@property (nonatomic, retain) IBOutlet UIButton *newNoButton;
@property (nonatomic, retain) IBOutlet UIButton *newYesButton;
@property (nonatomic, retain) IBOutlet UILabel *newYesNoLabel;
@property (nonatomic, retain) IBOutlet NSString *newYesNoText;
@property (nonatomic, retain) IBOutlet UILabel *extraYesLabel;
@property (nonatomic, retain) IBOutlet UILabel *extraNoLabel;
@property (nonatomic, retain) IBOutlet NSString *extraYesText;
@property (nonatomic, retain) IBOutlet NSString *extraNoText;

// Provider Test iVars
@property (nonatomic, retain) IBOutlet NSString *provider1Text;
@property (nonatomic, retain) IBOutlet NSString *provider2Text;
@property (nonatomic, retain) IBOutlet NSString *provider3Text;
@property (nonatomic, retain) IBOutlet NSString *provider4Text;
@property (nonatomic, retain) IBOutlet NSString *provider1ImageThumb;
@property (nonatomic, retain) IBOutlet NSString *provider2ImageThumb;
@property (nonatomic, retain) IBOutlet NSString *provider3ImageThumb;
@property (nonatomic, retain) IBOutlet NSString *provider4ImageThumb;
@property (nonatomic, retain) IBOutlet UIButton *provider1ImageButton;
@property (nonatomic, retain) IBOutlet UIButton *provider1TextButton;
@property (nonatomic, retain) IBOutlet UIButton *provider2ImageButton;
@property (nonatomic, retain) IBOutlet UIButton *provider2TextButton;
@property (nonatomic, retain) IBOutlet UIButton *provider3ImageButton;
@property (nonatomic, retain) IBOutlet UIButton *provider3TextButton;
@property (nonatomic, retain) IBOutlet UIButton *provider4ImageButton;
@property (nonatomic, retain) IBOutlet UIButton *provider4TextButton;

@property (nonatomic, retain) IBOutlet UIButton *provider5ImageButton;
@property (nonatomic, retain) IBOutlet UIButton *provider5TextButton;

@property (nonatomic, retain) IBOutlet UILabel *providerTestLabel;
@property (nonatomic, retain) IBOutlet NSString *providerTestText;

// Subclinic Test iVars
@property (nonatomic, retain) IBOutlet NSString *subclinic1Text;
@property (nonatomic, retain) IBOutlet NSString *subclinic2Text;
@property (nonatomic, retain) IBOutlet NSString *subclinic3Text;
@property (nonatomic, retain) IBOutlet NSString *subclinic4Text;
@property (nonatomic, retain) IBOutlet UIButton *subclinic1TextButton;
@property (nonatomic, retain) IBOutlet UIButton *subclinic2TextButton;
@property (nonatomic, retain) IBOutlet UIButton *subclinic3TextButton;
@property (nonatomic, retain) IBOutlet UIButton *subclinic4TextButton;

@property (nonatomic, retain) IBOutlet UIButton *subclinic5TextButton;

@property (nonatomic, retain) IBOutlet UILabel *subclinicTestLabel;
@property (nonatomic, retain) IBOutlet NSString *subclinicTestText;

// Helpful iVars
@property (nonatomic, retain) IBOutlet UILabel *helpfulLabel;
@property (nonatomic, retain) IBOutlet NSString *helpfulText;
@property (nonatomic, retain) IBOutlet UISegmentedControl *helpfulRating;

// Choose Goal iVars
@property int goalsSelected;

@property (nonatomic, retain) IBOutlet NSString *goal1Text;
@property (nonatomic, retain) IBOutlet NSString *goal2Text;
@property (nonatomic, retain) IBOutlet NSString *goal3Text;
@property (nonatomic, retain) IBOutlet NSString *goal4Text;
@property (nonatomic, retain) IBOutlet NSString *goal5Text;
@property (nonatomic, retain) IBOutlet UIButton *goal1TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal2TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal3TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal4TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal5TextButton;
@property (nonatomic, retain) IBOutlet NSString *goal6Text;
@property (nonatomic, retain) IBOutlet NSString *goal7Text;
@property (nonatomic, retain) IBOutlet NSString *goal8Text;
@property (nonatomic, retain) IBOutlet NSString *goal9Text;
@property (nonatomic, retain) IBOutlet NSString *goal10Text;
@property (nonatomic, retain) IBOutlet UIButton *goal6TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal7TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal8TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal9TextButton;
@property (nonatomic, retain) IBOutlet UIButton *goal10TextButton;
@property (nonatomic, retain) IBOutlet UILabel *goalChooseLabel;
@property (nonatomic, retain) IBOutlet NSString *goalChooseText;

// Rate Goal iVars
@property (nonatomic, retain) IBOutlet UISegmentedControl *goalRating;
@property (nonatomic, retain) IBOutlet UILabel *goalRateLabel;
@property (nonatomic, retain) IBOutlet NSString *goalRateText;

// Choose Module iVars
@property (nonatomic, retain) IBOutlet UIButton *module1Button;
@property (nonatomic, retain) IBOutlet UIButton *module2Button;
@property (nonatomic, retain) IBOutlet UILabel *chooseModuleLabel;
@property (nonatomic, retain) IBOutlet NSString *chooseModuleText;
@property (nonatomic, retain) IBOutlet UILabel *extraModule1Label;
@property (nonatomic, retain) IBOutlet UILabel *extraModule2Label;
@property (nonatomic, retain) IBOutlet NSString *extraModule1Text;
@property (nonatomic, retain) IBOutlet NSString *extraModule2Text;
@property (nonatomic, retain) IBOutlet UIImageView *module1Badge;
@property (nonatomic, retain) IBOutlet UIImageView *module2Badge;

@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, retain) RVRotationView *rotationView;

@property (nonatomic, retain) IBOutlet UITextField *enterGoalTextField;

@property (nonatomic, retain) NSString *userEnteredGoalText;

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

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)agreeButtonPressed:(id)sender;
- (IBAction)disagreeButtonPressed:(id)sender;
- (IBAction)yesButtonPressed:(id)sender;
- (IBAction)noButtonPressed:(id)sender;
- (IBAction)goal1ButtonPressed:(id)sender;
- (IBAction)goal2ButtonPressed:(id)sender;
- (IBAction)goal3ButtonPressed:(id)sender;
- (IBAction)goal4ButtonPressed:(id)sender;
- (IBAction)goal5ButtonPressed:(id)sender;
- (IBAction)goal6ButtonPressed:(id)sender;
- (IBAction)goal7ButtonPressed:(id)sender;
- (IBAction)goal8ButtonPressed:(id)sender;
- (IBAction)goal9ButtonPressed:(id)sender;
- (IBAction)goal10ButtonPressed:(id)sender;
- (IBAction)provider1ButtonPressed:(id)sender;
- (IBAction)provider2ButtonPressed:(id)sender;
- (IBAction)provider3ButtonPressed:(id)sender;
- (IBAction)provider4ButtonPressed:(id)sender;
- (IBAction)provider5ButtonPressed:(id)sender;
- (IBAction)subclinic1ButtonPressed:(id)sender;
- (IBAction)subclinic2ButtonPressed:(id)sender;
- (IBAction)subclinic3ButtonPressed:(id)sender;
- (IBAction)subclinic4ButtonPressed:(id)sender;
- (IBAction)subclinic5ButtonPressed:(id)sender;
- (IBAction)helpfulSegmentedControlIndexChanged:(UISegmentedControl *)aControl;
- (IBAction)goalRatingSegmentedControlIndexChanged:(UISegmentedControl *)aControl;

- (IBAction)module1ButtonPressed:(id)sender;
- (IBAction)module2ButtonPressed:(id)sender;

- (void)showModule1Badge;
- (void)showModule2Badge;

- (IBAction)doneEnteringGoal:(id)sender;
- (void)storeAndUpdateEnteredGoal;

@end
