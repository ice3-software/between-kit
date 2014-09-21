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
 of rendering various drag / drop events. For now, I have decided that the coordinator-renderer
 relationship is one-to-one (i.e. there will only be one class rendering the events emitted by
 the coordinator).
 
 All methods defined in this protocol are required because all rendering events must actually
 be rendered.
 
 @see I3GestureCoordinator
 
 @note The idea is that the framework will provide a 'default' render delegate that implements
 this protocol, but users can also define their own by extending the default delegate or even 
 implementing their own from scratch if they wish to fully customize how the drag dropping is 
 rendered.
 
 @note The coordinator will never 'rely' on the render delegate. That is, the results of a render
 method called on the delegate will never actually affect the state of the coordinator's routines.
 Therefore it will be 'safe' for there not to be a render delegate injected into the coordinator.
 
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
 
 Render a 'drop' onto a given collection from another collection.
 
 @param dstCollection   The destination collection
 @param at              The point at which we're dropping
 @param coordinator     The gesture coordinator
 
 */
-(void) renderDropOnCollection:(id<I3Collection>) dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;


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
 
 @param at              The point at which the dragging gesture occures
 @param coordinator     The gesture coordinator
 
 */
-(void) renderDraggingAtPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator;

@end
