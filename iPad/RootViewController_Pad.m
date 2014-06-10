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
@synthesize databasePath, mainTable, csvpath, databaseName;
@synthesize vcIndex;
@synthesize currentFontSize, patientSatisfactionLabelItems, familySatisfactionLabelItems, caregiverSatisfactionLabelItems, totalSurveyItems, surveyItemsRemaining, currentPromptString;
@synthesize patientPromptLabelItems, familyPromptLabelItems, caregiverPromptLabelItems, masterTTSPlayer, numSurveyItems, newChildControllers;

// Establish core interface
- (void)viewDidLoad
{
    currentDeviceName = @"iPad";
    
    speakItemsAloud = YES;
    
    finishingLastItem = NO;
    
    currentFontSize = 1;
    
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
    //backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, -75.0f);
    // sandy why is this shifted by 75?
    backsplash.frame = CGRectOffset(backsplash.frame, 0.0f, -75.0f);
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
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"survey_painscale_template" bundle:[NSBundle mainBundle]];
    
    NSMutableArray *storyboardControllerArray = [[NSMutableArray alloc] initWithObjects: nil];
    
    for (int i = 0; i < numSurveyItems; i++) {
        [storyboardControllerArray addObject:[aStoryboard instantiateViewControllerWithIdentifier:@"0"]];
        
    }
    
    newChildControllers = [[NSMutableArray alloc] initWithArray:storyboardControllerArray];
        
    NSLog(@"CREATED CHILDCONTROLLERS...");
    
    // Set each child as a child view controller, setting its tag and frame
    for (SwitchedImageViewController *controller in newChildControllers)
    {
       //sandy resetting this just to see what happens changed back to 1024
       // controller.view.tag = 1066;
        controller.view.tag = 1024;
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
//    [NSArray arrayWithObjects:plainPart,csvPart,nil];
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
                                     @"The staff treated me with respect.", nil];
    familySatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"My loved one received high quality care.",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"Unused Unused",
                                    @"My loved one knows his/her strengths and limitations better.",
                                    @"Our family was included in my loved one’s treatment program.",
                                    @"The facilities were comfortable, clean and well maintained.",
                                    @"I am pleased with the progress my loved one has made.",
                                    @"The overall quality of my loved one’s life has improved.",
                                    @"My relationship with my loved one has improved.",
                                    @"My loved one’s physical functioning has improved.",
                                    @"I feel that my rights as a family member have been respected.",
                                    @"I feel that my loved one’s rights as a patient have been respected.",
                                    @"My loved one’s treatment needs were addressed.",
                                    @"The staff involved me in setting treatment goals for my loved one.",
                                    @"The staff involved my loved one in setting treatment goals.",
                                    @"Our family was given clear, understandable information about our concerns and questions.",
                                    @"Our family was given clear information about the clinic program.",
                                    @"Clinic staff put our family at ease and took time to hear our concerns.",
                                    @"The staff treated me with respect.",
                                    @"The staff treated my loved one with respect.", nil];
    caregiverSatisfactionLabelItems = [[NSArray alloc] initWithObjects:@"The patient I care for received high quality care.",
                                       @"I feel better able to provide care for my patient.",
                                       @"My patient knows his or her strengths and limitations better.",
                                       @"The facilities were comfortable, clean and well maintained.",
                                       @"I am pleased with the progress my patient has made.",
                                       @"The overall quality of my patient’s life has improved.",
                                       @"My relationship with the patient I care for has improved.",
                                       @"My patient’s physical functioning has improved.",
                                       @"I feel that my rights as a caregiver have been respected.",
                                       @"I feel that my patient’s rights have been respected.",
                                       @"I was included in my patient’s treatment program.",
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
                                       @"The staff treated the patient I care for with respect.", nil];
    
    patientPromptLabelItems = [[NSArray alloc] initWithObjects:@"Please tell us about the services you received in this clinic, by marking the following scale,",
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
                                    @"Please tell us about the services you received in this clinic, by marking the following scale,", nil];
    
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
                                    @"Please tell us about the services your loved one received in this clinic, by marking the following scale,", nil];
    
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
                                       @"Please tell us about your impression of the services offered in this clinic, by marking the following scale,", nil];
                                    
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
    
    NSArray *satisfactionLabelItemArrayToUse;
    NSArray *satisfactionPromptLabelItemArrayToUse;
    
    if ([respondentType isEqualToString:@"patient"]) {
        NSLog(@"All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = patientSatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = patientPromptLabelItems;
    } else if ([respondentType isEqualToString:@"family"]) {
        NSLog(@"All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = familySatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = familyPromptLabelItems;
    } else if ([respondentType isEqualToString:@"caregiver"]) {
        NSLog(@"All satisfaction survey item labels updated for respondent type: %@", respondentType);
        satisfactionLabelItemArrayToUse = caregiverSatisfactionLabelItems;
        satisfactionPromptLabelItemArrayToUse = caregiverPromptLabelItems;
    } else {
        NSLog(@"Updating prompts only...No need to update satisfaction survey labels...defaults to respondent: %@", respondentType);
        satisfactionPromptLabelItemArrayToUse = patientPromptLabelItems;
    }
    
    int satisfactionLabelArrayIndex = 0;
    
    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        //        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
        NSLog(@"Updating %@ item # %d...",respondentType,satisfactionLabelArrayIndex);
        
        switchedController.currentSatisfactionLabel.text = [satisfactionLabelItemArrayToUse objectAtIndex:satisfactionLabelArrayIndex];
        switchedController.currentPromptLabel.text = [satisfactionPromptLabelItemArrayToUse objectAtIndex:satisfactionLabelArrayIndex];
        
        satisfactionLabelArrayIndex++;
    }
    
}

