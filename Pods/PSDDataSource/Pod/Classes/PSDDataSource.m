//
//  PSDDataSource.m
//
//  Created by Bob Ward on 12/13/13.
//  Copyright (c) 2013 Perfect Sense Digital, LLC All rights reserved.
//

/** @class PSDDataSource - base class modeling basic implementation a datasource compatible with UITableView and UICollectionView
 * This class interacts much like a NSFetchedResultsController - but isn't especially tied to CoreData
 */


#import "PSDDataSource.h"
#import "PSDDataSource+Private.h"
#import "UITableView+PSDDataSource.h"
#import "UICollectionView+PSDDataSource.h"

@implementation PSDDataSourceSectionInfo
@synthesize name = _name;
@synthesize indexTitle = _indexTitle;
@synthesize numberOfObjects = _numberOfObjects;
@synthesize objects = _objects;
@synthesize sortIndex = _sortIndex;

-(id)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@: %p, (%@)>", NSStringFromClass([self class]), self, self.name];
}

- (NSUInteger)numberOfObjects{
    return [[self objects] count];
}
@end



@implementation PSDDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)load{
    self.loading = NO;
    self.more = YES;
}

- (void)reset{
    self.loading = NO;
    self.more = YES;
}

- (BOOL)performFetch:(NSError **)error
{
    return YES;
}

- (void)addDelegate:(id<PSDDataSourceDelegate>)aDelegate
{
    [self.delegates addObject:aDelegate];
}

- (void)removeDelegate:(id<PSDDataSourceDelegate>)aDelegate
{
    [self.delegates removeObject:aDelegate];
}

- (void)setDelegate:(id<PSDDataSourceDelegate>)delegate {
    
    [self.delegates removeObject:_delegate];
    _delegate = delegate;
    [self.delegates addObject:_delegate];
}


#pragma mark - PSDDataSource primitives

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSUInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return 0;
}

- (NSArray*) allIndexPaths
{
    NSMutableArray* theArray = [[NSMutableArray alloc] init];
    for (NSUInteger sectionIndex=0; sectionIndex < self.numberOfSections; sectionIndex++)
    {
        for (NSUInteger rowIndex=0; rowIndex < [self numberOfItemsInSection: sectionIndex]; rowIndex++)
        {
            [theArray addObject: [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
        }
    }
    return theArray;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(NSIndexPath *)indexPathForObject:(id)object
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

- (NSArray *) sectionIndexTitles
{
    return [self.sections valueForKeyPath:@"indexTitle"];
}

//- (NSInteger) sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//  return 0;
//}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *)titleForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDataSource

//@required
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *item = [self objectAtIndexPath:indexPath];

    // if collectionView.cellForItem:item atIndexPath:indexPath
    if (tableView.cellForItemAtIndexPathBlock) {
        return tableView.cellForItemAtIndexPathBlock(tableView, item, indexPath);
    }
    else {
        NSString *cellIdentifier = [tableView cellIdentifierForItem:item];
        void(^block)(UITableViewCell *cell, NSObject *aObject) = [tableView cellConfigureBlockForIdentifier:cellIdentifier];

        NSAssert(block && cellIdentifier,
                @"block && cellIdentifier must be defined in order to utilize tablieView:cellForRowAtIndexPath");

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                forIndexPath:indexPath];
        if (block)
            block(cell, item);

        return cell;
    }
}

//@optional
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

//@optional  // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

//@optional
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
// @optional - override surprisingly default YES return value
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - UITableViewDelegate Helper
// UITableViewDelegate Helper
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
// @optional
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Index

//@optional
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
//@optional
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support
//@optional
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;


#pragma mark - UICollectionViewDataSource

//@required
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//@required
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *item = [self objectAtIndexPath:indexPath];

    // if collectionView.cellForItem:item atIndexPath:indexPath
    if (collectionView.cellForItemAtIndexPathBlock) {
        return collectionView.cellForItemAtIndexPathBlock(collectionView, item, indexPath);
    } else {
        NSString *cellIdentifier = [collectionView cellIdentifierForItem:item];
        void(^block)(id cell, NSObject*aObject) = [collectionView cellConfigureBlockForIdentifier:cellIdentifier];
        
        NSAssert(block && cellIdentifier,
                 @"block && cellIdentifier must be defined in order to utilize tablieView:cellForRowAtIndexPath");
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (block)
            block(cell, item);
        
        return cell;
    }
}

// @optional
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSections];
}


- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
// @optional
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end


