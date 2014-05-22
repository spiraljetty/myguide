//
//  DynamicStartAppButtonView.m
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import "DynamicStartAppButtonView.h"

@implementation DynamicStartAppButtonView

@synthesize demoButton;
@synthesize demoButtonType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
               type:(DemoButtonType)aType
                text:(NSString *)buttonText
                target:(id)aTarget
                selector:(SEL)aSelector
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        demoButtonType = aType;
        
        self.demoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        demoButton.titleLabel.font = [UIFont boldSystemFontOfSize:50];
        demoButton.titleLabel.numberOfLines = 0;
        demoButton.titleLabel.shadowOffset = CGSizeMake(-1.0, -1.0);
//        [demoButton setTitle:@"  DEMO \nBUTTON" forState:UIControlStateNormal];
        [demoButton setTitle:buttonText forState:UIControlStateNormal];
        [demoButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [demoButton addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
        
        switch (aType) {
            case kRoundedRectBlueSpeckled:
                demoButton.frame = CGRectMake(10, 10, 200, 51);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton1.png"] forState:UIControlStateNormal];
                break;
            case kRectWhiteGradient:
                demoButton.frame = CGRectMake(10, 10, 200, 51);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton2.png"] forState:UIControlStateNormal];
                break;
            case kPopRectGreen:
                demoButton.frame = CGRectMake(10, 10, 200, 51);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton3.png"] forState:UIControlStateNormal];
                break;
            case kPopRectDarkBlue:
                demoButton.frame = CGRectMake(10, 10, 199, 51);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton4.png"] forState:UIControlStateNormal];
                break;
            case kRoundedRectBlueSpeckledLarge:
                demoButton.frame = CGRectMake(10, 10, 400, 102);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton1@2x.png"] forState:UIControlStateNormal];
                break;
            case kRectWhiteGradientLarge:
                demoButton.frame = CGRectMake(10, 10, 400, 102);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton2@2x.png"] forState:UIControlStateNormal];
                break;
            case kPopRectGreenLarge:
                demoButton.frame = CGRectMake(10, 10, 400, 102);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton3@2x.png"] forState:UIControlStateNormal];
                break;
            case kPopRectDarkBlueLarge:
                demoButton.frame = CGRectMake(10, 10, 400, 102);
                [demoButton setBackgroundImage:[UIImage imageNamed:@"demoButton4@2x.png"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        [self addSubview:demoButton];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