- (void)cycleFontSizeForAllLabels {
    CGFloat newFontSize;
    
    // 1 = avenir medium 30
    if (currentFontSize == 1) {
        newFontSize = 40.0f;
        currentFontSize = 2;
    } else if (currentFontSize == 2) {
        newFontSize = 50.0f;
        currentFontSize = 3;
    } else {
        newFontSize = 30.0f;
        currentFontSize = 1;
    }

    for (SwitchedImageViewController *switchedController in newChildControllers)
    {
        switchedController.currentSatisfactionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:newFontSize];
    }
}

#pragma mark SQLite Database Methods

- (void)checkAndLoadLocalDatabase {
	
	NSLog(@"Loading local sqlite3 db...");
	
	// Setup some globals
//	databaseName = @"new_satisfaction_responses_deid.sql";
//    databaseName = @"testdb.sql";
    
   // databaseName = @"myguide_WR_db_d.sql";
    //sandy updated dbase name
databaseName = @"myguide_WR_db_e.sql";
    mainTable = @"sessiondata";
    csvpath = @"satisfactiondata.csv";
    
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
    NSLog(@"====== DB Open ========");
    if(sqlite3_open([[self filePath]UTF8String], &db) !=SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to Open");
    }
}

-(void)closeDB {
    sqlite3_close(db);
    NSLog(@"====== DB Closed ======");
}

