//
//  UICollectionView+PSDDataSource.h
//  Explorer
//
//  Created by Bob Ward on 2/6/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString* (^CellIdentifierBlock)(NSObject *aObject);

typedef UICollectionViewCell* (^CellForItemAtIndexPathBlock)(UICollectionView *collectionView, id aObject, NSIndexPath *indexPath);

@interface UICollectionView (PSDDataSource)
- (void)registerCellConfigureBlock:(void(^)(id cell, id aObject)) aConfigureBlock forCellReuseIdentifier:(NSString *)aCellIdentifier;

- (void(^)(UICollectionViewCell *cell, NSObject*aObject)) cellConfigureBlockForIdentifier:(NSString *)aIdentifier;
- (NSString *)cellIdentifierForItem:(NSObject *)aItem;

- (void)setCellIdentifierBlock:(CellIdentifierBlock)aBlock;
- (CellIdentifierBlock)cellIdentifierBlock;

- (void)setCellForItemAtIndexPathBlock:(CellForItemAtIndexPathBlock)aBlock;
- (CellForItemAtIndexPathBlock)cellForItemAtIndexPathBlock;

//- (void(^)(UIView *headerFooterView, NSObject*aObject)) headerfooterConfigureBlockForItem:(NSObject *)aItem;
//- (NSString *)headerFooterIdentifierForItem:(NSObject *)aItem;
@end
