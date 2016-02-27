//
//  AudiotsBrowseViewController.m
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsBrowseViewController.h"

#import "AudiotsPackSelectionCollectionViewCell.h"
#import "AudiotsPackEmoticonsCollectionViewCell.h"
#import "AudiotsCustomEmoticonsCollectionViewCell.h"
#import "AudiotsCreateCustomAudiotCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

@interface AudiotsBrowseViewController ()
@property (nonatomic, assign) BOOL isCurrentPackMyCreations;
@end

@implementation AudiotsBrowseViewController

- (BOOL)isOpenAccessGranted
{
    return [UIPasteboard generalPasteboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setIsCurrentPackMyCreations:NO];
    
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
    
    if (self.packSelectionDataSource == nil) {
        self.packSelectionDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudiotsAvailablePacks" ofType:@"plist"]];
    }
}

- (void)initializePackEmoticonsCollectionView {
    self.packEmoticonsCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return (NSString*)[aObject valueForKey:@"cellType"];
    };

    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCreateCustomAudiotCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCreateCustomAudiotCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"createCustomAudiotCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCustomEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCustomEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"customEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsPackEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
    } forCellReuseIdentifier:@"packEmoticonsCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCreateCustomAudiotCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setAudiotInfoDictionary:menuItemDictionary];
    } forCellReuseIdentifier:@"createCustomAudiotCollectionViewCell"];

    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCustomEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
    } forCellReuseIdentifier:@"customEmoticonsCollectionViewCell"];

    if (self.packEmoticonsDataSource == nil) {
        self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] valueForKey:@"packName"] ofType:@"plist"]];
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
            [self setIsCurrentPackMyCreations:NO];
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packName"]
                                                                                                                              ofType:@"plist"]];
        } else if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"custom"]) {
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
            NSString *audioFilePath = [emoticonInfoDictionary objectForKey:@"sound_file_path"];
            NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];

            [[AudiotsAudioVideoManager sharedInstance] createMovieWithFilePath:audioFilePath andImageArray:@[[UIImage imageNamed:imageFileName]]];
        }
    }
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
//        [self.view makeToast:@"WRITE FAILED"];
    });
}

-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl {

    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[movieFileUrl] applicationActivities:nil];

        [self presentViewController:activityViewController animated:YES completion:nil];
    });
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)unwindFromCreateStepOneViewController:(UIStoryboardSegue *)segue {
}


@end
