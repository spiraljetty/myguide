//
//  RootViewController_Pad.m
//  ___PROJECTNAME___
//
//  Template Created by Ben Ellingson (benellingson.blogspot.com) on 4/12/10.

//

#import "RootViewController_Pad.h"
#import "RotatingSegue.h"
//#import "ReflectingView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NewPlayerView.h"
#import "SampleViewController.h"
#import "AppDelegate_Pad.h"
#import "SwitchedImageViewController.h"
#import "DynamicContent.h"
#import "QuestionList.h"
#import "DynamicSpeech.h"

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))


@implementation RootViewController_Pad

@synthesize newTimer;
@synthesize queuePlayer = mQueuePlayer;
@synthesize playerView = mPlayerView;

@synthesize modalContent;

@synthesize currentDeviceName, currentUniqueID;

@synthesize speakItemsAloud, showDefaultButton, showFlipButton, showDissolveButton, showCurlButton;
@synthesize respondentType;
@synthesize databasePath, mainTable, csvpath, csvpathCurrentFilename, databaseName;
@synthesize vcIndex;
@synthesize currentFontSize, patientSatisfactionLabelItems, familySatisfactionLabelItems, caregiverSatisfactionLabelItems, totalSurveyItems, surveyItemsRemaining, currentPromptString;
@synthesize patientPromptLabelItems, familyPromptLabelItems, caregiverPromptLabelItems, masterTTSPlayer, numSurveyItems, newChildControllers;


static RootViewController_Pad* mViewController = NULL;

+ (RootViewController_Pad*) getViewController {
    return mViewController;
}

// Establish core interface
- (void)viewDidLoad {
    NSLog(@"RootViewController.viewDidLoad()");
    mViewController = self;
    currentDeviceName = @"iPad";
    
    speakItemsAloud = YES;
    
    finishingLastItem = NO;
    
    currentFontSize = 1;
    
    //rjl 9/13/14 deprecated
    totalSurveyItems = 0;
    surveyItemsRemaining = 0;
    numSurveyItems = 22;
    
    respondentType = [[NSString alloc] initWithString:@"patient"];
    
    currentPromptString = @"";
    
    [self checkAndLoadLocalDatabase];
    
    // Create a basic background.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    //sandy
    //self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create backsplash for animation support
    backsplash = [[ReflectingView alloc] initWithFrame:CGRectInset(self.view.frame, 0.0f, 75.0f)];
    backsplash.usesGradientOverlay = NO;
    // original backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, -75.0f);
    // sandy why is this shifted by 75?
    backsplash.frame = CGRectOffset(backsplash.frame, -40.0f, -75.0f);
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
//    [backsplash setupReflection];
    // [self setupGradient];
    
    // Create small view to control AVPlayerQueue
    self.playerView = [[NewPlayerView alloc] initWithFrame:CGRectInset(self.view.frame, 100.0f, 150.0f)];
    self.playerView.frame = CGRectOffset(self.playerView.frame, 0.0f, 80.0f);
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.playerView];
    [self.view sendSubviewToBack:self.playerView];
    
    // Add a page view controller
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numSurveyItems;
    [self.view addSubview:pageControl];
    
    // Load a survey type from storyboard
    NSLog(@"RootViewController.viewDidLoad() uses storyboard survey_painscale_template");
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"survey_painscale_template" bundle:[NSBundle mainBundle]];
    
    NSMutableArray *storyboardControllerArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    for (int i = 0; i < numSurveyItems; i++) {
        [storyboardControllerArray addObject:[aStoryboard instantiateViewControllerWithIdentifier:@"0"]];
        
    }
    
    newChildControllers = [[NSMutableArray alloc] initWithArray:storyboardControllerArray];
        
    NSLog(@"RootViewController.viewDidLoad() CREATED CHILDCONTROLLERS...");
    
    // Set each child as a child view controller, setting its tag and frame
    for (SwitchedImageViewController *controller in newChildControllers)
    {
       //sandy resetting this just to see what happens changed back to 1024
       // controller.view.tag = 1066;
        controller.view.tag = 1024;
       // trying to shift survey_painscale_template back to correct place like rjl
        // original controller.view.frame = backsplash.bounds;
        //controller.view.frame = [[UIScreen mainScreen] applicationFrame];
        //backsplash.frame = CGRectOffset(backsplash.frame, -40.0f, -75.0f);
        controller.view.frame = backsplash.bounds;
        [self addChildViewController:controller];
    }
    
    // Initialize scene with first child controller
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[newChildControllers objectAtIndex:0];
    [backsplash addSubview:controller.view];
    
    // Create Navigation Item for custom bar
    item = [[UINavigationItem alloc] initWithTitle:@"Patient Satisfaction Survey"];
//    item.leftBarButtonItem = BARBUTTON(@"\u25C0 Previous", @selector(progress:));
//    item.rightBarButtonItem = BARBUTTON(@"Next \u25B6", @selector(regress:));
    
    // Create and add custom Navigation Bar
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    bar.tintColor = COOKBOOK_PURPLE_COLOR;
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bar.items = [NSArray arrayWithObject:item];
    [self.view addSubview:bar];
    
    [self createAdditionalSurveyLabelArrays];

    
//    [self addNewActionsToButtons];
	
}

- (UISegmentedControl *)currentActiveSegmentedControlForIndex:(int)currentVCIndex {
    SwitchedImageViewController *currentController = [newChildControllers objectAtIndex:currentVCIndex];
    return currentController.satisfactionRating;
}

- (void)testButtonMethod {
    NSLog(@"Test...");
}


- (void)createAdditionalSurveyLabelArrays {
    NSLog(@"RootViewController.createAdditionalSurveyLabelArrays()");
    patientSatisfactionLabelItems = [[NSArray alloc] initWithObjects:
                                     @"The staff treated me with respect.",
                                     @"",@"",@"",@"",
                                     @"",@"",@"",@"",
                                     @"",@"",@"",@"",
                                     @"",@"",
                                     @"I would recommend this guide to others.",
                                     @"I am pleased with the care I have received.",
                                     @"I received high quality care.",
                                     @"My unique treatment needs were addressed.",
                                     @"The staff involved me in setting my treatment goals.",
                                     @"I was given clear, understandable information about my concerns and questions.",
                                     @"Clinic staff put me at ease and took time to hear my concerns.",nil];
//    [NSArray arrayWithObjects:plainPart,csvPart,nil];
   /* patientSatisfactionLabelItems = [[NSArray alloc] initWithObjects:
                                     @"The staff treated me with respect.",
                                     @"",@"",@"",@"",
                                     @"",@"",@"",@"",
                                     @"",@"",@"",@"",
                                     @"",@"",
                                     @"I would recommend this guide to others.",
                                     @"I am pleased with the care I have received.",
                                     @"I received high quality care.",
                                      @"My unique treatment needs were addressed.",
                                     @"The staff involved me in setting my treatment goals.",
                                     @"I was given clear, understandable information about my concerns and questions.",
                                     @"Clinic staff put me at ease and took time to hear my concerns.",nil];*/
     
    /*patientSatisfactionLabelItems = [[NSArray alloc] initWithObjects:
                                     @"The staff treated me with respect.",
                                     @"Clinic staff put me at ease and took time to hear my concerns.",
                                     @"I was given clear, understandable information about my concerns and questions.",
                                     @"The staff involved me in setting my treatment goals.",
                                     @"My unique treatment needs were addressed.",
                                     @"I received high quality care.",
                                     @"I am pleased with the care I have received.",
                                     @"I would recommend this guide to others.",nil];*/
   /*sandy updated 7-14
    patientSatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"I received high quality care.",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"Unused Unused",
                                     @"The facilities were comfortable, clean and well maintained.",
                                     @"My unique treatment needs were addressed.",
                                     @"My family was included in my treatment program.",
                                     @"I know my own strengths and limitations better.",
                                     @"Clinic staff put me at ease and took time to hear my concerns.",
                                     @"I was given clear information about the clinic program.",
                                     @"I was given clear, understandable information about my concerns and questions.",
                                     @"The staff involved me in setting my treatment goals.",
                                     @"I feel that my rights as a patient have been respected.",
                                     @"My physical functioning has improved.",
                                     @"The overall quality of my life has improved.",
                                     @"I am pleased with the progress I have made.",
                                     @"The staff treated me with respect.", nil];*/

    /*familySatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"My loved one received high quality care.",
                                    @"",@"",@"",@"",
                                    @"",@"",@"",@"",
                                    @"",@"",@"",@"",
                                    @"",@"",
                                    @"Our family was included in my loved one's treatment program.",
                                    @"My loved one's treatment needs were addressed.",
                                    @"The staff involved my loved one in setting treatment goals.",
                                    @"Our family was given clear, understandable information about our concerns and questions.",
                                    @"Clinic staff put our family at ease and took time to hear our concerns.",
                                    @"The staff treated me with respect.",
                                    @"The staff treated my loved one with respect.", nil];*/
    
    // sandy 7-17 updated questions
    familySatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"My loved one received high quality care.",
                                    @"",@"",@"",@"",
                                    @"",@"",@"",@"",
                                    @"",@"",@"",@"",
                                    @"",@"",
                                    @"Our family was included in my loved one's treatment program.",
                                    @"My loved one's treatment needs were addressed.",
                                    @"The staff involved my loved one in setting treatment goals.",
                                    @"Our family was given clear, understandable information about our concerns and questions.",
                                    @"Clinic staff put our family at ease and took time to hear our concerns.",
                                    @"The staff treated me with respect.",
                                    @"The staff treated my loved one with respect.", nil];
    /*familySatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"My loved one received high quality care.",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"My loved one knows his/her strengths and limitations better.",
                                    @"Our family was included in my loved one's treatment program.",
                                    @"The facilities were comfortable, clean and well maintained.",
                                    @"I am pleased with the progress my loved one has made.",
                                    @"The overall quality of my loved one's life has improved.",
                                    @"My relationship with my loved one has improved.",
                                    @"My loved one's physical functioning has improved.",
                                    @"I feel that my rights as a family member have been respected.",
                                    @"I feel that my loved one's rights as a patient have been respected.",
                                    @"My loved one's treatment needs were addressed.",
                                    @"The staff involved me in setting treatment goals for my loved one.",
                                    @"The staff involved my loved one in setting treatment goals.",
                                    @"Our family was given clear, understandable information about our concerns and questions.",
                                    @"Our family was given clear information about the clinic program.",
                                    @"Clinic staff put our family at ease and took time to hear our concerns.",
                                    @"The staff treated me with respect.",
                                    @"The staff treated my loved one with respect.", nil];*/
        /* tbd sandy 7-17 original replaced
    caregiverSatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"The patient I care for received high quality care.",
                                       @"I feel better able to provide care for my patient.",
                                       @"My patient knows his or her strengths and limitations better.",
                                       @"The facilities were comfortable, clean and well maintained.",
                                       @"I am pleased with the progress my patient has made.",
                                       @"The overall quality of my patient's life has improved.",
                                       @"My relationship with the patient I care for has improved.",
                                       @"My patient's physical functioning has improved.",
                                       @"I feel that my rights as a caregiver have been respected.",
                                       @"I feel that my patient's rights have been respected.",
                                       @"I was included in my patient's treatment program.",
                                       @"The patient I care for had their treatment needs addressed.",
                                       @"The staff involved me in setting treatment goals for my patient.",
                                       @"The staff involved the patient I care for in setting their treatment goals.",
                                       @"I was given clear, understandable information about my concerns and questions.",
                                       @"The patient I care for was given clear, understandable information about their concerns and questions.",
                                       @"I was given clear information about the clinic program.",
                                       @"The patient I care for was given clear information about the clinic program.",
                                       @"Clinic staff put me at ease and took time to hear my concerns.",
                                       @"Clinic staff put the patient I care for at ease and took time to hear their concerns.",
                                       @"The staff treated me with respect.",
                                       @"The staff treated the patient I care for with respect.", nil];*/
    
    caregiverSatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"The patient I care for received high quality care.",
                                       @"",@"",@"",@"",
                                       @"",@"",@"",@"",
                                       @"",
                                       @"I feel that my rights as a caregiver have been respected.",
                                       @"I feel that my patient's rights have been respected.",
                                       @"I was included in my patient's treatment program.",
                                       @"The patient I care for had their treatment needs addressed.",
                                       @"The staff involved me in setting treatment goals for my patient.",
                                       @"The staff involved the patient I care for in setting their treatment goals.",
                                       @"I was given clear information about the clinic program.",
                                       @"The patient I care for was given clear information about the clinic program.",
                                       @"Clinic staff put me at ease and took time to hear my concerns.",
                                       @"Clinic staff put the patient I care for at ease and took time to hear their concerns.",
                                       @"The staff treated me with respect.",
                                       @"The staff treated the patient I care for with respect.", nil];
    
 /*   patientPromptLabelItems = [[NSArray alloc] initWithObjects:@"Please tell us about the services you received in this clinic, by marking the following scale,",
                               @"Unused Unused",
                               @"Unused Unused",
                               @"Unused Unused",
                               @"Unused Unused",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                               @"As a result of my coming to the clinic and therapies,",
                                    @"As a result of my coming to the clinic and therapies,",
                               @"Please tell us about the services you received in this clinic, by marking the following scale,",
                               @"Please tell us about the services you received in this clinic, by marking the following scale,",
                                    @"Please tell us about the services you received in this clinic, by marking the following scale,",
                                    @"Please tell us about the services you received in this clinic, by marking the following scale,", nil];*/
   patientPromptLabelItems = [[NSArray alloc] initWithObjects:
                               @"Please tell us about the services you received in this clinic, by marking the following scale",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",
                               nil];
    /*patientPromptLabelItems = [[NSArray alloc] initWithObjects:
                               @"Please tell us about the services you received in this clinic, by marking the following scale",
                               @"",@"",@"",@"",
                               @"",@"",@"",
                               nil];*/
    
    /* sandy 7-17 original replaced
     familyPromptLabelItems = [[NSArray alloc] initWithObjects:@"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"As a result of my loved one coming to the clinic and therapies,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                                    @"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                                    @"Please tell us about the services your loved one received in this clinic, by marking the following scale,", nil];*/
    familyPromptLabelItems = [[NSArray alloc] initWithObjects:@"Please tell us about the services your loved one received in this clinic, by marking the following scale,",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",@"",@"",@"",
                              @"",
                              nil];
    
    /* sandy 7-17 original updated
     caregiverPromptLabelItems   = [[NSArray alloc] initWithObjects:@"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"As a result of coming to the clinic and therapies,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                       @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                       @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,", nil];*/
    caregiverPromptLabelItems   = [[NSArray alloc] initWithObjects:@"Please tell us about your impression of the services offered in this clinic, by marking the following scale,",
                                   @"",@"",@"",@"",
                                   @"",@"",@"",@"",
                                   @"",@"",@"",@"",
                                   @"",@"",@"",@"",
                                   @"",@"",@"",@"",
                                   @"",
                                   nil];
    
}

