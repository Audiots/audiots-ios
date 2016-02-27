//
// Created by Todd Brannam on 2/24/15.
// Copyright (c) 2015 Perfect Sense Digital. All rights reserved.
//

#import "PSDArrayController.h"
#import "PSDDataMerge.h"
@interface PSDArrayController ()
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, assign) BOOL mutating;
@end

@implementation PSDArrayController

- (instancetype)initWithMutableArray:(NSMutableArray *)mutableArray {

    self = [super init];
    self.mutableArray = mutableArray;
    return self;
}

-(NSUInteger)countOfArray {
    return self.mutableArray.count;
}

-(id)objectInArrayAtIndex:(NSUInteger)index {
    return [self.mutableArray objectAtIndex:index];
}

- (NSArray *)arrayAtIndexes:(NSIndexSet *)indexes {
    return [self.array objectsAtIndexes:indexes];
}

-(void)insertObject:(id)object inArrayAtIndex:(NSUInteger)index {
    [self.mutableArray insertObject:object atIndex:index];
}

- (void)insertArray:(NSArray *)objects atIndexes:(NSIndexSet *)indexSet {
    [self.mutableArray insertObjects:objects atIndexes:indexSet];
}

-(void)removeArrayAtIndexes:(NSIndexSet *)indexSet {
    [self.mutableArray removeObjectsAtIndexes:indexSet];
}

-(void)removeObjectFromArrayAtIndex:(NSUInteger)index{
    [self.mutableArray removeObjectAtIndex:index];
}

-(void)replaceObjectInArrayAtIndex:(NSUInteger)index withObject:(id)object {
    [self.mutableArray replaceObjectAtIndex:index withObject:object];
}

- (void)replaceArrayAtIndexes:(NSIndexSet *)indexSet withArray:(NSArray *)array{
    [self.mutableArray replaceObjectsAtIndexes:indexSet withObjects:array];
}

- (NSArray *)array {
    return self.mutableArray;
}

- (void)psdMerge:(NSObject *)obj
{
    if ([obj isKindOfClass:[PSDArrayController class]]) {
        [self psdMergeWithArrayController:(PSDArrayController *) obj];
    }
}

