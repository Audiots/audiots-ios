//
//  AudiotsPackEmoticonsCollectionViewCell.m
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsPackEmoticonsCollectionViewCell.h"

@interface AudiotsPackEmoticonsCollectionViewCell ()
@end

@implementation AudiotsPackEmoticonsCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [self.emoticonPreviewButton hitTest:[self.emoticonPreviewButton convertPoint:point fromView:self] withEvent:event];
//    if (view == nil) {
//        view = [super hitTest:point withEvent:event];
//    }
//    return view;
//}
//
//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    if ([super pointInside:point withEvent:event]) {
//        return YES;
//    }
//    //Check to see if it is within the delete button
//    return !self.emoticonPreviewButton.hidden && [self.emoticonPreviewButton pointInside:[self.emoticonPreviewButton convertPoint:point fromView:self] withEvent:event];
//}

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

@end
