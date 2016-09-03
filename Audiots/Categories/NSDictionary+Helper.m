//
//  NSDictionary+Helper.m
//  Audiots
//
//  Created by Tan Bui on 9/1/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary (Helper)

- (id)objectOrNilForKey:(id)aKey
{
    id object = [self objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}


- (id)safeObjectForKey:(NSString *)key {
    
    id object = [self objectForKey:key];
    if (object == [NSNull null]) {
        return nil;
    } else {
        return object;
    }
}

@end