- (void)addNewActionsToButtons {
    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        NSLog(@"Call to RootViewController_Pad.addNewActionsToButtons");
        [switchedController.stronglyDisagreeButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [switchedController.disagreeButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [switchedController.agreeButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [switchedController.stronglyAgreeButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [switchedController.neutralButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [switchedController.doesNotApplyButton addTarget:self action:@selector(testButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        
        switchedController.satisfactionRating.selectedSegmentIndex = 4;
        
    }
}

- (void)setAllSegmentsTo {
    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        switchedController.satisfactionRating.selectedSegmentIndex = 4;
    }
}

- (void)updateAllSatisfactionLabelItems {
    NSLog(@"RootViewController.updateAllSatisfactionLabelItems()");
    NSArray *satisfactionLabelItemArrayToUse;
    NSArray *satisfactionPromptLabelItemArrayToUse;
    
    
    QuestionList* matchingSurvey = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    
    if (matchingSurvey != NULL){
        NSString* prompt = [matchingSurvey getHeader2];
        NSArray* questionList =[matchingSurvey getQuestionSet2];
        NSMutableArray* matchingSatisfactionLabelItems = [[NSMutableArray alloc] init];
        NSMutableArray* matchingSatisfactionPromptItems = [[NSMutableArray alloc] init];
        for (NSString* question in questionList){
            [matchingSatisfactionLabelItems addObject:question];
            [matchingSatisfactionPromptItems addObject:@""];
        }
        [matchingSatisfactionPromptItems setObject:prompt atIndexedSubscript:0];
        
        // append mini survey after satisfaction survey
        long surveyItemCount = [matchingSatisfactionLabelItems count];
        NSString* prompt2 = [matchingSurvey getHeader3];
        NSArray* questionList2 =[matchingSurvey getQuestionSet3];
        for (NSString* question in questionList2){
            [matchingSatisfactionLabelItems addObject:question];
            [matchingSatisfactionPromptItems addObject:@""];
        }
        [matchingSatisfactionPromptItems setObject:prompt2 atIndexedSubscript:surveyItemCount];
        
        surveyItemCount = [matchingSatisfactionLabelItems count];
        for (int index = 0; index < surveyItemCount; index++) {
            SwitchedImageViewController *switchedController = [newChildControllers objectAtIndex:index];
            
            switchedController.currentSatisfactionLabel.text = [matchingSatisfactionLabelItems objectAtIndex:index];
            switchedController.currentPromptLabel.text = [matchingSatisfactionPromptItems objectAtIndex:index];
            NSLog(@"RootViewController.updateAllSatisfactionLabelItems() Updating %@ item # %d %@",respondentType,index, switchedController.currentSatisfactionLabel.text);

        }
        return;
    }
    
    //rjl 9/13/14 deprecated below
    if ([respondentType isEqualToString:@"patient"]) {
        NSLog(@"RootViewController.updateAllSatisfactionLabelItems() All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = patientSatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = patientPromptLabelItems;
    } else if ([respondentType isEqualToString:@"family"]) {
        NSLog(@"RootViewController.updateAllSatisfactionLabelItems() All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = familySatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = familyPromptLabelItems;
    } else if ([respondentType isEqualToString:@"caregiver"]) {
        NSLog(@"RootViewController.updateAllSatisfactionLabelItems() All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = caregiverSatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = caregiverPromptLabelItems;
    } else {
        NSLog(@"RootViewController.updateAllSatisfactionLabelItems() Updating prompts only...No need to update satisfaction survey labels...defaults to respondent: %@", respondentType);
        satisfactionPromptLabelItemArrayToUse = patientPromptLabelItems;
    }
    
    int satisfactionLabelArrayIndex = 0;
    
    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        //        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
        NSLog(@"RootViewController.updateAllSatisfactionLabelItems() Updating %@ item # %d...",respondentType,satisfactionLabelArrayIndex);
        
        switchedController.currentSatisfactionLabel.text = [satisfactionLabelItemArrayToUse objectAtIndex:satisfactionLabelArrayIndex];
        switchedController.currentPromptLabel.text = [satisfactionPromptLabelItemArrayToUse objectAtIndex:satisfactionLabelArrayIndex];
        
        satisfactionLabelArrayIndex++;
    }
    
}

- (void)cycleFontSizeForAllLabels {
    CGFloat newFontSize = [DynamicContent cycleFontSizes];
//    int textSize = [DynamicContent currentFontSize];
//    // 1 = avenir medium 30
//    if (textSize == 1) {
//        newFontSize = 40.0f;
//        textSize = 2;
//    } else if (textSize == 2) {
//        newFontSize = 50.0f;
//        textSize = 3;
//    } else {
//        textSize = 30.0f;
//        textSize = 1;
//    }

    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
        //sandy added prompt resizing
        switchedController.currentPromptLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
    }
}

#pragma mark SQLite Database Methods

- (void)checkAndLoadLocalDatabase {
	
	NSLog(@"Loading local sqlite3 db...");
	
	// Setup some globals
//	databaseName = @"new_satisfaction_responses_deid.sql";
//    databaseName = @"testdb.sql";
    
    //databaseName = @"myguide_WR_db_d.sql";
    //sandy updated dbase name but the table is not being written properly
    databaseName = @"myguide_WR_v3_db_g.sql";
    //databaseName = @"myguide_WR_v3_db_a.sql";
    //mainTable = @"sessiondata";
    //mainTable = @"sessiondatav3";
    mainTable = @"sessiondata";
    //csvpath = @"satisfactiondata_9_23_14.csv";
     csvpath = @"satisfactiondata_1_27_15.csv";
    // sandy 7-21 should append device name and date here
    NSString *thisdeviceName = [[UIDevice currentDevice] name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy_MM_dd";
    NSString *datesubstring = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    csvpathCurrentFilename = [NSString stringWithFormat:@"satisfactiondata_%@_%@.csv", datesubstring,thisdeviceName];
    csvpath = [csvpathCurrentFilename copy];
    NSLog(@"csvpath current datename is:%@ cvspath is:%@",csvpathCurrentFilename,csvpath);
    
    // version 1 database fields
    // Current sql db database fields
    // uniqueid (integer primary key)
    // demo (numeric = running demo version of app? 1/0)
    // respondenttype (text = patient/family/caregiver)
    // voiceassist (numeric = did the respondent use the voice assist accessibility feature? 1/0)
    // fontsize (numeric = what font size did the repondent prefer? 1=small (default), 2=medium, 3=large)
    // month (numeric = 1-12)
    // year (numeric = e.g. 2012)
    // startedsurvey (numeric = did the respondent start the survey? 1/0)
    // finishedsurvey (numeric = did the respondent finish the survey? 1/0)
    // totalsurveyduration (numeric = how long did it take the respondent to complete the 16 survey items, in ms?)
    // q1 - q16 (numeric = likert rating of satisfaction item; 1=strongly disagree, 2=disagree, 3=neutral, 4=agree, 5=strongly agree, 0=NA, NULL=skipped)
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	self.databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
    //---- this is one time only use data for building a new database table for the app
    int result = sqlite3_open([self.databasePath UTF8String], &db);
           if (SQLITE_OK == result) {
        }
        else {
            NSLog(@"db opening error");
       }
    //create table here once for version2 of database
//   2.0.0 format const char* sessiondataTableQuery = "CREATE TABLE IF NOT EXISTS sessiondata ( uniqueid INTEGER, pilot NUMERIC, pretxcompleteper NUMERIC, selfquidecompleteper NUMERIC, posttxcompleteper NUMERIC, totalcompleteper NUMERIC, accesspoint TEXT, wanderON NUMERIC, appversion TEXT, pretxdur NUMERIC, selfguidedur NUMERIC, treatmentdur, posttxdur NUMERIC, totaldur NUMERIC, s15tech NUMERIC, s14recommend NUMERIC, s13know NUMERIC, s12prepared NUMERIC, s11metgoal NUMERIC, s8clinichelp NUMERIC, s7prohelp NUMERIC, s5looking NUMERIC, s4prepared NUMERIC, s3reason NUMERIC, s2goalchoice NUMERIC, todaysGoal TEXT, s1clinictest NUMERIC, s0protest NUMERIC, setprovider TEXT, setvisit TEXT, setspecialty TEXT, setclinic TEXT, ipadname TEXT, demo NUMERIC, respondenttype TEXT, month NUMERIC, year NUMERIC, startedsurvey NUMERIC, finishedsurvey NUMERIC, totalsurveyduration NUMERIC, q1 NUMERIC, q2 NUMERIC, q3 NUMERIC, q4 NUMERIC, q5 NUMERIC, q6 NUMERIC, q7 NUMERIC, q8 NUMERIC, q9 NUMERIC, q10 NUMERIC, q11 NUMERIC, q12 NUMERIC, q13 NUMERIC, q14 NUMERIC, q15 NUMERIC, q16 NUMERIC, q17 NUMERIC, q18 NUMERIC, q19 NUMERIC, q20 NUMERIC, q21 NUMERIC, q22 NUMERIC, q23 NUMERIC, q24 NUMERIC, q25 NUMERIC, q26 NUMERIC, q27 NUMERIC, q28 NUMERIC, q29 NUMERIC, q30 NUMERIC, voiceassist NUMERIC, fontsize NUMERIC)";

    // new database structure for version 2.0.1  Sandy 10-14-14
    const char* sessiondataTableQuery = "CREATE TABLE IF NOT EXISTS sessiondata ( uniqueid INTEGER,pilot NUMERIC,accesspoint TEXT,wanderON NUMERIC,appversion TEXT,ipadname TEXT,demo NUMERIC, month NUMERIC,currentdatetime NUMERIC,startedsurvey NUMERIC,finishedsurvey NUMERIC, pretxdur NUMERIC,selfguidedur NUMERIC,treatmentdur NUMERIC,posttxdur NUMERIC,totaldur NUMERIC,pretxcompleteper NUMERIC,selfquidecompleteper NUMERIC,posttxcompleteper NUMERIC,totalcompleteper NUMERIC,setvisit TEXT,setclinic TEXT,setspecialty TEXT,setprovider TEXT,respondenttype TEXT,voiceassist NUMERIC,fontsize NUMERIC, protest NUMERIC,providernameselected TEXT,clinictest NUMERIC,clinicselected TEXT,goalchoices TEXT,typedGoal TEXT,ps1reason NUMERIC,ps2prepared NUMERIC,ps3looking NUMERIC,ps4prohelp NUMERIC,ps5clinichelp NUMERIC,presurvey6 NUMERIC,presurvey7 NUMERIC,presurvey8 NUMERIC,presurvey9 NUMERIC,presurvey10 NUMERIC,q1 NUMERIC,q2 NUMERIC,q3 NUMERIC,q4 NUMERIC,q5 NUMERIC,q6 NUMERIC,q7 NUMERIC,q8 NUMERIC,q9 NUMERIC,q10 NUMERIC,q11 NUMERIC,q12 NUMERIC,q13 NUMERIC,q14 NUMERIC,q15 NUMERIC,q16 NUMERIC,q17 NUMERIC,q18 NUMERIC,q19 NUMERIC,q20 NUMERIC,q21 NUMERIC,q22 NUMERIC,q23 NUMERIC,q24 NUMERIC,q25 NUMERIC,q26 NUMERIC,q27 NUMERIC,q28 NUMERIC,q29 NUMERIC,q30 NUMERIC,selfguideselected TEXT)";
    
   char * errInfo ;
    result = sqlite3_exec(db, sessiondataTableQuery, nil, nil, &errInfo);
    
    if (SQLITE_OK == result) {
        NSLog(@"sessiondata Table Created :)");
    }else {
    NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
       NSLog(@"error in creating table %@", err);
   }
//    //--------------- end of one time table building code
    
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	// The next line may cause the db to not load properly...better do it everytime
    //	if(success) return;
    
	// If not then proceed to copy the database from the application to the users filesystem
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
    
    NSLog(@"Finished loading db: %@", databaseName);
}

-(NSString *)filePath {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:databaseName];
}

-(void)openDB {
    NSLog(@"RootViewController_Pad.openDB() ====== DB Open ========");
    if(sqlite3_open([[self filePath]UTF8String], &db) !=SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to Open");
    }
}

-(void)closeDB {
    @try {
        sqlite3_close(db);
        NSLog(@"RootViewController_Pad.openDB() ====== DB Closed ======");
    }
    @catch(NSException *ne){
        NSLog(@"RootViewController.closeDB() ERROR");
    }

}

-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value
{
    
    NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@')VALUES(?,?)",tableName,field1,field2];
    const char *sql=[sqlStr UTF8String];
    NSLog(@"RootViewController_Pad.insertrecordInTable() sqlStr is %@", sqlStr);
    sqlite3_stmt *statement1;
    
    if(sqlite3_prepare_v2(db, sql, -1, &statement1, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement1, 1, [field1Vaue UTF8String], -1, nil);
        sqlite3_bind_text(statement1, 2, [field2Value UTF8String], -1, nil);
        NSLog(@"insertrecordIntoTable()====== Field Updated! ======");
    }
    if(sqlite3_step(statement1) !=SQLITE_DONE)
        NSAssert(0, @"Error upadating table");
    sqlite3_finalize(statement1);
}

-(void)updaterecordInTable:(NSString*)tableName withIDField:(NSString*)IDField IDFieldValue:(NSString*)IDField1Vaue andNewField:(NSString*)newField newFieldValue:(NSString*)newFieldValue
{
    ////const char *sql = "update Coffee Set CoffeeName = ?, Price = ? Where CoffeeID = ?";
    NSString *sqlStr=[NSString stringWithFormat:@"UPDATE '%@' Set '%@' = ? Where '%@' = ?",tableName, newField, IDField];
    const char *sql=[sqlStr UTF8String];
    NSLog(@"RootViewController_Pad.updaterecordInTable() sqlStr is %@", sqlStr);
    sqlite3_stmt *statement1;
    
    if(sqlite3_prepare_v2(db, sql, -1, &statement1, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement1, 1, [newFieldValue UTF8String], -1, nil);
        sqlite3_bind_text(statement1, 2, [IDField1Vaue UTF8String], -1, nil);
        NSLog(@"updaterecordInTable()====== Field Updated! ======");
    }
    if(sqlite3_step(statement1) !=SQLITE_DONE)
        NSAssert(0, @"Error upadating table");
    sqlite3_finalize(statement1);
}

-(void)createNewRespondentWithRespondentType:(NSString*)currentRespondentType {
    currentUniqueID = [self getUniqueIDFromCurrentTime];
    NSString *uniqueIDString = [NSString stringWithFormat:@"%d", currentUniqueID];
    [self insertrecordIntoTable:mainTable withField1:@"uniqueid" field1Value:uniqueIDString andField2:@"respondenttype" field2Value:currentRespondentType];
   // NSLog(@"RootViewController_Pad.createNewRespondentWithRespondentType %d %@", currentUniqueID, uniqueIDString);

}

- (void)updateSurveyNumberForField:(NSString *)surveyItem withThisRatingNum:(int)thisRating {
    [self updateSatisfactionRatingForField:surveyItem withSelectedIndex:thisRating];
}

- (void)updateSurveyTextForField:(NSString *)surveyItem withThisText:(NSString *)thisText {
    [self updateSatisfactionTextForField:surveyItem withThisText:thisText];
}

-(void)updateSatisfactionTextForField:(NSString*)satisfactionItem withThisText:(NSString *)thisText {
    // WORKS: UPDATE sessiondata Set month = 10 Where uniqueid = 1
    [self openDB];
    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;
    // Setup the SQL Statement and compile it for faster access
    //sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = '%@' Where uniqueid = %d", satisfactionItem, thisText, currentUniqueID];
    sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = '%@' Where uniqueid = %d", satisfactionItem, thisText, currentUniqueID];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    NSLog(@"RootViewController_Pad.updateSatisfactionTextForField() sqlStr is %@", sqlStatementString);
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        // Loop through the results and add them to the feeds array
        if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"updateSatisfactionTextForField()======== Updated row for respondent %d (%@ = '%@') ! =========", currentUniqueID, satisfactionItem, thisText);
        } else {
            NSLog(@"======== Insert failed! =========");
        }
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    [self closeDB];
}

-(void)updateSatisfactionRatingForField:(NSString*)satisfactionItem withSelectedIndex:(int)currentIndex {
    // WORKS: UPDATE sessiondata Set month = 10 Where uniqueid = 1
    [self openDB];
    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;
    // Setup the SQL Statement and compile it for faster access
    //sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = %d Where uniqueid = %d", satisfactionItem, currentIndex, currentUniqueID];
    sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = %d Where uniqueid = %d", satisfactionItem, currentIndex, currentUniqueID];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    NSLog(@"RootViewController_Pad.updateSatisfactionRatingForField() sqlStr is %@", sqlStatementString);

    int result = sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL);
    NSLog(@"======== sqlite_prepare result %d ", result);
    if(result == SQLITE_OK) {
        // Loop through the results and add them to the feeds array
        if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"updateSatisfactionRatingForField======== Updated row for respondent %d (%@ = %d) ! =========", currentUniqueID, satisfactionItem, currentIndex);
        } else {
            NSLog(@"======== Insert failed! =========");
        }
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    [self closeDB];
}

-(void)putNewRespondentInDB {
    
    int fontsize = -2;
     NSLog(@"Inserting new respondent in DB: %@...",respondentType);
    [self openDB];
    
    // Create new entry with uniqueid (integer primary key) and respondenttype (text = patient/family/caregiver)
    
    // Update the following fields:
    
    currentUniqueID = [self getUniqueIDFromCurrentTime];
//    BOOL inDemoMode = [[AppDelegate_Pad sharedAppDelegate] isAppRunningInDemoMode];
    BOOL inDemoMode = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isAppRunningInDemoMode];
//    NSString *currentAppVersion = [[AppDelegate_Pad sharedAppDelegate] appVersion];
    NSString *currentAppVersion = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] appVersion];
    
//    NSString *currentDeviceName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deviceName];
//    NSString *currentDeviceName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deviceName];
    
    NSLog(@"Inserting new respondent in DB for device: %@...",[[UIDevice currentDevice] name]);
    
    NSString *thisVisitString;
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isFirstVisit]) {
        thisVisitString = @"First";
    } else {
        thisVisitString = @"Return";
    }
    
    BOOL inPilotPhase = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] collectingPilotData];
    
    BOOL wanderGuardIsON = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] wanderGuardActivated];
    BOOL hasStartedSurvey = TRUE; //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] startedsurvey];
    BOOL hasFinishedSurvey = FALSE; //[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] finishedsurvey];
    
    NSString *accesspointName = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] settingsVC] lastConnectedWIFISSIDName];
    
    NSString *thisClinicName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentClinicName];
    NSString *thisSpecialtyClinicName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName];
    NSString *thisProviderName = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] attendingPhysicianName];
    
    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;

    NSLog(@"Inserting new respondent in db...");
    
    int maxRowID = 0;
    int totalNumPatientEntries = 0;
    
    int pretxdur = 0;
    int selfguidedur = 0;
    int treatmentdur = 0;
    int posttxdur = 0;
    int totaldur = 0;
    int pretxcompleteper = 0;
    int selfcompleteper = 0;
    int posttxcompleteper = 0;
    int totalcompleteper = 0;
    
    BOOL protest = false;//[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] providertest];
    NSString *selectedname = @"none";
    BOOL clinictest = false;//[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] clinictest];
    NSString *selectedclinic = @"none";
    NSString *goalchoices = @"none";
    NSString *typedGoal = @"none";
    NSString *selfguideselected = @"none";
    NSString* addToSelfGuideStatus  = @"-"; // initialize this array
    NSMutableArray* mySelfGuideStatusArray = [DynamicContent getSelfGuideStatus];
    [mySelfGuideStatusArray removeAllObjects];
    [mySelfGuideStatusArray insertObject:addToSelfGuideStatus atIndex: 0];
    
    
    // Setup the SQL Statement and compile it for faster access 
    //sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,%d,'%@',%d,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@','%@','%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name], currentUniqueID, [[NSNumber numberWithBool:inDemoMode]intValue], respondentType, [self getCurrentMonth], [self getCurrentDateTime], [[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
    
   // sqlStatementString = [NSString stringWithFormat:@"insert into sessiondatav3 values(%d,%d,%d,'%@',%d,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@','%@','%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name], currentUniqueID, [[NSNumber numberWithBool:inDemoMode]intValue], respondentType, [self getCurrentMonth], [self getCurrentDateTime], [[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
   
    //sg for tomorrow match this 666
    //2.0.0 version sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,%d,%d,'%@',%d,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%s',-1,-1,'%@','%@','%@','%@','%@',%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",currentUniqueID,[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,todaysGoal,thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name],[[NSNumber numberWithBool:inDemoMode]intValue],respondentType,[self getCurrentMonth],[self getCurrentDateTime],[[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
    
    //------10-9-14 database
   //     sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,'%@',%d,'%@','%@',%d,%d,%d,-1,-1,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%@','%@','%@','%@','%@',%d,%d,-1,'%@',-1,'%@',-1,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1)",currentUniqueID,[[NSNumber numberWithBool:inPilotPhase]intValue],accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,[[UIDevice currentDevice] name],[[NSNumber numberWithBool:inDemoMode]intValue],[self getCurrentMonth],[self getCurrentDateTime],[[NSNumber numberWithBool:hasStartedSurvey]intValue],[[NSNumber numberWithBool:hasFinishedSurvey]intValue],pretxdur,selfguidedur,treatmentdur,posttxdur,totaldur,pretxcompleteper,selfcompleteper,posttxcompleteper,totalcompleteper,thisVisitString,thisClinicName,thisSpecialtyClinicName,thisProviderName,respondentType,[[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize,[[NSNumber numberWithBool:providertest]intValue],selectedname,[[NSNumber numberWithBool:clinictest]intValue],selectedclinic,goalchoices,todaysGoal];
    sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,'%@',%d,'%@','%@',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%@','%@','%@','%@','%@',%d,%d,%d,'%@',%d,'%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@')",currentUniqueID,[[NSNumber numberWithBool:inPilotPhase]intValue],accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,[[UIDevice currentDevice] name],[[NSNumber numberWithBool:inDemoMode]intValue],[self getCurrentMonth],[self getCurrentDateTime],[[NSNumber numberWithBool:hasStartedSurvey]intValue],[[NSNumber numberWithBool:hasFinishedSurvey]intValue],pretxdur,selfguidedur,treatmentdur,posttxdur,totaldur,pretxcompleteper,selfcompleteper,posttxcompleteper,totalcompleteper,thisVisitString,thisClinicName,thisSpecialtyClinicName,thisProviderName,respondentType,[[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize,protest,selectedname,clinictest,selectedclinic,goalchoices,typedGoal,selfguideselected];
    NSLog(@"sqlStatement values %@",sqlStatementString);
    // new database structure for version 2.0.1  Sandy 10-12-14
    //  const char* sessiondataTableQuery = "CREATE TABLE IF NOT EXISTS sessiondata ( uniqueid INTEGER,pilot NUMERIC,accesspoint TEXT,wanderON NUMERIC,appversion TEXT,ipadname TEXT,demo NUMERIC, month NUMERIC,currentdatetime NUMERIC,startedsurvey NUMERIC,finishedsurvey NUMERIC, pretxdur NUMERIC,selfguidedur NUMERIC,treatmentdur NUMERIC,posttxdur NUMERIC,totaldur NUMERIC,pretxcompleteper NUMERIC,selfquidecompleteper NUMERIC,posttxcompleteper NUMERIC,totalcompleteper NUMERIC,setvisit TEXT,setclinic TEXT,setspecialty TEXT,setprovider TEXT,respondenttype TEXT,voiceassist NUMERIC,fontsize NUMERIC, protest NUMERIC,providernameselected TEXT,clinictest NUMERIC,clinicselected TEXT,goalchoices TEXT,todaysGoal TEXT, ps1reason NUMERIC,ps2prepared NUMERIC,ps3looking NUMERIC,ps4prohelp NUMERIC,ps5clinichelp NUMERIC, presurvey6 NUMERIC,presurvey7 NUMERIC,presurvey8 NUMERIC,presurvey9 NUMERIC,presurvey10 NUMERIC, q1 NUMERIC,q2 NUMERIC,q3 NUMERIC,q4 NUMERIC,q5 NUMERIC,q6 NUMERIC,q7 NUMERIC,q8 NUMERIC,q9 NUMERIC,q10 NUMERIC, q11 NUMERIC,q12 NUMERIC,q13 NUMERIC,q14 NUMERIC,q15 NUMERIC,q16 NUMERIC,q17 NUMERIC,q18 NUMERIC,q19 NUMERIC, q20 NUMERIC,q21 NUMERIC,q22 NUMERIC,q23 NUMERIC,q24 NUMERIC,q25 NUMERIC,q26 NUMERIC,q27 NUMERIC,q28 NUMERIC,q29 NUMERIC,q30 NUMERIC,selfguideselected TEXT)";
    
  
   // uniqueid INTEGER, pilot NUMERIC, posttxcompleteper NUMERIC, pretxcompleteper NUMERIC, accesspoint TEXT,
  //  wanderON NUMERIC, appversion TEXT, posttxdur NUMERIC, pretxdur NUMERIC,
   // s15tech NUMERIC, s14recommend NUMERIC, s13know NUMERIC, s12prepared NUMERIC, s11metgoal NUMERIC, s8clinichelp NUMERIC, s7prohelp NUMERIC, s5looking NUMERIC, s4prepared NUMERIC, s3reason NUMERIC, s2goalchoice NUMERIC,
   // todaysGoal TEXT, s1clinictest NUMERIC, s0protest NUMERIC,
   //setprovider TEXT, setvisit TEXT, setspecialty TEXT, setclinic TEXT, ipadname TEXT,
    //demo NUMERIC, respondenttype TEXT, month NUMERIC, year NUMERIC,startedsurvey NUMERIC, finishedsurvey NUMERIC, totalsurveyduration NUMERIC,
    //q1 NUMERIC, q2 NUMERIC, q3 NUMERIC, q4 NUMERIC, q5 NUMERIC, q6 NUMERIC, q7 NUMERIC, q8 NUMERIC, q9 NUMERIC, q10 NUMERIC, q11 NUMERIC, q12 NUMERIC, q13 NUMERIC, q14 NUMERIC, q15 NUMERIC, q16 NUMERIC, q17 NUMERIC, q18 NUMERIC, q19 NUMERIC, q20 NUMERIC, q21 NUMERIC, q22 NUMERIC, q23 NUMERIC, q24 NUMERIC, q25 NUMERIC, q26 NUMERIC, q27 NUMERIC, q28 NUMERIC, q29 NUMERIC, q30 NUMERIC,
    //voiceassist NUMERIC, fontsize NUMERIC
    
