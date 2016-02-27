//
//  UICollectionView+NSFetchedResultsController.h
//  Explorer
//
//  Created by Bob Ward on 2/6/14.
//  Copyright (c) 2014 Perfect Sense Digital, LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSDCoreDataSource.h"

@interface UICollectionView (NSFetchedResultsController)
- (void)beginChanges;
- (void)addChangeForSection:(id <PSDDataSourceSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
- (void)addChangeForObjectAtIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)commitChanges;
@end
