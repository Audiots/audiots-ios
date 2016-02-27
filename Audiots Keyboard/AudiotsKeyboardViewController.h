//
//  AudiotsKeyboardViewController.h
//  Audiots
//
//  Created by Bob Ward on 10/30/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudiotsPackSelectionCollectionView.h"
#import "AudiotsPackEmoticonsCollectionView.h"

#import "AudiotsAudioVideoManager.h"

#import <PSDDataSource/PSDPlistDataSource.h>
#import <PSDDataSource/UICollectionView+PSDDataSource.h>

@interface AudiotsKeyboardViewController : UIInputViewController <UICollectionViewDelegate, AudiotsAudioVideoManagerDelegate>

@property (nonatomic, strong) PSDPListDataSource *packSelectionDataSource;
@property (nonatomic, strong) PSDPListDataSource *packEmoticonsDataSource;


@property (weak, nonatomic) IBOutlet UIView *numbersRow1View;
@property (weak, nonatomic) IBOutlet UIView *symbolsRow1View;

@property (weak, nonatomic) IBOutlet UIView *numbersRow2View;
@property (weak, nonatomic) IBOutlet UIView *symbolsRow2View;

@property (weak, nonatomic) IBOutlet UIView *numbersSymbolsRow3View;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *letterButtonsArray;



@property (weak, nonatomic) IBOutlet UIButton *shiftButton;
@property (weak, nonatomic) IBOutlet UIButton *spaceButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;


@property (weak, nonatomic) IBOutlet UIButton *switchModeRow3Button;
@property (weak, nonatomic) IBOutlet UIButton *switchModeRow4Button;


@property (weak, nonatomic) IBOutlet UIButton *advanceKeyboardButton;
@property (weak, nonatomic) IBOutlet UIButton *backspaceKeyboardButton;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;

@property (weak, nonatomic) IBOutlet AudiotsPackSelectionCollectionView *packSelectionCollectionView;
@property (weak, nonatomic) IBOutlet AudiotsPackEmoticonsCollectionView *packEmoticonsCollectionView;

@property (weak, nonatomic) IBOutlet UIView *keyboardView;

- (IBAction)onAdvanceKeyboardButtonTapped:(id)sender;
- (IBAction)onBackspaceKeyboardButtonTapped:(id)sender;
- (IBAction)onKeyboardButtonTapped:(id)sender;

@end