-(void)insertrecordIntoTable:(NSString*) tableName withField1:(NSString*) field1 field1Value:(NSString*)field1Vaue andField2:(NSString*)field2 field2Value:(NSString*)field2Value
{
    
    NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@')VALUES(?,?)",tableName,field1,field2];
    const char *sql=[sqlStr UTF8String];
    
    sqlite3_stmt *statement1;
    
    if(sqlite3_prepare_v2(db, sql, -1, &statement1, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement1, 1, [field1Vaue UTF8String], -1, nil);
        sqlite3_bind_text(statement1, 2, [field2Value UTF8String], -1, nil);
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
    
    sqlite3_stmt *statement1;
    
    if(sqlite3_prepare_v2(db, sql, -1, &statement1, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement1, 1, [newFieldValue UTF8String], -1, nil);
        sqlite3_bind_text(statement1, 2, [IDField1Vaue UTF8String], -1, nil);
        NSLog(@"====== Field Updated! ======");
    }
    if(sqlite3_step(statement1) !=SQLITE_DONE)
        NSAssert(0, @"Error upadating table");
    sqlite3_finalize(statement1);
}

-(void)createNewRespondentWithRespondentType:(NSString*)currentRespondentType {
    currentUniqueID = [self getUniqueIDFromCurrentTime];
    NSString *uniqueIDString = [NSString stringWithFormat:@"%d", currentUniqueID];
    [self insertrecordIntoTable:mainTable withField1:@"uniqueid" field1Value:uniqueIDString andField2:@"respondenttype" field2Value:currentRespondentType];
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
    sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = '%@' Where uniqueid = %d", satisfactionItem, thisText, currentUniqueID];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        // Loop through the results and add them to the feeds array
        if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"======== Updated row for respondent %d (%@ = '%@') ! =========", currentUniqueID, satisfactionItem, thisText);
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
    sqlStatementString = [NSString stringWithFormat:@"update sessiondata Set %@ = %d Where uniqueid = %d", satisfactionItem, currentIndex, currentUniqueID];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        // Loop through the results and add them to the feeds array
        if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"======== Updated row for respondent %d (%@ = %d) ! =========", currentUniqueID, satisfactionItem, currentIndex);
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
    
    
    // Setup the SQL Statement and compile it for faster access 
    sqlStatementString = [NSString stringWithFormat:@"insert into sessiondata values(%d,%d,%d,'%@',%d,'%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'%@','%@','%@','%@','%@',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d,'%@',%d,%d,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,%d,%d)",[[NSNumber numberWithBool:inPilotPhase]intValue],0,0,accesspointName,[[NSNumber numberWithBool:wanderGuardIsON]intValue],currentAppVersion,thisProviderName,thisVisitString,thisSpecialtyClinicName,thisClinicName,[[UIDevice currentDevice] name], currentUniqueID, [[NSNumber numberWithBool:inDemoMode]intValue], respondentType, [self getCurrentMonth], [self getCurrentYear], [[NSNumber numberWithBool:speakItemsAloud]intValue],fontsize];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
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
		sqlStatement = "SELECT MAX(uniqueid) FROM sessiondata";
        //		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
				maxRowID = (int)sqlite3_column_int(compiledStatement, 0);
				NSLog(@"New maximum uniqueID in sessiondata table = %d", maxRowID);
				
			}
		}
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);
    
    if(sqlite3_open([[self filePath] UTF8String], &db) == SQLITE_OK) {
		
		// Setup the SQL Statement and compile it for faster access
		//		const char *sqlStatement = "select * from animals";
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
    
        NSLog(@"getAllUniqueIds");
        
        NSMutableArray *allUniqueIds = [[NSMutableArray alloc] initWithObjects: nil];
        
//        NSArray *rowArray;
    
        const char *sqlStatement;
        sqlite3_stmt *compiledStatement;
        NSString *sqlStatementString;
        
        int uniqueIDtmp = 0;

        int currentColIndex = 0;
        
        // Setup the SQL Statement and compile it for faster access
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
        NSLog(@"- %d",[thisUniqueId intValue]);
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

- (void)writeLocalDbToCSVFile {
    
    [self openDB];
    
    NSLog(@"Writing satisfaction sql db to file: %@", csvpath);
    
    NSMutableArray *allSatisfactionPatients = [[NSMutableArray alloc] initWithObjects:@"UNIQUEID,DEMO,RESPONDENTTYPE,FONTTMP,MONTH,YEAR,STARTEDSURVEY,FINISHEDSURVEY,TOTALSURVEYDURATION,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,VOICEASSIST,FONTSIZE", nil];

    NSArray *rowArray;

    const char *sqlStatement;
    sqlite3_stmt *compiledStatement;
    NSString *sqlStatementString;
    
    int uniqueIDtmp = 0;
    int debugModeTmp = 0;
    NSString *respondentTypeTmp = @"";
    int monthTmp = 0;
    int yearTmp = 0;
    int startedSatTmp = 0;
    int finishedSatTmp = 0;
    int surveydurTmp = 0;
    int q1Tmp = 0;
    int q2Tmp = 0;
    int q3Tmp = 0;
    int q4Tmp = 0;
    int q5Tmp = 0;
    int q6Tmp = 0;
    int q7Tmp = 0;
    int q8Tmp = 0;
    int q9Tmp = 0;
    int q10Tmp = 0;
    int q11Tmp = 0;
    int q12Tmp = 0;
    int q13Tmp = 0;
    int q14Tmp = 0;
    int q15Tmp = 0;
    int q16Tmp = 0;
    int voiceTmp = 0;
    NSString *appVerTmp = @"";
    int fontTmp = 0;
    int anotherFontTmp = 0;
    
    int writingRowIndex = 1;
    int currentColIndex = 0;
    
    // Setup the SQL Statement and compile it for faster access
    sqlStatementString = [NSString stringWithFormat:@"SELECT * FROM sessiondata"];
    sqlStatement = (const char *)[sqlStatementString UTF8String];
    
    if(sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {

            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                currentColIndex = 0;
                
                uniqueIDtmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                debugModeTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                respondentTypeTmp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, currentColIndex)];
                monthTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                yearTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                startedSatTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                finishedSatTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                surveydurTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q1Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q2Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q3Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q4Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q5Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q6Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q7Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q8Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q9Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q10Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q11Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q12Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q13Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q14Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q15Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                q16Tmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                voiceTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                fontTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                currentColIndex++;
                anotherFontTmp = (int)sqlite3_column_int(compiledStatement, currentColIndex);
                
                rowArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d,%@,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",uniqueIDtmp,debugModeTmp,respondentTypeTmp,monthTmp,yearTmp,startedSatTmp,finishedSatTmp,surveydurTmp,q1Tmp,q2Tmp,q3Tmp,q4Tmp,q5Tmp,q6Tmp,q7Tmp,q8Tmp,q9Tmp,q10Tmp,q11Tmp,q12Tmp,q13Tmp,q14Tmp,q15Tmp,q16Tmp,voiceTmp,fontTmp,anotherFontTmp], nil];
                [allSatisfactionPatients addObject:rowArray];
                
                NSLog(@"Writing row %d (%@) to csv file...",writingRowIndex,respondentTypeTmp);
                writingRowIndex++;
            }
        
            sqlite3_finalize(compiledStatement);

    }else{
        NSLog(@"database error");
    }
    
    [self closeDB];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:csvpath]];
    
    NSString* fullStringToWrite = [allSatisfactionPatients componentsJoinedByString:@""];
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"()\""];
    fullStringToWrite = [[fullStringToWrite componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
    
    [fullStringToWrite writeToFile:filePathLib atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
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
    
    BOOL shouldCurrentlyPlayMidwaySound = NO;
    
    shouldCurrentlyPlayMidwaySound = [self isCurrentSatisfactionItemMidwayWithIndex:thisPageIndex];
    
    NSString *currentQuestionKey = [NSString stringWithFormat:@"%@_q_%d",respondentType,thisPageIndex];
    
    NSString *midwayItemPath;
//    NSString *midwayItemSound;
//    AVPlayerItem *midwayItemToPlay;
    
    if (shouldCurrentlyPlayMidwaySound) {
        
        if ([respondentType isEqualToString:@"patient"]) {
            midwayItemPath = @"as_a_result_of_my_coming_prompt_new";
            
//            currentPromptString = @"As a result of my coming to the clinic and therapies,";
            
        } else if ([respondentType isEqualToString:@"family"]) {
            midwayItemPath = @"FamilyNew_since_i_began_coming_new";
            
//            currentPromptString = @"As a result of my loved one coming to the clinic and therapies,";
            
        } else {
            midwayItemPath = @"CaregiverNew_as_a_result_new";
            
//            currentPromptString = @"As a result of coming to the clinic and therapies,";
        }
        
    } else {
        if ([respondentType isEqualToString:@"patient"]) {
            midwayItemPath = @"Patient_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of my coming to the clinic and therapies,";
            
        } else if ([respondentType isEqualToString:@"family"]) {
            midwayItemPath = @"Family_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of my loved one coming to the clinic and therapies,";
            
        } else {
            midwayItemPath = @"CaregiverNew_please_tell_about_clinic_by_marking_new";
            
//            currentPromptString = @"As a result of coming to the clinic and therapies,";
        }
    
    }
    
    NSLog(@"retriving Sounds For Question: %@",currentQuestionKey);
    
    [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:midwayItemPath,@"silence_half_second",currentQuestionKey, nil]];
//[masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:currentQuestionKey, nil]];
}

// Transition to new view using custom segue
- (void)switchToView: (int) newIndex goingForward: (BOOL) goesForward
{

    if (finishingLastItem )
    {
        vcIndex = newIndex;
        
//        // Back to menu
//        [self saySurveyCompletion];
//        [[AppDelegate_Pad sharedAppDelegate] surveyCompleted]; 
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] surveyCompleted];
        
        [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] fadeOutSatisfactionSurvey];
        
