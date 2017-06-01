//
//  UICollectionView+PSDDataSource.m
//  Explorer
//
//  Created by Bob Ward on 2/6/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import "UICollectionView+PSDDataSource.h"
#import <objc/runtime.h>



@interface UICollectionView ()
@property (nonatomic) NSMutableDictionary *blockMap;
//@property (nonatomic) NSMutableDictionary *dataClassMap;
@property (nonatomic) CellIdentifierBlock cellIdentifierBlock;
//@property (nonatomic) NSMutableDictionary *headerFooterBlockMap;
//@property (nonatomic) NSMutableDictionary *headerFooterDataClassMap;
@end

@implementation UICollectionView (PSDDataSource)

- (void)registerCellConfigureBlock:(void(^)(id cell, id aObject)) aConfigureBlock forCellReuseIdentifier:(NSString *)aCellIdentifier
{
    [self.blockMap setObject:[aConfigureBlock copy] forKey:aCellIdentifier];
}

- (void(^)(UICollectionViewCell *cell, NSObject*aObject)) cellConfigureBlockForIdentifier:(NSString *)aIdentifier
{
    return [self.blockMap objectForKey:aIdentifier];
}

- (NSString *)cellIdentifierForItem:(NSObject *)aItem
{
    CellIdentifierBlock block = [self cellIdentifierBlock];
    NSString *identifier = NSStringFromClass([aItem class]);
    
    if (block == nil) {
        NSLog(@"block empty");
    }
    
    if (block)
    {
        identifier = block(aItem);
    }
    
    return identifier;
}



- (NSMutableDictionary *)blockMap {
    NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(blockMap));
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(blockMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}


- (void)setCellIdentifierBlock:(CellIdentifierBlock)aBlock
{
    objc_setAssociatedObject(self, @selector(cellIdentifierBlock), [aBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CellIdentifierBlock)cellIdentifierBlock
{
    CellIdentifierBlock result = objc_getAssociatedObject(self, @selector(cellIdentifierBlock));
    return result;
}


- (void)setCellForItemAtIndexPathBlock:(CellForItemAtIndexPathBlock)aBlock
{
    objc_setAssociatedObject(self, @selector(cellForItemAtIndexPathBlock), [aBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CellForItemAtIndexPathBlock)cellForItemAtIndexPathBlock
{
    CellForItemAtIndexPathBlock result = objc_getAssociatedObject(self, @selector(cellForItemAtIndexPathBlock));
    return result;
}


//- (NSMutableDictionary *)headerFooterBlockMap {
//  NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(headerFooterBlockMap));
//  if (result == nil) {
//    result = [NSMutableDictionary dictionary];
//    objc_setAssociatedObject(self, @selector(headerFooterBlockMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//  }
//  return result;
//}
//
//- (NSMutableDictionary *)headerFooterDataClassMap {
//  NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(headerFooterDataClassMap));
//  if (result == nil) {
//    result = [NSMutableDictionary dictionary];
//    objc_setAssociatedObject(self, @selector(headerFooterDataClassMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//  }
//  return result;
//}

@end
