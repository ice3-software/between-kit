//
//  I3DragDataSource.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol I3Collection;


/**
 
 Delegate protocol that provides the data around the state of which items in a collection
 are draggable.
 
 Deals in `NSIndexPath`s only where there is a guarentee that we are referencing a specific
 data item. Deals in `CGPoint` when there is no such guarentee. 
 
 @todo Provide example of what we mean...
 
 @see UITableViewDataSource
 @see UICollectionViewDataSource
 
 */
@protocol I3DragDataSource <NSObject>


@required


/**
 
 Returns YES or NO based on whether an item at a given point can be dragged at all. Assumed
 as NO if this is not implemented.
 
 @name Coordination
 @todo We want to know what point we're starting the drag from.
 @param at          The index at which the item is being dragged from.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection;


@optional


/**
 
 Called to update the data source on drop of an item from one container onto another.
 
 @name Coordination
 @param from            The index that the item is from.
 @param to              The index to which the foreign item is being dragged.
 @param fromCollection  The collection that we're dragging from.
 @param toCollection    The collection that we're drop onto.
 
 */
-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection;


/**
 
 Called to update the data source on the drop of an item from one collection onto another.
 
 @name Coordination
 @param from            The index in fromCollection from which the drag originates.
 @param to              The point in onCollection on which we drop
 @param fromCollection  The collection that we're dragging from.
 @param toCollection    The collection that we're drop onto.
 
 */
-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint) to onCollection:(UIView<I3Collection> *)toCollection;


/**
 
 Called to update the data source on rearrange.
 
 @name Coordination
 @param from            The index from which the item is being dragged from.
 @param to              The index to which the item is being dragged to.
 @param collection      The collection to which the drag/drops relate.
 
 */
-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection;


/**
 
 Called to delete an item from the data source.
 
 @name Coordination
 @param at              The index at which the item originates.
 @param collection      The from which we're deleting the item.
 
 */
-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection;


/**
 
 Returns YES or NO based on whether an item at a given index from one collection can be
 dropped onto a given index on another collection.
 
 @name Coordination
 @param from            The index from the original collection that the item is from
 @param to              The index path on the target collection that we're dropping on
 @param fromCollection  The original collection that we're dragging from.
 @param toCollection      The target collection that we're dragging to.
 @return BOOL
 
 */
-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection;


/**
 
 Returns YES or NO based on whether an item at a given index from one collection can be
 dropped onto a given index on another collection.
 
 @name Coordination
 @param from            The index from the original collection that the item is from
 @param to              The index path on the target collection that we're dropping on
 @param fromCollection  The original collection that we're dragging from.
 @param toCollection      The target collection that we're dragging to.
 @return BOOL
 
 */
-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint) at onCollection:(UIView<I3Collection> *)toCollection;


/**
 
 Returns YES or NO based on whether an item at a given point can be rearranged in the collection
 with an item at another point. Assumed as NO if this is not implemented.
 
 @name Coordination
 @param from        The index at which the cell is being dragged from.
 @param to          The index at which the cell is being dragged to.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection;


/**
 
 Returns YES or NO based on whether an item at a given point can be 'deleted' (be the renderer)
 if it is dropped outside of all valid containers. Assumed as NO if this is not implemented.
 
 @name Coordination
 @param from        The index at which the cell is being dragged from.
 @param to          The point in the superview to which the item is being dragged.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint) to;


@end
