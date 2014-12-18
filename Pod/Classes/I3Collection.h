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
 items. It is used to abstract away the details of the collection, e.g. a custom UICollectionView
 could implement this protocol, as could a UITableView, or even a custom UIView.
 
 @note Optional methods should be implemented for convenience, to avoid users having to check the 
 type of the collectionView in their data source methods. For example, our UITableView category 
 implements these methods to avoid forcing users to call `isKindOfClass` and cast between different
 view types in their data source.
 
 @todo How do we enforce the constraint the items's are subviews of the collection view?
 1.* didn't enforce this but I feel we should.

 */
@protocol I3Collection <NSObject>


@required


/**
 
 Returns the containing UIView that has is the superview of the 'items'. This can be
 used to access the bounds of the collection for coordination as well as the for
 rendering.
 
 @todo Get rid of this as per #42
 
 */
@property (nonatomic, strong, readonly) UIView *collectionView;


/**
 
 Should be implemented to map a given point to an NSIndexPath. Should return nil if an
 item does not exist at the given index path.
 
 @param     at      CGPoint
 @return    NSIndexPath
 
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
 
 @param     index   NSIndexPath
 @return    UIView
 
 */
-(UIView *)itemAtIndexPath:(NSIndexPath *)index;


@optional


/**
 
 Can be implemented as a agnostic method for deleting items at a set of given index paths.
 
 @see `UICollectionView deleteItemAtIndexPaths:`
 @see #42
 
 @param indeces     NSArray *   Array of index paths to delete items at
 
 */
-(void) deleteItemAtIndexPaths:(NSArray *)indeces;


/**
 
 Can be implemented as a agnostic method for reloading items at a set of given index paths.
 
 @see `UICollectionView reloadItemsAtIndexPaths:`
 @see #42
 @param indeces     NSArray *   Array of index paths to reload items at
 
 */
-(void) reloadItemsAtIndexPaths:(NSArray *)indeces;


/**
 
 Can be implemented as a agnostic method for creating items at a set of given index paths.
 
 @see `UICollectionView insertItemsAtIndexPaths:`
 @see #42

 @param indeces     NSArray *   Array of index paths to insert items at
 
 */
-(void) insertItemsAtIndexPaths:(NSArray *)indeces;


@end
