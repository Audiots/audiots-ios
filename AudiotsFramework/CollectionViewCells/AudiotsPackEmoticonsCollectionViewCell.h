//
//  AudiotsPackEmoticonsCollectionViewCell.h
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsAudioVideoManager.h"

@interface AudiotsPackEmoticonsCollectionViewCell : UICollectionViewCell <AudiotsAudioVideoManagerDelegate>

@property (strong, nonatomic) NSDictionary *emoticonInfoDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *emoticonImageView;

@property (weak, nonatomic) IBOutlet UIButton *emoticonPreviewButton;


- (IBAction)onPreviewButtonTapped:(id)sender;
@end
