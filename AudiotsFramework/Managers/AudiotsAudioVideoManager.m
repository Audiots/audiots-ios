//
//  AudiotsAudioVideoManager.m
//  audiots
//
//  Created by Bob Ward on 10/29/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsAudioVideoManager.h"

static void *AVPlayerRateObservationContext = &AVPlayerRateObservationContext;
static void *AVPlayerStatusObservationContext = &AVPlayerStatusObservationContext;
static void *AVPlayerCurrentItemObservationContext = &AVPlayerCurrentItemObservationContext;
static void *AVPlayerCurrentItemTimedMetadataObservationContext = &AVPlayerCurrentItemTimedMetadataObservationContext;

@interface AudiotsAudioVideoManager ()
@property (nonatomic, strong) NSHashTable *delegates;

@property (nonatomic, strong) AVQueuePlayer *player;
//@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (strong) id playerObserver;

@end

@implementation AudiotsAudioVideoManager

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.delegates = [NSHashTable weakObjectsHashTable];
        
        //Audio Session Initialization
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAVAudioSessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAVAudioSessionRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
    }
    return self;
}

+ (AudiotsAudioVideoManager *)sharedInstance {
    static AudiotsAudioVideoManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudiotsAudioVideoManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Delegates

- (void)addDelegate:(id<AudiotsAudioVideoManagerDelegate>)aDelegate {
    [self.delegates addObject:aDelegate];
}

- (void)removeDelegate:(id<AudiotsAudioVideoManagerDelegate>)aDelegate {
    [self.delegates removeObject:aDelegate];
}


#pragma mark - Controls

- (void)resumePlaying {
    [self.player play];
}

- (void)startPlaying {
    [self.player play];
}

- (void)pausePlaying {
    [self.player pause];
}

- (void)stopPlaying {
    [self.player pause];
}

- (void)startRecording {
    if (self.isPlaying) {
        [self stopPlaying];
    }
    
    if (self.recorder.isRecording == NO) {
        [self.audioSession setActive:YES error:nil];
        [self.recorder record];
    }
}

- (void)stopRecording {
    if (self.recorder.recording) {
        [self.recorder stop];
        [self.audioSession setActive:NO error:nil];
    }
}

#pragma mark - State

- (BOOL)isPlaying {
    return ((self.player.rate > 0 && !self.player.error));
}

- (BOOL)isRecording {
    return self.recorder.isRecording;
}

#pragma mark - Start Streams

- (void)startStreamWithURL:(NSURL *)streamUrl {

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:streamUrl options:nil];

    NSError *tracksError = nil;

    AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&tracksError];

    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            NSError *error = nil;
                            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
                            if (status == AVKeyValueStatusLoaded && asset.tracks.count) {
                                [self prepareToPlayAsset:asset];
                            } else {
                                
                                [self prepareToPlayStreamUrl:streamUrl];
                            }
                        });
     }];
}

- (void)startWithDataAssest:(NSDataAsset *)dataAsset {
    
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"emoticon.mp3"];
    [[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:dataAsset.data attributes:nil];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:tempFilePath] options:nil];

    [self prepareToPlayAsset:asset];
//    //Remove Existing player key value observers and notifications
//    if (self.player) {
//        [self.player removeObserver:self forKeyPath:@"currentItem"];
//        [self.player removeObserver:self forKeyPath:@"rate"];
//    }
//    
//    NSError *audioPlayerError = nil;
//
//    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:dataAsset.data error:&audioPlayerError];
//    [self setAudioPlayer:audioPlayer];
//    [self.audioPlayer play];
}

#pragma mark - Stream Preparation

- (void)prepareToPlayStreamUrl:(NSURL*)streamUrl {
    
    //Remove existing player item key value observers and notifications.
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    //Create a new instance of AVPlayerItem from the now successfully loaded AVAsset.
    self.playerItem = [AVPlayerItem playerItemWithURL:streamUrl];
    
    //Observe the player item "status" key to determine when it is ready to play.
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerStatusObservationContext];
    
    //When the player item has played to its end time we'll toggle the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    //Observe the player item "timedMetadata" key to determine when it is ready to play.
    [self.playerItem addObserver:self
                      forKeyPath:@"timedMetadata"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerCurrentItemTimedMetadataObservationContext];
    
    //Remove Existing player key value observers and notifications
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"currentItem"];
        [self.player removeObserver:self forKeyPath:@"rate"];
    }
    
    //Get a new AVQueuePlayer initialized to play the specified player item.
    //queuePlayerWithItems crashes down deep in core audio
    AVQueuePlayer *queuePlayer = [[AVQueuePlayer alloc] initWithItems:@[self.playerItem]];
    [self setPlayer:queuePlayer];
    //[self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[self.playerItem]]];
    
    //Observe the AVPlayer "currentItem" property to find out when any AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did occur.
    [self.player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerCurrentItemObservationContext];
    
    //Observe the AVPlayer "rate" property to update the scrubber control.
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerRateObservationContext];
}

