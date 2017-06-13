//
//  AudiotsCreateStepTwoViewController.m
//  Audiots
//
//  Created by Bob Ward on 11/22/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsCreateStepTwoViewController.h"

@interface AudiotsCreateStepTwoViewController ()

@end

@implementation AudiotsCreateStepTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
    NSString *mediaType = [self.selectedEmoticonInfoDictionary valueForKey:@"mediaType"];
    
    if ([mediaType  isEqual: @"photo"]) {
        [self.currentEmoticonImageView setImage:[self.selectedEmoticonInfoDictionary valueForKey:@"image_play"]];
    } else {
    [self.currentEmoticonImageView setImage:[UIImage imageNamed:[self.selectedEmoticonInfoDictionary valueForKey:@"image_play"]]];
    }
    
    [[AudiotsAudioVideoManager sharedInstance] addDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[AudiotsAudioVideoManager sharedInstance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AudiotsAudioVideoManagerDelegate
-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onAudioRecordFinsihed:(NSURL *)recordedAudioFileUrl {
        
    NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
   
    NSMutableArray *rootArray = [NSMutableArray arrayWithContentsOfFile:myCreationsPlistPath];
    NSDictionary *objectsDictionary = [rootArray objectAtIndex:0];
    NSMutableArray *objectsArray = [objectsDictionary valueForKey:@"objects"];

    NSDictionary *customAudiotDictionary = nil;
    
    NSString *mediaType = [self.selectedEmoticonInfoDictionary valueForKey:@"mediaType"];
    if ([mediaType  isEqual: @"photo"]) {
        
        NSString *photoFilename = [NSString stringWithFormat:@"%@/photo_%u.png", [storeUrl path], arc4random()];
        
        UIImage *image = [self.selectedEmoticonInfoDictionary valueForKey:@"image_play"];
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        [imageData writeToFile:photoFilename atomically:NO];
        
        customAudiotDictionary = @{@"image_plain"      : photoFilename,
                                   @"image_play"       : photoFilename,
                                   @"image_speaker"    : photoFilename,
                                   @"sound_file_path"  : [recordedAudioFileUrl path],
                                   @"cellType"         : @"customEmoticonsCollectionViewCell",
                                   @"mediaType"        : @"photo"};
    } else {
        customAudiotDictionary = @{@"image_plain"      : [self.selectedEmoticonInfoDictionary valueForKey:@"image_plain"],
                                             @"image_play"       : [self.selectedEmoticonInfoDictionary valueForKey:@"image_play"],
                                             @"image_speaker"    : [self.selectedEmoticonInfoDictionary valueForKey:@"image_speaker"],
                                             @"sound_file_path"  : [recordedAudioFileUrl path],
                                             @"cellType"         : @"customEmoticonsCollectionViewCell"};
    }
    
    [objectsArray addObject:customAudiotDictionary];
    [objectsDictionary setValue:objectsArray forKey:@"objects"];
    [rootArray arrayByAddingObject:objectsDictionary];
    
    //Update MyCreations file
    [rootArray writeToFile:myCreationsPlistPath atomically:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status{}
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onPreviewSoundFinished:(BOOL)finished{}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onRecordAudioButtonTapped:(id)sender {
    if ([[AudiotsAudioVideoManager sharedInstance] isRecording] == NO) {
        
        [self changeText:@"Tap the button to stop the recording"];
        
        NSString *audioFilename = [NSString stringWithFormat:@"%@_%u",[self.selectedEmoticonInfoDictionary valueForKey:@"image_play"], arc4random()];

        [[AudiotsAudioVideoManager sharedInstance] recordCustomAudioWithFilename:audioFilename];
        [self.recordAudioButton setImage:[UIImage imageNamed:@"Stop-Button"] forState:UIControlStateNormal];
    } else {
        [self changeText:@"Tap the record to start"];
        [[AudiotsAudioVideoManager sharedInstance] stopRecording];
        [self.recordAudioButton setImage:[UIImage imageNamed:@"Record-Button"] forState:UIControlStateNormal];
    }
}

-(void) changeText: (NSString*) updateText{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.descriptionLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    self.descriptionLabel.text = updateText;
    
}

@end
