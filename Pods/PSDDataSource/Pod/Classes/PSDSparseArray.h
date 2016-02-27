//
//  PSDSparseArray.h
//  Ubik
//
//  Created by Todd Brannam on 4/1/15.
//  Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSDSparseArray : NSMutableArray
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
@end