- (void)prepareToPlayAsset:(AVURLAsset*)asset {
    
    //Remove existing player item key value observers and notifications.
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    //Create a new instance of AVPlayerItem from the now successfully loaded AVAsset.
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    //Observe the player item "status" key to determine when it is ready to play.
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerStatusObservationContext];
    
    //When the player item has played to its end time we'll toggle the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    //Observe the player item "timedMetadata" key to determine when it is ready to play.
    [self.playerItem addObserver:self
                      forKeyPath:@"timedMetadata"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerCurrentItemTimedMetadataObservationContext];
    
    //Remove Existing player key value observers and notifications
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"currentItem"];
        [self.player removeObserver:self forKeyPath:@"rate"];
    }
    
    //Get a new AVQueuePlayer initialized to play the specified player item.
    [self setPlayer:[AVQueuePlayer queuePlayerWithItems:@[self.playerItem]]];
    
    //Observe the AVPlayer "currentItem" property to find out when any AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did occur.
    [self.player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerCurrentItemObservationContext];
    
    //Observe the AVPlayer "rate" property to update the scrubber control.
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerRateObservationContext];
    
}

#pragma mark - Stream Failed

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
//    /* Display the error. */
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                        message:[error localizedFailureReason]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    [alertView show];
}

#pragma mark - AVPlayer and AVPlayerItem KVO

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    __weak AudiotsAudioVideoManager *weakSelf = self;
    
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerStatusObservationContext)
    {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerItemStatusUnknown:
            {
                break;
            }
            case AVPlayerItemStatusReadyToPlay:
            {
                [self startPlaying];
                break;
            }
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                break;
            }
        }
        
        id<AudiotsAudioVideoManagerDelegate> delegate = nil;
        for (delegate in [self.delegates copy]) {
        }
    }
    
    
    
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerRateObservationContext)
    {
        
        id<AudiotsAudioVideoManagerDelegate> delegate = nil;
        for (delegate in [self.delegates copy]) {
        }
    }
    
    /* AVPlayer "currentItem.timedMetadata" property value observer. */
    else if (context == AVPlayerCurrentItemTimedMetadataObservationContext)
    {
    }
    
    
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
        }
        else /* Replacement of player currentItem has occurred */
        {
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}








#pragma mark - AVAudioSession Notifications

