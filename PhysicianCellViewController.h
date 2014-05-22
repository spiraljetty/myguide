/*
     File: PhysicianCellViewController.h
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 

 */

#import <UIKit/UIKit.h>

@interface PhysicianCellViewController : UICollectionViewController {

    int currentNumberOfCells;
    NSArray *allItemsIndexPaths;
    NSArray *currentlySelectedClinicPhysicians;
}

@property (nonatomic, retain) NSArray *currentlySelectedClinicPhysicians;

- (void)updateNewNumOfCellsTo:(int)newCellNum;
- (void)initNumberOfCellsForCurrentlySelectedRowWithIndex:(int)currentRowIndex;
- (void)reconfigureCellsForSelectedClinicIndex:(int)currentClinicIndex;
- (void)setPhysicianSettingsForPhysicianName:(NSString *)currentlySelectedPhysicianName;

@end
