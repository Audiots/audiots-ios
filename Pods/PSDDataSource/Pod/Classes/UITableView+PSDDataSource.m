//
//  UITableView+PSDDataSource.m
//  Explorer
//
//  Created by Bob Ward on 2/4/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import "UITableView+PSDDataSource.h"
#import <objc/runtime.h>

@interface UITableView ()
@property (nonatomic) NSMutableDictionary *blockMap;
@property (nonatomic) NSMutableDictionary *headerFooterBlockMap;
@property (nonatomic) NSMutableDictionary *headerFooterDataClassMap;
@end

@implementation UITableView (PSDDataSource)

- (void)registerCellConfigureBlock:(void(^)(id cell, id aObject)) aConfigureBlock forCellReuseIdentifier:(NSString *)aCellIdentifier;
{
    [self.blockMap setObject:[aConfigureBlock copy] forKey:aCellIdentifier];
}

- (void(^)(UITableViewCell *cell, NSObject*aObject)) cellConfigureBlockForItem:(NSObject *)aItem
{
    return [self.blockMap objectForKey:NSStringFromClass([aItem class])];
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

- (void(^)(UITableViewCell *cell, NSObject*aObject)) cellConfigureBlockForIdentifier:(NSString *)aIdentifier
{
    return [self.blockMap objectForKey:aIdentifier];
}


- (void)setCellForItemAtIndexPathBlock:(TableCellForItemAtIndexPathBlock)aBlock
{
    objc_setAssociatedObject(self, @selector(cellForItemAtIndexPathBlock), [aBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TableCellForItemAtIndexPathBlock)cellForItemAtIndexPathBlock
{
    TableCellForItemAtIndexPathBlock result = objc_getAssociatedObject(self, @selector(cellForItemAtIndexPathBlock));
    return result;
}


//- (void(^)(UIView *headerFooterView, NSObject*aObject)) headerfooterConfigureBlockForItem:(NSObject *)aItem
//{
//  return [self.headerFooterBlockMap objectForKey:NSStringFromClass([aItem class])];
//}
//
//- (NSString *)headerFooterIdentifierForItem:(NSObject *)aItem
//{
//  return [self.headerFooterDataClassMap objectForKey:NSStringFromClass([aItem class])];
//}


- (NSMutableDictionary *)blockMap {
    NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(blockMap));
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(blockMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSMutableDictionary *)headerFooterBlockMap {
    NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(headerFooterBlockMap));
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(headerFooterBlockMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSMutableDictionary *)headerFooterDataClassMap {
    NSMutableDictionary *result = objc_getAssociatedObject(self, @selector(headerFooterDataClassMap));
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(headerFooterDataClassMap), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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


@end
