//
//  AudiotsInAppTableViewCell.m
//  Audiots
//
//  Created by Tan Bui on 1/10/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsInAppTableViewCell.h"
#import "AudiotsIAPHelper.h"

@implementation AudiotsInAppTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buyButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(buy:)]) {
        [self.delegate buy:self.product] ;
    }
}


-(void) setInAppProduct: (SKProduct *) product {
    
    self.product = product;
    
    self.titleLabel.text = product.localizedTitle;
    self.descriptionLabel.text = product.localizedDescription;
    
    
    if ([[AudiotsIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        [self.buyButton setTitle:@"Paid" forState:UIControlStateNormal];
        
    } else {
        
        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        [self.buyButton setTitle:[NSString stringWithFormat:@"%@",  [priceFormatter stringFromNumber:product.price]] forState:UIControlStateNormal];
    }
    [self.buyButton sizeToFit];
}

@end
