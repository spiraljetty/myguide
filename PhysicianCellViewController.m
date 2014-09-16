/*
     File: PhysicianCellViewController.m
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 

 */

#import "PhysicianCellViewController.h"
#import "Cell.h"
#import "MasterViewController.h"
#import "AppDelegate_Pad.h"
#import "ClinicianInfo.h"
#import "DynamicContent.h"

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
    if (currentRowIndex == 0)
        currentlySelectedClinicPhysicians = [DynamicContent getNewClinicianNames];
    else
    if (currentRowIndex == 1)
        currentlySelectedClinicPhysicians = [DynamicContent getSubclinicPhysicianNames:@"pmnr"];
    else
    if (currentRowIndex == 2)
        currentlySelectedClinicPhysicians = [DynamicContent getSubclinicPhysicianNames:@"emg"];
    else
    if (currentRowIndex == 3)
        currentlySelectedClinicPhysicians = [DynamicContent getSubclinicPhysicianNames:@"pns"];
    else
    if (currentRowIndex == 4)
        currentlySelectedClinicPhysicians = [DynamicContent getSubclinicPhysicianNames:@"acupuncture"];
    else
    if (currentRowIndex == 5)
        currentlySelectedClinicPhysicians = [DynamicContent getSubclinicPhysicianNames:@"at"];
    
//    currentlySelectedClinicPhysicians = [[[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] pmnrSubClinicPhysicians] objectAtIndex:currentRowIndex];

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

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    
    // This is where the thumbnails are added to the clinic picker grid

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
//    NSArray *allClinicPhysicians = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysicians]; // original (hardcoded) list of clinicians
    NSMutableArray *allPhysicianNames = [DynamicContent getNewClinicianNames];
//    int originalPhysicianCount = [allClinicPhysicians count];
    NSString* matchingDoc = NULL;
    for (NSString* name in allPhysicianNames){
        if ([name isEqualToString:thisCellText]){
            matchingDoc = name;
            break;
        }
    }
    int currentPhysicianIndex = [allPhysicianNames indexOfObject:thisCellText];
//    if (currentPhysicianIndex < originalPhysicianCount){
//        // if index is for original hardcoded clinician then get thumb image from plist in hidden folder
//        NSArray *allPhysicianThumbs = [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController] allClinicPhysiciansThumbs];
//        NSString *imageToLoad = [NSString stringWithFormat:@"%@",[allPhysicianThumbs objectAtIndex:currentPhysicianIndex]];
//        NSLog(@"PhysicianCellViewController.cellForItemAtIndexPath() imageToLoad: %@", imageToLoad);
//        cell.image.image = [UIImage imageNamed:imageToLoad];
//    }
//    else {
        // if index is for new (not hardcoded) clinician then get thumb image from documents directory
//        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString  *documentsDirectory = [paths objectAtIndex:0];
//            [[[[AppDelegate_Pad sharedAppDelegate] loaderViewController] currentWRViewController]
//                    getClinician:currentPhysicianIndex];
        ClinicianInfo *currentClinician = [DynamicContent getClinician:currentPhysicianIndex];
        if (currentClinician){
            NSString *filename = [currentClinician getImageFilename];
           // cell.image.image = [UIImage imageNamed:filename];
            //if (!cell.image.image)
                cell.image.image = [DynamicContent loadImage:filename];
        }
//    }
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
