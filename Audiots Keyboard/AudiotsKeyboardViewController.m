//
//  AudiotsKeyboardViewController.m
//  Audiots
//
//  Created by Bob Ward on 10/30/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsKeyboardViewController.h"

#import "AudiotsPackSelectionCollectionViewCell.h"
#import "AudiotsPackEmoticonsCollectionViewCell.h"
#import "AudiotsCustomEmoticonsCollectionViewCell.h"
#import "AudiotsCreateCustomAudiotCollectionViewCell.h"

#import <Toast/UIView+Toast.h>

#import <QuartzCore/QuartzCore.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AudiotsKeyboardViewController ()
@property (assign, nonatomic) NSInteger shiftStatus; //0 = off, 1 = on, 2 = caps lock
@end

@implementation AudiotsKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize Crashlytics
    [Fabric with:@[[Crashlytics class]]];

    //Initialize Collection Views
    [self initializeKeyboard];
    [self initializePackSelectionCollectionView];
    [self initializePackEmoticonsCollectionView];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    
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

- (BOOL)isOpenAccessGranted
{
    return [UIPasteboard generalPasteboard];
}

#pragma mark - Initialization

- (void) initializeKeyboard {
    
    //start with shift on
    self.shiftStatus = 1;
    //_shiftStatus = 1;
    
    //initialize space key double tap
    UITapGestureRecognizer *spaceDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spaceKeyDoubleTapped:)];
    
    spaceDoubleTap.numberOfTapsRequired = 2;
    [spaceDoubleTap setDelaysTouchesEnded:NO];
    
    [self.spaceButton addGestureRecognizer:spaceDoubleTap];
    
    //initialize shift key double and triple tap
    UITapGestureRecognizer *shiftDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyDoubleTapped:)];
    UITapGestureRecognizer *shiftTripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyPressed:)];
    
    shiftDoubleTap.numberOfTapsRequired = 2;
    shiftTripleTap.numberOfTapsRequired = 3;
    
    [shiftDoubleTap setDelaysTouchesEnded:NO];
    [shiftTripleTap setDelaysTouchesEnded:NO];
    
    [self.shiftButton addGestureRecognizer:shiftDoubleTap];
    [self.shiftButton addGestureRecognizer:shiftTripleTap];
    
    //Initialize space button
    [[self.spaceButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [self.spaceButton.layer setCornerRadius:10.0f];
    [self.spaceButton setClipsToBounds:YES];
    
//    UIImage *image = [[UIImage imageNamed:@"return"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.returnButton setImage:image forState:UIControlStateNormal];
//    self.returnButton.tintColor = [UIColor redColor];
}

- (void)initializePackSelectionCollectionView {
    self.packSelectionCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return (NSString*)[aObject valueForKey:@"cellType"];;
    };
    
    [self.packSelectionCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackSelectionCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackSelectionCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packSelectionCollectionViewCell"];
    
    [self.packSelectionCollectionView registerCellConfigureBlock:^(AudiotsPackSelectionCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setPackInfoDictionary:menuItemDictionary];
        [cell.packCoverEmoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"packCoverImage"]]];
    } forCellReuseIdentifier:@"packSelectionCollectionViewCell"];
    
    if (self.packSelectionDataSource == nil) {
        self.packSelectionDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudiotsAvailablePacks" ofType:@"plist"]];
    }
}

- (void)initializePackEmoticonsCollectionView {
    

    self.packEmoticonsCollectionView.cellIdentifierBlock = ^(NSObject *aObject) {
        return (NSString*)[aObject valueForKey:@"cellType"];
    };
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsPackEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsPackEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"packEmoticonsCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCreateCustomAudiotCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCreateCustomAudiotCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"createCustomAudiotCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerNib:[UINib nibWithNibName:@"AudiotsCustomEmoticonsCollectionViewCell" bundle:[NSBundle bundleForClass:[AudiotsCustomEmoticonsCollectionViewCell class]]]
                       forCellWithReuseIdentifier:@"customEmoticonsCollectionViewCell"];
    
    
    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsPackEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
    } forCellReuseIdentifier:@"packEmoticonsCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCreateCustomAudiotCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setAudiotInfoDictionary:menuItemDictionary];
    } forCellReuseIdentifier:@"createCustomAudiotCollectionViewCell"];
    
    [self.packEmoticonsCollectionView registerCellConfigureBlock:^(AudiotsCustomEmoticonsCollectionViewCell *cell, NSDictionary *menuItemDictionary) {
        [cell setEmoticonInfoDictionary:menuItemDictionary];
        [cell.emoticonImageView setImage:[UIImage imageNamed:[menuItemDictionary valueForKey:@"image_play"]]];
    } forCellReuseIdentifier:@"customEmoticonsCollectionViewCell"];
    
    if (self.packEmoticonsDataSource == nil) {
        self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] valueForKey:@"packName"] ofType:@"plist"]];
    }
    
    if ([self isOpenAccessGranted]) {
    } else {
        [self.packEmoticonsCollectionView setAlpha:0.3f];
    }

}

