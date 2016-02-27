//
//  AudiotsPackSelectionCollectionViewCell.m
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsPackSelectionCollectionViewCell.h"

@implementation AudiotsPackSelectionCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setPackInfoDictionary:(NSDictionary *)packInfoDictionary {
    if (packInfoDictionary != _packInfoDictionary) {
        _packInfoDictionary = packInfoDictionary;
    }
}

-(void)prepareForReuse {
}

@end
