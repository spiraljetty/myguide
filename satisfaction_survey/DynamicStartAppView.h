//
//  DynamicStartAppView.h
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import <UIKit/UIKit.h>

@interface DynamicStartAppView : UIView {
    BOOL showInstitutionImage;
}

@property BOOL showInstitutionImage;

- (id)initWithFrame:(CGRect)frame
institutionImageFileName:(NSString *)institutionImageFileName
fullWelcomeClinicText:(NSString *)welcomeClinicText
             target:(id)aTarget
           selector:(SEL)aSelector
            showInstitutionImage:(BOOL)shouldShowInstitutionImage;

@end
