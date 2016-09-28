//
//  AudiotsBrowseViewController.m
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsBrowseViewController.h"
#import "AudiotsIAPHelper.h"

#import "AudiotsPackSelectionCollectionViewCell.h"
#import "AudiotsPackEmoticonsCollectionViewCell.h"
#import "AudiotsCustomEmoticonsCollectionViewCell.h"
#import "AudiotsCreateCustomAudiotCollectionViewCell.h"
#import "AudiotsPackPremiumEmoticonsCollectionViewCell.h"
#import "AudiotsInAppTableViewController.h"

#import <Toast/UIView+Toast.h>

#import <QuartzCore/QuartzCore.h>
#import "NSDictionary+Helper.h"


@interface AudiotsBrowseViewController ()
@property (nonatomic, assign) BOOL isCurrentPackMyCreations;

@property (nonatomic, assign) BOOL isDeleteMode;

@end

@implementation AudiotsBrowseViewController

- (BOOL)isOpenAccessGranted
{
    return [UIPasteboard generalPasteboard] != nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    if ([self.selectionPack isEqualToString:@"AudiotsRecordPacks"]) {
        [self setIsCurrentPackMyCreations:YES];
    } else {
        [self setIsCurrentPackMyCreations:NO];
    }

    [self setIsDeleteMode: NO];

    
    //Initialize My Creations
    [self initializeMyCreations];
    
    //Drop shadow on the pack selection collection view
    self.packSelectionCollectionView.layer.masksToBounds = NO;
    self.packSelectionCollectionView.layer.shadowOffset = CGSizeMake(0,2);
    self.packSelectionCollectionView.layer.shadowRadius = 1;
    self.packSelectionCollectionView.layer.shadowOpacity = 0.3;
    
    //Initialize Collection Views
    [self initializePackSelectionCollectionView];
    [self initializePackEmoticonsCollectionView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDeleteNotification:)
                                                 name:@"DeleteCustomCell"
                                               object:nil];
    
}




-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];

    [[AudiotsAudioVideoManager sharedInstance] addDelegate:self];

    if (self.isCurrentPackMyCreations) {
        [self setIsCurrentPackMyCreations:YES];
        NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
        NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
        self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:myCreationsPlistPath];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[AudiotsAudioVideoManager sharedInstance] removeDelegate:self];
    
        [[NSNotificationCenter defaultCenter] removeObserver:@"DeleteCustomCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

- (void)initializeMyCreations {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    NSURL* storeUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
    
    if ([fileManager fileExistsAtPath:myCreationsPlistPath] == NO) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"MyCreations" ofType:@"plist"];
        [fileManager copyItemAtPath:resourcePath toPath:myCreationsPlistPath error:&error];
    }
//    else {
//        [fileManager removeItemAtPath:myCreationsPlistPath error:&error];
//        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"MyCreations" ofType:@"plist"];
//        [fileManager copyItemAtPath:resourcePath toPath:myCreationsPlistPath error:&error];        
//    }
    
    //Attempt to sync through iCloud
    if ([[iCloud sharedCloud] checkCloudAvailability] == YES) {
        //Set ourself as iCloud delegate
        [[iCloud sharedCloud] setDelegate:self];
        
        //Use the default ubiquity container
        [[iCloud sharedCloud] setupiCloudDocumentSyncWithUbiquityContainer:nil];
        
        //Initialize iCloud
        [[iCloud sharedCloud] init];
        
        if ([[iCloud sharedCloud] doesFileExistInCloud:@"MyCreations.plist"] == YES) {
        } else {
            [[iCloud sharedCloud] saveAndCloseDocumentWithName:@"MyCreations.plist"
                                                   withContent:[fileManager contentsAtPath:myCreationsPlistPath]
                                                    completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
                                                        if (error == nil) {
                                                        }
                                                    }];
        }
    }
    
}

- (void)initializePackSelectionCollectionView {
    self.packSelectionCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return (NSString*)[aObject valueForKey:@"cellType"];;
    };

    [self.packSelectionCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackSelectionCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackSelectionCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packSelectionCollectionViewCell"];

    [self.packSelectionCollectionView registerCellConfigureBlock:^(AudiotsPackSelectionCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setPackInfoDictionary:menuItemDictionary];
        [cell.packCoverEmoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"packCoverImage"]]];
    } forCellReuseIdentifier:@"packSelectionCollectionViewCell"];
    
    [self setSelectionDataSource];
    
    
    // set default index
    NSIndexPath *indexPath = [[NSIndexPath alloc]init];
    indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    self.navigationItem.title = [[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packTitleName"];
    
}


-(void) setSelectionDataSource {
    
    
    // always load premium for now
    self.selectionPack = @"AudiotsAvailablePacks";
    
//    if ([[AudiotsIAPHelper sharedInstance] isPremiumPurchased]){
//        self.selectionPack = @"AudiotsAvailablePacksPremium";
//    }
    
    self.packSelectionDataSource = nil;
        
    // load the selected pack
    self.packSelectionDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.selectionPack ofType:@"plist"]];
    
}

