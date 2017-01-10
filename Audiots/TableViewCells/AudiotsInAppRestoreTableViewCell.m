//
//  AudiotsInAppRestoreTableViewCell.m
//  Audiots
//
//  Created by Tan Bui on 1/10/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsInAppRestoreTableViewCell.h"

@implementation AudiotsInAppRestoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)restoreButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(restore)]) {
        [self.delegate restore] ;
    }
}    

@end
