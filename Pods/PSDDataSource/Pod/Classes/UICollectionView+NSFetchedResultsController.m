//
//  UICollectionView+NSFetchedResultsController.m
//  Explorer
//
//  Created by Bob Ward on 2/6/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import "UICollectionView+NSFetchedResultsController.h"
#import <objc/runtime.h>

@interface UICollectionView (ChangesInternal)
@property (strong, nonatomic, readonly) NSMutableArray *sectionChanges;
@property (strong, nonatomic, readonly) NSMutableArray *objectChanges;
@end

@implementation UICollectionView (NSFetchedResultsController)

- (void)beginChanges
{
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

- (void)addChangeForSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        default:
            break;
    }
    
    [self.sectionChanges addObject:change];
}

- (void)addChangeForObjectAtIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}

- (void)commitChanges
{
    if ([self.sectionChanges count] > 0)
    {
        [self performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        default:
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            //NSLog(@"finished updating sections!");
        }];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        if ([self shouldReloadCollectionViewToPreventKnownIssue]) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self reloadData];
            
        } else {
            [self performBatchUpdates:^{
                
                for (NSDictionary *change in self.objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
        
    }
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSIndexPath *indexPath = obj;  //not if type == changeMove
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            if  (((type == NSFetchedResultsChangeInsert ) && ([self numberOfItemsInSection:indexPath.section] == 0)) ||
                 ((type == NSFetchedResultsChangeDelete ) && ([self numberOfItemsInSection:indexPath.section] == 1))){
                shouldReload = YES; *stop = YES; return;
            }
        }];
    }
    return shouldReload;
}
#pragma mark - changes arrays

- (NSMutableArray *)sectionChanges
{
    static char kSectionChangesKey;
    NSMutableArray *sectionChanges = objc_getAssociatedObject(self, &kSectionChangesKey);
    if (sectionChanges == nil) {
        sectionChanges = [NSMutableArray array];
        objc_setAssociatedObject(self, &kSectionChangesKey, sectionChanges, OBJC_ASSOCIATION_RETAIN);
    }
    return sectionChanges;
}

- (NSMutableArray *)objectChanges
{
    static char kObjectChangesKey;
    NSMutableArray *objectChanges = objc_getAssociatedObject(self, &kObjectChangesKey);
    if (objectChanges == nil) {
        objectChanges = [NSMutableArray array];
        objc_setAssociatedObject(self, &kObjectChangesKey, objectChanges, OBJC_ASSOCIATION_RETAIN);
    }
    return objectChanges;
}
@end
