//
// Created by Todd Brannam on 2/24/15.
// Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import "NSMutableDictionary+PSDDataSource.h"

@implementation NSMutableDictionary (PSDDataSource)

- (void)psdMergeWithDictionary:(NSDictionary*)dict
{
    NSEnumerator* keyEnumerator = [dict keyEnumerator];

    for (id<NSCopying> key in keyEnumerator) {

        NSObject<PSDDataMerge> *destinationValue = [self objectForKey:key];
        NSObject<PSDDataMerge> *sourceValue = [dict objectForKey:key];

        if (!destinationValue) {
            [self setObject:sourceValue forKey:key];
        } else if ([destinationValue respondsToSelector:@selector(psdMerge:)] && [sourceValue respondsToSelector:@selector(psdMerge:)]) {
            [destinationValue psdMerge:sourceValue];
        } else {
            [self setObject:sourceValue forKey:key];
        }
    }
}

- (void)psdMerge:(NSObject *)object
{
    if ([object isKindOfClass:NSMutableDictionary.class]) {
        [self psdMergeWithDictionary:(NSMutableDictionary *)object];
    }
}


@end
