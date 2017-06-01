//
//  UITableView+PSDDataSource.h
//  Explorer
//
//  Created by Bob Ward on 2/4/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString* (^CellIdentifierBlock)(NSObject *aObject);


@interface UITableView (PSDDataSource)

typedef UITableViewCell* (^TableCellForItemAtIndexPathBlock)(UITableView *tableView, id aObject, NSIndexPath *indexPath);

- (void)registerCellConfigureBlock:(void(^)(id cell, id aObject)) aConfigureBlock forCellReuseIdentifier:(NSString *)aCellIdentifier;

- (void(^)(UITableViewCell *cell, NSObject*aObject)) cellConfigureBlockForIdentifier:(NSString *)aIdentifier;
- (NSString *)cellIdentifierForItem:(NSObject *)aItem;

- (void)setCellForItemAtIndexPathBlock:(TableCellForItemAtIndexPathBlock)aBlock;
- (TableCellForItemAtIndexPathBlock)cellForItemAtIndexPathBlock;

- (void)setCellIdentifierBlock:(CellIdentifierBlock)aBlock;
- (CellIdentifierBlock)cellIdentifierBlock;

@end
