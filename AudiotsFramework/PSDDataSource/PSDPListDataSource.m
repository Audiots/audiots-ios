//
//  PSDPListDataSource.m
//  Pods
//
//  Created by Bob Ward on 6/3/14.
//
//

#import "PSDPListDataSource.h"
#import "PSDDataSource+Private.h"

@interface PSDPListDataSource()
@end

@implementation PSDPListDataSource

- (id)initWithContentsOfFile:(NSString *)plistPath
{
    NSArray *data = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *sections = [NSMutableArray new];
    for (NSDictionary *fileSection in data) {
        PSDDataSourceSectionInfo *sectionInfo = [[PSDDataSourceSectionInfo alloc] init];
        sectionInfo.objects = [fileSection objectForKey:@"objects"];
        [sections addObject:sectionInfo];
    }
    
    self = [super initWithSections:sections];
    
    return self;
}

@end
