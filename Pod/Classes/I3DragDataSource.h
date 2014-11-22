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
 
 @see UITableViewDataSource
 @see UICollectionViewDataSource
 
 */
@protocol I3DragDataSource <NSObject>


@required


/**
 
 Returns YES or NO based on whether an item at a given point can be dragged at all. Assumed
 as NO if this is not implemented.
 
 @name Coordination
 @param at          The point at which the cell is being dragged from.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection;


@optional


/**
 
 Called to update the data source on an exchange of items between 2 collections.
 
 @name Coordination
 @param from            The point from the foreign draggable that the item is from.
 @param to              The point in this draggable to which the foreign item is being dragged.
 @param fromCollection  The foreign collection.
 @param toCollection    The collection we're providing data for.
 
 */
-(void) exchangeItemAtPoint:(CGPoint) from inCollection:(id<I3Collection>) fromCollection withItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection;


/**
 
 Called to update the data source on the appendation of an item from one collection onto 
 another.
 
 @see `canItemAtPoint:fromCollection:beAppendedToCollection:toCollection:` for notes on semantics
 @name Coordination
 @param from            The point in fromCollection from which the drag originates.
 @param to              The point in onCollection on which we drop.
 @param fromCollection  The collection that we're dragging from.
 @param onCollection    The collection that we're appending onto.
 
 */
-(void) appendItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection toPoint:(CGPoint) to onCollection:(id<I3Collection>) onCollection;


/**
 
 Called to update the data source on rearrange.
 
 @name Coordination
 @param from            The point from which the item is being dragged from.
 @param to              The point to which the item is being dragged to.
 @param collection      The collection to which the drag/drops relate.
 
 */
-(void) rearrangeItemAtPoint:(CGPoint) from withItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) collection;


/**
 
 Called to delete an item from the data source.
 
 @name Coordination
 @param at              The point at which the item originates.
 @param collection      The from which we're deleting the item.
 
 */
-(void) deleteItemAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection;


/**
 
 Returns YES or NO based on whether an item originating at a given point from one collection 
 can be exchanged with an item in another collection at another given point. Assumed as NO if 
 this is not implemented.
 
 @name Coordination
 @param from            The point from the original collection that the item is from
 @param to              The point in the target collection that we're dropping on.
 @param fromCollection  The original collection that we're dragging from.
 @param toCollection    The target collection that we're dropping on.
 @return BOOL
 
 */
-(BOOL) canItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection beExchangedWithItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection;


/**
 
 Returns YES or NO based on whether an item at a given point from one collection can be
 appended onto the end of another collection at another given point. Assumed as NO if this
 is not implemented.

 @note Semantically, 'append' here refers to the drag data source' implementation of
 `appendItemAtPoint:fromCollection:toPoint:onCollection:`. Its important to note that
 its up to the user how they want to realise appendation. E.g. the may want to implement
 'appending' by adding the new data at the end of a list, at the beginning of a list,
 whereever they like really. As far as the framework's concerned, its all appendation.
 
 @name Coordination
 @param from            The point from the original collection that the item is from
 @param to              The point in the target collection that we're dropping on.
 @param fromCollection  The original collection that we're dragging from.
 @param toCollection      The target collection that we're dragging to.
 @return BOOL

 */
-(BOOL) canItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection beAppendedToCollection:(id<I3Collection>) toCollection atPoint:(CGPoint) to;

/**
 
 Returns YES or NO based on whether an item at a given point can be rearranged in the collection
 with an item at another point. Assumed as NO if this is not implemented.
 
 @name Coordination
 @param from        The point at which the cell is being dragged from.
 @param to          The point at which the cell is being dragged to.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemFromPoint:(CGPoint) from beRearrangedWithItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) collection;


/**
 
 Returns YES or NO based on whether an item at a given point can be 'deleted' (be the renderer)
 if it is dropped outside of all valid containers. Assumed as NO if this is not implemented.
 
 @name Coordination
 @param from        The point at which the cell is being dragged from.
 @param to          The point outside of the collection to which the item is being dragged.
 @param collection  The collection we're providing data for.
 @return BOOL
 
 */
-(BOOL) canItemAtPoint:(CGPoint) from beDeletedFromCollection:(id<I3Collection>) collection atPoint:(CGPoint) to;


/**
 
 Should an item's original view be 'hidden' whilst it is being dragged? If YES, the item
 view will appear to have been lifted off the collection and be dragged about. If NO, a
 'ghost' duplicate will appear to track around with the user's pan gesture.
 
 @name Rendering
 @param at          The point at which the item is.
 @param collection  The collection we're providing data for.
 @todo Remove this - it has no place here. If the basic render delegate wants to ask fine-grained
 questions about whether it should 'hide this' or 'style something like that', it should provide its
 own delegate protocol. Something like `I3BasicRenderDelegateDataSource`... Still open to discussion.
 @deprecated
 @return BOOL
 
 */
-(BOOL) hidesItemWhileDraggingAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection;

@end
