//
//  PSDDataSource.h
//
//  Created by Bob Ward on 12/17/13.
//  Copyright (c) 2013 Perfect Sense Digital, LLC All rights reserved.
//

// Strict definition of the data source


@class PSDDataSource;

@protocol PSDDataSourceContainer <NSObject>
@required
@property (nonatomic, strong) PSDDataSource *dataSource;
@end

#import <CoreData/NSFetchedResultsController.h>
@protocol PSDDataSourceDelegate;

@protocol PSDDataSource <NSObject>

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, getter=hasMore) BOOL more;
@property (nonatomic, assign) NSUInteger pageSize; // default 20
@property (nonatomic, assign) BOOL unreadOnly; // default NO

@property (nonatomic, strong) NSDictionary *contentParams;
@property (nonatomic, strong, readonly) NSArray *sections;

@property (nonatomic, assign) id<PSDDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *itemType;

- (id)init;

- (void)load;
- (void)reset;

- (NSUInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSUInteger)section;
- (NSArray*) allIndexPaths;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSString *)titleForFooterInSection:(NSInteger)section;

- (BOOL)performFetch:(NSError **)error;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;

@end

// Baseline implemenation
@interface PSDDataSource : NSObject<PSDDataSource, UITableViewDataSource, UICollectionViewDataSource>
{
}

@property (nonatomic, strong) NSDictionary *contentParams;

@property (nonatomic, assign) NSUInteger pageSize; // default 20
@property (nonatomic, assign) BOOL unreadOnly; // default NO
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, getter=hasMore) BOOL more;

@property (nonatomic, strong) NSString *itemType;

@property (nonatomic, assign) id<PSDDataSourceDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray *sections;

- (id)init;

- (void)load; // think about changing to load
- (void)reset;  // this should be more like reset -- which perhaps suggests a subsequent call to loadMore would be required

- (BOOL)performFetch:(NSError **)error;

- (void)addDelegate:(id<PSDDataSourceDelegate>)aDelegate;
- (void)removeDelegate:(id<PSDDataSourceDelegate>)aDelegate;


- (NSUInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSUInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *)indexPathForObject:(id)object;
- (NSArray*) allIndexPaths;

//@optional  // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSString *)titleForFooterInSection:(NSInteger)section;

// UITableViewDelegate Helper
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;


/// Measure variable height cells. Variable height cells are not supported when there is more than one column. The goal here is to do the minimal necessary configuration to get the correct size information.
- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath;

/// Determine whether or not a cell is editable. Default implementation returns YES.
- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath;

/// Determine whether or not the cell is movable. Default implementation returns NO.
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

/// Determine whether an item may be moved from its original location to a proposed location. Default implementation returns NO.
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/// Called by the collection view to alert the data source that an item has been moved. The data source should update its contents.
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath;


@end

//#ifdef _COREDATADEFINES_H
@protocol PSDDataSourceSectionInfo <NSFetchedResultsSectionInfo>
@end
//#else
//@protocol PSDDataSourceSectionInfo
//@end
//#endif

@protocol PSDDataSourceSectionInfoObjectProtocol <NSObject>
@property (nonatomic, readonly, assign) NSUInteger sortIndex;
@end

@interface PSDDataSourceSectionInfo : NSObject <PSDDataSourceSectionInfo, PSDDataSourceSectionInfoObjectProtocol>
{
    NSString *_name;
    NSString *_indexTitle;
    NSUInteger _numberOfObjects;
    NSMutableArray *_objects;
    NSUInteger _sortIndex;
}

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) NSString *indexTitle;
@property (nonatomic, readonly, assign) NSUInteger numberOfObjects;
@property (nonatomic, readonly, assign) NSUInteger sortIndex;

@end



@interface PSDDataSourceSectionInfo(Collections)
@property (nonatomic, readonly, strong) NSArray *objects;       // objects must conform to
@end


// interface and heuristics are modeled after NSFetchedResultsControllerDelegate

//#ifndef _COREDATADEFINES_H
//
//@protocol NSFetchedResultsSectionInfo
//
///* Name of the section
// */
//@property (nonatomic, readonly) NSString *name;
//
///* Title of the section (used when displaying the index)
// */
//@property (nonatomic, readonly) NSString *indexTitle;
//
///* Number of objects in section
// */
//@property (nonatomic, readonly) NSUInteger numberOfObjects;
//
///* Returns the array of objects in the section.
// */
//@property (nonatomic, readonly) NSArray *objects;
//
//@end // NSFetchedResultsSectionInfo
//
//
//enum {
//	NSFetchedResultsChangeInsert = 1,
//	NSFetchedResultsChangeDelete = 2,
//	NSFetchedResultsChangeMove = 3,
//	NSFetchedResultsChangeUpdate = 4
//
//};
//typedef NSUInteger NSFetchedResultsChangeType;
//#endif


@protocol PSDDataSourceDelegate<NSObject>

enum {
    PSDDataSourceChangeInsert = NSFetchedResultsChangeInsert,
    PSDDataSourceChangeDelete = NSFetchedResultsChangeDelete,
    PSDDataSourceChangeMove = NSFetchedResultsChangeMove,
    PSDDataSourceChangeUpdate = NSFetchedResultsChangeUpdate
};

typedef NSUInteger PSDDataSourceChangeType;

@optional
- (void)dataSource:(PSDDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(PSDDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

@optional
- (void)dataSource:(PSDDataSource *)dataSource didChangeSection:(id <PSDDataSourceSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(PSDDataSourceChangeType)type;

@optional
- (void)dataSourceWillChangeContent:(PSDDataSource *)dataSource;

@optional
- (void)dataSourceDidChangeContent:(PSDDataSource *)dataSource;

@optional
- (NSString *)dataSource:(PSDDataSource *)dataSource sectionIndexTitleForSectionName:(NSString *)sectionName;

@end


