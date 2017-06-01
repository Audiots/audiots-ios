//
//  PSDCompoundDataSource.h
//  Pods
//
//  Created by Bob Ward on 7/2/14.
//
//

#import "PSDDataSource.h"

@interface PSDCompoundDataSource : PSDDataSource
- (instancetype)initWithDataSources:(NSArray*)dataSources;
@end
