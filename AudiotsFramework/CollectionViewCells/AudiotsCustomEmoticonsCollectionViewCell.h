//
//  AudiotsCustomEmoticonsCollectionViewCell.h
//  Audiots
//
//  Created by Bob Ward on 11/23/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsAudioVideoManager.h"

@interface AudiotsCustomEmoticonsCollectionViewCell : UICollectionViewCell <AudiotsAudioVideoManagerDelegate>

@property (strong, nonatomic) NSDictionary *emoticonInfoDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *emoticonImageView;

@property (weak, nonatomic) IBOutlet UIButton *emoticonPreviewButton;


- (IBAction)onPreviewButtonTapped:(id)sender;

@end
