//
//  MiniDemoViewController.h
//  satisfaction_survey
//
//  Created by David Horton on 12/8/12.
//
//

#import <UIKit/UIKit.h>

@interface MiniDemoViewController : UIViewController {
    
    IBOutlet NSString *demoText;
    IBOutlet NSString *clinicText;
    IBOutlet NSString *subClinicText;
    IBOutlet NSString *visitText;
    IBOutlet NSString *seeingText;
    IBOutlet NSString *respondentText;
    IBOutlet NSString *edText;
    IBOutlet NSString *satisfactionText;
    
    IBOutlet UILabel *demoLabel;
    IBOutlet UILabel *clinicLabel;
    IBOutlet UILabel *subClinicLabel;
    IBOutlet UILabel *visitLabel;
    IBOutlet UILabel *seeingLabel;
    IBOutlet UILabel *respondentLabel;
    IBOutlet UILabel *edLabel;
    IBOutlet UILabel *satisfactionLabel;
    
	BOOL showingMiniMenu;
    
    IBOutlet UIButton *miniMenuButton;
}
@property (nonatomic, retain) IBOutlet NSString *demoText;
@property (nonatomic, retain) IBOutlet NSString *clinicText;
@property (nonatomic, retain) IBOutlet NSString *subClinicText;
@property (nonatomic, retain) IBOutlet NSString *visitText;
@property (nonatomic, retain) IBOutlet NSString *seeingText;
@property (nonatomic, retain) IBOutlet NSString *respondentText;
@property (nonatomic, retain) IBOutlet NSString *edText;
@property (nonatomic, retain) IBOutlet NSString *satisfactionText;

@property (nonatomic, retain) IBOutlet UILabel *demoLabel;
@property (nonatomic, retain) IBOutlet UILabel *clinicLabel;
@property (nonatomic, retain) IBOutlet UILabel *subClinicLabel;
@property (nonatomic, retain) IBOutlet UILabel *visitLabel;
@property (nonatomic, retain) IBOutlet UILabel *seeingLabel;
@property (nonatomic, retain) IBOutlet UILabel *respondentLabel;
@property (nonatomic, retain) IBOutlet UILabel *edLabel;
@property (nonatomic, retain) IBOutlet UILabel *satisfactionLabel;

@property (nonatomic, retain) UIButton *miniMenuButton;

@property BOOL showingMiniMenu;


- (IBAction)menuButtonPressed;
- (IBAction)resetButtonPressed;
- (IBAction)updateAllMiniMenuLabels;

@end
