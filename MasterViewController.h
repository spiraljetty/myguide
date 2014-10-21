/*
    File: MasterViewController.h
Abstract: A simple view controller that manages a table view
 Version: 2.1

*/

#import <UIKit/UIKit.h>

@class PhysicianCellViewController;

@interface MasterViewController : UITableViewController {
    int currentlySelectedRow;
    NSMutableArray *subClinicNames;
}

@property (nonatomic, retain) NSArray *subClinicNames;
@property (nonatomic, retain) PhysicianCellViewController *myDetailViewController;
@property int currentlySelectedRow;

- (void)setSubClinicNameTo:(NSString *)currentlySelectedSubClinicName;

@end
