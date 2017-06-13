//
//  AudiotsCustomEmoticonsCollectionViewCell.m
//  Audiots
//
//  Created by Bob Ward on 11/23/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsCustomEmoticonsCollectionViewCell.h"

#import "AudiotsAudioVideoManager.h"

@interface AudiotsCustomEmoticonsCollectionViewCell (){
    
    BOOL hasMediaType;
}

-(void) startShake;
-(void) stopShake;

@property (nonatomic, strong) CABasicAnimation *animation;

@property (weak, nonatomic) IBOutlet UIImageView *deleteImage;

@end

@implementation AudiotsCustomEmoticonsCollectionViewCell


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    hasMediaType = NO;
    
    //NSLog(@"awakeFromNib");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStartNotification:)
                                                 name:@"StartShake"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStopNotification:)
                                                 name:@"StopShake"
                                               object:nil];
    
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];

    //[self.deleteImage setHidden:YES];
    
    [self.deleteImage setAlpha:0.0];
    self.deleteImage.clipsToBounds = YES;
    self.deleteImage.layer.cornerRadius = 12.5;
    
}

-(void) FadeIn {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.deleteImage setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"Done!");
                     }];
    
}

-(void) FadeOut {
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.deleteImage setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"Done!");
                     }];
    
}

- (void) receiveStartNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"StartShake"]) {
        
        [self startShake];
    }
    
}

- (void) receiveStopNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"StopShake"]) {
        [self stopShake];
    }
    
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
        
        if (_emoticonInfoDictionary != nil) {
            NSString *mediaType = _emoticonInfoDictionary[@"mediaType"];
            
            if ([mediaType isEqualToString:@"photo"]) {
                
                hasMediaType = true;
                [self setButtonImage:@"play-32"];
            }
        }
    }
}

-(void) setButtonImage: (NSString*) imageName {
    _emoticonPreviewButton.layer.cornerRadius = 16;
    _emoticonPreviewButton.backgroundColor = [UIColor whiteColor];
    UIImage * buttonImage = [UIImage imageNamed:imageName];
    [_emoticonPreviewButton setImage:buttonImage forState:UIControlStateNormal];
}

- (IBAction)onPreviewButtonTapped:(id)sender {
    
    NSString *audioFileName = [self.emoticonInfoDictionary objectForKey:@"sound_file_path"];
    
    if (hasMediaType) {
       [self setButtonImage:@"speaker-32"];
    } else {

        NSString *speakerImage = [self.emoticonInfoDictionary objectForKey:@"image_speaker"];
        
        [self.emoticonImageView setImage:[UIImage imageNamed:speakerImage]];
    }

    NSURL *audio_inputFileUrl = [NSURL fileURLWithPath:audioFileName];

    [[AudiotsAudioVideoManager sharedInstance] addDelegate:self];
    [[AudiotsAudioVideoManager sharedInstance] startStreamWithURL:audio_inputFileUrl];
}



#pragma mark - AudiotsAudioVideoManagerDelegate

-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onPreviewSoundFinished:(BOOL)finished {
    
    if (hasMediaType) {
        [self setButtonImage:@"play-32"];
    } else {
        NSString *playImage = [self.emoticonInfoDictionary objectForKey:@"image_play"];
        
        [self.emoticonImageView setImage:[UIImage imageNamed:playImage]];
    }
    
    [[AudiotsAudioVideoManager sharedInstance] removeDelegate:self];
}

- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onAudioRecordFinsihed:(NSURL *)recordedAudioFileUrl{}


-(void) startShake {
    
    [self FadeIn];
    _animation.fromValue = @(0.0);
    _animation.toValue =  @(M_PI/25);
    _animation.duration = 0.2;
    _animation.repeatCount = 1000;
    _animation.autoreverses = true;
    
    
    [self.layer addAnimation:_animation forKey:@"iconShake"];
}

- (void) stopShake {
    
    [self FadeOut];
    [self.layer removeAnimationForKey:@"iconShake"];
}

- (IBAction)deleteAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCustomCell" object:self];
}

@end