#pragma mark - DataSources

-(void)setPackSelectionDataSource:(PSDPListDataSource *)packSelectionDataSource {
    if (packSelectionDataSource != _packSelectionDataSource) {
        _packSelectionDataSource = packSelectionDataSource;
        [self.packSelectionCollectionView setDataSource:_packSelectionDataSource];
        [self.packSelectionCollectionView reloadData];
    }
}
-(void)setPackEmoticonsDataSource:(PSDPListDataSource *)packEmoticonsDataSource {
    if (packEmoticonsDataSource != _packEmoticonsDataSource) {
        _packEmoticonsDataSource = packEmoticonsDataSource;
        [self.packEmoticonsCollectionView setDataSource:_packEmoticonsDataSource];
        [self.packEmoticonsCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldSelect = NO;

    if (collectionView == self.packSelectionCollectionView) {
        shouldSelect = YES;
    } else if (collectionView == self.packEmoticonsCollectionView) {
        if ([self isOpenAccessGranted]) {
            return shouldSelect = YES;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"'Allow Full Access' must be enabled in Settings in order to send Audiots." duration:5.0f position:CSToastPositionCenter];
            });
        }
    }
    
    return shouldSelect;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.packSelectionCollectionView) {
        if (self.keyboardView.isHidden == NO) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.keyboardView setAlpha:0.0f];
            } completion: ^(BOOL finished) {
                [self.keyboardView setHidden:YES];
            }];
        }

        if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"xcassets"]) {
            //[self setIsCurrentPackMyCreations:NO];
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packName"]
                                                                                                                              ofType:@"plist"]];
        } else if ([[(NSDictionary*)[self.packSelectionDataSource objectAtIndexPath:indexPath] valueForKey:@"packType"] isEqualToString:@"custom"]) {
            //[self setIsCurrentPackMyCreations:YES];
            NSURL* storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
            NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
            self.packEmoticonsDataSource = [[PSDPListDataSource alloc] initWithContentsOfFile:myCreationsPlistPath];
        }
    } else if (collectionView == self.packEmoticonsCollectionView) {
        NSDictionary *emoticonInfoDictionary = [(AudiotsPackEmoticonsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] emoticonInfoDictionary];
        
        if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"packEmoticonsCollectionViewCell"]) {
            NSString *audioFileName = [emoticonInfoDictionary objectForKey:@"sound_mp3"];
            NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];
            
            [[AudiotsAudioVideoManager sharedInstance] createMovieWithAudioFileName:audioFileName andImageArray:@[[UIImage imageNamed:imageFileName]]];
        } else if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"customEmoticonsCollectionViewCell"]) {
            NSString *audioFilePath = [emoticonInfoDictionary objectForKey:@"sound_file_path"];
            NSString *imageFileName = [emoticonInfoDictionary objectForKey:@"image_play"];

            if ([self isOpenAccessGranted]) {
                [[AudiotsAudioVideoManager sharedInstance] createMovieWithFilePath:audioFilePath andImageArray:@[[UIImage imageNamed:imageFileName]]];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:@"Please enable Full Access."];
                });
            }
        } else if ([[emoticonInfoDictionary valueForKey:@"cellType"] isEqualToString:@"createCustomAudiotCollectionViewCell"]) {
        }
    }
}

#pragma mark - TextInput methods

- (void)textWillChange:(id<UITextInput>)textInput {
}

- (void)textDidChange:(id<UITextInput>)textInput {
}

#pragma mark - AudiotsAudioVideoManagerDelegate
-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFailed:(BOOL)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"Failed to generate Audiot."];
    });
}

