//
//  AudiotsAudioVideoManager.h
//  audiots
//
//  Created by Bob Ward on 10/29/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@class AudiotsAudioVideoManager;

@protocol AudiotsAudioVideoManagerDelegate <NSObject>
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onPreviewSoundFinished:(BOOL)finished;
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl;
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status;
- (void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onAudioRecordFinsihed:(NSURL *)recordedAudioFileUrl;

@optional
@end

@interface AudiotsAudioVideoManager : NSObject <AVAudioRecorderDelegate>

+ (AudiotsAudioVideoManager *)sharedInstance;

//Delegates
- (void)addDelegate:(id<AudiotsAudioVideoManagerDelegate>)aDelegate;
- (void)removeDelegate:(id<AudiotsAudioVideoManagerDelegate>)aDelegate;

//Controls
- (void)resumePlaying;
- (void)startPlaying;
- (void)pausePlaying;
- (void)stopPlaying;
- (void)startRecording;
- (void)stopRecording;

//State
- (BOOL)isPlaying;
- (BOOL)isRecording;

//Start Streams
- (void)startStreamWithURL:(NSURL *)streamUrl;
- (void)startWithDataAssest:(NSDataAsset *)dataAsset;

//Record Custom Audio
- (void)recordCustomAudioWithFilename:(NSString *)audioFilename;

//Video creation
- (void)createMovieWithFilePath:(NSString *)filePath andImageArray:(NSArray *)imageArray;
- (void)createMovieWithAudioFileName:(NSString *)audioFileName andImageArray:(NSArray *)imageArray;

@end