//    sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,%d,'%@',%d,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@','%@','%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name], currentUniqueID, [[NSNumber numberWithBool:inDemoMode]intValue], respondentType, [self getCurrentMonth], [self getCurrentYear], [[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
   
    // sandy 10-13-14 tested using other string value instead
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    int result = sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL);
    
    
    NSLog(@"Database returned error %d: %s", sqlite3_extended_errcode(db), sqlite3_errmsg(db));
    if(result == SQLITE_OK) {
        // Loop through the results and add them to the feeds array
        if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"======== New respondent (%d = %@) inserted in db! =========", currentUniqueID, respondentType);
        } else {
            NSLog(@"======== Insert failed! =========");
        }
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    
    if(sqlite3_open([[self filePath] UTF8String], &db) == SQLITE_OK) {
		
		// Setup the SQL Statement and compile it for faster access
		//		const char *sqlStatement = "select * from animals";
		// version one data table was sessiondata
        //sqlStatement = "SELECT MAX(uniqueid) FROM sessiondata";
        sqlStatement = "SELECT MAX(uniqueid) FROM sessiondata";
        
        
        //		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
				maxRowID = (int)sqlite3_column_int(compiledStatement, 0);
				//NSLog(@"New maximum uniqueID in sessiondata table = %d", maxRowID);
                NSLog(@"New maximum uniqueID in sessiondata table = %d", maxRowID);
				
			}
		}
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    
    if(sqlite3_open([[self filePath] UTF8String], &db) == SQLITE_OK) {
		
		// Setup the SQL Statement and compile it for faster access
		//		const char *sqlStatement = "select * from animals";
		//sg 9_16_14
        //sqlStatement = "SELECT COUNT(*) FROM sessiondata";
        sqlStatement = "SELECT COUNT(*) FROM sessiondata";
        
        //		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
				totalNumPatientEntries = (int)sqlite3_column_int(compiledStatement, 0);
				NSLog(@"New num patients in sessiondata table = %d", totalNumPatientEntries);
				
			}
		}
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    
    [self closeDB];
    
}

//sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = '%@' Where uniqueid = %d", satisfactionItem, thisText, currentUniqueID];

- (NSString *)getRespondentTypeForUniqueId:(int)thisUniqueId {
    
    [self openDB];
    
    NSLog(@"getRespondentTypeForUniqueId: %d",thisUniqueId);
    
    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;
    
    int uniqueIDtmp = 0;
    
    int currentColIndex = 0;
    
    NSString *thisRespondentType;
    
    // Setup the SQL Statement and compile it for faster access
    // sg 9_16_14
    //sqlStatementString = [NSString stringWithFormat:@"SELECT respondenttype FROM sessiondata where uniqueid = %d",thisUniqueId];
        sqlStatementString = [NSString stringWithFormat:@"SELECT respondenttype FROM sessiondata where uniqueid = %d",thisUniqueId];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            
            currentColIndex = 0;
            thisRespondentType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, currentColIndex)];
            
        }
        
        sqlite3_finalize(compiledStatement);
        
    }else{
        NSLog(@"database error");
    }
    
    [self closeDB];
    
    NSLog(@"UniqueId %d is a %@...",thisUniqueId,thisRespondentType);
    
    return thisRespondentType;
}

- (NSMutableArray *)getAllUniqueIds {
    
        [self openDB];
    
        NSLog(@"RootViewController.getAllUniqueIds()");
        
        NSMutableArray *allUniqueIds = [[NSMutableArray alloc] initWithObjects: nil];
        
//        NSArray *rowArray;
    
        const char *sqlStatement;
        sqlite3_stmt *compiledStatement;
        NSString *sqlStatementString;
        
        int uniqueIDtmp = 0;

        int currentColIndex = 0;
        
        // Setup the SQL Statement and compile it for faster access
        //sqlStatementString = [NSString stringWithFormat:@"SELECT uniqueid FROM sessiondata"];
        sqlStatementString = [NSString stringWithFormat:@"SELECT uniqueid FROM sessiondata"];
        sqlStatement = (const char *)[sqlStatementString UTF8String];
        
        if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                currentColIndex = 0;
                uniqueIDtmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                [allUniqueIds addObject:[NSNumber numberWithInt:uniqueIDtmp]];

            }
            
            sqlite3_finalize(compiledStatement);
            
        }else{
            NSLog(@"database error");
        }
        
        [self closeDB];
    
    for (NSNumber *thisUniqueId in allUniqueIds)
    {
        NSLog(@"thisUniqueID is - %d",[thisUniqueId intValue]);
    }
    
    return allUniqueIds;
}

- (BOOL)isUniqueIdSuffixInDb:(int)thisUniqueIdSuffix {
    NSMutableArray *allUniqueIds = [self getAllUniqueIds];
    
    int suffixLength = [[NSString stringWithFormat:@"%d",thisUniqueIdSuffix] length];
    
    BOOL isThisUniqueIdInDb = NO;
    
    NSString *tempSuffix;
    int tempSuffixLength = 0;
    int fromIndex = 0;
    
    for (NSNumber *thisUniqueId in allUniqueIds)
    {
        tempSuffix = [thisUniqueId stringValue];
        tempSuffixLength = [tempSuffix length];
        fromIndex = tempSuffixLength - suffixLength;
        tempSuffix = [tempSuffix substringFromIndex:fromIndex];
        
        NSLog(@"Comparing %d to %@...",thisUniqueIdSuffix,tempSuffix);
        
        if ([tempSuffix isEqualToString:[NSString stringWithFormat:@"%d",thisUniqueIdSuffix]]) {
            isThisUniqueIdInDb = YES;
            NSLog(@"Found match!");
        }
        
    }
    
    return isThisUniqueIdInDb;
}

- (int)getUniqueIdWithSuffix:(int)thisUniqueIdSuffix {
    
    int uniqueIdToReturn = 0;
    
    NSMutableArray *allUniqueIds = [self getAllUniqueIds];
    
    int suffixLength = [[NSString stringWithFormat:@"%d",thisUniqueIdSuffix] length];
    
    BOOL isThisUniqueIdInDb = NO;
    
    NSString *tempSuffix;
    int tempSuffixLength = 0;
    int fromIndex = 0;
    
    for (NSNumber *thisUniqueId in allUniqueIds)
    {
        tempSuffix = [thisUniqueId stringValue];
        tempSuffixLength = [tempSuffix length];
        fromIndex = tempSuffixLength - suffixLength;
        tempSuffix = [tempSuffix substringFromIndex:fromIndex];
        
        NSLog(@"Comparing %d to %@...",thisUniqueIdSuffix,tempSuffix);
        
        if ([tempSuffix isEqualToString:[NSString stringWithFormat:@"%d",thisUniqueIdSuffix]]) {
            isThisUniqueIdInDb = YES;
            NSLog(@"Found match!");
            
            uniqueIdToReturn = [thisUniqueId intValue];
        }
        
    }
    
    return uniqueIdToReturn;
}

//- (NSString *) GetUTCDateTimeFromLocalTime:(NSString *)IN_strLocalTime
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
//    return strDateTime;
//}

- (void) writeLogMsg:(NSString*)msg{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:csvpathCurrentFilename]];
    NSString* filename  = @"alogtest1.txt";
    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:filename]];
//    NSString* msg  = @"this is a test log msg";

//    NSString* fullStringToWrite = [allSatisfactionPatients componentsJoinedByString:@""];
//    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"()\""];
//    fullStringToWrite = [[fullStringToWrite componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
    
    [msg writeToFile:filePathLib atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    //NSLog(@"Satisfaction sql db written to local file: %@", csvpathCurrentFilename);
    NSLog(@"RootViewController.writeLogMsg(): %@", msg);

}

- (void) myLog:(NSString*) format, ...{
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"%@", formattedMessage);
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filename  = @"alogtest2.txt";
        NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:filename]];

    [formattedMessage writeToFile:filePathLib atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//    NSFileHandle* fileHandle = [fileHandleForWritingAtPath filePathLib];
//    fprintf(filePathLib, "%s\n", [formattedMessage UTF8String]);
    [formattedMessage release];
}

