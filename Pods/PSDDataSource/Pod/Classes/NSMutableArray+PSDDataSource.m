//
// Created by Todd Brannam on 2/24/15.
// Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import "NSMutableArray+PSDDataSource.h"

@implementation NSMutableArray (PSDDataSource)

- (void)psdMerge:(NSObject *)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        [self psdMergeWithArray:(NSArray *) obj];
    }
}

- (void)psdMergeWithArray:(NSArray *)array
{
    NSInteger index = 0;
    NSInteger initialCount = self.count;

    for (NSObject<PSDDataMerge> *sourceEntry in array) {

        if (index < initialCount) {
            NSObject<PSDDataMerge> *destinationEntry = [self objectAtIndex:index];
            if ([sourceEntry respondsToSelector:@selector(psdMerge:)] && [destinationEntry respondsToSelector:@selector(psdMerge:)]) {
                [destinationEntry psdMerge:sourceEntry];
            } else {
                [self addObject:sourceEntry];
            }
        } else {
            [self addObject:sourceEntry];
        }
        index++;
    }
}


@end