//
//  NSDictionary+Helper.h
//  Audiots
//
//  Created by Tan Bui on 9/1/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helper)

- (id)objectOrNilForKey:(id)aKey;
- (id)safeObjectForKey:(NSString *)key;

@end