-(void)AudiotsAudioVideoManager:(AudiotsAudioVideoManager *)audioVideoManager onCreateMovieFinsihed:(NSURL *)movieFileUrl {
    NSData *data = [NSData dataWithContentsOfURL:movieFileUrl];
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    [pasteBoard setData:data forPasteboardType:@"com.apple.quicktime-movie"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CSToastStyle *notificationStyle = [[CSToastStyle alloc] initWithDefaultStyle];
        [notificationStyle setBackgroundColor:[UIColor colorWithRed:65.0/255.0 green:184.0/255.0 blue:175.0/255.0 alpha:1.0]];
        [notificationStyle setCornerRadius:6.0f];
        [notificationStyle setTitleAlignment:NSTextAlignmentCenter];
        [notificationStyle setTitleColor:[UIColor whiteColor]];
        [notificationStyle setMaxWidthPercentage:0.9f];

        [self.view makeToast:@"Copied. Tap text field and select paste."
                    duration:5.0
                    position:CSToastPositionBottom
                       title:nil
                       image:nil
                       style:notificationStyle
                  completion:^(BOOL didTap) {
                  }
         ];
    });
}

#pragma mark - Actions

- (IBAction)onAdvanceKeyboardButtonTapped:(id)sender {
    [self advanceToNextInputMode];
}

- (IBAction)onBackspaceKeyboardButtonTapped:(id)sender {
    [self.textDocumentProxy deleteBackward];
}

- (IBAction)onKeyboardButtonTapped:(id)sender {
    if (self.keyboardView.isHidden) {
        [self.keyboardView setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self.keyboardView setAlpha:1.0f];
        } completion: ^(BOOL finished) {
        }];
    }
}

- (IBAction) keyPressed:(UIButton*)sender {
    
    //inserts the pressed character into the text document
    [self.textDocumentProxy insertText:sender.titleLabel.text];
    
    //if shiftStatus is 1, reset it to 0 by pressing the shift key
    if (_shiftStatus == 1) {
        [self shiftKeyPressed:self.shiftButton];
    }
    
}

-(IBAction) backspaceKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy deleteBackward];
}



-(IBAction) spaceKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy insertText:@" "];
    
}


-(void) spaceKeyDoubleTapped: (UIButton*) sender {
    
    //double tapping the space key automatically inserts a period and a space
    //if necessary, activate the shift button
    [self.textDocumentProxy deleteBackward];
    [self.textDocumentProxy insertText:@". "];
    
    if (_shiftStatus == 0) {
        [self shiftKeyPressed:self.shiftButton];
    }
}


-(IBAction) returnKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy insertText:@"\n"];
}


-(IBAction) shiftKeyPressed: (UIButton*) sender {
    
    //if shift is on or in caps lock mode, turn it off. Otherwise, turn it on
    _shiftStatus = _shiftStatus > 0 ? 0 : 1;
    
    [self shiftKeys];
}



-(void) shiftKeyDoubleTapped: (UIButton*) sender {
    
    //set shift to caps lock and set all letters to uppercase
    _shiftStatus = 2;
    
    [self shiftKeys];
    
}


- (void) shiftKeys {
    
    //if shift is off, set letters to lowercase, otherwise set them to uppercase
    if (_shiftStatus == 0) {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.lowercaseString forState:UIControlStateNormal];
        }
    } else {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.uppercaseString forState:UIControlStateNormal];
        }
    }
    
    //adjust the shift button images to match shift mode
    NSString *shiftButtonImageName = [NSString stringWithFormat:@"shift_%li.png", (long)_shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonImageName] forState:UIControlStateNormal];
    
    
    NSString *shiftButtonHLImageName = [NSString stringWithFormat:@"shift_%liHL.png", (long)_shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonHLImageName] forState:UIControlStateHighlighted];
    
}


- (IBAction) switchKeyboardMode:(UIButton*)sender {
    
    self.numbersRow1View.hidden = YES;
    self.numbersRow2View.hidden = YES;
    self.symbolsRow1View.hidden = YES;
    self.symbolsRow2View.hidden = YES;
    self.numbersSymbolsRow3View.hidden = YES;
    
    //switches keyboard to ABC, 123, or #+= mode
    //case 1 = 123 mode, case 2 = #+= mode
    //default case = ABC mode
    
    switch (sender.tag) {
            
        case 1: {
            self.numbersRow1View.hidden = NO;
            self.numbersRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to #+= and row 4 switch button to ABC
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"symbols.png"] forState:UIControlStateNormal];
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"symbolsHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow3Button.tag = 2;
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"abc.png"] forState:UIControlStateNormal];
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"abcHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow4Button.tag = 0;
        }
            break;
            
        case 2: {
            self.symbolsRow1View.hidden = NO;
            self.symbolsRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to 123
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"numbers.png"] forState:UIControlStateNormal];
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"numbersHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow3Button.tag = 1;
        }
            break;
            
        default:
            //change the row 4 switch button image to 123
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"numbers.png"] forState:UIControlStateNormal];
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"numbersHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow4Button.tag = 1;
            break;
    }
    
}

@end