- (void)writeLocalDbToCSVFile {
    
    [self openDB];
    
   //NSLog(@"Writing satisfaction sql db to file: %@", csvpathCurrentFilename);
    NSLog(@"Writing satisfaction sql db to file: %@", csvpath);
    // sandy 7-20 need make sure the data matches the sequence the user experiences
    //   sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,%d,
    //'%@'%d,'%@',
    //-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@','%@','%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",
    //[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,
    //accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,
    //thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name],
    //currentUniqueID, [[NSNumber numberWithBool:inDemoMode]intValue], respondentType, [self getCurrentMonth], [self getCurrentYear],
    //[[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
    
    
    NSMutableArray *allSatisfactionPatients = [[NSMutableArray alloc] initWithObjects:@"UNIQUEID,PILOT,ACCESSPT,WANDERON,APPVERSION,IPAD,DEMO,MONTH,TIMESTAMP,STARTEDSURVEY,FINISHEDSURVEY,PRETXDUR,SELFGUIDEDUR,TXDUR,POSTTXDUR,TOTALDUR,PRETXPERCENT,SELFGUIDEPERCENT,POSTTXPECENT,TOTALPERCENT,SETVISIT,SETCLINIC,SETSPECIALTY,SETPROVIDER,RESPONDENTTYPE,VOICEASSIST,FONTSIZE,PROVTEST,PROVNAME,CLINICTEST,CLINIC,GOALCHOICES,TypedGoal,Presurvey_1,Presurvey_2,Presurvey_3,Presurvey_4,Presurvey_5,Presurvey_6,Presurvey_7,Presurvey_8,Presurvey_9,Presurvey_10,PostQ1,PostQ2,PostQ3,PostQ4,PostQ5,PostQ6,PostQ7,PostQ8,PostQ9,PostQ10,PostQ11,PostQ12,PostQ13,PostQ14,PostQ15,MiniPostQ1,MiniPostQ2,MiniPostQ3,MiniPostQ4,MiniPostQ5,MiniPostQ6,MiniPostQ7,MiniPostQ8,MiniPostQ9,MiniPostQ10,SEC3Q1,SEC3Q2,SEC3Q3,SEC3Q4,SEC3Q5,EDMODSELECTED", nil];
    
    // sessiondatv3 format uniqueIDtmp,debugModeTmp,respondentTypeTmp,setvisit,setspeciality,setclinic,monthTmp,strDateTime,startedSatTmp,finishedSatTmp,surveydurTmp,s0providertestVal,s1clinictestVal,s2goalchoiceVal,typedGoal,s3reasonVal,s4preparedVal,s5lookingVal,s7prohelpVal,s8clinichelpVal,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,q17Tmp,q18Tmp,q19Tmp,q20Tmp,q21Tmp,q22Tmp,q23Tmp,q24Tmp,q25Tmp,q26Tmp,q27Tmp,q28Tmp,q29Tmp,q30Tmp,voiceTmp,fontTmp,appversion,posttxdurTmp,pretxdurTmp,ipadnameTmp,setprovider

    NSArray *rowArray;

    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;
    int writingRowIndex = 1;
    int currentColIndex = 0;
    int yearTmp = 0;
    
//    int currentUniqueID;
//    int pilot = 0;
//    NSString *accesspoint;
//    int wanderON = 0;
//    int posttxcompleteper = 0;
//    int pretxcompleteper = 0;
//
//
//    NSString *currentAppVersion;
//    NSString *posttxdurTmp;
//    NSString *pretxdurTmp;
//    int s15techVal = 0;           // "Overall I like this type of technology"
//    int s14recommendVal = 0;      // "I would recommend this guide"
//    int s13knowVal = 0;            // "Overall I felt more knowledgeable"
//    int s12preparedVal = 0;        // "Overall I felt more prepared"
//    int s11metgoalVal = 0;         // "Did today's visit meet your expectations regarding your goal"
//    int s8clinichelpVal = 0;      // "Please indicate how helpful you found this clinic information"
//    int s7prohelpVal = 0;        // "Please indicate how helpful you found this information on your provider"
//    int s5lookingVal = 0;       // "I am looking forward to today's visit
//    int s4preparedVal = 0;     // "I feel prepared for today's visit"
//    int s3reasonVal = 0;      // "I understand the reason or reasons for today's visit"
//    int s2goalchoiceVal = 0;  // goal value selected
//    NSString *todaysGoal;  // added value typed on keyboard by respondend
//    int s1clinictestVal = 0;// clinic user selected
//    int s0protestVal = 0;// provider user selected
//    NSString *setprovider;
//    NSString *setvisit;
//    NSString *setspecialty;
//    NSString *setclinic;
//    NSString *ipadnameTmp;
//    integer_t uniqueIDtmp = 0;
//    int debugModeTmp = 0;
//    NSString *respondentTypeTmp;
//    int monthTmp = 0;
//    int yearTmp = 0;
//    int startedSatTmp = 0;
//    int finishedSatTmp = 0;
//    int surveydurTmp = 0;
//    int voiceTmp, fontTmp, anotherFontTmp = 0;
    
    int Tmp_currentUniqueID;  // uniqueid (integer primary key)
    int Tmp_pilot;
    NSString *Tmp_accesspoint;
    int Tmp_wanderON;
    NSString *Tmp_currentAppVersion;
    NSString *Tmp_ipadname;
    int Tmp_demo; // demo (numeric = running demo version of app? 1/0)
    int Tmp_month; // month (numeric = 1-12)
    int Tmp_timestamp; // timestamp collected at start of survey use
    int Tmp_startedsurvey;
    int Tmp_finishedsurvey;
    NSString *Tmp_pretxdur;
    NSString *Tmp_selfguidedur;
    NSString *Tmp_treatmentdur;
    NSString *Tmp_posttxdur;// = [NSString stringWithFormat:@"%4.4f",0.0f];
    int Tmp_totaldur;
    int Tmp_pretxcompleteper;
    int Tmp_selfcompleteper;
    int Tmp_posttxcompleteper;
    int Tmp_totalcompleteper;
    NSString *Tmp_thisVisitString;
    NSString *Tmp_thisClinicName;
    NSString *Tmp_thisSpecialtyClinicName;
    NSString *Tmp_thisProviderName;
    NSString *Tmp_respondentType; // respondenttype (text = patient/family/caregiver)
    int Tmp_voiceassist; // voiceassist (numeric = did the respondent use the voice assist accessibility feature? 1/0)
    int Tmp_fontsize; // fontsize (numeric = what font size did the repondent prefer? 1=small (default), 2=medium, 3=large)
    // pre treatment questions
    int Tmp_providertest; // provider user selected
    NSString *Tmp_selectedname;
    int Tmp_clinictest; // clinic user selected
    NSString *Tmp_selectedclinic;
    NSString *Tmp_goalchoices;  // goal value selected
    NSString *Tmp_typedGoal;  // text typed on the keyboard
    int Tmp_ps1reason;      // "I understand the reason or reasons for today's visit"
    int Tmp_ps2prepared; // "I feel prepared for today's visit"
    int Tmp_ps3looking; // "I am looking forward to today's visit
    int Tmp_ps4prohelp; // "Please indicate how helpful you found this information on your provider"
    int Tmp_ps5clinichelp; // "Please indicate how helpful you found this clinic information"
    int Tmp_presurvey6;
    int Tmp_presurvey7;
    int Tmp_presurvey8;
    int Tmp_presurvey9;
    int Tmp_presurvey10;

    int q30Tmp,q29Tmp,q28Tmp,q27Tmp,q26Tmp,q25Tmp,q24Tmp,q23Tmp,q21Tmp,q22Tmp,q20Tmp,q19Tmp,q18Tmp,q17Tmp = 0;
    int q1Tmp, q2Tmp, q3Tmp, q4Tmp, q5Tmp, q6Tmp, q7Tmp, q8Tmp, q9Tmp, q10Tmp, q11Tmp, q12Tmp, q13Tmp, q14Tmp, q15Tmp, q16Tmp = 0;
    NSString *Tmp_selfguideselected;

  
    
//    
//    NSNumber *pilot;
//    NSNumber *posttxcompleteper;
//    NSNumber *pretxcompleteper;
//    NSString *accesspoint;
//    NSNumber *wanderON;
//    NSString *appversion;
//    NSString *posttxdur;
//    NSString *pretxdur;
//    NSString *uniqueIDtmp;
//    NSNumber *debugModeTmp;
//    NSString *respondentTypeTmp;
//    NSString *setprovider;
//    NSString *setvisit;
//    NSString *setspecialty;
//    NSString *setclinic;
//    int monthTmp;
//    int yearTmp;
//    int startedSatTmp;
//    int finishedSatTmp;
//    int surveydurTmp;
//    int q1Tmp, q2Tmp, q3Tmp, q4Tmp, q5Tmp, q6Tmp, q7Tmp, q8Tmp, q9Tmp, q10Tmp, q11Tmp, q12Tmp, q13Tmp, q14Tmp, q15Tmp, q16Tmp;
//    int voiceTmp, fontTmp, anotherFontTmp;
//    NSString *s8clinichelpVal;      // "Please indicate how helpful you found this clinic information"
//    NSString *s7prohelpVal;        // "Please indicate how helpful you found this information on your provider"
//    NSString *s5lookingVal;       // "I am looking forward to today's visit
//    NSString *s4preparedVal;     // "I feel prepared for today's visit"
//    NSString *s3reasonVal;      // "I understand the reason or reasons for today's visit"
//    NSString *s2goalchoiceVal;  // goal value selected
//    NSString *s1clinictestVal; // clinic user selected
//    NSString *s0protestVal; // provider user selected
//    
    //  struct from database values
    //
    //    struct ElementsStructure {
    //        int ID;
    //        int Slug;

    //    };
    //    //field to column mappings for sql lite queries
    //    struct ElementsStructure oElements;
    //    oElements.ID = 0;
    //    oElements.Slug = 1;
    //    ...
    //
    //    NSNumber *ID = [NSNumber numberWithInt: sqlite3_column_int(statement, oElements.ID)];
    
    struct ElementsStructure {
    int row_currentUniqueID;  // uniqueid (integer primary key)
    int row_pilot;
    NSString *row_accesspoint;
    int row_wanderON;
    NSString *row_currentAppVersion;
    NSString *row_ipadname;
    int row_demo; // demo (numeric = running demo version of app? 1/0)
    int row_month; // month (numeric = 1-12)
    int row_timestamp; // timestamp collected at start of survey use
    int row_startedsurvey;
    int row_finishedsurvey;
    NSString *row_pretxdur;
    NSString *row_selfguidedur;
    NSString *row_treatmentdur;
    NSString *row_posttxdur;// = [NSString stringWithFormat:@"%4.4f",0.0f];
    int row_totaldur;
    int row_pretxcompleteper;
    int row_selfcompleteper;
    int row_posttxcompleteper;
    int row_totalcompleteper;
    NSString *row_thisVisitString;
    NSString *row_thisClinicName;
    NSString *row_thisSpecialtyClinicName;
    NSString *row_thisProviderName;
    NSString *row_respondentType; // respondenttype (text = patient/family/caregiver)
    int row_voiceassist; // voiceassist (numeric = did the respondent use the voice assist accessibility feature? 1/0)
    int row_fontsize; // fontsize (numeric = what font size did the repondent prefer? 1=small (default), 2=medium, 3=large)
                                // pre treatment questions
    int row_providertest; // provider user selected
    NSString *row_selectedname;
    int row_clinictest; // clinic user selected
    NSString *row_selectedclinic;
    NSString *row_goalchoices;  // goal value selected
    NSString *row_typedGoal;  // text typed on the keyboard
    int row_ps1reason;      // "I understand the reason or reasons for today's visit"
    int row_ps2prepared; // "I feel prepared for today's visit"
    int row_ps3looking; // "I am looking forward to today's visit
    int row_ps4prohelp; // "Please indicate how helpful you found this information on your provider"
    int row_ps5clinichelp; // "Please indicate how helpful you found this clinic information"
    int row_presurvey6;
    int row_presurvey7;
    int row_presurvey8;
    int row_presurvey9;
    int row_presurvey10;
        int row_postsurvey1;
        int row_postsurvey2;
        int row_postsurvey3;
        int row_postsurvey4;
        int row_postsurvey5;
        int row_postsurvey6;
        int row_postsurvey7;
        int row_postsurvey8;
        int row_postsurvey9;
        int row_postsurvey10;
        int row_postsurvey11;
        int row_postsurvey12;
        int row_postsurvey13;
        int row_postsurvey14;
        int row_postsurvey15;
        int row_miniposts1;
        int row_miniposts2;
        int row_miniposts3;
        int row_miniposts4;
        int row_miniposts5;
        int row_miniposts6;
        int row_miniposts7;
        int row_miniposts8;
        int row_miniposts9;
        int row_miniposts10;
        int row_set3post1;
        int row_set3post2;
        int row_set3post3;
        int row_set3post4;
        int row_set3post5;
        NSString *row_selfguideselected;

    };
    
    //    //field to column mappings for sql lite queries
       struct ElementsStructure oElements;
    oElements.row_currentUniqueID = 0;
    oElements.row_pilot = 1;
    oElements.row_accesspoint = 2;
    oElements.row_wanderON = 3;
    oElements.row_currentAppVersion = 4;
    oElements.row_ipadname = 5;
    oElements.row_demo = 6;
    oElements.row_month = 7;
    oElements.row_timestamp = 8;
    oElements.row_startedsurvey = 9;
    oElements.row_finishedsurvey = 10;
    oElements.row_pretxdur = 11;
    oElements.row_selfguidedur = 12;
    oElements.row_treatmentdur = 13;
    oElements.row_posttxdur = 14;
    oElements.row_totaldur = 15;
    oElements.row_pretxcompleteper = 16;
    oElements.row_selfcompleteper = 17;
    oElements.row_posttxcompleteper = 18;
    oElements.row_totalcompleteper = 19;
    oElements.row_thisVisitString = 20;
    oElements.row_thisClinicName = 21;
    oElements.row_thisSpecialtyClinicName = 22;
    oElements.row_thisProviderName = 23;
    oElements.row_respondentType = 24;
    oElements.row_voiceassist = 25;
    oElements.row_fontsize = 26;
    oElements.row_providertest = 27;
    oElements.row_selectedname = 28;
    oElements.row_clinictest = 29;
    oElements.row_selectedclinic = 30;
    oElements.row_goalchoices = 31;
    oElements.row_typedGoal = 32;
    oElements.row_ps1reason = 33;
    oElements.row_ps2prepared = 34;
    oElements.row_ps3looking = 35;
    oElements.row_ps4prohelp = 36;
    oElements.row_ps5clinichelp = 37;
    oElements.row_presurvey6 = 38;
    oElements.row_presurvey7 = 39;
    oElements.row_presurvey8 = 40;
    oElements.row_presurvey9 = 41;
    oElements.row_presurvey10 = 42;
    oElements.row_postsurvey1 = 43;
    oElements.row_postsurvey2 = 44;
    oElements.row_postsurvey3 = 45;
    oElements.row_postsurvey4 = 46;
    oElements.row_postsurvey5 = 47;
    oElements.row_postsurvey6 = 48;
    oElements.row_postsurvey7 = 49;
    oElements.row_postsurvey8 = 50;
    oElements.row_postsurvey9 = 51;
    oElements.row_postsurvey10 = 52;
    oElements.row_postsurvey11 = 53;
    oElements.row_postsurvey12 = 54;
    oElements.row_postsurvey13 = 55;
    oElements.row_postsurvey14 = 56;
    oElements.row_postsurvey15 = 57;
    oElements.row_miniposts1 = 58;
    oElements.row_miniposts2 = 59;
    oElements.row_miniposts3 = 60;
    oElements.row_miniposts4 = 61;
    oElements.row_miniposts5 = 62;
    oElements.row_miniposts6 = 63;
    oElements.row_miniposts7 = 64;
    oElements.row_miniposts8 = 65;
    oElements.row_miniposts9 = 66;
    oElements.row_miniposts10 = 67;
    oElements.row_set3post1 = 68;
    oElements.row_set3post2 = 69;
    oElements.row_set3post3 = 70;
    oElements.row_set3post4 = 71;
    oElements.row_set3post5 = 72;
    oElements.row_selfguideselected = 73;

    // Setup the SQL Statement and compile it for faster access
    //sqlStatementString = [NSString stringWithFormat:@"SELECT * FROM sessiondata"];
    sqlStatementString = [NSString stringWithFormat:@"SELECT * FROM sessiondata"];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {

            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
               // currentColIndex = 0;
               Tmp_currentUniqueID = (int)sqlite3_column_int(compiledStatement, oElements.row_currentUniqueID);
               Tmp_pilot =  (int)sqlite3_column_int(compiledStatement, oElements.row_pilot);
               Tmp_accesspoint = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_accesspoint)];
                if (Tmp_accesspoint == NULL)
                    Tmp_accesspoint = @"null";
                Tmp_wanderON = (int)sqlite3_column_int(compiledStatement, oElements.row_wanderON);
                Tmp_currentAppVersion = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_currentAppVersion)];
                
                Tmp_ipadname = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_ipadname)];
                if (Tmp_ipadname == NULL)
                    Tmp_ipadname = @"null";
                Tmp_demo = (int)sqlite3_column_int(compiledStatement, oElements.row_demo);
                Tmp_month = (int)sqlite3_column_int(compiledStatement, oElements.row_month);
                Tmp_timestamp = (int)sqlite3_column_int(compiledStatement, oElements.row_timestamp);
                
                Tmp_startedsurvey = (int)sqlite3_column_int(compiledStatement, oElements.row_startedsurvey);
                Tmp_finishedsurvey = (int)sqlite3_column_int(compiledStatement, oElements.row_finishedsurvey);
                
                Tmp_pretxdur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_pretxdur)];
                Tmp_selfguidedur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_selfguidedur)];
                Tmp_treatmentdur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_treatmentdur)];
                Tmp_posttxdur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.row_posttxdur)];
                Tmp_totaldur = (int)sqlite3_column_int(compiledStatement, oElements.row_totaldur);
                

                Tmp_pretxcompleteper = (int)sqlite3_column_int(compiledStatement, oElements.row_pretxcompleteper);
                Tmp_selfcompleteper = (int)sqlite3_column_int(compiledStatement, oElements.row_selfcompleteper);
                Tmp_posttxcompleteper = (int)sqlite3_column_int(compiledStatement, oElements.row_posttxcompleteper);
                Tmp_totalcompleteper = (int)sqlite3_column_int(compiledStatement, oElements.row_totalcompleteper);
                Tmp_thisVisitString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_thisVisitString)];
                Tmp_thisClinicName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_thisClinicName)];
                Tmp_thisSpecialtyClinicName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_thisSpecialtyClinicName)];
                Tmp_thisProviderName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_thisProviderName)];
                // sandy 10-15-14 split this if there are credentials
                NSString* myString = Tmp_thisProviderName;
                NSArray* myArray = [myString  componentsSeparatedByString:@","];
                NSString* Tmp_thisProviderName = [myArray objectAtIndex:0];
                
                Tmp_respondentType = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_respondentType)];
                Tmp_voiceassist = (int)sqlite3_column_int(compiledStatement, oElements.row_voiceassist);
                Tmp_fontsize = (int)sqlite3_column_int(compiledStatement, oElements.row_fontsize);

                // pre treatment questions
                Tmp_providertest = (int)sqlite3_column_int(compiledStatement, oElements.row_providertest); // provider user selected
                Tmp_selectedname = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_selectedname)];
                
                Tmp_clinictest = (int)sqlite3_column_int(compiledStatement, oElements.row_clinictest); // clinic user selected
                Tmp_selectedclinic= [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_selectedclinic)];
                Tmp_goalchoices = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_goalchoices)];  // goal value selected
                Tmp_typedGoal = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_typedGoal)];
                Tmp_ps1reason = (int)sqlite3_column_int(compiledStatement, oElements.row_ps1reason);     // "I understand the reason or reasons for today's visit"
                Tmp_ps2prepared = (int)sqlite3_column_int(compiledStatement, oElements.row_ps2prepared);    // "I feel prepared for today's visit"
                Tmp_ps3looking = (int)sqlite3_column_int(compiledStatement, oElements.row_ps3looking);       // "I am looking forward to today's visit
                Tmp_ps4prohelp = (int)sqlite3_column_int(compiledStatement, oElements.row_ps4prohelp);  // "Please indicate how helpful you found this information on your provider"
                Tmp_ps5clinichelp = (int)sqlite3_column_int(compiledStatement, oElements.row_ps5clinichelp);      // "Please indicate how helpful you found this clinic information"

                Tmp_presurvey6 = (int)sqlite3_column_int(compiledStatement, oElements.row_presurvey6);
                Tmp_presurvey7 = (int)sqlite3_column_int(compiledStatement, oElements.row_presurvey7);
                Tmp_presurvey8 = (int)sqlite3_column_int(compiledStatement, oElements.row_presurvey8);
                Tmp_presurvey9 = (int)sqlite3_column_int(compiledStatement, oElements.row_presurvey9);
                Tmp_presurvey10 = (int)sqlite3_column_int(compiledStatement, oElements.row_presurvey10);


                 q1Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey1);
                 q2Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey2);
                 q3Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey3);
                 q4Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey4);
                 q5Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey5);
                q6Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey6);
                q7Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey7);
                q8Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey8);
                q9Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey9);
                q10Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey10);
                q11Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey11);
                q12Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey12);
                q13Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey13);
                q14Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey14);
                q15Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_postsurvey15);
                q16Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts1);
                q17Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts2);
                q18Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts3);
                q19Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts4);
                q20Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts5);
                q21Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts6);
                q22Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts7);
                q23Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts8);
                q24Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts9);
                q25Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_miniposts10);
                q26Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_set3post1);
                q27Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_set3post1);
                q28Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_set3post1);
                q29Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_set3post1);
                q30Tmp = (int)sqlite3_column_int(compiledStatement, oElements.row_set3post1);
                Tmp_selfguideselected = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.row_selfguideselected)]; //@""; rjl 1/27/15
                
                
                
//            
//                currentColIndex = 0;
//                NSNumber *pilot = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_pilot)];
//                NSNumber *posttxcompleteper = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_posttxcompleteper)];
//                NSNumber *pretxcompleteper = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_pretxcompleteper)];
//                
//                // NSString *access_point = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.temp_accesspoint)];
//                
//                char *access_point = (char *)sqlite3_column_text(compiledStatement, oElements.temp_accesspoint);
//                
//                NSString *CurrencyCoin = nil;
//                if (access_point !=NULL)
//                    CurrencyCoin = [NSString stringWithUTF8String: access_point];
//                // NSString *access_point = [NSString stringWithCString:(char*)sqlite3_column_text(compiledStatement, oElements.temp_accesspoint)];
//
//                NSNumber *wanderON = [NSNumber numberWithBool: sqlite3_column_int(compiledStatement, oElements.temp_wanderON )];
//                
//                NSString *appversion = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.temp_appversion)];
//                
//                NSString *posttxdur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.temp_posttxdur)];
//                
//                NSString *pretxdur = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement, oElements.temp_prettxdur)];
//                
//                NSNumber  *s15tech = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s15tech)];
//                NSNumber *s14recommend = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s14recommend )];
//                NSNumber *s13know = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s13know)];           // "Overall I felt more knowledgeable"
//                NSNumber *s12prepared = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s12prepared)];        // "Overall I felt more prepared"
//                NSNumber *s11metgoal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s11metgoal)];         // "Did today's visit meet your expectations regarding your goal"
//                // pre treatment questions
//                NSNumber *s8clinichelpVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s8clinichelp)];      // "Please indicate how helpful you found this clinic information"
//                NSNumber *s7prohelpVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s7prohelp)];        // "Please indicate how helpful you found this information on your provider"
//                NSNumber *s5lookingVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s5looking)];       // "I am looking forward to today's visit
//                NSNumber *s4preparedVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s4prepared)];    // "I feel prepared for today's visit"
//                NSNumber *s3reasonVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s3reason)];     // "I understand the reason or reasons for today's visit"
//                NSNumber *s2goalchoiceVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s2goalchoice)];  // goal value selected
//                NSNumber *s1clinictestVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s1clinictest)]; // clinic user selected
//                NSNumber *s0providertestVal = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.s0protest)]; // provider user selected
//                
//                NSString *setprovider = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_setprovider)];
//                NSString *setvisit = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_setvisit)];
//                NSString *setspeciality = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_setspecialty)];
//                NSString *setclinic = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_setclinic)];
//                NSString *ipadname = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_ipadname)];
//                NSNumber *q28Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q28)];
//                NSNumber *q27Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q27)];
//                NSNumber *q26Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q26)];
//                NSNumber *q25Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q25)];
//                NSNumber *q24Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q24)];
//                NSNumber *q23Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q23)];
//                NSNumber *q22Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q22)];
//                NSNumber *q20Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q20)];
//                NSNumber *q19Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q19)];
//                NSNumber *q18Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q18)];
//                NSNumber *q17Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_q17)];
//                uniqueIDtmp = (int)sqlite3_column_int(compiledStatement, oElements.temp_uniqueID);
//                NSNumber *debugModeTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_demo)];
//                NSString *respondentTypeTmp = [NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatement,oElements.temp_respondenttype)];
//                NSNumber *monthTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_month)];
//                NSNumber *yearTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_year)];
//                NSNumber *startedSatTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_startedsurvey)];
//                NSNumber *finishedSatTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_finishedsurvey)];
//                NSNumber *surveydurTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_totalsurveyduration)];
//                NSNumber *q1Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q1Tmp)];
//                NSNumber *q2Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q2Tmp)];
//                NSNumber *q3Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q3Tmp)];
//                NSNumber *q4Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q4Tmp)];
//                NSNumber *q5Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q5Tmp)];
//                NSNumber *q6Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q6Tmp)];
//                NSNumber *q7Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q7Tmp)];
//                NSNumber *q8Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q8Tmp)];
//                NSNumber *q9Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q9Tmp)];
//                NSNumber *q10Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q10Tmp)];
//                NSNumber *q11Tmp= [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q11Tmp)];
//                NSNumber *q12Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q12Tmp)];
//                NSNumber *q13Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q13Tmp)];
//                NSNumber *q14Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q14Tmp)];
//                NSNumber *q15Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q15Tmp)];
//                NSNumber *q16Tmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.q16Tmp)];
//                NSNumber *voiceTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.temp_voiceassist)];
//                NSNumber *fontTmp = [NSNumber numberWithInt: sqlite3_column_int(compiledStatement, oElements.fontTmp)];

              
//                uniqueIDtmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                debugModeTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                respondentTypeTmp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, currentColIndex)];
//                //respondentTypeTmp = @"tmp";
//                monthTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                yearTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                startedSatTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                finishedSatTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                surveydurTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q1Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q2Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q3Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q4Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q5Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q6Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q7Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q8Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q9Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q10Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q11Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q12Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q13Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q14Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q15Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                q16Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                voiceTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                fontTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
//                currentColIndex++;
//                anotherFontTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
  
                
                
  //    NSMutableArray *allSatisfactionPatients = [[NSMutableArray alloc] initWithObjects:@"UNIQUEID,DEMO,RESPONDENTTYPE,FONTTMP,MONTH,YEAR,STARTEDSURVEY,FINISHEDSURVEY,TOTALSURVEYDURATION,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,VOICEASSIST,FONTSIZE", nil];