- (void)onAVAudioSessionInterruption:(NSNotification *)notification {
    NSNumber *interruptionType = [[notification userInfo] valueForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] valueForKey:AVAudioSessionInterruptionOptionKey];
    
    switch ([interruptionType intValue]) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
        {
            switch ([interruptionOption intValue]) {
                case AVAudioSessionInterruptionOptionShouldResume:
                {
                    [self.player play];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)onAVAudioSessionRouteChange:(NSNotification *)notification {
    NSNumber *routeChangeReason = [[notification userInfo] valueForKey:AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteDescription *routeDescription = [[notification userInfo] valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    [self.player pause];
    switch ([routeChangeReason intValue]) {
        case AVAudioSessionRouteChangeReasonUnknown:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
        {
            break;
        }
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - Played to end

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    id<AudiotsAudioVideoManagerDelegate> delegate = nil;
    for (delegate in [self.delegates copy]) {
        id<AudiotsAudioVideoManagerDelegate> delegate = nil;
        for (delegate in [self.delegates copy]) {
            if (delegate && [delegate respondsToSelector:@selector(AudiotsAudioVideoManager:onPreviewSoundFinished:)]) {
                [delegate AudiotsAudioVideoManager:self onPreviewSoundFinished:YES];
            }
        }
    }
}

#pragma mark - Record Custom Audio

-(void) initializeAudioRecorderWithFilename:(NSString *)audioFilename
{
    NSError *error = nil;

    NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *audio_outputPath = [[storeUrl path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", audioFilename]];

    NSURL *outputFileURL = [NSURL fileURLWithPath:audio_outputPath];
    
    // Setup audio session
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

- (void)recordCustomAudioWithFilename:(NSString *)audioFilename {
    [self initializeAudioRecorderWithFilename:audioFilename];
    [self startRecording];
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    id<AudiotsAudioVideoManagerDelegate> delegate = nil;
    for (delegate in [self.delegates copy]) {
        if (delegate && [delegate respondsToSelector:@selector(AudiotsAudioVideoManager:onAudioRecordFinsihed:)]) {
            [delegate AudiotsAudioVideoManager:self onAudioRecordFinsihed:avrecorder.url];
        }
    }
}

#pragma mark - Video Creation

- (void)createMovieWithFilePath:(NSString *)filePath andImageArray:(NSArray *)imageArray {
    
    
    //[[AudiotsAudioVideoManager sharedInstance] startStreamWithURL:[NSURL URLWithString:filePath] ];

    NSError *error = nil;
    NSUInteger fps = 30;
    CGSize frameSize = CGSizeMake(192, 192);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *imageToVideoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"imageToVideo.mov"];
    if ([fileMgr removeItemAtPath:imageToVideoOutputPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:imageToVideoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    ///////////////////////////////////////////////////////////////////
    //////////////  Convert image array to video  /////////////////////
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 1;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    for(UIImage * image in imageArray)
    {
        //UIImage * img = frm._imageFrame;
        //UIImage *normalizedImage = [image normalize];
        
        buffer = [self pixelBufferFromCGImage:[image CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                NSLog(@"adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            NSLog(@"error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        /////////////////////////////////////////////////////////
        //////////////  Add audio to video  /////////////////////
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
        NSURL *audio_inputFileUrl = [NSURL fileURLWithPath:filePath];
        NSURL *video_inputFileUrl = [NSURL fileURLWithPath:imageToVideoOutputPath];
        
        // create the final video output file as MOV file - may need to be MP4, but this works so far...
        NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"audiotsVideo.mov"];
        NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        
        CMTime nextClipStartTime = kCMTimeZero;
        
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        AVAssetExportSession* assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        assetExportSession.outputFileType = @"com.apple.quicktime-movie";
        assetExportSession.outputURL = outputFileUrl;
        
        [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
            id<AudiotsAudioVideoManagerDelegate> delegate = nil;
            for (delegate in [self.delegates copy]) {
                if (delegate && [delegate respondsToSelector:@selector(AudiotsAudioVideoManager:onCreateMovieFinsihed:)]) {
                    [delegate AudiotsAudioVideoManager:self onCreateMovieFinsihed:outputFileUrl];
                }
            }
        }];
    }];;
}

- (void)createMovieWithAudioFileName:(NSString *)audioFileName andImageArray:(NSArray *)imageArray {
    
    NSError *error = nil;
    NSUInteger fps = 30;
    CGSize frameSize = CGSizeMake(192, 192);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *imageToVideoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"imageToVideo.mov"];
    if ([fileMgr removeItemAtPath:imageToVideoOutputPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:imageToVideoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    ///////////////////////////////////////////////////////////////////
    //////////////  Convert image array to video  /////////////////////
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 1;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    for(UIImage * image in imageArray)
    {
        //UIImage * img = frm._imageFrame;
        //UIImage *normalizedImage = [image normalize];
        
        buffer = [self pixelBufferFromCGImage:[image CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                NSLog(@"adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            NSLog(@"error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        /////////////////////////////////////////////////////////
        //////////////  Add audio to video  /////////////////////
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
        NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:audioFileName];
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *audio_inputFilePath = [cacheDirectory stringByAppendingPathComponent:@"inputAudio.mp3"];
        [dataAsset.data writeToFile:audio_inputFilePath atomically:YES];
        
        NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
        
        // this is the video file that was just written above, full path to file is in --> videoOutputPath
        NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:imageToVideoOutputPath];
        
        // create the final video output file as MOV file - may need to be MP4, but this works so far...
        NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"audiotsVideo.mp4"];
        NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        
        CMTime nextClipStartTime = kCMTimeZero;
        
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        
        
        AVAssetExportSession* assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        //assetExportSession.outputFileType = @"com.apple.quicktime-movie";
        assetExportSession.outputFileType = AVFileTypeMPEG4;
        //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
        assetExportSession.outputURL = outputFileUrl;
        
        [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
            id<AudiotsAudioVideoManagerDelegate> delegate = nil;
            for (delegate in [self.delegates copy]) {
                if (delegate && [delegate respondsToSelector:@selector(AudiotsAudioVideoManager:onCreateMovieFinsihed:)]) {
                    [delegate AudiotsAudioVideoManager:self onCreateMovieFinsihed:outputFileUrl];
                }
            }
        }];

    }];;
}

#pragma mark - Private Methods

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image {
    
    CGSize size = CGSizeMake(192, 192);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 (kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst));

    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));

    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));

    CGContextDrawImage(context, CGRectMake((size.width - CGImageGetWidth(image)) / 2, (size.height - CGImageGetHeight(image)) / 2, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);


    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
