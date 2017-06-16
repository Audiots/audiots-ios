//
//  PSDArrayDataSource.m
//  Pods
//
//  Created by Todd Brannam on 10/7/14.
//
//

#import "PSDArrayDataSource.h"
#import "PSDDataSource+Private.h"

@implementation PSDArrayDataSource

- (id)initWithSections:(NSArray *)sections
{
    self = [super init];
    
    if (self) {
        self.sections = [sections mutableCopy];
    }
    return self;
}

- (id)initWithObjects:(NSArray*)objects
{
    PSDDataSourceSectionInfo *sectionInfo = [[PSDDataSourceSectionInfo alloc] init];
    sectionInfo.objects = [objects mutableCopy];
    self = [self initWithSections:@[sectionInfo]];
    return self;
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
