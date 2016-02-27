//
//  PSDCoreDataSource+Private.h
//
//  Created by Bob Ward on 12/19/13.
//  Copyright (c) 2013 Perfect Sense Digital, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSDCoreDataSource()

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, copy) NSString *sectionNameKeyPath;

@end


