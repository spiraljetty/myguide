#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface testPickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UIButton *button;
	IBOutlet UIButton *upload;
    IBOutlet UIImageView *image;
	UIImagePickerController *imgPicker;
}
//- (IBAction)grabImage;
- (IBAction)uploadImage;



@end