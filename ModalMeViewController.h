//
//  ModalMeViewController.h
//  ModalMe
//
//  Created by John Ray on 5/5/10.
//  Copyright Poisontooth Enterprises 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"

@interface ModalMeViewController : UIViewController {
    IBOutlet ContentViewController *modalContent;
    IBOutlet UISegmentedControl *presentationStyle;
    IBOutlet UISegmentedControl *transitionStyle;
    IBOutlet UILabel *outputLabel;
}

-(IBAction) showModal:(id)sender;

@property (nonatomic,retain) ContentViewController *modalContent;
@property (nonatomic,retain) UISegmentedControl *presentationStyle;
@property (nonatomic,retain) UISegmentedControl *transitionStyle;
@property (nonatomic,retain) UILabel *outputLabel;


@end

