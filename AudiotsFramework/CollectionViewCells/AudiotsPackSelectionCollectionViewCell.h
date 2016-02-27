//
//  AudiotsPackSelectionCollectionViewCell.h
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudiotsPackSelectionCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSDictionary *packInfoDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *packCoverEmoticonImageView;
@end