//                NSLog(@"logged values %d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",uniqueIDtmp,debugModeTmp,respondentTypeTmp,setvisit,setspeciality,setclinic,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,s0providertestVal,s1clinictestVal,s2goalchoiceVal,s3reasonVal,s4preparedVal,s5lookingVal,s7prohelpVal,s8clinichelpVal,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,voiceTmp,fontTmp,setprovider);
                
    //shift question return values by one to avoid negative numbers in spreadsheet
                Tmp_ps1reason = Tmp_ps1reason+1;
                Tmp_ps2prepared = Tmp_ps2prepared+1;
                Tmp_ps3looking = Tmp_ps3looking+1;
                Tmp_ps4prohelp = Tmp_ps4prohelp+1;
                Tmp_ps5clinichelp = Tmp_ps5clinichelp+1;
                Tmp_presurvey6 = Tmp_presurvey6+1;
                Tmp_presurvey7 = Tmp_presurvey7+1;
                Tmp_presurvey8 = Tmp_presurvey8+1;
                Tmp_presurvey9 = Tmp_presurvey9+1;
                Tmp_presurvey10 = Tmp_presurvey10+1;
                q1Tmp = q1Tmp +1;
                q2Tmp = q2Tmp +1;
                q3Tmp = q3Tmp +1;
                q4Tmp = q4Tmp +1;
                q5Tmp = q5Tmp +1;
                q6Tmp = q6Tmp +1;
                q7Tmp = q7Tmp +1;
                q8Tmp = q8Tmp +1;
                q9Tmp = q9Tmp +1;
                q10Tmp = q10Tmp +1;
                q11Tmp = q11Tmp +1;
                q12Tmp = q12Tmp +1;
                q13Tmp = q13Tmp +1;
                q14Tmp = q14Tmp +1;
                q15Tmp = q15Tmp +1;
                q16Tmp = q16Tmp +1;
                q17Tmp = q17Tmp +1;
                q18Tmp = q18Tmp +1;
                q19Tmp = q19Tmp +1;
                q20Tmp = q20Tmp +1;
                q21Tmp = q21Tmp +1;
                q22Tmp = q22Tmp +1;
                q23Tmp = q23Tmp +1;
                q24Tmp = q24Tmp +1;
                q25Tmp = q25Tmp +1;
                q26Tmp = q26Tmp +1;
                q27Tmp = q27Tmp +1;
                q28Tmp = q28Tmp +1;
                q29Tmp = q29Tmp +1;
                q30Tmp = q30Tmp +1;
                
                NSDate *now = [NSDate dateWithTimeIntervalSince1970:yearTmp];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
                //
                //
//                    NSInteger second = [components second];
                NSInteger minute = [components minute];
                NSInteger hour = [components hour];
                NSInteger day = [components day];
                NSInteger month = [components month];
                NSInteger year = [components year];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                NSString *strDateTime   = [dateFormatter stringFromDate:now];
    
                
                
               NSLog(@"logged values %d,%d,'%@',%d,'%@','%@',%d,%d,%d,%d,%d,%@,%@,%@,%@,%d,%d,%d,%d,%d,'%@','%@','%@','%@','%@',%d,%d,%d,'%@',%d,'%@','%@','%@',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%@'",Tmp_currentUniqueID,Tmp_pilot,Tmp_accesspoint,Tmp_wanderON,Tmp_currentAppVersion,Tmp_ipadname,Tmp_demo,Tmp_month,Tmp_timestamp,Tmp_startedsurvey,Tmp_finishedsurvey,Tmp_pretxdur,Tmp_selfguidedur,Tmp_treatmentdur,Tmp_posttxdur,Tmp_totaldur,Tmp_pretxcompleteper,Tmp_selfcompleteper,Tmp_posttxcompleteper,Tmp_totalcompleteper,Tmp_thisVisitString,Tmp_thisClinicName,Tmp_thisSpecialtyClinicName,Tmp_thisProviderName,Tmp_respondentType,Tmp_voiceassist,Tmp_fontsize,Tmp_providertest,Tmp_selectedname,Tmp_clinictest,Tmp_selectedclinic,Tmp_goalchoices,Tmp_typedGoal,Tmp_ps1reason,Tmp_ps2prepared,Tmp_ps3looking,Tmp_ps4prohelp,Tmp_ps5clinichelp,Tmp_presurvey6,Tmp_presurvey7,Tmp_presurvey8,Tmp_presurvey9,Tmp_presurvey10,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,q17Tmp,q18Tmp,q19Tmp,q20Tmp,q21Tmp,q22Tmp,q23Tmp,q24Tmp,q25Tmp,q26Tmp,q27Tmp,q28Tmp,q29Tmp,q30Tmp,Tmp_selfguideselected);
                
                rowArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d,'%@',%d,'%@','%@',%d,%d,%d,%d,%d,%@,%@,%@,%@,%d,%d,%d,%d,%d,'%@','%@','%@','%@','%@',%d,%d,%d,'%@',%d,'%@','%@','%@',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%@'",Tmp_currentUniqueID,Tmp_pilot,Tmp_accesspoint,Tmp_wanderON,Tmp_currentAppVersion,Tmp_ipadname,Tmp_demo,Tmp_month,Tmp_timestamp,Tmp_startedsurvey,Tmp_finishedsurvey,Tmp_pretxdur,Tmp_selfguidedur,Tmp_treatmentdur,Tmp_posttxdur,Tmp_totaldur,Tmp_pretxcompleteper,Tmp_selfcompleteper,Tmp_posttxcompleteper,Tmp_totalcompleteper,Tmp_thisVisitString,Tmp_thisClinicName,Tmp_thisSpecialtyClinicName,Tmp_thisProviderName,Tmp_respondentType,Tmp_voiceassist,Tmp_fontsize,Tmp_providertest,Tmp_selectedname,Tmp_clinictest,Tmp_selectedclinic,Tmp_goalchoices,Tmp_typedGoal,Tmp_ps1reason,Tmp_ps2prepared,Tmp_ps3looking,Tmp_ps4prohelp,Tmp_ps5clinichelp,Tmp_presurvey6,Tmp_presurvey7,Tmp_presurvey8,Tmp_presurvey9,Tmp_presurvey10,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,q17Tmp,q18Tmp,q19Tmp,q20Tmp,q21Tmp,q22Tmp,q23Tmp,q24Tmp,q25Tmp,q26Tmp,q27Tmp,q28Tmp,q29Tmp,q30Tmp,Tmp_selfguideselected], nil];

  // 10-14-14 version of DB              sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,'%@',%d,'%@','%@',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%@','%@','%@','%@','%@',%d,%d,%d,'%@',%d,'%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@')",currentUniqueID,[[NSNumber numberWithBool:inPilotPhase]intValue],accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,[[UIDevice currentDevice] name],[[NSNumber numberWithBool:inDemoMode]intValue],[self getCurrentMonth],[self getCurrentDateTime],[[NSNumber numberWithBool:hasStartedSurvey]intValue],[[NSNumber numberWithBool:hasFinishedSurvey]intValue],pretxdur,selfguidedur,treatmentdur,posttxdur,totaldur,pretxcompleteper,selfcompleteper,posttxcompleteper,totalcompleteper,thisVisitString,thisClinicName,thisSpecialtyClinicName,thisProviderName,respondentType,[[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize,providertest,selectedname,clinictest,selectedclinic,goalchoices,typedGoal,selfguideselected];
   //             NSLog(@"sqlStatement values %@",sqlStatementString);
                // new database structure for version 2.0.1  Sandy 10-12-14
                //  const char* sessiondataTableQuery = "CREATE TABLE IF NOT EXISTS sessiondata ( uniqueid INTEGER,pilot NUMERIC,accesspoint TEXT,wanderON NUMERIC,appversion TEXT,ipadname TEXT,demo NUMERIC, month NUMERIC,currentdatetime NUMERIC,startedsurvey NUMERIC,finishedsurvey NUMERIC, pretxdur NUMERIC,selfguidedur NUMERIC,treatmentdur NUMERIC,posttxdur NUMERIC,totaldur NUMERIC,pretxcompleteper NUMERIC,selfquidecompleteper NUMERIC,posttxcompleteper NUMERIC,totalcompleteper NUMERIC,setvisit TEXT,setclinic TEXT,setspecialty TEXT,setprovider TEXT,respondenttype TEXT,voiceassist NUMERIC,fontsize NUMERIC, protest NUMERIC,providernameselected TEXT,clinictest NUMERIC,clinicselected TEXT,goalchoices TEXT,todaysGoal TEXT, ps1reason NUMERIC,ps2prepared NUMERIC,ps3looking NUMERIC,ps4prohelp NUMERIC,ps5clinichelp NUMERIC, presurvey6 NUMERIC,presurvey7 NUMERIC,presurvey8 NUMERIC,presurvey9 NUMERIC,presurvey10 NUMERIC, q1 NUMERIC,q2 NUMERIC,q3 NUMERIC,q4 NUMERIC,q5 NUMERIC,q6 NUMERIC,q7 NUMERIC,q8 NUMERIC,q9 NUMERIC,q10 NUMERIC, q11 NUMERIC,q12 NUMERIC,q13 NUMERIC,q14 NUMERIC,q15 NUMERIC,q16 NUMERIC,q17 NUMERIC,q18 NUMERIC,q19 NUMERIC, q20 NUMERIC,q21 NUMERIC,q22 NUMERIC,q23 NUMERIC,q24 NUMERIC,q25 NUMERIC,q26 NUMERIC,q27 NUMERIC,q28 NUMERIC,q29 NUMERIC,q30 NUMERIC)";
                
                
                
                

//                NSLog(@"logged values %d,%d,%@,%@,%@,%@,%d,%d,%d,%d,%d,%@,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%@",uniqueIDtmp,debugModeTmp,respondentTypeTmp,setvisit,setspeciality,setclinic,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,s0providertestVal,s1clinictestVal,s2goalchoiceVal,s3reasonVal,s4preparedVal,s5lookingVal,s7prohelpVal,s8clinichelpVal,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,q17Tmp,q18Tmp,q19Tmp,q20Tmp,q21Tmp,q22Tmp,q23Tmp,q24Tmp,q25Tmp,q26Tmp,q27Tmp,q28Tmp,voiceTmp,fontTmp,setprovider);
//                rowArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d,%@,%@,%@,%@,%d,%d,%d,%d,%d,%@,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%@",uniqueIDtmp,debugModeTmp,respondentTypeTmp,setvisit,setspeciality,setclinic,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,s0providertestVal,s1clinictestVal,s2goalchoiceVal,s3reasonVal,s4preparedVal,s5lookingVal,s7prohelpVal,s8clinichelpVal,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,q17Tmp,q18Tmp,q19Tmp,q20Tmp,q21Tmp,q22Tmp,q23Tmp,q24Tmp,q25Tmp,q26Tmp,q27Tmp,q28Tmp,voiceTmp,fontTmp,setprovider], nil];
//                
//                rowArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",uniqueIDtmp,debugModeTmp,respondentTypeTmp,setvisit,setspeciality,setclinic,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,s0providertestVal,s1clinictestVal,s2goalchoiceVal,s3reasonVal,s4preparedVal,s5lookingVal,s7prohelpVal,s8clinichelpVal,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,voiceTmp,fontTmp,setprovider], nil];
//                
                //rowArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d,%@,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",uniqueIDtmp,debugModeTmp,respondentTypeTmp,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,voiceTmp,fontTmp], nil];
                [allSatisfactionPatients addObject:rowArray];
                
                NSLog(@"Writing row %d (%@) to csv file...",writingRowIndex,Tmp_respondentType);
                writingRowIndex++;
            }
        
            sqlite3_finalize(compiledStatement);

    }else{
        NSLog(@"database error");
    }
    
    [self closeDB];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    //NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:csvpathCurrentFilename]];
    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:csvpath]];
    
    NSString* fullStringToWrite = [allSatisfactionPatients componentsJoinedByString:@""];
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"()\""];
    fullStringToWrite = [[fullStringToWrite componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
    
    [fullStringToWrite writeToFile:filePathLib atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    //NSLog(@"Satisfaction sql db written to local file: %@", csvpathCurrentFilename);
     NSLog(@"Satisfaction sql db written to local file: %@", csvpath);
    NSLog(@"Open iTunes or email as attachment to retrieve data");
}

- (int)getUniqueIDFromCurrentTime {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    
    NSInteger second = [components second];
    NSInteger minute = [components minute];
    NSInteger hour = [components hour];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    NSLog(@"Today is: %dYears %dMonths %dDays %dHours %dMinutes %dSeconds", year, month, day, hour, minute, second);
    
    int thisMomentInt = (year * 100000) + (month * 10000) + (day * 1000) + (hour * 100) + (minute * 10) + second;
    
    thisMomentInt = (thisMomentInt * M_2_SQRTPI) / 2;
    
    NSLog(@"Moment Integer is: %d", thisMomentInt);
    
	return thisMomentInt;
}

- (int)getCurrentDay {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    
    NSInteger day = [components day];
    
    int thisDay = day + 0;
    
    return thisDay;
}

- (int)getCurrentMonth {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit) fromDate:date];
    
    NSInteger month = [components month];
    
    int thisMonth = month + 0;
    
    return thisMonth;
}

- (int)getCurrentYear {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit) fromDate:date];
    
    NSInteger year = [components year];
    
    int thisYear = year + 0;
    
    return thisYear;
}


- (int)getCurrentDateTime {
    NSDate *date = [NSDate date];
    int timeSince1970 = [date timeIntervalSince1970];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
//    
//
//    NSInteger second = [components second];
//    NSInteger minute = [components minute];
//    NSInteger hour = [components hour];
//    NSInteger day = [components day];
//    NSInteger month = [components month];
//    NSInteger year = [components year];
//
//    
//    NSLog(@"Current time is %dHours :  %dMinutes ",  hour, minute);
//    
//    int thisTimeInt = (hour * 60) + minute;
    
	return timeSince1970; //thisTimeInt;
}

// Informal delegate method re-enables bar buttons
- (void) segueDidComplete
{
    item.rightBarButtonItem.enabled = YES;
    item.leftBarButtonItem.enabled = YES;
    
    pageControl.currentPage = vcIndex;
    
//    if (speakItemsAloud) {
//        
//        [self playSound];
//    }

}

- (void)playSound
{
    //	if ([MPMusicPlayerController iPodMusicPlayer].playbackState ==  MPMusicPlaybackStatePlaying)
    //		AudioServicesPlayAlertSound(mysound);
    //	else
    
//    CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:sndpath];
//	
//	// Identify it as not a UI Sound
//    AudioServicesCreateSystemSoundID(baseURL, &currentsound);
//    //    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:sndpath], &currentsound);
//	AudioServicesPropertyID flag = 0;  // 0 means always play
//	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), &currentsound, sizeof(AudioServicesPropertyID), &flag);
//    
//    
//    NSLog(@"Playing audio for item %d", vcIndex);
//    AudioServicesPlaySystemSound(currentsound);
    
//    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"1_Patient"
//                                                withExtension: @"mp3"];
//    
//    // Store the URL as a CFURLRef instance
//    self.soundFileURLRef1 = (CFURLRef) [tapSound retain];
//    
//    tapSound   = [[NSBundle mainBundle] URLForResource: @"1_Patient"
//                                         withExtension: @"mp3"];
 
}

-(IBAction)nextDone:(id)inSender
{
	[self.queuePlayer advanceToNextItem];
	
	NSInteger remainingItems = [[self.queuePlayer items] count];
	
	if (remainingItems < 1)
	{
		[inSender setEnabled:NO];
	}
}

- (void)highlightStronglyDisagree {
    SwitchedImageViewController *sourceVC = [newChildControllers objectAtIndex:vcIndex];
    sourceVC.stronglyDisagreeButton.alpha = 1.0;
    
//    stronglyDisagreeButton.alpha = 1.0;
    sourceVC.disagreeButton.alpha = 0.7;
    sourceVC.neutralButton.alpha = 0.7;
    sourceVC.agreeButton.alpha = 0.7;
    sourceVC.stronglyAgreeButton.alpha = 0.7;
    sourceVC.doesNotApplyButton.alpha = 0.7;
}

- (void)highlightDisagree {
    
    
}


- (void)highlightNeutral {
    
    
}


- (void)highlightAgree {
    
    
}


- (void)highlightStronglyAgree {
    
    
}


- (void)highlightDoesNotApply {
    
    
}

- (void)playSoundForIndex:(int)thisPageIndex {
    // sandy 7-16 will disable the sound prompts after first patient satisfaction survey question here I think may have to do major revision to make this match
    // for now the prompts are just disabled in the call to the tts
    
    BOOL shouldCurrentlyPlayMidwaySound = NO;
    
    //shouldCurrentlyPlayMidwaySound = [self isCurrentSatisfactionItemMidwayWithIndex:thisPageIndex];
    
    NSString *currentQuestionKey = [NSString stringWithFormat:@"%@_q_%d",respondentType,thisPageIndex];
    
    NSString *midwayItemPath;
//    NSString *midwayItemSound;
//    AVPlayerItem *midwayItemToPlay;
    if ([DynamicSpeech isEnabled]){
        
        QuestionList* matchingSurvey = [DynamicContent getSurveyForCurrentClinicAndRespondent];
        NSString* question = NULL;
        if (matchingSurvey != NULL){
            NSString* prompt = NULL;//[matchingSurvey getHeader2];
            NSArray* questionList2 =[matchingSurvey getQuestionSet2];
            int questionList2Count = [questionList2 count];
            if (thisPageIndex < questionList2Count)
                question = [questionList2 objectAtIndex:thisPageIndex];
            else {
                int index = thisPageIndex - questionList2Count;
                if (index == 0)
                    prompt = [matchingSurvey getHeader3];
                NSArray* questionList3 =[matchingSurvey getQuestionSet3];
                int questionList3Count = [questionList3 count];
                if (index < questionList3Count)
                    question = [questionList3 objectAtIndex:index];
            }
            NSMutableArray* utterances = [[NSMutableArray alloc] init];
            if (prompt != NULL && [prompt length] > 0){
                [utterances addObject:prompt];
                if (question != NULL && [question length] > 0)
                    [utterances addObject:@"_PAUSE_"];
            }
            if (question != NULL && [question length] > 0)
                [utterances addObject:question];
            [DynamicSpeech speakList:utterances];
            return;
        }
    }
    
    //sandy 7-16 this is played during the satisfaction survey
    if (shouldCurrentlyPlayMidwaySound) {
 //not hit until q17
        if ([respondentType isEqualToString:@"patient"]) {
           // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"as_a_result_of_my_coming_prompt_new";
            
//            currentPromptString = @"As a result of my coming to the clinic and therapies,";
            
        } else if ([respondentType isEqualToString:@"family"]) {
            // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"FamilyNew_since_i_began_coming_new";
            
//            currentPromptString = @"As a result of my loved one coming to the clinic and therapies,";
            
        } else {
            // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"CaregiverNew_as_a_result_new";
            
//            currentPromptString = @"As a result of coming to the clinic and therapies,";
        }

    } else {
        if ([respondentType isEqualToString:@"patient"]) {
            // sandy 7-20 this is the hack to fix the prompts to match the array
            // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"Patient_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of my coming to the clinic and therapies,";
            
        } else if ([respondentType isEqualToString:@"family"]) {
            // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"Family_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of my loved one coming to the clinic and therapies,";
            
        } else {
            // sandy 7-20 disable prompts to match current question list
            //midwayItemPath = @"CaregiverNew_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of coming to the clinic and therapies,";
        }
    
    }
    
    NSLog(@"retriving Sounds For Question: %@",currentQuestionKey);
   // sandy 7-20 disabling first Prompt
    //[masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:midwayItemPath,@"silence_half_second",currentQuestionKey, nil]];
    [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:currentQuestionKey, nil]];
