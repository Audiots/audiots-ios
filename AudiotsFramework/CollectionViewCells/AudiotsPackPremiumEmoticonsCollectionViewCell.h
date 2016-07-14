//
//  AudiotsPackPremiumEmoticonsCollectionViewCell.h
//  Audiots
//
//  Created by Tan Bui on 7/12/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudiotsAudioVideoManager.h"

@interface AudiotsPackPremiumEmoticonsCollectionViewCell : UICollectionViewCell<AudiotsAudioVideoManagerDelegate>

@property (strong, nonatomic) NSDictionary *emoticonInfoDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *emoticonImageView;

@property (weak, nonatomic) IBOutlet UIButton *emoticonPreviewButton;

@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

@end
