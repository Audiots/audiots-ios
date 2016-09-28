//
//  AudiotsCreateCustomAudiotCollectionViewCell.m
//  Audiots
//
//  Created by Bob Ward on 11/9/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsCreateCustomAudiotCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation AudiotsCreateCustomAudiotCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setAudiotInfoDictionary:(NSDictionary *)audiotInfoDictionary {
    if (audiotInfoDictionary != _audiotInfoDictionary) {
        _audiotInfoDictionary = audiotInfoDictionary;
    }
}

-(void)setEmoticonInfoDictionary:(NSDictionary *)emoticonInfoDictionary {
    if (emoticonInfoDictionary != _emoticonInfoDictionary) {
        _emoticonInfoDictionary = emoticonInfoDictionary;
    }
}

@end
