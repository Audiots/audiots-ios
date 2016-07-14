//
//  AudiotsPackPremiumEmoticonsCollectionViewCell.m
//  Audiots
//
//  Created by Tan Bui on 7/12/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsPackPremiumEmoticonsCollectionViewCell.h"

@implementation AudiotsPackPremiumEmoticonsCollectionViewCell


-(void)setEmoticonInfoDictionary:(NSDictionary *)emoticonInfoDictionary {
    if (emoticonInfoDictionary != _emoticonInfoDictionary) {
        _emoticonInfoDictionary = emoticonInfoDictionary;
    }
}

- (IBAction)onPreviewButtonTapped:(id)sender {
    NSString *audioFileName = [self.emoticonInfoDictionary objectForKey:@"sound_mp3"];
    NSString *speakerImage = [self.emoticonInfoDictionary objectForKey:@"image_speaker"];
    
    [self.emoticonImageView setImage:[UIImage imageNamed:speakerImage]];
    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:audioFileName];
    
    [[AudiotsAudioVideoManager sharedInstance] addDelegate:self];
    [[AudiotsAudioVideoManager sharedInstance] startWithDataAssest:dataAsset];
}

#pragma mark - AudiotsAudioVideoManagerDelegate

-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onPreviewSoundFinished:(BOOL)finished {
    NSString *playImage = [self.emoticonInfoDictionary objectForKey:@"image_play"];
    
    [self.emoticonImageView setImage:[UIImage imageNamed:playImage]];
    
    [[AudiotsAudioVideoManager sharedInstance] removeDelegate:self];
}

- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onAudioRecordFinsihed:(NSURL *)recordedAudioFileUrl{}

@end
