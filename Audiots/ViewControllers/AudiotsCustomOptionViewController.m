//
//  AudiotsCustomOptionViewController.m
//  Audiots
//
//  Created by Tan Bui on 6/7/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsCustomOptionViewController.h"
#import "AudiotsCreateStepTwoViewController.h"

@interface AudiotsCustomOptionViewController ()

@property (nonatomic, strong) UIImage *selectedPhotoImage;

@end

@implementation AudiotsCustomOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *tintColor = [UIColor colorWithRed:0.25 green:0.72 blue:0.69 alpha:1.0];
    
    //self.navigationItem.title = @"Create Your Own";
    // set title color
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : tintColor}];

    
    [TGCameraColor setTintColor:tintColor];
    //[TGCamera setOption:kTGCameraOptionHiddenAlbumButton value:@YES];
    [TGCamera setOption:kTGCameraOptionHiddenFilterButton value:@YES];
    //[TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:@YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showEmojisAction:(id)sender {
    [self showEmojis];
}

- (IBAction)showCameraAction:(id)sender {
    
    [self photoOption];
}

-(void) showEmojis {
    [self performSegueWithIdentifier:@"showEmoji" sender:nil];
}

-(void) photoOption {
    
    UIAlertController *optionAlert = [UIAlertController alertControllerWithTitle:@"Take Photo" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self performSegueWithIdentifier:@"showEmoji" sender:nil];
        
        TGCameraNavigationController *navigationController =
        [TGCameraNavigationController newWithCameraDelegate:self];
        
        [self presentViewController:navigationController animated:YES completion:nil];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pickerController =
        [TGAlbum imagePickerControllerWithDelegate:self];
        
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
 
    
    [optionAlert addAction:camera];
    [optionAlert addAction:library];
    
    [self presentViewController:optionAlert animated:YES completion:nil ];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *image = [TGAlbum imageWithMediaInfo:info];
    
    [self proceedImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"showCreateStepTwoB" sender:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    // When this method is implemented, an image will be saved on the user's device
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    [self proceedImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"showCreateStepTwoB" sender:nil];
    }];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    [self proceedImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"showCreateStepTwoB" sender:nil];
    }];
}


- (void) proceedImage: (UIImage *) image {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1); //1 it represents the quality of the image.
    NSLog(@"W:%f H:%f Size of Image(bytes):%lu", image.size.width, image.size.height, (unsigned long)[imgData length]);
    
    UIImage *resizeImage = [self imageWithImage: image scaledToSize:CGSizeMake(185.0, 185.0)];
    NSData *sizeImgData = UIImageJPEGRepresentation(resizeImage, 1); //1 it represents the quality of the image.
    NSLog(@"W:%f H:%f Size of Image(bytes):%lu",resizeImage.size.width, resizeImage.size.height,(unsigned long)[sizeImgData length]);
    
    self.selectedPhotoImage = [resizeImage copy];
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
     
     po self.selectedEmoticonInfoDictionary
     {
     cellType = packPremiumEmoticonsCollectionViewCell;
     "image_plain" = "little-dog-1-plain";
     "image_play" = "little-dog-1-play";
     "image_speaker" = "little-dog-1-speaker";
     "in_app_bundle_id" = "com.4_girls_tech.audiots.inapp.premium";
     "sound_mp3" = AdoptPetToday;
     }
     
     */
    
    //    NSDictionary *customAudiotDictionary = @{@"image_plain"      : @"image_plain",
    //                                             //@"image_play"       : UIImageJPEGRepresentation(self.selectedPhotoImage, 1),
    //                                             @"image_speaker"    : @"image_speaker",
    //                                             @"sound_file_path"  : @"sound_file_path",
    //                                             @"cellType"         : @"customPhotoCollectionViewCell"};
    
    if ([[segue identifier] isEqualToString:@"showCreateStepTwoB"]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (self.selectedPhotoImage != nil) {
            [dict setObject:self.selectedPhotoImage forKey:@"image_play"];
        }
        
        [dict setObject:@"photo" forKey:@"mediaType"];
        
        AudiotsCreateStepTwoViewController *createStepTwoViewController = (AudiotsCreateStepTwoViewController *)[segue destinationViewController];
        [createStepTwoViewController setSelectedEmoticonInfoDictionary:dict];
    }
}

@end
