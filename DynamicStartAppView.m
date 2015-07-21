//
//  DynamicStartAppView.m
//  satisfaction_survey
//
//  Created by dhorton on 1/21/13.
//
//

#import "DynamicStartAppView.h"
#import "DynamicStartAppButtonView.h"
#import "KSLabel.h"

@implementation DynamicStartAppView

@synthesize showInstitutionImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        DemoButtonView *demoButtonView = [[DemoButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*i, 0, self.view.frame.size.width, 70) type:6 text:@"  DEMO \nBUTTON"];

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
               institutionImageFileName:(NSString *)institutionImageFileName
               fullWelcomeClinicText:(NSString *)welcomeClinicText
                target:(id)aTarget
                selector:(SEL)aSelector
                showInstitutionImage:(BOOL)shouldShowInstitutionImage
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        float angle =  270 * M_PI  / 180;
        CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
        float leftAngle =  90 * M_PI  / 180;
        CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
        
        UIImageView *allWhiteBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_white.png"]];
        allWhiteBack.frame = CGRectMake(0, 0, 768, 1024);
        [self addSubview:allWhiteBack];
        
        if (shouldShowInstitutionImage) {
            int divideOriginalInstitutionImageBy = 2;
            UIImageView *institutionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vapachs_launch-ipad_landscape_trim.png"]];
            institutionImageView.frame = CGRectMake(0, 0, institutionImageView.frame.size.width/divideOriginalInstitutionImageBy, institutionImageView.frame.size.height/divideOriginalInstitutionImageBy);
            [institutionImageView setCenter:CGPointMake(460.0f, 670.0f)];
            institutionImageView.transform = rotateLeft;
            [self addSubview:institutionImageView];
        }
        
        KSLabel *welcomeToMainAndSubClinicLabel = [[KSLabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 300)];
        welcomeToMainAndSubClinicLabel.drawBlackOutline = YES;
        welcomeToMainAndSubClinicLabel.drawGradient = YES;
        welcomeToMainAndSubClinicLabel.text = [NSString stringWithFormat:@"%@",welcomeClinicText];
        welcomeToMainAndSubClinicLabel.textAlignment = UITextAlignmentCenter;
        welcomeToMainAndSubClinicLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:60];
        welcomeToMainAndSubClinicLabel.numberOfLines = 0;
        [welcomeToMainAndSubClinicLabel setCenter:CGPointMake(512.0f, 150.0f)];
//        [welcomeToMainAndSubClinicLabel setCenter:CGPointMake(150.0f, 512.0f)];
        //welcomeToMainAndSubClinicLabel.transform = rotateRight;
        [self addSubview:welcomeToMainAndSubClinicLabel];
        
        UIImageView *taperedWhiteLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapered_fade_dividing_line-horiz-lrg.png"]];
        taperedWhiteLine.frame = CGRectMake(0, 0, 700, 50);
        [taperedWhiteLine setCenter:CGPointMake(512.0f, 300.0f)];
//        [taperedWhiteLine setCenter:CGPointMake(300.0f, 512.0f)];
        //taperedWhiteLine.transform = rotateRight;
        [self addSubview:taperedWhiteLine];
        
        DynamicStartAppButtonView *startAppButtonView = [[DynamicStartAppButtonView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 102) type:kPopRectGreenLarge text:@"START" target:aTarget selector:aSelector fontsize:50];
        [startAppButtonView setCenter:CGPointMake(800.0f, 400.0f)];
        //startAppButtonView.transform = rotateRight;
        [self addSubview:startAppButtonView];
        
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
