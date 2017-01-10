//
//  AudiotsInAppTableViewCell.h
//  Audiots
//
//  Created by Tan Bui on 1/10/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "AudiotsIAPHelper.h"

@interface AudiotsInAppTableViewCell : UITableViewCell


@property (nonatomic, weak) id <InAppDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *inAppImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (strong, nonatomic) SKProduct* product;

-(void) setInAppProduct:(SKProduct*) product;


@end
