/*
     File: PhysicianCellViewController.m
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 

 */

#import "PhysicianCellViewController.h"
#import "Cell.h"
#import "MasterViewController.h"
#import "AppDelegate_Pad.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id

@implementation PhysicianCellViewController

@synthesize currentlySelectedClinicPhysicians;

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    NSLog(@"PhysicianCellViewController.initWithCollectionViewLayout()");

    
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"CollectionStoryboard" bundle:[NSBundle mainBundle]];
    
    self = [aStoryboard instantiateViewControllerWithIdentifier:@"0"];
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return currentNumberOfCells;
}

- (void)initNumberOfCellsForCurrentlySelectedRowWithIndex:(int)currentRowIndex {
    NSLog(@"PhysicianCellViewController.initNumberOfCellsForCurrentlySelectedRowWithIndex() currentRowIndex: %d", currentRowIndex);

    currentlySelectedClinicPhysicians = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] pmnrSubClinicPhysicians] objectAtIndex:currentRowIndex];
    
    currentNumberOfCells = [currentlySelectedClinicPhysicians count];
    NSLog(@"PhysicianCellViewController.initNumberOfCellsForCurrentlySelectedRowWithIndex() Number of cells initialized to: %d",currentNumberOfCells);
}

- (void)updateNewNumOfCellsTo:(int)newCellNum {
    NSLog(@"PhysicianCellViewController.updateNewNumOfCellsTo() newCellNum: %d", newCellNum);
    currentNumberOfCells = newCellNum;
    NSLog(@"Number of cells updated to: %d",currentNumberOfCells);
}

- (void)viewDidLoad {
    NSLog(@"PhysicianCellViewController.viewDidLoad()");

    int masterRowSelected = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] masterViewController] currentlySelectedRow];

    
    [self initNumberOfCellsForCurrentlySelectedRowWithIndex:masterRowSelected];
     NSLog(@"Loading detail VC for master row: %d", masterRowSelected);

}

- (void)setPhysicianSettingsForPhysicianName:(NSString *)currentlySelectedPhysicianName {
    NSLog(@"PhysicianCellViewController.setPhysicianSettingsForPhysicianName() %@", currentlySelectedPhysicianName);

    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] setAttendingPhysicianName:currentlySelectedPhysicianName];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"PhysicianCellViewController.didSelectItemAtIndexPath()");
    Cell *selectedCell = (Cell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"PhysicianCellViewController.didSelectItemAtIndexPath() Cell selected: %@", selectedCell.label.text);
    
//    [self setPhysicianSettingsForPhysicianName:selectedCell.label.text];
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] storeAttendingPhysicianSettingsForPhysicianName:selectedCell.label.text];
    
    [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] activateLaunchButton];

    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"PhysicianCellViewController.cellForItemAtIndexPath()");
    
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
//    cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
    
    NSString *thisCellText = [currentlySelectedClinicPhysicians objectAtIndex:indexPath.row];
    cell.label.text = thisCellText;
    
    // load the image for this cell
    //rjl 8/16/14
    NSMutableArray *allPhysicianNames = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysicians];
    NSMutableArray *allPhysicianThumbs = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] getAllClinicPhysiciansThumbs];
//    NSArray *allPhysicianNames = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians];
//    NSArray *allPhysicianThumbs = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs];
    int currentPhysicianIndex = [allPhysicianNames indexOfObject:thisCellText];
//    int currentPhysicianIndex = [allPhysicianNames indexOfObjectIdenticalTo:thisCellText];
//    if (currentPhysicianIndex > 15) // rjl 8/16/14 hack because indexOfObjectIdenticalTo fails matching NFCFCConstantString vs. NFCFCString
//        currentPhysicianIndex = 15;
//    NSString *imageToLoad = [NSString stringWithFormat:@"%d.JPG", indexPath.row];
    NSString *imageToLoad = [NSString stringWithFormat:@"%@",[allPhysicianThumbs objectAtIndex:currentPhysicianIndex]];
    NSLog(@"PhysicianCellViewController.cellForItemAtIndexPath() imageToLoad: %@", imageToLoad);

    cell.image.image = [UIImage imageNamed:imageToLoad];
    
    return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue...");
//    if ([[segue identifier] isEqualToString:@"showDetail"])
//    {
//        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
//        
//        // load the image, to prevent it from being cached we use 'initWithContentsOfFile'
//        NSString *imageNameToLoad = [NSString stringWithFormat:@"%d_full", selectedIndexPath.row];
//        NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"JPG"];
//        UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
//        
//        DetailViewController *detailViewController = [segue destinationViewController];
//        detailViewController.image = image;
//    }
}

@end
