/*
    File: MasterViewController.m
Abstract: A simple view controller that manages a table view
 Version: 2.1

*/

#import "MasterViewController.h"
#import "PhysicianCellViewController.h"
#import "AppDelegate_Pad.h"

@implementation MasterViewController {
    NSDictionary *_ipsums;
    
}

@synthesize currentlySelectedRow, subClinicNames;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Choose a Provider", @"");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // On iPad only, don't clear the selection (we are displaying in a split view on iPad).
            self.clearsSelectionOnViewWillAppear = NO;
        }
        
        subClinicNames = [@[@"All",
                       @"PM&R",
                       @"EMG",
                       @"PNS",
                       @"Acupuncture",
                          @"AT Center"] mutableCopy];
    }
    return self;
}

- (void)configureDetailItemForRow:(NSUInteger)row
{
    NSString *item = subClinicNames[row];
//    NSString *title = NSLocalizedString(item, @"All-PM&R-EMG-PNS-Acupuncture");
    
    NSLog(@"Currently selected item: %@", item);

    currentlySelectedRow = row;
        
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setNewDetailVCForRow:currentlySelectedRow];
    
    [self setSubClinicNameTo:item];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self configureDetailItemForRow:0];
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#endif

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [subClinicNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell.
    cell.textLabel.text = subClinicNames[indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Disclsure indicators on iPhone only.
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)setSubClinicNameTo:(NSString *)currentlySelectedSubClinicName {
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setCurrentSubClinicName:currentlySelectedSubClinicName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %d selected", indexPath.row);
    currentlySelectedRow = indexPath.row;
    [self configureDetailItemForRow:indexPath.row];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] deactivateLaunchButton];
}

@end
