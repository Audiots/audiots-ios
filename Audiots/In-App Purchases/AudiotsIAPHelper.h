//
//  AudiotsIAPHelper.h
//  Audiots
//
//  Created by Tan Bui on 4/29/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "IAPHelper.h"

@protocol InAppDelegate <NSObject>
@optional
- (void)buy:(SKProduct*) product;
- (void)restore;
@end

extern NSString * const kInAppIdPremium;
extern NSString * const kInAppIdSeeJane;
extern NSString * const kInAppIdCureCancer;

@interface AudiotsIAPHelper : IAPHelper

+ (AudiotsIAPHelper *)sharedInstance;


@end