//        [self writeLocalDbToCSVFile];
        
    } else if (vcIndex == newIndex)
    {
        return;
        
    } else {
        
        
        NSLog(@"SWITCHING from item %d to item %d", vcIndex, newIndex);
        
        // Prepare for segue by disabling bar buttons
        item.rightBarButtonItem.enabled = NO;
        item.leftBarButtonItem.enabled = NO;
        
        // Segue to the new controller
        UIViewController *source = [newChildControllers objectAtIndex:vcIndex];
        UIViewController *destination = [newChildControllers objectAtIndex:newIndex];
        RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
        segue.goesForward = goesForward;
        segue.delegate = self;
        [segue perform];
        
        vcIndex = newIndex;
        
        [self playSoundForIndex:vcIndex];
        
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
            surveyItemsRemaining = totalSurveyItems - 15;
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
    
    BOOL isCurrentIndexLast = NO;
    
    if ([respondentType isEqualToString:@"patient"]) {
        if (thisIndex == 9) {
            isCurrentIndexLast = YES;
        }
    } else if ([respondentType isEqualToString:@"family"]) {
        if (thisIndex == 5) {
            isCurrentIndexLast = YES;
        }
    } else {
        if (thisIndex == 1) {
            isCurrentIndexLast = YES;
        }
    }
    
    if (isCurrentIndexLast) {
        NSLog(@"Should end after this index: %d", thisIndex);
    }
    
    return isCurrentIndexLast;
}

