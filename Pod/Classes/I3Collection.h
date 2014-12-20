//
//  I3Collection.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I3DragDataSource.h"


/**
 
 Protocol defining a common, agnostic interface for 'collection's. Collections represent views that
 contain draggable child items.
 
 This interface exposes methods for accessing properties of the collection and its child
 items. It is used to abstract away the details of the collection. The framework provides category
 implementations of this for both UITableView and UICollectionView, but allows users the flexibillity
 to even implement their own collection view by conforming to this protocol.
 
 Optional methods should be implemented for convenience, to avoid users having to check the
 type of the collectionView in their data source methods. For example, our UITableView category 
 implements these methods to avoid forcing users to call `isKindOfClass` and cast between different
 view types in their data source:
 
 
 ``` Objective-C
 
 if([toCollection isKindOfClass:[UITableView class]]){
    [(UITableView *)toCollection insertRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade];
 }
 else{
    [(UICollectionView *)toCollection insertItemsAtIndexPaths:indeces];
 }
 
 ```
 
 can instead be written as...
 
 ```Objective-C
 
 [toCollection insertItemsAtIndexPaths:indeces];

 ```
 
 For the avoidance of any doubt, this protocol is only intended to be conformed to by `UIViews` 
 (or subclasses thereof).
 
 
 @see UITableView+I3CollectionView
 @see UICollectionView+I3CollectionView
 
 */
@protocol I3Collection <NSObject>


@required


/**
 
 Should be implemented to map a given point to an NSIndexPath. May return nil if an
 item does not exist at the given index path, but is not required.
 
 @param at      The point at which we want to retrieve an index path for
 @return NSIndexPath
 
 */
-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at;


/**
 
 Should be implemented to retrieve the actual item view for a given NSIndexPath. 
 
 @note that whether or not an item actual exists at a given index path depends on the return 
 value of this method. If `indexPathForItemAtPoint:` return an NSIndexPath and this method 
 does not, we should assume that there is no valid index path here. Therefore
 `indexPathForItemAtPoint:` should not be used to check whether a valid item exists.
 
 @note follow on from above, this method may be called with a nil value for index. More often
 than not (particularly in the coordinator) the return value of `indexPathForItemAtPoint:` will
 be passed straight to this method to check whether an item exists. If `indexPathForItemAtPoint:`
 returns nil it will be forward to this method.
 
 @note this method should _never_ return a view for a nil index path. The coordinator will 
 throw if it does
 
 @param index   The index path at which we want ot retrieve a view for
 @return UIView
 
 */
-(UIView *)itemAtIndexPath:(NSIndexPath *)index;


@optional


/**
 
 Can be implemented as a agnostic method for deleting items at a set of given index paths.
 
 @see `UICollectionView deleteItemAtIndexPaths:`
 @see #42
 
 @param indeces Array of index paths to delete items at
 
 */
-(void) deleteItemsAtIndexPaths:(NSArray *)indeces;


/**
 
 Can be implemented as a agnostic method for reloading items at a set of given index paths.
 
 @see `UICollectionView reloadItemsAtIndexPaths:`
 @see #42
 @param indeces Array of index paths to reload items at
 
 */
-(void) reloadItemsAtIndexPaths:(NSArray *)indeces;


/**
 
 Can be implemented as a agnostic method for creating items at a set of given index paths.
 
 @see `UICollectionView insertItemsAtIndexPaths:`
 @see #42

 @param indeces Array of index paths to insert items at
 
 */
-(void) insertItemsAtIndexPaths:(NSArray *)indeces;


@end
