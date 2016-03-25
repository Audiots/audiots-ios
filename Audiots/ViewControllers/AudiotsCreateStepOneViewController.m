//
//  AudiotsCreateStepOneViewController.m
//  Audiots
//
//  Created by Bob Ward on 11/22/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsCreateStepOneViewController.h"

#import "AudiotsCreateStepTwoViewController.h"

#import "AudiotsPackSelectionCollectionViewCell.h"
#import "AudiotsPackEmoticonsCollectionViewCell.h"

@interface AudiotsCreateStepOneViewController ()
@property (nonatomic, strong) NSDictionary *selectedEmoticonInfoDictionary;
@end

@implementation AudiotsCreateStepOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Drop shadow on the pack selection collection view
    self.packSelectionCollectionView.layer.masksToBounds = NO;
    self.packSelectionCollectionView.layer.shadowOffset = CGSizeMake(0,-1);
    self.packSelectionCollectionView.layer.shadowRadius = 1;
    self.packSelectionCollectionView.layer.shadowOpacity = 0.3;
    
    
    //Initialize Collection Views
    [self initializePackSelectionCollectionView];
    [self initializePackEmoticonsCollectionView];

}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
    //Reset selected emoticon
    [self setSelectedEmoticonInfoDictionary:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *localAvailablePack = [NSString stringWithFormat:@"AudiotsAvailablePacks-%@", [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode]];
        self.packSelectionDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:localAvailablePack ofType:@"plist"]];
    }
}

- (void)initializePackEmoticonsCollectionView {
    self.packEmoticonsCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return @"packEmoticonsCollectionViewCell";
    };
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packEmoticonsCollectionViewCell"];
    
    
    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsPackEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
        //[cell.emoticonPreviewButton setBackgroundImage:[UIImage imageNamed:@"PlayBubble"] forState:UIControlStateNormal];
    } forCellReuseIdentifier:@"packEmoticonsCollectionViewCell"];
        
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

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.packSelectionCollectionView) {
        if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"xcassets"]) {
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packName"]
                                                                                                                              ofType:@"plist"]];
        } else if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"custom"]) {
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MyCreations"
                                                                                                                              ofType:@"plist"]];
        }
    } else if (collectionView == self.packEmoticonsCollectionView) {
        [self setSelectedEmoticonInfoDictionary:(NSDictionary *)[self.packEmoticonsDataSource objectAtIndexPath:indexPath]];
        [self performSegueWithIdentifier:@"showCreateStepTwo" sender:nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showCreateStepTwo"]) {
        AudiotsCreateStepTwoViewController *createStepTwoViewController = (AudiotsCreateStepTwoViewController *)[segue destinationViewController];
        [createStepTwoViewController setSelectedEmoticonInfoDictionary:self.selectedEmoticonInfoDictionary];
    }
}


@end
