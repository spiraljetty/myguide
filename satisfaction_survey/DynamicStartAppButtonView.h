//
//  DynamicStartAppButtonView.h
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import "DemoButton.h"

typedef enum {
    kRoundedRectBlueSpeckled,
    kRectWhiteGradient,
    kPopRectGreen,
    kPopRectDarkBlue,
    kRoundedRectBlueSpeckledLarge,
    kRectWhiteGradientLarge,
    kPopRectGreenLarge,
    kPopRectDarkBlueLarge,
    kNone,
} DemoButtonType;

@interface DynamicStartAppButtonView : UIView

//@property (nonatomic, strong) UIButton *demoButton;
@property (nonatomic, strong) DemoButton *demoButton;
@property (nonatomic, readonly) DemoButtonType demoButtonType;

- (id)initWithFrame:(CGRect)frame
               type:(DemoButtonType)aType
               text:(NSString *)buttonText
             target:(id)aTarget
           selector:(SEL)aSelector;

@end
