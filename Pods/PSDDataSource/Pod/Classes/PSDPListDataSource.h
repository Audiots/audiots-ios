//
//  PSDPListDataSource.h
//  Pods
//
//  Created by Bob Ward on 6/3/14.
//
//

#import "PSDDataSource.h"
#import "PSDArrayDataSource.h"

@interface PSDPListDataSource : PSDArrayDataSource
- (id)initWithContentsOfFile:(NSString *)plistPath;
@end
