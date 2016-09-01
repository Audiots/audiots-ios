//
//  AudiotsIAPHelper.h
//  Audiots
//
//  Created by Tan Bui on 4/29/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "IAPHelper.h"


extern NSString * const kInAppIdPremium;
extern NSString * const kInAppIdSeeJane;

@interface AudiotsIAPHelper : IAPHelper

+ (AudiotsIAPHelper *)sharedInstance;

- (BOOL) isPremiumPurchased;

@end