//[masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:currentQuestionKey, nil]];
}

- (void) showNextSurveyPage {
    [DynamicSpeech stopSpeaking];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
    QuestionList* matchingSurvey = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    finishingLastItem = NO;
    if (matchingSurvey != NULL){
        totalSurveyItems = [[matchingSurvey getQuestionSet2] count] + [[matchingSurvey getQuestionSet3] count];
        surveyItemsRemaining = totalSurveyItems - vcIndex -1;
        if (vcIndex == totalSurveyItems-1) {
            finishingLastItem = YES;
            NSLog(@"RootViewController.showNextSurveyPage() finishingLastItem");
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] surveyCompleted];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeOutSatisfactionSurvey];
            
        } else {
            int newIndex = vcIndex +1;
            NSLog(@"RootViewController_Pad.showNextSurveyPage() SWITCHING from item %d to item %d", vcIndex, newIndex);
        
        // Prepare for segue by disabling bar buttons
        item.rightBarButtonItem.enabled = NO;
        item.leftBarButtonItem.enabled = NO;
        
        //rjl this is where the display and audio are sequed to the next index
        // the phrase "as a result" is always used in case of patient index < 22 (its 21 here)
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        
        //rjl 7/17/14
        /* if( newIndex > 0){
         UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_noprompt_template" bundle:[NSBundle mainBundle]];
         destination = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
         }*/
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = NO; //goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        // rjl
        //int soundIndex = vcIndex;
//        if (soundIndex ==24)
//            soundIndex = 23;
//        else
//            soundIndex = vcIndex +6;
        [self playSoundForIndex:vcIndex] ; //]soundIndex]; //rjl
        
        }
    }
    
}

// Transition to new view using custom segue
- (void)switchToView: (int) newIndex goingForward: (BOOL) goesForward {
    

    finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex]; //rjl 7/15/14
    if (finishingLastItem )
    {
        
        NSLog(@"RootViewController.switchToView() finishingLastItem");
        vcIndex = newIndex;
        
//        // Back to menu
//        [self saySurveyCompletion];
//        [[AppDelegate_Pad sharedAppDelegate] surveyCompleted]; 
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] surveyCompleted];
        
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeOutSatisfactionSurvey];
        
//        [self writeLocalDbToCSVFile];
        
    } else if (vcIndex == newIndex) {
        return;
        
    } else {
        
        
        NSLog(@"RootViewController_Pad.switchtoview() SWITCHING from item %d to item %d", vcIndex, newIndex);
        
        // Prepare for segue by disabling bar buttons
        item.rightBarButtonItem.enabled = NO;
        item.leftBarButtonItem.enabled = NO;
        
        //rjl this is where the display and audio are sequed to the next index
        // the phrase "as a result" is always used in case of patient index < 22 (its 21 here)
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        
        //rjl 7/17/14
       /* if( newIndex > 0){
            UIStoryboard *painScaleStoryboard = [UIStoryboard storyboardWithName:@"survey_new_painscale_noprompt_template" bundle:[NSBundle mainBundle]];
            destination = [painScaleStoryboard instantiateViewControllerWithIdentifier:@"0"];
        }*/
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        // rjl
        int soundIndex = vcIndex;
        if (soundIndex ==24)
            soundIndex = 23;
        else
            soundIndex = vcIndex +6;
        [self playSoundForIndex:vcIndex] ; //]soundIndex]; //rjl
        
        // Update to new sound
        if (vcIndex == 0) {
//            current_satisfaction_sound_item = satisfaction_sound_1_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deactivateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] hidePreviousButton];
            surveyItemsRemaining = totalSurveyItems - 1;
        } else if (vcIndex == 27) {
//            current_satisfaction_sound_item = satisfaction_sound_2_item;
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            surveyItemsRemaining = totalSurveyItems - 2;
        } else if (vcIndex == 26) {
//            current_satisfaction_sound_item = satisfaction_sound_3_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 3;
        } else if (vcIndex == 25) {
//            current_satisfaction_sound_item = satisfaction_sound_4_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 4;
        } else if (vcIndex == 24) {
//            current_satisfaction_sound_item = satisfaction_sound_5_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 5;
        } else if (vcIndex == 23) {
//            current_satisfaction_sound_item = satisfaction_sound_6_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 6;
        } else if (vcIndex == 22) {
//            current_satisfaction_sound_item = satisfaction_sound_7_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 7;
        } else if (vcIndex == 21) {
//            current_satisfaction_sound_item = satisfaction_sound_8_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 8;
        } else if (vcIndex == 20) {
//            current_satisfaction_sound_item = satisfaction_sound_9_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 9;
        } else if (vcIndex == 19) {
//            current_satisfaction_sound_item = satisfaction_sound_10_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 10;
        } else if (vcIndex == 18) {
//            current_satisfaction_sound_item = satisfaction_sound_11_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 11;
        } else if (vcIndex == 17) {
//            current_satisfaction_sound_item = satisfaction_sound_12_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 12;
        } else if (vcIndex == 16) {
//            current_satisfaction_sound_item = satisfaction_sound_13_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 13;
        } else if (vcIndex == 15) {
//            current_satisfaction_sound_item = satisfaction_sound_14_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 14;
        } else if (vcIndex == 14) {
//            current_satisfaction_sound_item = satisfaction_sound_15_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            NSLog(@"RootViewController_Pad.switchtoview() totalSurveyItems: %d", totalSurveyItems);
            surveyItemsRemaining = 0;// rjl 7/15/14 totalSurveyItems - 15;
        } else if (vcIndex == 13) {
//            current_satisfaction_sound_item = satisfaction_sound_16_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 16;
        } else if (vcIndex == 12) {
//            current_satisfaction_sound_item = satisfaction_sound_17_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 17;
        } else if (vcIndex == 11) {
//            current_satisfaction_sound_item = satisfaction_sound_18_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 18;
        } else if (vcIndex == 10) {
//            current_satisfaction_sound_item = satisfaction_sound_19_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 19;
        } else if (vcIndex == 9) {
//            current_satisfaction_sound_item = satisfaction_sound_20_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 20;
        } else if (vcIndex == 8) {
//            current_satisfaction_sound_item = satisfaction_sound_21_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 21;
        } else if (vcIndex == 7) {
//            current_satisfaction_sound_item = satisfaction_sound_22_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 22;
        } else if (vcIndex == 6) {
//            current_satisfaction_sound_item = satisfaction_sound_23_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 23;
        } else if (vcIndex == 5) {
//            current_satisfaction_sound_item = satisfaction_sound_24_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 24;
        } else if (vcIndex == 4) {
//            current_satisfaction_sound_item = satisfaction_sound_25_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 25;
        } else if (vcIndex == 3) {
//            current_satisfaction_sound_item = satisfaction_sound_26_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 26;
        } else if (vcIndex == 2) {
//            current_satisfaction_sound_item = satisfaction_sound_27_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 27;
        } else if (vcIndex == 1) {
//            current_satisfaction_sound_item = satisfaction_sound_28_item;
            finishingLastItem = [self isCurrentSatisfactionItemLastWithIndex:vcIndex];
            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateSurveyBackButton];
            [[[AppDelegate_Pad sharedAppDelegate] loaderViewController] showPreviousButton];
            surveyItemsRemaining = totalSurveyItems - 28;
        }
        
//        if (shouldCurrentlyPlayMidwaySound) {
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:midwayItemToPlay,current_satisfaction_sound_item,nil]];
//        } else {
//            self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:midwayItemToPlay,current_satisfaction_sound_item,nil]];
        }
        
//        [self.playerView setPlayer:self.queuePlayer];
        
        // Create a new AVPlayerItem and make it the player's current item.
        //	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        if (speakItemsAloud) {
            NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
            
            
            
            //        [self.queuePlayer advanceToNextItem];
            
//            //
            //
            //        NSInteger remainingItems = [[self.queuePlayer items] count];
            //
            //        if (remainingItems < 1)
            //        {
            //            //            [inSender setEnabled:NO];
            //            NSLog(@"REACHED LAST ITEM IN AVPLAYERQUEUE");
            //        }
        } // if speakItemsAloud
        
    
}

- (void)replayCurrentSatisfactionSound {
    
    if (speakItemsAloud) {
        
        NSLog(@"Replay current satisfaction sound...");
        [self playSoundForIndex:vcIndex];
    
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
    
//    NSString *satisfaction_sound_1;
//    NSString *satisfaction_sound_2;
//    NSString *satisfaction_sound_3;
//    NSString *satisfaction_sound_4;
//    NSString *satisfaction_sound_5;
//    NSString *satisfaction_sound_6;
//    NSString *satisfaction_sound_7;
//    NSString *satisfaction_sound_8;
//    NSString *satisfaction_sound_9;
//    NSString *satisfaction_sound_10;
//    NSString *satisfaction_sound_11;
//    NSString *satisfaction_sound_12;
//    NSString *satisfaction_sound_13;
//    NSString *satisfaction_sound_14;
//    NSString *satisfaction_sound_15;
//    NSString *satisfaction_sound_16;
//    NSString *satisfaction_sound_17;
//    NSString *satisfaction_sound_18;
//    NSString *satisfaction_sound_19;
//    NSString *satisfaction_sound_20;
//    NSString *satisfaction_sound_21;
//    NSString *satisfaction_sound_22;
//    NSString *satisfaction_sound_23;
//    NSString *satisfaction_sound_24;
//    NSString *satisfaction_sound_25;
//    NSString *satisfaction_sound_26;
//    NSString *satisfaction_sound_27;
//    NSString *satisfaction_sound_28;
//    
//    if ([respondentType isEqualToString:@"patient"]) {
//        satisfaction_sound_1 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q1-care" ofType:@"mp3"];
//        satisfaction_sound_2 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q2-respect" ofType:@"mp3"];
//        satisfaction_sound_3 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q3-ease" ofType:@"mp3"];
//        satisfaction_sound_4 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q4-clear_info" ofType:@"mp3"];
//        satisfaction_sound_5 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q5-concerns_questions" ofType:@"mp3"];
//        satisfaction_sound_6 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q6-goals" ofType:@"mp3"];
//        satisfaction_sound_7 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q7-rights" ofType:@"mp3"];
//        satisfaction_sound_8 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q8-school" ofType:@"mp3"];
//        satisfaction_sound_9 = [[NSBundle mainBundle]
//                                pathForResource:@"Patient_Q9-work" ofType:@"mp3"];
//        satisfaction_sound_10 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q10-solve_probs" ofType:@"mp3"];
//        satisfaction_sound_11 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q11-communication" ofType:@"mp3"];
//        satisfaction_sound_12 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q12-leisure" ofType:@"mp3"];
//        satisfaction_sound_13 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q13-physical" ofType:@"mp3"];
//        satisfaction_sound_14 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q14-emotional" ofType:@"mp3"];
//        satisfaction_sound_15 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q15-QOL" ofType:@"mp3"];
//        satisfaction_sound_16 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q16-progress" ofType:@"mp3"];
//        satisfaction_sound_17 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q17-facilities" ofType:@"mp3"];
//        satisfaction_sound_18 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q18-unique_needs" ofType:@"mp3"];
//        satisfaction_sound_19 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q19-family_included" ofType:@"mp3"];
//        satisfaction_sound_20 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_21 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_22 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_23 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_24 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_25 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_26 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_27 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//        satisfaction_sound_28 = [[NSBundle mainBundle]
//                                 pathForResource:@"Patient_Q20-know_strengths" ofType:@"mp3"];
//    } else if ([respondentType isEqualToString:@"family"]) {
//        satisfaction_sound_1 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q1-care" ofType:@"mp3"];
//        satisfaction_sound_2 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q2-respect" ofType:@"mp3"];
//        satisfaction_sound_3 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q3-me_respect" ofType:@"mp3"];
//        satisfaction_sound_4 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q4-ease" ofType:@"mp3"];
//        satisfaction_sound_5 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q5-clear_info" ofType:@"mp3"];
//        satisfaction_sound_6 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q6-concerns_questions" ofType:@"mp3"];
//        satisfaction_sound_7 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q7-goals" ofType:@"mp3"];
//        satisfaction_sound_8 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q8-goals_for_loved" ofType:@"mp3"];
//        satisfaction_sound_9 = [[NSBundle mainBundle]
//                                pathForResource:@"FamilyNew_Q9-treatment_needs" ofType:@"mp3"];
//        satisfaction_sound_10 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q10-rights" ofType:@"mp3"];
//        satisfaction_sound_11 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q11-rights_as_fam" ofType:@"mp3"];
//        satisfaction_sound_12 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q12-school" ofType:@"mp3"];
//        satisfaction_sound_13 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q13-work" ofType:@"mp3"];
//        satisfaction_sound_14 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q14-solve_probs" ofType:@"mp3"];
//        satisfaction_sound_15 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q15-communication" ofType:@"mp3"];
//        satisfaction_sound_16 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q16-leisure" ofType:@"mp3"];
//        satisfaction_sound_17 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q17-physical" ofType:@"mp3"];
//        satisfaction_sound_18 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q18-emotional" ofType:@"mp3"];
//        satisfaction_sound_19 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q19-relationship" ofType:@"mp3"];
//        satisfaction_sound_20 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q20-QOL" ofType:@"mp3"];
//        satisfaction_sound_21 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q21-progress" ofType:@"mp3"];
//        satisfaction_sound_22 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q22-facilities" ofType:@"mp3"];
//        satisfaction_sound_23 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q23-fam_included" ofType:@"mp3"];
//        satisfaction_sound_24 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q24-knows_strengths" ofType:@"mp3"];
//        satisfaction_sound_25 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q24-knows_strengths" ofType:@"mp3"];
//        satisfaction_sound_26 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q24-knows_strengths" ofType:@"mp3"];
//        satisfaction_sound_27 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q24-knows_strengths" ofType:@"mp3"];
//        satisfaction_sound_28 = [[NSBundle mainBundle]
//                                 pathForResource:@"FamilyNew_Q24-knows_strengths" ofType:@"mp3"];
//    } else {
//        satisfaction_sound_1 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q1-care" ofType:@"mp3"];
//        satisfaction_sound_2 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q2-respect" ofType:@"mp3"];
//        satisfaction_sound_3 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q3-me_respect" ofType:@"mp3"];
//        satisfaction_sound_4 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q4-ease" ofType:@"mp3"];
//        satisfaction_sound_5 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q5-me_ease" ofType:@"mp3"];
//        satisfaction_sound_6 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q6-clear_info" ofType:@"mp3"];
//        satisfaction_sound_7 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q7-i_was_given_clear_info" ofType:@"mp3"];
//        satisfaction_sound_8 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q8-concerns_questions" ofType:@"mp3"];
//        satisfaction_sound_9 = [[NSBundle mainBundle]
//                                pathForResource:@"CaregiverNew_Q9-i_was_given_concerns_questions" ofType:@"mp3"];
//        satisfaction_sound_10 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q10-goals" ofType:@"mp3"];
//        satisfaction_sound_11 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q11-involved_me_in_goals" ofType:@"mp3"];
//        satisfaction_sound_12 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q12-treatment_needs" ofType:@"mp3"];
//        satisfaction_sound_13 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q13-i_was_included" ofType:@"mp3"];
//        satisfaction_sound_14 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q14-rights" ofType:@"mp3"];
//        satisfaction_sound_15 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q15-my_rights" ofType:@"mp3"];
//        satisfaction_sound_16 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q16-school" ofType:@"mp3"];
//        satisfaction_sound_17 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q17-work" ofType:@"mp3"];
//        satisfaction_sound_18 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q18-solve_probs" ofType:@"mp3"];
//        satisfaction_sound_19 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q19-communication" ofType:@"mp3"];
//        satisfaction_sound_20 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q20-leisure" ofType:@"mp3"];
//        satisfaction_sound_21 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q21-physical" ofType:@"mp3"];
//        satisfaction_sound_22 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q22-emotional" ofType:@"mp3"];
//        satisfaction_sound_23 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q23-relationship" ofType:@"mp3"];
//        satisfaction_sound_24 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q24-QOL" ofType:@"mp3"];
//        satisfaction_sound_25 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q25-progress" ofType:@"mp3"];
//        satisfaction_sound_26 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q26-facilities" ofType:@"mp3"];
//        satisfaction_sound_27 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q27-knows_strengths" ofType:@"mp3"];
//        satisfaction_sound_28 = [[NSBundle mainBundle]
//                                 pathForResource:@"CaregiverNew_Q28-better_care" ofType:@"mp3"];
//    }
//    
//    
//    satisfaction_sound_1_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_1]];
//    satisfaction_sound_2_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_2]];
//    satisfaction_sound_3_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_3]];
//    satisfaction_sound_4_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_4]];
//    satisfaction_sound_5_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_5]];
//    satisfaction_sound_6_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_6]];
//    satisfaction_sound_7_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_7]];
//    satisfaction_sound_8_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_8]];
//    satisfaction_sound_9_item = [AVPlayerItem playerItemWithURL:
//                                 [NSURL fileURLWithPath:satisfaction_sound_9]];
//    satisfaction_sound_10_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_10]];
//    satisfaction_sound_11_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_11]];
//    satisfaction_sound_12_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_12]];
//    satisfaction_sound_13_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_13]];
//    satisfaction_sound_14_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_14]];
//    satisfaction_sound_15_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_15]];
//    satisfaction_sound_16_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_16]];
//    satisfaction_sound_17_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_17]];
//    satisfaction_sound_18_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_18]];
//    satisfaction_sound_19_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_19]];
//    satisfaction_sound_20_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_20]];
//    satisfaction_sound_21_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_21]];
//    satisfaction_sound_22_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_22]];
//    satisfaction_sound_23_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_23]];
//    satisfaction_sound_24_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_24]];
//    satisfaction_sound_25_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_25]];
//    satisfaction_sound_26_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_26]];
//    satisfaction_sound_27_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_27]];
//    satisfaction_sound_28_item = [AVPlayerItem playerItemWithURL:
//                                  [NSURL fileURLWithPath:satisfaction_sound_28]];
//    
//    
//    
//    
//    
//    // Update to new sound
//    if (vcIndex == 0) {
//        current_satisfaction_sound_item = satisfaction_sound_1_item;
//    } else if (vcIndex == 27) {
//        current_satisfaction_sound_item = satisfaction_sound_2_item;
//    } else if (vcIndex == 26) {
//        current_satisfaction_sound_item = satisfaction_sound_3_item;
//    } else if (vcIndex == 25) {
//        current_satisfaction_sound_item = satisfaction_sound_4_item;
//    } else if (vcIndex == 24) {
//        current_satisfaction_sound_item = satisfaction_sound_5_item;
//    } else if (vcIndex == 23) {
//        current_satisfaction_sound_item = satisfaction_sound_6_item;
//    } else if (vcIndex == 22) {
//        current_satisfaction_sound_item = satisfaction_sound_7_item;
//    } else if (vcIndex == 21) {
//        current_satisfaction_sound_item = satisfaction_sound_8_item;
//    } else if (vcIndex == 20) {
//        current_satisfaction_sound_item = satisfaction_sound_9_item;
//    } else if (vcIndex == 19) {
//        current_satisfaction_sound_item = satisfaction_sound_10_item;
//    } else if (vcIndex == 18) {
//        current_satisfaction_sound_item = satisfaction_sound_11_item;
//    } else if (vcIndex == 17) {
//        current_satisfaction_sound_item = satisfaction_sound_12_item;
//    } else if (vcIndex == 16) {
//        current_satisfaction_sound_item = satisfaction_sound_13_item;
//    } else if (vcIndex == 15) {
//        current_satisfaction_sound_item = satisfaction_sound_14_item;
//    } else if (vcIndex == 14) {
//        current_satisfaction_sound_item = satisfaction_sound_15_item;
//    } else if (vcIndex == 13) {
//        current_satisfaction_sound_item = satisfaction_sound_16_item;
//    } else if (vcIndex == 12) {
//        current_satisfaction_sound_item = satisfaction_sound_17_item;
//    } else if (vcIndex == 11) {
//        current_satisfaction_sound_item = satisfaction_sound_18_item;
//    } else if (vcIndex == 10) {
//        current_satisfaction_sound_item = satisfaction_sound_19_item;
//    } else if (vcIndex == 9) {
//        current_satisfaction_sound_item = satisfaction_sound_20_item;
//    } else if (vcIndex == 8) {
//        current_satisfaction_sound_item = satisfaction_sound_21_item;
//    } else if (vcIndex == 7) {
//        current_satisfaction_sound_item = satisfaction_sound_22_item;
//    } else if (vcIndex == 6) {
//        current_satisfaction_sound_item = satisfaction_sound_23_item;
//    } else if (vcIndex == 5) {
//        current_satisfaction_sound_item = satisfaction_sound_24_item;
//    } else if (vcIndex == 4) {
//        current_satisfaction_sound_item = satisfaction_sound_25_item;
//    } else if (vcIndex == 3) {
//        current_satisfaction_sound_item = satisfaction_sound_26_item;
//    } else if (vcIndex == 2) {
//        current_satisfaction_sound_item = satisfaction_sound_27_item;
//    } else if (vcIndex == 1) {
//        current_satisfaction_sound_item = satisfaction_sound_28_item;
//    }
        
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:current_satisfaction_sound_item,nil]];
//    
//    [self.playerView setPlayer:self.queuePlayer];
//
//        
//    //

    } // if speakItemsAloud
}

