//
//  I3DragRenderDelegate.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <Foundation/Foundation.h>


@class I3GestureCoordinator;
@protocol I3Collection;


/**
 
 This is a protocol for a class that is delegated out the responsibillity by the coordinator 
 of rendering various drag / drop events. 
 
 All methods defined in this protocol are required because all rendering events must actually
 be rendered.
 
 The framework provies a basic implementation of the render delegate (`I3BasicRenderDelegate`).
 If users want to implement their own rendering styles and UI updates, they can either extend
 the basic render delegate or even implement their own by conforming to this protocol.
 
 Note that render delegates should take care in retaining / releasing references to their parent
 coordinators.
 
 Note that the rendering methods of classes that conform to this protocol should never be
 called directly, except in unit tests. The preconditions of each method will heavily depend on 
 the coordinator's state - leave it up to the coordinator to call them at the correct intervals.
 
 @see I3BasicRenderDelegate
 
 */
@protocol I3DragRenderDelegate <NSObject>


/**
 
 Render the 'start' of a drag.
 
 @param coordinator     The gesture coordinator
 
 */
-(void) renderDragStart:(I3GestureCoordinator *)coordinator;


/**
 
 Render a 'reset' from a given point to the original drag origin.
 
 @param at              The point that we're resetting from (i.e. the point at which a given drag 
                        stops
 @param coordinator     The gesture coordinator

 */
-(void) renderResetFromPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


/**
 
 Renders a drop of an item from the original dragging collection to the dst collection.
 
 @param dstCollection   The destination collection
 @param at              The point at which we're dropping
 @param coordinator     The gesture coordinator

 */
-(void) renderDropOnCollection:(UIView<I3Collection> *)dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


/**
 
 Renders a 'delete' of a given item form the dragging collection.
 
 @param at              The point at which the item stops to be deleted
 @param coordinator     The gesture coordinator

 */
-(void) renderDeletionAtPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


/**
 
 Renders a 'rearrange' between 2 items on the dragging collection.
 
 @param at              The point at which the dragging item stops
 @param coordinator     The gesture coordinator
 
 */
-(void) renderRearrangeOnPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


/**
 
 Render method called whilst 'dragging' is occuring.
 
 @param coordinator     The gesture coordinator
 
 */
-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator;

@end
