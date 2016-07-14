//
//  AudiotsIAPHelper.m
//  Audiots
//
//  Created by Tan Bui on 4/29/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsIAPHelper.h"

@implementation AudiotsIAPHelper


+ (AudiotsIAPHelper *)sharedInstance { static dispatch_once_t once;
    static AudiotsIAPHelper * sharedInstance; dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.4_girls_tech.audiots.inapp.premium",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers]; });
    return sharedInstance;
}


-(BOOL) isPremiumPurchased {
    
    return [self productPurchased:@"com.4_girls_tech.audiots.inapp.premium"];
}

@end
