//
//  AudiotsCreateStepTwoViewController.h
//  Audiots
//
//  Created by Bob Ward on 11/22/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsAudioVideoManager.h"

@interface AudiotsCreateStepTwoViewController : UIViewController <AudiotsAudioVideoManagerDelegate>

@property (nonatomic, strong) NSDictionary *selectedEmoticonInfoDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *currentEmoticonImageView;


@property (weak, nonatomic) IBOutlet UIButton *recordAudioButton;
- (IBAction)onRecordAudioButtonTapped:(id)sender;
@end