- (void)showReplayButton {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        for (SwitchedImageViewController *switchedController in newChildControllers)
        {
            switchedController.currentReplayButton.alpha = 1.0;
        }
        
    }
    [UIView commitAnimations];
}

- (void)hideReplayButton {
    [UIView beginAnimations:nil context:nil];
    {
        [UIView	setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        
        for (SwitchedImageViewController *switchedController in newChildControllers)
        {
            switchedController.currentReplayButton.alpha = 0.0;
        }
        
    }
    [UIView commitAnimations];
}

- (BOOL)isCurrentSatisfactionItemLastWithIndex:(int)thisIndex {
    NSLog(@"RootViewController_Pad.isCurrentSatisfactionItemLastWithIndex() index: %d", thisIndex);
    BOOL isCurrentIndexLast = NO;
//    QuestionList* matchingSurvey = [DynamicContent getSurveyForRespondentType:respondentType];
//    if (matchingSurvey != NULL){
//        if (thisIndex == [[matchingSurvey getQuestionSet2] count])
//            isCurrentIndexLast = YES;
//    }
//    else
    if ([respondentType isEqualToString:@"patient"]) {
        if (thisIndex == 15){// rjl 7/15/14 ==9) {
            isCurrentIndexLast = YES;
        }
    } else if ([respondentType isEqualToString:@"family"]) {
        if (thisIndex == 15) {// sandy 7-17 original was ==5 updated to 15
            isCurrentIndexLast = YES;
        }//probably need to adjust this for caregiver case
    } else if ([respondentType isEqualToString:@"caregiver"]) {
        if (thisIndex == 10) {// sandy 7-17 original was ==5 updated to 15
            isCurrentIndexLast = YES;
        }//probably need to adjust this for caregiver case
    } else {
        if (thisIndex == 1) {
            isCurrentIndexLast = YES;
        }
    }
    
    if (isCurrentIndexLast)
        NSLog(@"RootViewController_Pad.isCurrentSatisfactionItemLastWithIndex() isCurrentIndexLast = true");
    else
      NSLog(@"RootViewController_Pad.isCurrentSatisfactionItemLastWithIndex() isCurrentIndexLast = false");
    
    return isCurrentIndexLast;
}

- (BOOL)isCurrentSatisfactionItemMidwayWithIndex:(int)thisIndex {
     NSLog(@"RootViewController_Pad.isCurrentSatisfactionItemMidwayWithIndex() index: %d", thisIndex);
    BOOL isCurrentIndexMidway = NO;
    
    if (thisIndex == 0) {
        isCurrentIndexMidway = NO;
    } else {
    
        if ([respondentType isEqualToString:@"patient"]) {
            if (thisIndex <= 17) {//rjl
                isCurrentIndexMidway = YES;
            }
        } else if ([respondentType isEqualToString:@"family"]) {
            if (thisIndex <= 11 ) {
                isCurrentIndexMidway = YES;
            }
        } else {
            if (thisIndex <= 7) {
                isCurrentIndexMidway = YES;
            }
        }
        
    }
    
    if (isCurrentIndexMidway) {
        NSLog(@"Should play midway sound each time after this index: %d", thisIndex);
    }
    
    return isCurrentIndexMidway;
}

-(void)madeDynamicSurveyRatingWithSegmentIndex:(int)selectedIndex {
    NSLog(@"Dynamic Survey Rating Selected: %d", selectedIndex);
    NSString *fieldToUpdate;
    
    int currentDynamicSurveyPageIndex = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] dynamicSurveyModule] vcIndex];
    //updated fieldnames
    // protest NUMERIC,providernameselected TEXT,clinictest NUMERIC,clinicselected TEXT,goalchoices TEXT,todaysGoal TEXT,ps1reason NUMERIC,ps2prepared NUMERIC,ps3looking NUMERIC,ps4prohelp NUMERIC,ps5clinichelp NUMERIC,

    
    switch (currentDynamicSurveyPageIndex) {
        case 0:
            //fieldToUpdate = [NSString stringWithFormat:@"protest"];
            //fieldToUpdate = [NSString stringWithFormat:@"s0protest"];
            break;
        case 1:
            fieldToUpdate = [NSString stringWithFormat:@"clinictest"];
            //fieldToUpdate = [NSString stringWithFormat:@"s1clinictest"];
            break;
        case 2:
            fieldToUpdate = [NSString stringWithFormat:@"goalchoices"];
            //fieldToUpdate = [NSString stringWithFormat:@"s2goalchoice"];
            break;
        case 3:
            fieldToUpdate = [NSString stringWithFormat:@"ps1reason"];
            //fieldToUpdate = [NSString stringWithFormat:@"s3reason"];
            break;
        case 4:
            fieldToUpdate = [NSString stringWithFormat:@"ps2prepared"];
            //fieldToUpdate = [NSString stringWithFormat:@"s4prepared"];
            break;
        case 5:
            fieldToUpdate = [NSString stringWithFormat:@"ps3looking"];
            //fieldToUpdate = [NSString stringWithFormat:@"s5looking"];
            break;
        case 6:
            fieldToUpdate = [NSString stringWithFormat:@"presurvey6"];
            //fieldToUpdate = [NSString stringWithFormat:@""];
            break;
        case 7:
            fieldToUpdate = [NSString stringWithFormat:@"ps4prohelp"];
            //fieldToUpdate = [NSString stringWithFormat:@"s7prohelp"];
            break;
        case 8:
            fieldToUpdate = [NSString stringWithFormat:@"ps5clinichelp"];
            //fieldToUpdate = [NSString stringWithFormat:@"s8clinichelp"];
            break;
        case 9:
            fieldToUpdate = [NSString stringWithFormat:@"presurvey9"];
            //fieldToUpdate = [NSString stringWithFormat:@""];
            break;
        case 10:
            fieldToUpdate = [NSString stringWithFormat:@"presurvey10"];
            //fieldToUpdate = [NSString stringWithFormat:@""];
            break;
//        case 11:
//            fieldToUpdate = [NSString stringWithFormat:@"s11metgoal"];
//            break;
//        case 12:
//            fieldToUpdate = [NSString stringWithFormat:@"s12prepared"];
//            break;
//        case 13:
//            fieldToUpdate = [NSString stringWithFormat:@"s13know"];
//            break;
//        case 14:
//            fieldToUpdate = [NSString stringWithFormat:@"s14recommend"];
//            break;
//        case 15:
//            fieldToUpdate = [NSString stringWithFormat:@"s15tech"];
//            break;
        default:
            break;
    }
    
    [self updateSurveyNumberForField:fieldToUpdate withThisRatingNum:selectedIndex];
}

// Go forward
- (void)progress:(id)sender
{
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] decrementProgressBar];
    
    int newIndex = ((vcIndex + 1) % newChildControllers.count);
    [self switchToView:newIndex goingForward:YES];
    if (speakItemsAloud) {
        
        NSLog(@"PLAYING NEXT ITEM IN queuePlayer...");
        [self.queuePlayer advanceToNextItem];
        
        NSInteger remainingItems = [[self.queuePlayer items] count];
        
        if (remainingItems < 1)
        {
//            [inSender setEnabled:NO];
            NSLog(@"REACHED LAST ITEM IN AVPLAYERQUEUE");
        }
    }
}

// Go backwards
- (void)regress:(id)sender
{
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] incrementProgressBar];
    
    int newIndex = vcIndex - 1;
    if (newIndex < 0) newIndex = newChildControllers.count - 1;
//    if (newIndex < 0) newIndex = 3 - 1;
    [self switchToView:newIndex goingForward:NO];
}

-(void)madeSatisfactionRatingForVC:(id)currentVC withSegmentIndex:(int)selectedIndex {
    NSLog(@"RootViewController_Pad.madeSatisfactionRatingForVC() Satisfaction Rating Selected: %d", selectedIndex);
    NSString *fieldToUpdate;
    
    int shiftedvcIndex = vcIndex; // to avoid the array starts with 0 issue
    QuestionList* surveyQuestions = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    int questionList2_count = [[surveyQuestions getQuestionSet2] count];
    int missingQuestionCount = 15 - questionList2_count;
    if (vcIndex >= questionList2_count)
        shiftedvcIndex += missingQuestionCount;
    
    shiftedvcIndex++;  // always add 1 to change from 0-based to 1-based values;
    
    switch (shiftedvcIndex) {
        case 0:
//            [[AppDelegate_Pad sharedAppDelegate] deactivateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q0"];
            break;
        case 1:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q1"];
            break;
        case 2:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q2"];
            break;
        case 3:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q3"];
            break;
        case 4:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q4"];
            break;
        case 5:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q5"];
            break;
        case 6:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q6"];
            break;
        case 7:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q7"];
            break;
        case 8:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q8"];
            break;
        case 9:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q9"];
            break;
        case 10:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q10"];
            break;
        case 11:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q11"];
            break;
        case 12:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q12"];
            break;
        case 13:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q13"];
            break;
        case 14:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q14"];
            break;
        case 15:
            fieldToUpdate = [NSString stringWithFormat:@"q15"];
            break;
        case 16:
            fieldToUpdate = [NSString stringWithFormat:@"q16"];
            break;
        case 17:
            fieldToUpdate = [NSString stringWithFormat:@"q17"];
            break;
        case 18:
            fieldToUpdate = [NSString stringWithFormat:@"q18"];
            break;
        case 19:
            fieldToUpdate = [NSString stringWithFormat:@"q19"];
            break;
        case 20:
            fieldToUpdate = [NSString stringWithFormat:@"q20"];
            break;
        case 21:
            fieldToUpdate = [NSString stringWithFormat:@"q21"]; //should be the start of the second question set
            break;
        case 22:
            fieldToUpdate = [NSString stringWithFormat:@"q22"];
            break;
        case 23:
            fieldToUpdate = [NSString stringWithFormat:@"q23"];
            break;
        case 24:
            fieldToUpdate = [NSString stringWithFormat:@"q24"];
            break;
        case 25:
            fieldToUpdate = [NSString stringWithFormat:@"q25"];
            break;
        case 26:
            fieldToUpdate = [NSString stringWithFormat:@"q26"];
            break;
        case 27:
            fieldToUpdate = [NSString stringWithFormat:@"q27"];
            break;
        case 28:
            fieldToUpdate = [NSString stringWithFormat:@"q28"];
            break;
        case 29:
            fieldToUpdate = [NSString stringWithFormat:@"q29"];
            break;
        case 30:
            fieldToUpdate = [NSString stringWithFormat:@"q30"];
            break;
            
        default:
            break;
    }

    [self updateSatisfactionRatingForField:fieldToUpdate withSelectedIndex:selectedIndex];
}

- (void)turnVoiceOn:(id)sender {
    NSLog(@"RootViewController.turnVoiceOn() Turned voice ON");
    speakItemsAloud = YES;
    [DynamicSpeech setIsSpeechEnabled:true];
//    [self sayOK];
    
    [self showReplayButton];
    
}

- (void)turnVoiceOff:(id)sender {
    NSLog(@"RootViewController.turnVoiceOff() Turned voice OFF");
    speakItemsAloud = NO;
    [DynamicSpeech stopSpeaking];
    [DynamicSpeech setIsSpeechEnabled:false];
    
//    [self sayOK];
    
    [self hideReplayButton];
}

- (void)setRespondentToPatient:(id)sender {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"patient"];
    
//    item.title = @"Patient Satisfaction Survey";
    item.title = @"Patient Satisfaction Survey";
    
    [self sayOK];
    
    [self putNewRespondentInDB];
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    // sandy thiese will have to be a variable value for new clinics -> currentclinic.totalSurveyItems
    //sandy 7-14 updated totals 7-16 undo
    totalSurveyItems = 14;
    surveyItemsRemaining = 14;

    //totalSurveyItems = 8;
    //surveyItemsRemaining = 8;
}

- (void)setRespondentToFamily:(id)sender {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"family"];
    
//    item.title = @"Family Satisfaction Survey";
    item.title = @"Family Satisfaction Survey";
    
    [self sayOK];
    
    [self putNewRespondentInDB];
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    totalSurveyItems = 18;
    surveyItemsRemaining = 18;
}

- (void)setRespondentToCaregiver:(id)sender {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"caregiver"];
    
//    item.title = @"Caregiver Satisfaction Survey";
    
    item.title = @"Caregiver Satisfaction Survey";
    
    [self sayOK];
    
    [self putNewRespondentInDB];
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    totalSurveyItems = 22;
    surveyItemsRemaining = 22;
}

- (void)updateRespondentToPatient {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"patient"];
    
    //    item.title = @"Patient Satisfaction Survey";
    item.title = @"Patient Satisfaction Survey";
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    //sandy 7-14 updated undid 7-16
    totalSurveyItems = 14;
    surveyItemsRemaining = 14;

    //totalSurveyItems = 8;
    //surveyItemsRemaining = 8;
}

- (void)updateRespondentToFamily {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"family"];
    
    //    item.title = @"Family Satisfaction Survey";
    item.title = @"Family Satisfaction Survey";
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    totalSurveyItems = 18;
    surveyItemsRemaining = 18;
}

- (void)updateRespondentToCaregiver {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"caregiver"];
    
    //    item.title = @"Caregiver Satisfaction Survey";
    
    item.title = @"Caregiver Satisfaction Survey";
    
    [DynamicContent setCurrentRespondent:[respondentType copy]];
    QuestionList* questionInfo = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    [DynamicSurveyViewController_Pad setProviderHelpfulText: [questionInfo getClinicianInfoRatingQuestion]];
    [DynamicSurveyViewController_Pad setClinicHelpfulText: [questionInfo getClinicInfoRatingQuestion]];
    [self updateAllSatisfactionLabelItems];

    totalSurveyItems = 22;
    surveyItemsRemaining = 22;
}

- (void)sayWelcomeToApp {
    //    // Define path to sounds

    NSString *welcome_sound;
    NSString *vapahcs_sound = @"vapahcs_new";
    NSString *main_clinic_sound;
    
    switch ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentMainClinic]) {
        case kATLab:
            main_clinic_sound = @"silence_quarter_second";
            //sandy tried uncommenting this
            main_clinic_sound = @"at_main_clinic";
            break;
        case kPMNRClinic:
            main_clinic_sound = @"pmnr_main_clinic";
            break;
        case kPNSClinic:
            main_clinic_sound = @"pns_main_clinic";
            break;
        case kNoMainClinic:
            main_clinic_sound = @"silence_quarter_second";
            break;
        default:
            main_clinic_sound = @"silence_quarter_second";
            break;
    }
    
    NSString *clinic_sound = @"sub_clinic_all";
    
    NSString *read_sound = @"would_you_like_me_to_read_new";
    
    NSString *participation_is_voluntary_sound = @"~privacy_policy";
// sandy original 4 sentence phrase
//    NSString *participation_is_voluntary_sound = @"~participation_is_voluntary_new";
    
    NSMutableArray *soundFilenamesToRead = [[NSMutableArray alloc] initWithObjects: nil];
    
    if ([[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] isFirstVisit]) {
        welcome_sound = @"welcome_to_the_new";
    } else {
        welcome_sound = @"welcome_back_to_the_new";
    }
    NSLog(@"Starting app with sounds:");
    [soundFilenamesToRead addObject:welcome_sound];
    NSLog(@"- %@",welcome_sound);
//    [soundFilenamesToRead addObject:vapahcs_sound];
//    NSLog(@"- %@",vapahcs_sound);
    [soundFilenamesToRead addObject:main_clinic_sound];
    NSLog(@"- %@",main_clinic_sound);
    if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"None"]) {
        [soundFilenamesToRead addObject:clinic_sound];
        NSLog(@"- %@",clinic_sound);
    } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Acupuncture"]) {
        [soundFilenamesToRead addObject:@"specialty_clinic_acupuncture"];
        NSLog(@"- %@",@"specialty_clinic_acupuncture");
    } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"Pain"]) {
        [soundFilenamesToRead addObject:@"specialty_clinic_pain"];
        NSLog(@"- %@",@"specialty_clinic_pain");
    } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"PNS"]) {
        [soundFilenamesToRead addObject:@"specialty_clinic_pns"];
        NSLog(@"- %@",@"specialty_clinic_pns");
    } else if ([[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] currentSpecialtyClinicName] isEqualToString:@"EMG"]) {
        [soundFilenamesToRead addObject:@"specialty_clinic_emg"];
        NSLog(@"- %@",@"specialty_clinic_emg");
    } else {
        [soundFilenamesToRead addObject:clinic_sound];
        NSLog(@"- %@",clinic_sound);
    }
    
    [soundFilenamesToRead addObject:@"silence_half_second"];
