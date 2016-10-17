//
//  AudiotsIAPHelper.m
//  Audiots
//
//  Created by Tan Bui on 4/29/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsIAPHelper.h"

@implementation AudiotsIAPHelper

NSString * const kInAppIdPremium = @"com.4_girls_tech.audiots.inapp.premium";
NSString * const kInAppIdSeeJane = @"com.4_girls_tech.audiots.inapp.seejane";
NSString * const kInAppIdCureCancer = @"com.4_girls_tech.audiots.inapp.curecancer";

+ (AudiotsIAPHelper *)sharedInstance { static dispatch_once_t once;
    static AudiotsIAPHelper * sharedInstance; dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      kInAppIdPremium,
                                      kInAppIdSeeJane,
                                      kInAppIdCureCancer,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers]; });
    return sharedInstance;
}



@end
