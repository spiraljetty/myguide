//
//  DynamicPageSubDetailViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 1/17/13.
//
//

#import "DynamicPageSubDetailViewController.h"
#import "AppDelegate_Pad.h"
#import "DynamicContent.h"

@interface DynamicPageSubDetailViewController ()

@end

@implementation DynamicPageSubDetailViewController

@synthesize dynamicPageHeaderLabel, dynamicPageSubDetailSectionLabel, headerLabelText, subDetailSectionLabelText, dynamicImageView, needsImage, currentImageFilename;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dynamicPageHeaderLabel.text = headerLabelText;
        dynamicPageSubDetailSectionLabel.text = subDetailSectionLabelText;
        dynamicImageView.alpha = 0.0;
        needsImage = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    dynamicPageHeaderLabel.text = headerLabelText;
    dynamicPageSubDetailSectionLabel.text = subDetailSectionLabelText;
    
    if (needsImage) {
        dynamicImageView.alpha = 1.0;
        
        NSLog(@"DynamicPageSubDetailViewController.viewDidLoad() Loading imageview for current subdetail image: %@...",currentImageFilename);
        UIImage* pageImage = [UIImage imageNamed:currentImageFilename];
        if (!pageImage)
            pageImage = [DynamicContent loadImage:currentImageFilename];
        UIImageView *currentSubdetailImageView = [[UIImageView alloc] initWithImage:pageImage];
        currentSubdetailImageView.frame = CGRectMake(0, 0, 300, 300);
//        currentSubdetailImageView.transform = rotateRight;
        // sandy tried shifting by hand
        // [currentSubdetailImageView setCenter:CGPointMake(735.0f, 465.0f)];
        [currentSubdetailImageView setCenter:CGPointMake(545.0f, 500.0f)];
        [self.view addSubview:currentSubdetailImageView];
        
        [dynamicPageSubDetailSectionLabel setFrame:CGRectMake(dynamicPageSubDetailSectionLabel.frame.origin.x, dynamicPageSubDetailSectionLabel.frame.origin.y-35, dynamicPageSubDetailSectionLabel.frame.size.width-300, dynamicPageSubDetailSectionLabel.frame.size.height+80)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
