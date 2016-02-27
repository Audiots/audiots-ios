//
// Created by Todd Brannam on 2/24/15.
// Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDDataMerge.h"

@interface PSDArrayController : NSObject<PSDDataMerge>

- (instancetype)initWithMutableArray:(NSMutableArray *)mutableArray;

@property (nonatomic, readonly) NSArray *array;
@property (nonatomic, readonly, getter=isMutating) BOOL mutating;

-(NSUInteger)countOfArray;

-(id)objectInArrayAtIndex:(NSUInteger)index;

-(void)insertObject:(id)object inArrayAtIndex:(NSUInteger)index;

-(void)removeObjectFromArrayAtIndex:(NSUInteger)index;

-(void)replaceObjectInArrayAtIndex:(NSUInteger)index withObject:(id)object;


@end
