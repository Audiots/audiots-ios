//
//  PSDArrayDataSource.h
//  Pods
//
//  Created by Todd Brannam on 10/7/14.
//
//

#import "PSDDataSource.h"

@interface PSDArrayDataSource : PSDDataSource
- (id)initWithSections:(NSArray *)sections;
- (id)initWithObjects:(NSArray*)objects;
@end
