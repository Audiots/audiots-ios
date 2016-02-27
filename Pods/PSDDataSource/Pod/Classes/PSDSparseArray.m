//
//  PSDSparseArray.m
//  Ubik
//
//  Created by Todd Brannam on 4/1/15.
//  Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import "PSDSparseArray.h"

@interface PSDSparseArray ()
@property (nonatomic, strong) NSPointerArray *storage;
@end

@implementation PSDSparseArray

- (instancetype)init;
{
    if ((self = [super init])) {
        _storage = [NSPointerArray strongObjectsPointerArray];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems;
{
    if ((self = [super init])) {
        _storage = [NSPointerArray strongObjectsPointerArray];
        
        [_storage setCount:MAX((NSInteger)numItems - 1, 0)];
    }
    return self;
}

#pragma mark - NSArray primitive methods

- (NSUInteger)count;
{
    return [_storage count];
}

- (id)objectAtIndex:(NSUInteger)index;
{
    return [_storage pointerAtIndex:index];
}

#pragma mark - NSMutableArray primitive methods

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (index >= [_storage count]) {
        [_storage setCount:index+1];
        [_storage replacePointerAtIndex: index withPointer:(__bridge void *)anObject];
    } else {
        [_storage insertPointer:(__bridge void *)anObject atIndex:index];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index;
{
    [_storage removePointerAtIndex:index];
}

- (void)addObject:(id)anObject;
{
    [_storage addPointer:(__bridge void *)anObject];
}

- (void)removeLastObject;
{
    [_storage removePointerAtIndex:[_storage count]];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index >= [_storage count])
        [_storage setCount:index+1];
    
    [_storage replacePointerAtIndex:index withPointer:(__bridge void *)anObject];
}

#pragma mark - Subscript Overrides

// Avoids NSRangeException thrown in setObject:atIndex: (Private?)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    [self replaceObjectAtIndex:idx withObject:obj];
}

// Don't need to override but it's nice to be sure
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

@end