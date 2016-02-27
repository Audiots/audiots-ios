//
//  PSDCollectionViewController.h
//  Pods
//
//  Created by Todd Brannam on 10/7/14.
//
//

#import <UIKit/UIKit.h>

@class PSDDataSource;

/**
 *  @class Implements Basic notification PSDDataSource notifications 
 *  callbacks for data source changes
 */

@interface PSDCollectionViewController : UICollectionViewController
@property (nonatomic, strong) PSDDataSource *dataSource;
@end
