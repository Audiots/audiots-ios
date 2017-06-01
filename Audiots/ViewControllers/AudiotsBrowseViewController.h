//
//  AudiotsBrowseViewController.h
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsPackSelectionCollectionView.h"
#import "AudiotsPackEmoticonsCollectionView.h"

#import "AudiotsAudioVideoManager.h"

#import "PSDPlistDataSource.h"
#import "UICollectionView+PSDDataSource.h"

#import <iCloudDocumentSync/iCloud.h>

@interface AudiotsBrowseViewController : UIViewController <UICollectionViewDelegate, PSDDataSourceDelegate, iCloudDelegate, AudiotsAudioVideoManagerDelegate>


@property (nonatomic, strong) NSString *selectionPack;
@property (nonatomic, strong) PSDPListDataSource *packSelectionDataSource;
@property (nonatomic, strong) PSDPListDataSource *packEmoticonsDataSource;


@property (weak, nonatomic) IBOutlet AudiotsPackSelectionCollectionView *packSelectionCollectionView;
@property (weak, nonatomic) IBOutlet AudiotsPackEmoticonsCollectionView *packEmoticonsCollectionView;

@end