- (BOOL)isCurrentSatisfactionItemMidwayWithIndex:(int)thisIndex {
    
    BOOL isCurrentIndexMidway = NO;
    
    if (thisIndex == 0) {
        isCurrentIndexMidway = NO;
    } else {
    
        if ([respondentType isEqualToString:@"patient"]) {
            if (thisIndex <= 22) {
                isCurrentIndexMidway = YES;
            }
        } else if ([respondentType isEqualToString:@"family"]) {
            if (thisIndex <= 17 ) {
                isCurrentIndexMidway = YES;
            }
        } else {
            if (thisIndex <= 13) {
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
    
    switch (currentDynamicSurveyPageIndex) {
        case 0:
            fieldToUpdate = [NSString stringWithFormat:@"s0protest"];
            break;
        case 1:
            fieldToUpdate = [NSString stringWithFormat:@"s1clinictest"];
            break;
        case 2:
            fieldToUpdate = [NSString stringWithFormat:@"s2goalchoice"];
            break;
        case 3:
            fieldToUpdate = [NSString stringWithFormat:@"s3reason"];
            break;
        case 4:
            fieldToUpdate = [NSString stringWithFormat:@"s4prepared"];
            break;
        case 5:
            fieldToUpdate = [NSString stringWithFormat:@"s5looking"];
            break;
        case 6:
            fieldToUpdate = [NSString stringWithFormat:@""];
            break;
        case 7:
            fieldToUpdate = [NSString stringWithFormat:@"s7prohelp"];
            break;
        case 8:
            fieldToUpdate = [NSString stringWithFormat:@"s8clinichelp"];
            break;
        case 9:
            fieldToUpdate = [NSString stringWithFormat:@""];
            break;
        case 10:
            fieldToUpdate = [NSString stringWithFormat:@""];
            break;
        case 11:
            fieldToUpdate = [NSString stringWithFormat:@"s11metgoal"];
            break;
        case 12:
            fieldToUpdate = [NSString stringWithFormat:@"s12prepared"];
            break;
        case 13:
            fieldToUpdate = [NSString stringWithFormat:@"s13know"];
            break;
        case 14:
            fieldToUpdate = [NSString stringWithFormat:@"s14recommend"];
            break;
        case 15:
            fieldToUpdate = [NSString stringWithFormat:@"s15tech"];
            break;
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
    NSLog(@"RootViewController_Pad.made SatisfactionRatingForVC Satisfaction Rating Selected: %d", selectedIndex);
    NSString *fieldToUpdate;
    
    switch (vcIndex) {
        case 0:
//            [[AppDelegate_Pad sharedAppDelegate] deactivateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q1"];
            break;
        case 1:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q28"];
            break;
        case 2:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q27"];
            break;
        case 3:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q26"];
            break;
        case 4:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q25"];
            break;
        case 5:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q24"];
            break;
        case 6:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q23"];
            break;
        case 7:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q22"];
            break;
        case 8:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q21"];
            break;
        case 9:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q20"];
            break;
        case 10:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q19"];
            break;
        case 11:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q18"];
            break;
        case 12:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q17"];
            break;
        case 13:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q16"];
            break;
        case 14:
//            [[AppDelegate_Pad sharedAppDelegate] activateSurveyBackButton];
            fieldToUpdate = [NSString stringWithFormat:@"q15"];
            break;
        case 15:
            fieldToUpdate = [NSString stringWithFormat:@"q14"];
            break;
        case 16:
            fieldToUpdate = [NSString stringWithFormat:@"q13"];
            break;
        case 17:
            fieldToUpdate = [NSString stringWithFormat:@"q12"];
            break;
        case 18:
            fieldToUpdate = [NSString stringWithFormat:@"q11"];
            break;
        case 19:
            fieldToUpdate = [NSString stringWithFormat:@"q10"];
            break;
        case 20:
            fieldToUpdate = [NSString stringWithFormat:@"q9"];
            break;
        case 21:
            fieldToUpdate = [NSString stringWithFormat:@"q8"];
            break;
        case 22:
            fieldToUpdate = [NSString stringWithFormat:@"q7"];
            break;
        case 23:
            fieldToUpdate = [NSString stringWithFormat:@"q6"];
            break;
        case 24:
            fieldToUpdate = [NSString stringWithFormat:@"q5"];
            break;
        case 25:
            fieldToUpdate = [NSString stringWithFormat:@"q4"];
            break;
        case 26:
            fieldToUpdate = [NSString stringWithFormat:@"q3"];
            break;
        case 27:
            fieldToUpdate = [NSString stringWithFormat:@"q2"];
            break;
        default:
            break;
    }

    [self updateSatisfactionRatingForField:fieldToUpdate withSelectedIndex:selectedIndex];
}

- (void)turnVoiceOn:(id)sender {
    NSLog(@"Turned voice ON");
    speakItemsAloud = YES;
    
//    [self sayOK];
    
    [self showReplayButton];
    
}

- (void)turnVoiceOff:(id)sender {
    NSLog(@"Turned voice OFF");
    speakItemsAloud = NO;
    
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
    
    [self updateAllSatisfactionLabelItems];
    
    totalSurveyItems = 14;
    surveyItemsRemaining = 14;
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
    
    [self updateAllSatisfactionLabelItems];
    
    totalSurveyItems = 14;
    surveyItemsRemaining = 14;
}

- (void)updateRespondentToFamily {
    
    if (respondentType) {
        [respondentType release];
        respondentType = nil;
    }
    
    respondentType = [[NSString alloc] initWithString:@"family"];
    
    //    item.title = @"Family Satisfaction Survey";
    item.title = @"Family Satisfaction Survey";
    
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
//            main_clinic_sound = @"at_main_clinic";
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
    [soundFilenamesToRead addObject:read_sound];
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
    [self regress:self];
    
}

- (void)overlayPreviousPressed {
    NSLog(@"overlayPreviousPressed...");
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
    NSLog(@"overlayFontsizePressed...");
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

- (void)sayFirstItem {
    
    if ([respondentType isEqualToString:@"patient"]) {
        totalSurveyItems = 20;
        surveyItemsRemaining = 20;
    } else if ([respondentType isEqualToString:@"family"]) {
        totalSurveyItems = 24;
        surveyItemsRemaining = 24;
    } else {
        totalSurveyItems = 28;
        surveyItemsRemaining = 28;
    }
    
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
    if (speakItemsAloud) {
        
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
        
        NSString *respondentSurveyPath;
        
        if ([respondentType isEqualToString:@"patient"]) {
            respondentSurveyPath = @"Patient_satisfaction_survey_new";
        } else if ([respondentType isEqualToString:@"family"]) {
            respondentSurveyPath = @"Family_satisfaction_survey_new";
        } else {
            respondentSurveyPath = @"caregiver_satisfaction_survey_new";
        }
        
        [masterTTSPlayer playItemsWithNames:[NSArray arrayWithObjects:respondentSurveyPath,@"~participation_is_voluntary_new", nil]];
        
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
    }
}

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
    AVPlayerItem *comingsoon_item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:comingsoon_sound]];
    [self.queuePlayer removeAllItems];
    self.queuePlayer = nil;
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:comingsoon_item,nil]];
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
