//
//  PSDCoreDataSource.h
//
//  Created by Bob Ward on 12/19/13.
//  Copyright (c) 2013 Perfect Sense Digital, LLC All rights reserved.
//

#import "PSDDataSource.h"
#import <CoreData/NSFetchedResultsController.h>

//#ifdef _COREDATADEFINES_H
@interface PSDCoreDataSource : PSDDataSource<NSFetchedResultsControllerDelegate>

- (id)initWithFetchRequest:(NSFetchRequest*)fetchRequest
      managedObjectContext:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath;

@end
//#endif
