//
//  PSDCompoundDataSource.m
//  Pods
//
//  Created by Bob Ward on 7/2/14.
//
//

#import "PSDCompoundDataSource.h"
#import "PSDDataSource+Private.h"

@interface PSDCompoundDataSource()<PSDDataSourceDelegate>
@property (nonatomic, strong) NSArray *dataSources;
@property (nonatomic, strong) NSMutableArray *sections;
@end

// each data source provided implements a section with a one-dimentional datasource

@implementation PSDCompoundDataSource

@synthesize sections;

- (instancetype)initWithDataSources:(NSArray*)dataSources
{
    self = [super init];
    
    self.dataSources = [dataSources copy];
    
    self.sections = [[NSMutableArray alloc] init];
    
    for (PSDDataSource *dataSource in dataSources) {
        NSError *error = nil;
        [dataSource performFetch:&error];
        
        // add sections from sections of contained data sources
        [self.sections addObjectsFromArray:dataSource.sections];
        
        [dataSource addDelegate:self];
    }
    
    return self;
}

#pragma mark - PSDDataSoure primatives

-(void)dealloc {
    
    for (PSDDataSource *dataSource in self.dataSources) {
        [dataSource removeDelegate:self];
    }
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSUInteger)section
{
    NSUInteger offset = 0;
    PSDDataSource *sectionSource = [self dataSourceForSection:section offset:&offset];
    
    // FIXME: datasources should be allowed to implement multiple sections
    return [sectionSource numberOfItemsInSection:offset];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger offset = 0;
    PSDDataSource *sectionSource = [self dataSourceForSection:indexPath.section offset:&offset];
    return [sectionSource objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
}

-(NSIndexPath *)indexPathForObject:(id)object
{
    NSUInteger sectionCount = self.sections.count;
    
    for (NSUInteger ii = 0; ii < sectionCount; ii++) {
        NSUInteger rowCount = [self.sections[ii] numberOfObjects];
        NSArray *objects = [self.sections[ii] objects];
        for (NSUInteger jj = 0; jj < rowCount; jj++) {
            if (objects[jj] == object)
                return [NSIndexPath indexPathForRow:jj inSection:ii];
        }
    }
    return nil;
}

- (NSUInteger)mapDataSource:(PSDDataSource *)childDataSource childSectionIndex:(NSUInteger)childSectionIndex
{
    NSUInteger comboSectionCount = 0;
    
    for (PSDDataSource *dataSource in self.dataSources) {
        
        if (dataSource == childDataSource) {
            return 1 + comboSectionCount + childSectionIndex - dataSource.sections.count ;
        }
        
        comboSectionCount += dataSource.sections.count;
    }
    
    NSAssert(0, @"%s: could not find datasource", __PRETTY_FUNCTION__);
    return 0;
}


- (NSIndexPath *)mapDataSource:(PSDDataSource *)dataSource childIndexPath:(NSIndexPath *)sourceIndexPath
{
    NSUInteger comboSectionIndex = [self mapDataSource:dataSource childSectionIndex:sourceIndexPath.section];
    return [NSIndexPath indexPathForRow:sourceIndexPath.row inSection:comboSectionIndex];
}


- (PSDDataSource *)dataSourceForSection:(NSUInteger)sectionIndex offset:(NSUInteger*)offset;
{
    NSUInteger comboSectionCount = 0;
    NSUInteger index = sectionIndex;
    
    for (PSDDataSource *dataSource in self.dataSources) {
        
        comboSectionCount += dataSource.sections.count;
        
        if (comboSectionCount > sectionIndex) {
            *offset = index;
            return dataSource;
        }
        
        index -= dataSource.sections.count;
        
    }
    
    return nil;
}

- (void)dataSource:(PSDDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)childIndexPath forChangeType:(PSDDataSourceChangeType)type newIndexPath:(NSIndexPath *)newChildIndexPath
{
    
    switch (type) {
        case PSDDataSourceChangeInsert:
            newChildIndexPath = [self mapDataSource:dataSource childIndexPath:newChildIndexPath];
            break;
        case PSDDataSourceChangeMove:
            newChildIndexPath = [self mapDataSource:dataSource childIndexPath:newChildIndexPath];
            childIndexPath = [self mapDataSource:dataSource childIndexPath:childIndexPath];
            break;
            
        default:
            childIndexPath = [self mapDataSource:dataSource childIndexPath:childIndexPath];
            break;
    }
    
    for (id<PSDDataSourceDelegate> delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSource:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [delegate dataSource:self didChangeObject:anObject atIndexPath:childIndexPath forChangeType:type newIndexPath:newChildIndexPath];
        }
    }
}

- (void)dataSource:(PSDDataSource *)dataSource didChangeSection:(id <PSDDataSourceSectionInfo>)sectionInfo atIndex:(NSUInteger)childSectionIndex forChangeType:(PSDDataSourceChangeType)type
{
    NSUInteger comboSectionIndex = NSUIntegerMax;
    
    // map index path of contained object into the index path of the combodatasource
    switch (type) {
        case PSDDataSourceChangeDelete:
            comboSectionIndex = [self.sections indexOfObject:sectionInfo];
            [self.sections removeObject:sectionInfo];
            // remove from self.sections;
            break;
        case PSDDataSourceChangeInsert:
            comboSectionIndex = [self mapDataSource:dataSource childSectionIndex:childSectionIndex];
            [self.sections insertObject:sectionInfo atIndex:comboSectionIndex];
            // insert into self.sections;
            break;
        default:
            break;
    }
    
    if (comboSectionIndex != NSUIntegerMax) {
        for (id<PSDDataSourceDelegate> delegate in self.delegates) {
            if (delegate && [delegate respondsToSelector:@selector(dataSource:didChangeSection:atIndex:forChangeType:)]) {
                [delegate dataSource:self didChangeSection:sectionInfo atIndex:comboSectionIndex forChangeType:type];
            }
        }
    }
}


- (void)dataSourceWillChangeContent:(PSDDataSource *)dataSource
{
    for (id<PSDDataSourceDelegate> delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSourceWillChangeContent:)]) {
            [delegate dataSourceWillChangeContent:self];
        }
    }
}


- (void)dataSourceDidChangeContent:(PSDDataSource *)dataSource
{
    for (id<PSDDataSourceDelegate> delegate in self.delegates) {
        if (delegate && [delegate respondsToSelector:@selector(dataSourceDidChangeContent:)]) {
            [delegate dataSourceDidChangeContent:self];
        }
    }
}

- (NSString *)dataSource:(PSDDataSource *)dataSource sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return nil;
}


@end
