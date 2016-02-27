//
//  PSDCollectionViewController.m
//  Pods
//
//  Created by Todd Brannam on 10/7/14.
//
//

#import "PSDCollectionViewController.h"
#import "PSDDataSource.h"
#import "UICollectionView+NSFetchedResultsController.h"

@interface PSDCollectionViewController()<PSDDataSourceDelegate>
@end

@implementation PSDCollectionViewController

#pragma mark - PSDDataSource

-(void)setDataSource:(PSDDataSource *)dataSource {
    if (dataSource != _dataSource) {
        [_dataSource removeDelegate:self];
        _dataSource = dataSource;
        [_dataSource addDelegate:self];
    }
}

// Use Class Extension to implement change managment
- (void)dataSourceWillChangeContent:(PSDDataSource *)dataSource {
    if (self.collectionView.dataSource == dataSource) {
        [self.collectionView beginChanges];
    }
}

- (void)dataSource:(PSDDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(PSDDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (self.collectionView.dataSource == dataSource) {
        [self.collectionView addChangeForObjectAtIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)dataSource:(PSDDataSource *)dataSource didChangeSection:(id <PSDDataSourceSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(PSDDataSourceChangeType)type {
    if (self.collectionView.dataSource == dataSource) {
        [self.collectionView addChangeForSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

- (void)dataSourceDidChangeContent:(PSDDataSource *)dataSource {
    if (self.collectionView.dataSource == dataSource) {
        [self.collectionView commitChanges];
    }
}

@end
