//
// Created by Todd Brannam on 2/24/15.
//

#import "PSDKVOArrayDataSource.h"
#import "PSDDataSource+Private.h"
#import "PSDArrayController.h"

@interface PSDKVOArrayDataSource()
@property (nonatomic,strong) NSArray *arrayControllers;
@end


@implementation PSDKVOArrayDataSource

- (id)initWithArrayControllers:(NSArray*)arrayControllers
{
    self = [super init];

    NSMutableArray *sections = [NSMutableArray array];
    self.arrayControllers = arrayControllers;

    for (PSDArrayController *arrayController in arrayControllers) {
        PSDDataSourceSectionInfo *sectionInfo = [[PSDDataSourceSectionInfo alloc] init];
        sectionInfo.objects = (NSMutableArray *)arrayController.array;
        [arrayController addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void*)sectionInfo];
        [arrayController addObserver:self forKeyPath:@"mutating" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void*)sectionInfo];
        [sections addObject:sectionInfo];
    }

    self.sections = sections;

    return self;
}

-(void)dealloc {
    for (PSDArrayController *arrayController in self.arrayControllers) {
        [arrayController removeObserver:self forKeyPath:@"array"];
        [arrayController removeObserver:self forKeyPath:@"mutating"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"mutating"]) {

        BOOL isMutating = [change[NSKeyValueChangeNewKey] boolValue];
        if (isMutating) {
            for (id <PSDDataSourceDelegate> delegate in self.delegates) {
                [delegate dataSourceWillChangeContent:self];
            }
        } else {
            for (id <PSDDataSourceDelegate> delegate in self.delegates) {
                [delegate dataSourceDidChangeContent:self];
            }
        }
    }

    if ([keyPath isEqualToString:@"array"]) {

        NSIndexSet *indices = change[NSKeyValueChangeIndexesKey];
        if (indices == nil)
            return; // Nothing to do


        // Build index paths from index sets
        NSUInteger indexCount = [indices count];
        NSUInteger buffer[indexCount];
        [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];

        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (int i = 0; i < indexCount; i++) {
            NSUInteger indexPathIndices[2];
            indexPathIndices[0] = 0;  // associate CONTEXT with current section
            indexPathIndices[1] = buffer[i];
            NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
            [indexPathArray addObject:newPath];
        }

        for (NSIndexPath * indexPath in indexPathArray){

            NSNumber *kind = change[NSKeyValueChangeKindKey];
            if ([kind integerValue] == NSKeyValueChangeInsertion) { // Rows were added
                for (id <PSDDataSourceDelegate> delegate in self.delegates) {

                    [delegate dataSource:self didChangeObject:nil atIndexPath:nil forChangeType:PSDDataSourceChangeInsert newIndexPath:indexPath];
                }
            }
            else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
            {
                for (id <PSDDataSourceDelegate> delegate in self.delegates) {
                    [delegate dataSource:self didChangeObject:nil atIndexPath:indexPath forChangeType:PSDDataSourceChangeDelete newIndexPath:nil];
                }
            }
            else if ([kind integerValue] == NSKeyValueChangeReplacement)  // Rows were updates
            {
                for (id <PSDDataSourceDelegate> delegate in self.delegates) {
                    [delegate dataSource:self didChangeObject:nil atIndexPath:indexPath forChangeType:PSDDataSourceChangeUpdate newIndexPath:nil];
                }
            }
        }
    }

}


- (void)load
{
}

- (void)reset
{
}

- (BOOL)more
{
    return NO;
}

- (BOOL)performFetch:(NSError **)aError {
    return YES;
}


#pragma mark - Overrides

- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [self.sections[indexPath.section] objects][indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {

    for (NSUInteger ii = 0; ii < [self numberOfSections]; ii++ ) {
        id<PSDDataSourceSectionInfo> section = self.sections[ii];

        for (NSUInteger jj = 0; jj < [[section objects] count]; jj++ )
        {
            if (object == section.objects[jj]){
                return [NSIndexPath indexPathForRow:jj inSection:ii];
            }
        }
    }

    return nil;
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}


- (NSInteger)numberOfItemsInSection:(NSUInteger)section
{
    return [[self.sections[section] objects] count];
}

@end