- (void)initializePackEmoticonsCollectionView {
    self.packEmoticonsCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return (NSString*)[aObject valueForKey:@"cellType"];
    };

    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackPremiumEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packPremiumEmoticonsCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCreateCustomAudiotCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCreateCustomAudiotCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"createCustomAudiotCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCustomEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCustomEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"customEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsPackEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
    } forCellReuseIdentifier:@"packEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsPackPremiumEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
        
        BOOL hideLock = YES;
        
        // don't display the lock if the cell is a dummy
        NSString *inAppBundleIdStr = [menuItemDictionary safeObjectForKey:@"in_app_bundle_id"];
        if (inAppBundleIdStr != nil && ![inAppBundleIdStr isEqualToString:@"dummy"]) {

            hideLock = [[AudiotsIAPHelper sharedInstance] productPurchased:inAppBundleIdStr];
        }
        
        [cell.lockImageView setHidden:hideLock];
        
        
    } forCellReuseIdentifier:@"packPremiumEmoticonsCollectionViewCell"];

    
    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCreateCustomAudiotCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setAudiotInfoDictionary:menuItemDictionary];
    } forCellReuseIdentifier:@"createCustomAudiotCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCustomEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
        
        [cell addGestureRecognizer:longPress];
        
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
        
        
    } forCellReuseIdentifier:@"customEmoticonsCollectionViewCell"];

    if (self.packEmoticonsDataSource == nil) {
        
        // get the list of emojis from the first item of packSelectionDataSource
        self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] valueForKey:@"packName"] ofType:@"plist"]];
    }
}



#pragma mark - Delete Emoji Cell

- (void)longPressGestureAction:(UIGestureRecognizer *)recognizer {
    
    
    // we want to start the shaking animation right away
    if ( recognizer.state == UIGestureRecognizerStateBegan ) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartShake" object:self];
        
        [self setIsDeleteMode:YES];
    }
}


- (void) receivedDeleteNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"DeleteCustomCell"]) {
        
        AudiotsCustomEmoticonsCollectionViewCell *cell = (AudiotsCustomEmoticonsCollectionViewCell*) notification.object;
        
        NSDictionary  *info = cell.emoticonInfoDictionary;
        
        NSIndexPath *indexPath = [self.packEmoticonsCollectionView indexPathForCell:cell];
        
        [self showAlertOnDeleteItem:info atIndex:indexPath];
    }
    
}

-(void) reloadEmoticonsDataSource {
    
    NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
    self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:myCreationsPlistPath];
    
}


-(void) removeItemAt: (NSIndexPath*) indexPath {
    
    [self.packEmoticonsCollectionView performBatchUpdates:^{
        
        // can't use deleteItemsAtIndexPaths for static datasource.  we need to change to dynamic datasource.
        //[self.packEmoticonsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) showAlertOnDeleteItem:(NSDictionary*) info atIndex: (NSIndexPath*) indexPath {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete Your Custom Emoji"
                                  message:@"Deleting emoji will also delete the audio file."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* deleteButton = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self deleteEmojiResource:info];
                                       [self reloadEmoticonsDataSource];
                                       
                                       //[self removeItemAt:indexPath];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"StopShake" object:self];
                                       [self setIsDeleteMode:NO];
                                   }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"StopShake" object:self];
                                       [self setIsDeleteMode:NO];
                                   }];
    
    [alert addAction:deleteButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) deleteEmojiResource:(NSDictionary*) currentInfo {
    
    NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
    
    NSMutableArray *rootArray = [NSMutableArray arrayWithContentsOfFile:myCreationsPlistPath];
    NSDictionary *objectsDictionary = [rootArray objectAtIndex:0];
    NSMutableArray *objectsArray = [objectsDictionary valueForKey:@"objects"];
    
    BOOL found = NO;
    
    for (int i=0; i < objectsArray.count; i++) {
        
        NSDictionary *item = [objectsArray objectAtIndex:i];
        
        if ([item[@"cellType"] caseInsensitiveCompare:@"customEmoticonsCollectionViewCell"] == NSOrderedSame) {
            
            if ([currentInfo isEqualToDictionary:item]){
                [objectsArray removeObject:item];
                found = YES;
                break;
            }
        }
    }
    
    if (found) {
    
        [objectsDictionary setValue:objectsArray forKey:@"objects"];
        [rootArray arrayByAddingObject:objectsDictionary];
        
        //Update MyCreations file
        [rootArray writeToFile:myCreationsPlistPath atomically:YES];
        
        NSString *filePath = currentInfo[@"sound_file_path"];
        NSError *error;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            
            if (success){
                NSLog(@"success deleting file: %@", filePath);
            }
        }
    }
    
}

