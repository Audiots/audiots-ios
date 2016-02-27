//
//  AudiotsCreateStepOneViewController.h
//  Audiots
//
//  Created by Bob Ward on 11/22/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsPackSelectionCollectionView.h"
#import "AudiotsPackEmoticonsCollectionView.h"

#import <PSDDataSource/PSDPlistDataSource.h>
#import <PSDDataSource/UICollectionView+PSDDataSource.h>

@interface AudiotsCreateStepOneViewController : UIViewController <UICollectionViewDelegate, PSDDataSourceDelegate>

@property (nonatomic, strong) PSDPListDataSource *packSelectionDataSource;
@property (nonatomic, strong) PSDPListDataSource *packEmoticonsDataSource;


@property (weak, nonatomic) IBOutlet AudiotsPackSelectionCollectionView *packSelectionCollectionView;
@property (weak, nonatomic) IBOutlet AudiotsPackEmoticonsCollectionView *packEmoticonsCollectionView;

@end
