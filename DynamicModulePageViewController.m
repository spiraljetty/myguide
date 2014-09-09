//
//  DynamicModulePageViewController.m
//  satisfaction_survey
//
//  Created by David Horton on 1/17/13.
//
//

#import "DynamicModulePageViewController.h"
#import "DynamicModuleViewController_Pad.h"

NSString *kPagesNameKey = @"Name";
NSString *kPagesTypeKey = @"Type";
NSString *kPagesImagePageKey = @"ImagePage";
NSString *kPagesImageFilenameKey = @"ImageFilename";
NSString *kPagesShowHeaderKey = @"ShowHeader";
NSString *kPagesHeaderTextKey = @"HeaderText";
NSString *kPagesHeaderTTSFilenamePrefixKey = @"HeaderTTSFilenamePrefix";
NSString *kPagesShowButtonsForKey = @"ShowButtonsFor";
NSString *kPagesTextKey = @"Text";
NSString *kPagesTTSFilenamePrefixKey = @"TTSFilenamePrefix";
NSString *kPagesContainsTerminologyKey = @"ContainsTerminology";
NSString *kPagesTerminologyButtonsKey = @"TerminologyButtons";

@interface DynamicModulePageViewController ()

@end

@implementation DynamicModulePageViewController

@synthesize delegate, isSurveyPage;
@synthesize name, type, imagePage, imageFilename, showHeader, headerColor, headerText, headerTTSFilenamePrefix;
@synthesize showButtonsFor, text, TTSFilenamePrefix, containsTerminology, terminologyButtons;
@synthesize dynamicPageHeader, dynamicPageSubDetail;

- (id)initWithDictionary:(NSDictionary *)pageDictionary {
    self = [super init];
    if (self) {

    NSLog(@"DynamicModulePageViewController.initWithDictionary() dict: %@", pageDictionary);

    isSurveyPage = NO;
    
    name = [pageDictionary objectForKey:kPagesNameKey];
    type = [pageDictionary objectForKey:kPagesTypeKey];
    imagePage = [[pageDictionary objectForKey:kPagesImagePageKey] boolValue];
    imageFilename = [pageDictionary objectForKey:kPagesImageFilenameKey];
    showHeader = [[pageDictionary objectForKey:kPagesShowHeaderKey] boolValue];
    headerText = [pageDictionary objectForKey:kPagesHeaderTextKey];
    headerTTSFilenamePrefix = [pageDictionary objectForKey:kPagesHeaderTTSFilenamePrefixKey];
    showButtonsFor = [pageDictionary objectForKey:kPagesShowButtonsForKey];
    text = [pageDictionary objectForKey:kPagesTextKey];
    TTSFilenamePrefix = [pageDictionary objectForKey:kPagesTTSFilenamePrefixKey];
    containsTerminology = [[pageDictionary objectForKey:kPagesContainsTerminologyKey] boolValue];
    terminologyButtons = [pageDictionary objectForKey:kPagesTerminologyButtonsKey];

    NSLog(@"DynamicModulePageViewController.initWithDictionary()Initialized dynamic page: %@ (image: %i, header: %i, terminology: %i)...",name,imagePage,showHeader,containsTerminology);
    }
    return self;
}

- (void)setPageHeaderColorTo:(UIColor *)thisColor {
    headerColor = thisColor;
}

- (void)setHeaderContent {
    float angle =  270 * M_PI  / 180;
    CGAffineTransform rotateRight = CGAffineTransformMakeRotation(angle);
    float leftAngle =  90 * M_PI  / 180;
    CGAffineTransform rotateLeft = CGAffineTransformMakeRotation(leftAngle);
    
    dynamicPageHeader = [[DynamicPageDetailViewController alloc] initWithNibName:nil bundle:nil];
//    dynamicPageHeader.view.alpha = 1.0;
    dynamicPageHeader.view.frame = CGRectMake(0, 0, 1024, 233);
//    dynamicPageHeader.view.backgroundColor = [UIColor clearColor];
    [dynamicPageHeader.view setCenter:CGPointMake(100.0f, 104.0f)];
//    dynamicPageHeader.view.transform = rotateLeft;
    
    DynamicModuleViewController_Pad *currDelegate = (DynamicModuleViewController_Pad *)delegate;
    dynamicPageHeader.dynamicModuleName = currDelegate.moduleName;
    NSLog(@"DynamicModulePageViewController.setHeaderContent() Header set to: %@",dynamicPageHeader.dynamicModuleName);
    
    [self.view addSubview:dynamicPageHeader.view];
//    [self.view sendSubviewToBack:physicianDetailVC.view];
}

- (void)setSubDetailContent {
    NSLog(@"DynamicModulePageViewController.setSubDetailContent()");

    if ([headerText isEqualToString:@"NA"]) {
        dynamicPageSubDetail.headerLabelText = @"";
        dynamicPageSubDetail.dynamicPageHeaderLabel.text = @"";
    } else {
        dynamicPageSubDetail.headerLabelText = headerText;
        dynamicPageSubDetail.dynamicPageHeaderLabel.text = headerText;
    }
    dynamicPageSubDetail.subDetailSectionLabelText = text;
    dynamicPageSubDetail.dynamicPageSubDetailSectionLabel.text = text;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    if (showHeader) {
//        [self setHeaderContent];
//    }
    [self setSubDetailContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