//    [soundFilenamesToRead addObject:@"silence_half_second"];
//    [soundFilenamesToRead addObject:@"silence_half_second"];
    [soundFilenamesToRead addObject:@"silence_half_second"];
    [soundFilenamesToRead addObject:participation_is_voluntary_sound]; //rjl 7/8/14
    [soundFilenamesToRead addObject:@"silence_half_second"];
    [soundFilenamesToRead addObject:read_sound]; //rjl 7/8/14 TTS for "Would you like me to read the questions out loud?"
    NSLog(@"- %@",read_sound);

    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:soundFilenamesToRead];
    }
}

#pragma mark DynamicButtonOverlayDelegate Methods

- (void)goForward {
    [self overlayNextPressed];
}

- (void)goBackward {
    [self overlayPreviousPressed];
}

- (void)overlayNextPressed {
    NSLog(@"overlayNextPressed...");
    QuestionList* matchingSurvey = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    if (matchingSurvey !=  NULL){
        NSLog(@"matchingsurvey not null - should have called incrementProgressBar");
        [self showNextSurveyPage];
    }
    else
        [self regress:self];
    
}

- (void)overlayPreviousPressed {
    NSLog(@"overlayPreviousPressed...");
    finishingLastItem = false;
    [self progress:self];
    
}

//- (void)overlayYesPressed {
//    NSLog(@"overlayYesPressed...");
//    if (inSubclinicMode) {
//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchSatisfactionSurvey];
//    } else {
//        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] launchDynamicSubclinicEducationModule];
//    }
//}
//
//- (void)overlayNoPressed {
//    NSLog(@"overlayNoPressed...");
//    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] returnToMenu];
//}

- (void)overlayMenuPressed {
    NSLog(@"overlayMenuPressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] returnToMenu];
}

- (void)overlayFontsizePressed {
    NSLog(@"RootViewController_Pad.overlayFontsizePressed()...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fontsizeButtonPressed:self];
}

- (void)overlayVoicePressed {
    NSLog(@"overlayVoicePressed...");
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] voiceassistButtonPressed:self];
}

#pragma mark RJGoogleTTSDelegate Methods

- (void)handleFailedRequest {
    NSLog(@"Handling TTS request failure...");
}

- (void)sentAudioRequest {
    NSLog(@"Sent TTS request...");
}

- (void)receivedAudio:(NSMutableData *)data {
    NSLog(@"Audio request received...");
    NSLog(@"data length:%d", [data length]);
    
    //    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:csvpath]];
    
    //    NSString* fullStringToWrite = [allSatisfactionPatients componentsJoinedByString:@""];
    //    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"()\""];
    //    fullStringToWrite = [[fullStringToWrite componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
    
    //    [fullStringToWrite writeToFile:filePathLib atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    //    NSLog(@"Satisfaction sql db written to local file: %@", csvpath);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tts_test3.mp3"];
    
    //    [data writeToFile:[self filePathWithName:@"tmp.mp3"] atomically:YES];
    [data writeToFile:path atomically:YES];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"======== SUCCESSFULLY RETRIEVED SYNTHESIZED MP3...======== ");
        
        //        NSString *test_sound = [[NSBundle mainBundle] pathForResource:@"tts_test2" ofType:@"mp3"];
        AVPlayerItem *test_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
        
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:test_item,nil]];
        //
        
        //        player = [[AVAudioPlayer alloc] initWithContentsOfURL:
        //                  [NSURL fileURLWithPath:path] error:&err];
        //        player.volume = 0.4f;
        //        [player prepareToPlay];
        //        [player setNumberOfLoops:0];
        //        [player play];
    } else {
        NSLog(@"======== FAILED TO RETRIEVE SYNTHESIZED MP3...======== ");
    }
}

- (void)testGoogleTTS {
    
    NSLog(@"Testing google's TTS...");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tts_test3.mp3"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"======== SUCCESSFULLY RETRIEVED SYNTHESIZED MP3...======== ");
        
        //        NSString *test_sound = [[NSBundle mainBundle] pathForResource:@"tts_test" ofType:@"mp3"];
        AVPlayerItem *test_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
        
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:test_item,nil]];
        //
    
        
//    NSString *urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",text];
//    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
//    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" forHTTPHeaderField:@"User-Agent"];
//    NSURLResponse* response = nil;
//    NSError* error = nil;
//    NSData* data = [NSURLConnection sendSynchronousRequest:request
//                                         returningResponse:&response
//                                                     error:&error];
//    [data writeToFile:path atomically:YES];
    
        
    

    
//    NSLog(@"data length:%d", [sounds length]);
//    [sounds writeToFile:[self filePathWithName:@"tmp.mp3"] atomically:YES];
    
//    AVAudioPlayer  *player;
//    NSError        *err;
    
        
//        player = [[AVAudioPlayer alloc] initWithContentsOfURL:
//                  [NSURL fileURLWithPath:path] error:&err];
//        player.volume = 0.4f;
//        [player prepareToPlay];
//        [player setNumberOfLoops:0];
//        [player play];    
    } else {
        NSLog(@"======== FAILED TO RETRIEVE SYNTHESIZED MP3... CREATING NEW ONE======== ");
        NSString *text = @"Welcome to the V A Palo Alto Healthcare System Physical Medicine and Rehabilitation E M G clinic.";
        RJGoogleTTS *googleTTSObject = [[RJGoogleTTS alloc] init];
        googleTTSObject.delegate = self;
        
        [googleTTSObject convertTextToSpeech:text];
    }
}

- (void) sayFirstSatisfactionSurveyItem{
    [DynamicSpeech stopSpeaking];
    QuestionList* matchingSurvey = [DynamicContent getSurveyForCurrentClinicAndRespondent];
    
    if (matchingSurvey != NULL){
        NSString* prompt = [matchingSurvey getHeader2];
        NSArray* questionList =[matchingSurvey getQuestionSet2];
        NSString* question1 = [questionList objectAtIndex:0];
        NSMutableArray* utterances = [[NSMutableArray alloc] init];
        if (prompt != NULL && [prompt length] > 0){
            [utterances addObject:prompt];
            if (question1 != NULL && [question1 length] > 0)
                [utterances addObject:@"_PAUSE_"];
        }
        if (question1 != NULL && [question1 length] > 0)
            [utterances addObject:question1];
        [DynamicSpeech speakList:utterances];
    }

}

- (void)sayFirstItem {
    if ([respondentType isEqualToString:@"patient"]) {
        totalSurveyItems = 8;//rjl 7/15/14 20;
        surveyItemsRemaining = 8;//rjl 7/15/14 20;
    } else if ([respondentType isEqualToString:@"family"]) {
        totalSurveyItems = 8; // sandy 7-17 original was 24
        surveyItemsRemaining = 8;
    } else {
        totalSurveyItems = 13; // sandy 7-17 original was 28
        surveyItemsRemaining = 13;
    }
    NSLog(@"RootViewController.sayFirstSatisfactionSurveyItem() totalSurveyItems %d", totalSurveyItems);

    NSString *preFirstItemPath;
    NSString *firstItemPath;
//    
//    if ([respondentType isEqualToString:@"patient"]) {
//        preFirstItemPath = @"Patient_please_tell_about_clinic_by_marking";
//        firstItemPath = @"Patient_Q1-care";
//    } else if ([respondentType isEqualToString:@"family"]) {
//        preFirstItemPath = @"FamilyNew_please_tell_about_clinic_by_marking";
//        firstItemPath = @"FamilyNew_Q1-care";
//    } else {
//        preFirstItemPath = @"CaregiverNew_please_tell_about_clinic_by_marking";
//        firstItemPath = @"CaregiverNew_Q1-care";
//    }
    
    
    
    if (speakItemsAloud) {
//        NSString *pre_satisfaction_sound_1 = [[NSBundle mainBundle] pathForResource:preFirstItemPath ofType:@"mp3"];
//        NSString *satisfaction_sound_1 = [[NSBundle mainBundle] pathForResource:firstItemPath ofType:@"mp3"];
//        AVPlayerItem *pre_satisfaction_sound_1_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:pre_satisfaction_sound_1]];
//        AVPlayerItem *satisfaction_sound_1_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:satisfaction_sound_1]];
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:pre_satisfaction_sound_1_item,satisfaction_sound_1_item,nil]];
//        //
  // sandy 7-20 this is where the first item speech is set for the satisfaction survey. There should not be a Label string for questions after this first question
    if ([respondentType isEqualToString:@"patient"]) {
        preFirstItemPath = @"Patient_please_tell_about_clinic_by_marking_new";
        firstItemPath = @"patient_q_0";
    } else if ([respondentType isEqualToString:@"family"]) {
        preFirstItemPath = @"Family_please_tell_about_clinic_by_marking_new";
        firstItemPath = @"family_q_0";
    } else {
        preFirstItemPath = @"CaregiverNew_please_tell_about_clinic_by_marking_new";
        firstItemPath = @"caregiver_q_0";
    }
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:preFirstItemPath,firstItemPath, nil]];
    }
}

- (void)sayOK {
    if (false){ //speakItemsAloud) {
        
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"okay_new", nil]];
        
//    NSString *ok_sound = [[NSBundle mainBundle]
//                          pathForResource:@"okay" ofType:@"mp3"];
//    AVPlayerItem *ok_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:ok_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:ok_item,nil]];
//    //
    }
}

- (void)sayRespondentTypes {
    if (speakItemsAloud) {
        NSMutableArray *soundFilenamesToRead = [[NSMutableArray alloc] initWithObjects:@"are_you_a_pt_fam_care", nil];
        [masterTTSPlayer playItemsWithNames:soundFilenamesToRead];
    }
}

- (void)saySelectActivity {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"please_choose_a_wr_activity_new", nil]];
//    NSString *activity_sound = [[NSBundle mainBundle]
//                                   pathForResource:@"please_choose_a_wr_activity" ofType:@"mp3"];
//    AVPlayerItem *activity_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:activity_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:activity_item,nil]];
//    //
    }
}

- (void)saySurveyIntro {
    if (speakItemsAloud) {
        if ([DynamicSpeech isEnabled]){
            NSMutableArray* utterances = [[NSMutableArray alloc] init];
            NSString* surveyName = NULL;
            if ([respondentType isEqualToString:@"patient"]) {
                surveyName = @"Patient Satisfaction Survey";
            } else if ([respondentType isEqualToString:@"family"]) {
                surveyName = @"Family Satisfaction Survey";
            } else {
                surveyName = @"Caregiver Satisfaction Survey";
            }
            [utterances addObject:surveyName];
            [utterances addObjectsFromArray:[DynamicContent getPrivacyPolicyForSpeech]];
            [DynamicSpeech speakList:utterances];
            return;
        }
        NSString *respondentSurveyPath;
        
        if ([respondentType isEqualToString:@"patient"]) {
            respondentSurveyPath = @"Patient_satisfaction_survey_new";
        } else if ([respondentType isEqualToString:@"family"]) {
            respondentSurveyPath = @"Family_satisfaction_survey_new";
        } else {
            respondentSurveyPath = @"caregiver_satisfaction_survey_new";
        }
        
        // sandy original string contains 4th phrase
        //[masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:respondentSurveyPath,@"~participation_is_voluntary_new", nil]];
        
        // sandy 3 string privacy policy
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:respondentSurveyPath,@"~privacy_policy", nil]];
    }
}
//    NSString *surveyintro_sound_a = [[NSBundle mainBundle]
//                                   pathForResource:respondentSurveyPath ofType:@"mp3"];
//    AVPlayerItem *surveyintro_item_a = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_a]];
//    NSString *surveyintro_sound_b = [[NSBundle mainBundle]
//                                     pathForResource:@"participation_is_voluntary" ofType:@"mp3"];
//    AVPlayerItem *surveyintro_item_b = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_b]];
//
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveyintro_item_a,surveyintro_item_b,nil]];
//    //
    //}
//}

- (void)saySurveyAgreement {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"tap_agree_or_disagree_new", nil]];
//        NSString *surveyintro_sound_b = [[NSBundle mainBundle]
//                                         pathForResource:@"tap_agree_or_disagree" ofType:@"mp3"];
//        AVPlayerItem *surveyintro_item_b = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_b]];
//
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveyintro_item_b,nil]];
//        //
    }
}

- (void)sayThankYouForParticipatingMoveToFirstItem {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"thank_you_will_be_presented-short_new", @"lets_move_to_first-short_new",nil]];
//        NSString *surveyintro_sound_c= [[NSBundle mainBundle]
//                                        pathForResource:@"thank_you_will_be_presented-short" ofType:@"mp3"];
//        AVPlayerItem *surveyintro_item_c = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_c]];
//        NSString *surveyintro_sound_d= [[NSBundle mainBundle]
//                                        pathForResource:@"lets_move_to_first-short" ofType:@"mp3"];
//        AVPlayerItem *surveyintro_item_d = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_d]];
//        
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveyintro_item_c,surveyintro_item_d,nil]];
//        //
    }
}

- (void)sayEducationModuleCompletion {
    if (speakItemsAloud) {
        
    NSString *edModulecomplete_sound = [[NSBundle mainBundle]
                                   pathForResource:@"you_have_completed_tbi_and_brain" ofType:@"mp3"];
    AVPlayerItem *edModulecomplete_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:edModulecomplete_sound]];
        NSString *return_to_menu_sound = [[NSBundle mainBundle]
                                          pathForResource:@"in_five_seconds_returned_to_menu" ofType:@"mp3"];
        AVPlayerItem *return_to_menu_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:return_to_menu_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:edModulecomplete_item,return_to_menu_item,nil]];
    //
    }
}

- (void)saySurveyCompletion {
    if (speakItemsAloud) {
        
        NSString *respondentSurveyPath;
        
        if ([respondentType isEqualToString:@"patient"]) {
            respondentSurveyPath = @"Patient_satisfaction_survey";
        } else if ([respondentType isEqualToString:@"family"]) {
            respondentSurveyPath = @"Family_satisfaction_survey";
        } else {
            respondentSurveyPath = @"caregiver_satisfaction_survey";
        }
        
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"thank_you_for_completing_the_new",respondentSurveyPath,@"in_five_seconds_returned_to_menu_new",nil]];
        
//        NSString *surveyintro_sound_a = [[NSBundle mainBundle]
//                                         pathForResource:respondentSurveyPath ofType:@"mp3"];
//        AVPlayerItem *surveyintro_item_a = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveyintro_sound_a]];
//        NSString *surveycomplete_sound = [[NSBundle mainBundle]
//                                          pathForResource:@"thank_you_for_completing_the" ofType:@"mp3"];
//        AVPlayerItem *surveycomplete_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:surveycomplete_sound]];
//        NSString *return_to_menu_sound = [[NSBundle mainBundle]
//                                          pathForResource:@"in_five_seconds_returned_to_menu" ofType:@"mp3"];
//        AVPlayerItem *return_to_menu_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:return_to_menu_sound]];
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:surveycomplete_item,surveyintro_item_a,return_to_menu_item,nil]];
//        //
    }
}

- (void)sayComingSoon {
    if (speakItemsAloud) {
    NSString *comingsoon_sound = [[NSBundle mainBundle]
                                   pathForResource:@"coming_soon_short" ofType:@"mp3"];
    if (comingsoon_sound != NULL){
        AVPlayerItem *comingsoon_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:comingsoon_sound]];
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:comingsoon_item,nil]];
    }
    //
    }
}

- (void)sayAgree {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"i_agree_new",nil]];
//    NSString *agree_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"i_agree" ofType:@"mp3"];
//    AVPlayerItem *agree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:agree_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:agree_item,nil]];
//    //
    }
}

- (void)sayAgreeLonger {
    if (speakItemsAloud) {
//        NSString *agree_sound = [[NSBundle mainBundle]
//                                 pathForResource:@"i_agree_longer2" ofType:@"mp3"];
//        AVPlayerItem *agree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:agree_sound]];
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:agree_item,nil]];
//        //
    }
}

- (void)sayDisagree {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"i_disagree_new",nil]];
//    NSString *Disagree_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"i_disagree" ofType:@"mp3"];
//    AVPlayerItem *Disagree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:Disagree_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:Disagree_item,nil]];
//    //
    }
}

- (void)sayNA {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"does_not_apply_to_me_new",nil]];
//    NSString *NA_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"does_not_apply_to_me" ofType:@"mp3"];
//    AVPlayerItem *NA_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:NA_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:NA_item,nil]];
//    //
    }
}

- (void)sayNeutral {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"i_am_neutral_new",nil]];
//    NSString *Neutral_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"i_am_neutral" ofType:@"mp3"];
//    AVPlayerItem *Neutral_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:Neutral_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:Neutral_item,nil]];
//    //
    }
}

- (void)sayStrongAgree {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"i_strongly_agree_new",nil]];
//    NSString *StrongAgree_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"i_strongly_agree" ofType:@"mp3"];
//    AVPlayerItem *StrongAgree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:StrongAgree_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:StrongAgree_item,nil]];
//    //
    }
}

- (void)sayStrongDisagree {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"i_strongly_disagree_new",nil]];
//    NSString *StrongDisagree_sound = [[NSBundle mainBundle]
//                                  pathForResource:@"i_strongly_disagree" ofType:@"mp3"];
//    AVPlayerItem *StrongDisagree_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:StrongDisagree_sound]];
//    [self.queuePlayer removeAllItems];
//    self.queuePlayer = nil;
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:StrongDisagree_item,nil]];
//    //
    }
}

- (void)sayEdModuleIntro {
    if (speakItemsAloud) {
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:@"tbi_brain_intro",nil]];
        
//
        
//        NSString *edModule_sound = [[NSBundle mainBundle]
//                                          pathForResource:@"tbi_ed_module_intro" ofType:@"mp3"];
//        AVPlayerItem *edModule_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:edModule_sound]];
//        NSString *next_sound = [[NSBundle mainBundle]
//                                    pathForResource:@"press_next_to_continue" ofType:@"mp3"];
//        AVPlayerItem *next_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:next_sound]];
//        [self.queuePlayer removeAllItems];
//        self.queuePlayer = nil;
//        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:edModule_item,next_item,nil]];
        //
    }
    
}

- (IBAction)showDefault:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showFlip:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showDissolve:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)showCurl:(id)sender {
    SampleViewController *sampleView = [[[SampleViewController alloc] init] autorelease];
    [sampleView setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:sampleView animated:YES];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [backsplash setupReflection];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.queuePlayer = nil;
}


- (void)dealloc {
    
    [respondentType release];
    [backsplash release];
    [mPlayerView release];
    [pageControl release];
    [newChildControllers release];
    [item release];
    [bar release];
    
    [super dealloc];
}


@end