- (void)psdMergeWithArrayController:(PSDArrayController *)otherController
{
    NSInteger index = 0;
    NSInteger initialCount = self.array.count;

    if (otherController.array.count == 0) return;

    
//    https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW17
    
//    - (IBAction)insertAndDeleteRows:(id)sender {
//        // original rows: Arizona, California, Delaware, New Jersey, Washington
//        
//        [states removeObjectAtIndex:4]; // Washington

//        // original rows: Arizona, California, Delaware, New Jersey
//        [states removeObjectAtIndex:2]; // Delaware

//        // original rows: Arizona, California, New Jersey

//        [states insertObject:@"Alaska" atIndex:0];

//        // original rows: Alaska, Arizona, California, New Jersey

//        [states insertObject:@"Georgia" atIndex:3];

//        // original rows: Alaska, Arizona, California, Georgia, New Jersey
//        [states insertObject:@"Virginia" atIndex:5];

//        // original rows: Alaska, Arizona, California, Georgia, New Jersey, Virginia
    
//
//        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
//                                     [NSIndexPath indexPathForRow:2 inSection:0],
//                                     [NSIndexPath indexPathForRow:4 inSection:0],
//                                     nil];
//        NSArray *insertIndexPaths = [NSArray arrayWithObjects:
//                                     [NSIndexPath indexPathForRow:0 inSection:0],
//                                     [NSIndexPath indexPathForRow:3 inSection:0],
//                                     [NSIndexPath indexPathForRow:5 inSection:0],
//                                     nil];
//        UITableView *tv = (UITableView *)self.view;
//        
//        [tv beginUpdates];
//        [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
//        [tv deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
//        [tv endUpdates];
//        
//        // ending rows: Alaska, Arizona, California, Georgia, New Jersey, Virginia
//    }
//    This example removes two strings from an array (and their corresponding rows) and inserts three strings into the array (along with their corresponding rows). The next section, Ordering of Operations and Index Paths, explains particular aspects of the row (or section) insertion and deletion behavior.
//    
    
//    Ordering of Operations and Index Paths
//    You might have noticed something in the code shown in Listing 7-8 that seems peculiar. The code calls the deleteRowsAtIndexPaths:withRowAnimation: method after it calls insertRowsAtIndexPaths:withRowAnimation:. However, this is not the order in which UITableView completes the operations. It defers any insertions of rows or sections until after it has handled the deletions of rows or sections. The table view behaves the same way with reloading methods called inside an update block—the reload takes place with respect to the indexes of rows and sections before the animation block is executed. This behavior happens regardless of the ordering of the insertion, deletion, and reloading method calls.
//    
//  Deletion and reloading operations within an animation block specify which rows and sections in the original table should be removed or reloaded; insertions specify which rows and sections should be added to the resulting table. The index paths used to identify sections and rows follow this model. Inserting or removing an item in a mutable array, on the other hand, may affect the array index used for the successive insertion or removal operation; for example, if you insert an item at a certain index, the indexes of all subsequent items in the array are incremented.
//        
//        An example is useful here. Say you have a table view with three sections, each with three rows. Then you implement the following animation block:
//        
//        Begin updates.
//        Delete row at index 1 of section at index 0.
//        Delete section at index 1.
//        Insert row at index 1 of section at index 1.
//        End updates.
//        Figure 7-2 illustrates what takes place after the animation block concludes.
//        
//        Figure 7-2  Deletion of section and row and insertion of row
//        Deletion of section and row and insertion of row
    
    //https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/Art/batch_insert_delete.jpg

    NSMutableArray *deletedObjects = [NSMutableArray array];
    NSMutableIndexSet *deletedIndexSet = [NSMutableIndexSet indexSet];
    
    NSMutableArray *replaceObjects = [NSMutableArray array];
    NSMutableIndexSet *replaceIndexSet = [NSMutableIndexSet indexSet];

    NSMutableArray *insertObjects = [NSMutableArray array];
    NSMutableIndexSet *insertIndexSet = [NSMutableIndexSet indexSet];

    
    for (NSObject<PSDDataMerge> *sourceEntry in otherController.array) {

        if (index < initialCount) {

            NSObject<PSDDataMerge> *destinationEntry = self.array[index];
            if ([sourceEntry respondsToSelector:@selector(psdMerge:)] && [destinationEntry respondsToSelector:@selector(psdMerge:)]) {

                BOOL skip = NO;
                if ([sourceEntry isKindOfClass:NSDictionary.class]) {
                    skip = [(NSDictionary *)sourceEntry count]==0;
                }

                if (skip == NO) {
                    
                    if (![destinationEntry isEqual:sourceEntry]) {
                        
                        destinationEntry = [destinationEntry mutableCopy];
                        
                    [destinationEntry psdMerge:sourceEntry];
                    // can we figure if there are things that aren't changed?
                    [replaceObjects addObject:destinationEntry];
                    [replaceIndexSet addIndex:index];
                }
            }
            }
        } else {
            [insertObjects addObject:sourceEntry];
            [insertIndexSet addIndex:index];
        }

        index++;
    }

    for (NSUInteger deletedIndex = otherController.array.count; deletedIndex < self.array.count; deletedIndex++) {
        id deletedObject = self.array[deletedIndex];
        [deletedObjects addObject:deletedObject];
        [deletedIndexSet addIndex:deletedIndex];
    }
    
    // follows will be be observed via KVO - so don't mutate below here

    if (deletedIndexSet.count || replaceObjects.count || insertObjects.count) {
        self.mutating = YES;
    }

    if (deletedIndexSet.count) {
        [self removeArrayAtIndexes:deletedIndexSet];
    }

    if (replaceIndexSet.count) {
        [self replaceArrayAtIndexes:replaceIndexSet withArray:replaceObjects];
    }

    // update insertIndexSet with the new indexes of the insertObjects
    
    
    //  Deletion and reloading operations within an animation block specify which rows and sections in the original table should be removed or reloaded; insertions specify which rows and sections should be added to the resulting table. The index paths used to identify sections and rows follow this model. Inserting or removing an item in a mutable array, on the other hand, may affect the array index used for the successive insertion or removal operation; for example, if you insert an item at a certain index, the indexes of all subsequent items in the array are incremented.

    
    if (insertObjects.count) {
        [self insertArray:insertObjects atIndexes:insertIndexSet];
    }


    if (deletedIndexSet.count || replaceObjects.count || insertObjects.count) {
        self.mutating = NO;
    }

}

@end