#pragma mark - DataSources

-(void)setPackSelectionDataSource:(PSDPListDataSource *)packSelectionDataSource {
    if (packSelectionDataSource != _packSelectionDataSource) {
        _packSelectionDataSource = packSelectionDataSource;
        [self.packSelectionCollectionView setDataSource:_packSelectionDataSource];
        [self.packSelectionCollectionView reloadData];
    }
}
-(void)setPackEmoticonsDataSource:(PSDPListDataSource *)packEmoticonsDataSource {
    if (packEmoticonsDataSource != _packEmoticonsDataSource) {
        _packEmoticonsDataSource = packEmoticonsDataSource;
        [self.packEmoticonsCollectionView setDataSource:_packEmoticonsDataSource];
        [self.packEmoticonsCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.packSelectionCollectionView) {
        
        if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"xcassets"]) {
            
            self.navigationItem.title = [[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packTitleName"];
            
            [self setIsCurrentPackMyCreations:NO];
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packName"] ofType:@"plist"]];
            
        } else if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"custom"]) {
            
            self.navigationItem.title = [[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packTitleName"];
            
            [self setIsCurrentPackMyCreations:YES];
            NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
            NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
            
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:myCreationsPlistPath];
        }
    } else if (collectionView == self.packEmoticonsCollectionView) {
        NSDictionary *emoticonInfoDictionary = [(AudiotsPackEmoticonsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] emoticonInfoDictionary];
        
        if ([[(NSDictionary*)[self.packEmoticonsDataSource objectAtIndexPath:indexPath] valueForKey:@"cellType"] isEqualToString:@"createCustomAudiotCollectionViewCell"]) {
            
            [self performSegueWithIdentifier:@"showCreateStepOne" sender:nil];
            
        } else if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"packEmoticonsCollectionViewCell"]) {
            NSString *audioFileName = [emoticonInfoDictionary objectForKey:@"sound_mp3"];
            NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];
            
            [[AudiotsAudioVideoManager sharedInstance] createMovieWithAudioFileName:audioFileName andImageArray:@[[UIImage imageNamed:imageFileName]]];
            
        } else if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"customEmoticonsCollectionViewCell"]) {
            
            if(self.isDeleteMode) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StopShake" object:self];
                [self setIsDeleteMode:NO];
            } else {
                NSString *audioFilePath = [emoticonInfoDictionary objectForKey:@"sound_file_path"];
                NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];

                [[AudiotsAudioVideoManager sharedInstance] createMovieWithFilePath:audioFilePath andImageArray:@[[UIImage imageNamed:imageFileName]]];
            }
        } else if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"packPremiumEmoticonsCollectionViewCell"]) {
            
            // Do nothing if the cell is a dummy
            NSString *inAppBundleIdStr = [emoticonInfoDictionary safeObjectForKey:@"in_app_bundle_id"];
            if (inAppBundleIdStr != nil && ![inAppBundleIdStr isEqualToString:@"dummy"]) {
                
                if ([[AudiotsIAPHelper sharedInstance] productPurchased:inAppBundleIdStr]) {
                    
                    NSString *audioFileName = [emoticonInfoDictionary objectForKey:@"sound_mp3"];
                    NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];
                    
                    [[AudiotsAudioVideoManager sharedInstance] createMovieWithAudioFileName:audioFileName andImageArray:@[[UIImage imageNamed:imageFileName]]];
                    
                } else {
                    
                    [self showAlertPremiumContent];
                    
                }
                
            }
            


            
        }
    }
}

-(void) showAlertPremiumContent {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Premium Content"
                                  message:@"To unlock, purchase is required.  Would you to continue? "
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* continueButton = [UIAlertAction
                                   actionWithTitle:@"Continue"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       AudiotsInAppTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"sbInAppPurchase"];
                                       
                                       [self.navigationController pushViewController:vc animated:YES];
                                   }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {

                                   }];
    
    [alert addAction:continueButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - iCloudDelegate

-(void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer {
}

-(void)iCloudDidFinishInitializingWitUbiquityToken:(id)cloudToken withUbiquityContainer:(NSURL *)ubiquityContainer {
}

-(void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
}


#pragma mark - AudiotsAudioVideoManagerDelegate
-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"Failed to generate Audiot."];
    });
}

-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[movieFileUrl] applicationActivities:nil];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:activityViewController animated:YES completion:nil];
        } else {
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    });
    
}


- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onAudioRecordFinsihed:(NSURL *)recordedAudioFileUrl{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onPreviewSoundFinished:(BOOL)finished{}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)unwindFromCreateStepOneViewController:(UIStoryboardSegue *)segue {
}


@end
