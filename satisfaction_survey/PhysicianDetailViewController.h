//
//  PhysicianDetailViewController.h
//  satisfaction_survey
//
//  Created by dhorton on 1/5/13.
//
//

#import <UIKit/UIKit.h>

@interface PhysicianDetailViewController : UIViewController {
    IBOutlet UIImageView *physicianImageView;
    IBOutlet UILabel *physicianNameLabel;
    
    NSTimer *physicianTimer;
    IBOutlet UILabel *todayCareHandledByLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *physicianImageView;
@property (nonatomic, retain) IBOutlet UILabel *physicianNameLabel;

@property (nonatomic, retain) NSTimer *physicianTimer;
@property (nonatomic, retain) IBOutlet UILabel *todayCareHandledByLabel;

- (void)beginFadeOutOfCareHandledByLabel;
- (void)continueFadeOutOfCareHandledByLabel:(NSTimer*)theTimer;
- (void)finishFadeOutOfCareHandledByLabel:(NSTimer*)theTimer;

@end
