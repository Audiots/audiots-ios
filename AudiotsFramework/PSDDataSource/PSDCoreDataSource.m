//
//  PSDCoreDataSource.m
//
//  Created by Bob Ward on 12/19/13.
//  Copyright (c) 2013 Perfect Sense Digital, LLC All rights reserved.
//

//#ifdef _COREDATADEFINES_H
#import <CoreData/CoreData.h>
#import "PSDCoreDataSource.h"
#import "PSDDataSource+Private.h"
#import "PSDCoreDataSource+Private.h"

@interface PSDCoreDataSource()
//@property (nonatomic, readwrite) NSArray *sections;
@end

@implementation PSDCoreDataSource

@synthesize delegate = _delegate;

- (id)initWithFetchRequest:(NSFetchRequest*)fetchRequest
      managedObjectContext:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    self = [super init];
    if (self)
    {
        self.fetchRequest = fetchRequest;
        self.context = context;
        self.sectionNameKeyPath = sectionNameKeyPath;
    }
    return self;
}


// can we keep this object hidden - that's the idea
-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:self.sectionNameKeyPath
                                                                                   cacheName:nil];
        
        
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)load
{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
    }
}


- (void)reset
{
}

- (BOOL)performFetch:(NSError **)aError {
    
    NSError *error = nil;
    BOOL success = [[self fetchedResultsController] performFetch:&error];
    if (error) {
        NSLog(@"%s error:%@", __PRETTY_FUNCTION__, error);
        *aError = error;
    }
    
    return success;
}


#pragma mark - Overrides

- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.fetchedResultsController indexPathForObject:object];
}

- (NSUInteger)numberOfSections {
    
    return [[[self fetchedResultsController] sections] count];
}


- (NSInteger)numberOfItemsInSection:(NSUInteger)section
{
    if ([[[self fetchedResultsController] sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return 0;
    }
}


-(NSArray *)sections
{
    return [self.fetchedResultsController sections];
}

#pragma mark - <NSFetchedResultsControllerDelegate>

// Translate delegate calls to our delegate prototype

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    id<PSDDataSourceDelegate> delegate = nil;
    
    for (delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSource:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [delegate dataSource:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    id<PSDDataSourceDelegate> delegate = nil;
    
    for (delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSource:didChangeSection:atIndex:forChangeType:)]) {
            [delegate dataSource:self didChangeSection:(id <PSDDataSourceSectionInfo>)sectionInfo atIndex:sectionIndex forChangeType:type];
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    id<PSDDataSourceDelegate> delegate = nil;
    
    for (delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSourceWillChangeContent:)]) {
            [delegate dataSourceWillChangeContent:self];
        }
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    id<PSDDataSourceDelegate> delegate = nil;
    
    for (delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSourceDidChangeContent:)])
        {
            [delegate dataSourceDidChangeContent:self];
        };
    }
}


#pragma mark - <UITableViewDataSource>

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject* object = [self objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [object managedObjectContext];
        [context deleteObject:object];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"%s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        }
    }
}

@end

//#endif

