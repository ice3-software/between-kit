//
//  I3GestureCoordinator.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I3DragArena.h"
#import "I3Collection.h"
#import "I3DragRenderDelegate.h"


/**
 
 The gesture coordinator! This listens to a UIPanGestureRegonizer and calculates the state
 of dragging from the I3Collection instances in the I3DragArena.
 
 @note We are using OCMock in the Demo project to test. This can't reliably mock `respondsToSelector` 
 for mock protocols, therefore we need to implement fixture implementations of the I3DragDataSource
 class so that we can cover how the coordinator handles different implementations. The convention
 we follow is to check that `can*` method exists _before_ the actual data modification method,
 e.g.
 
 ```objective-c
 
 [dragDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)] &&
 [dragDataSource respondsToSelector:@selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:)] &&
 [dragDataSource canItemFromPoint:_currentDragOrigin beRearrangedWithItemAtPoint:at inCollection:_currentDraggingCollection]
 
 ```
 
 Be aware of this convention as it dictates how we implement the fixtures.
 
 @todo Please may want to use this coordinator with gesture recognizers other than the 
 UIPanGestureRecognizer. For example, to trigger a drag on long click we require this class to coordinate
 a UILongPressGestureRecongizer. We need to make this more generic.
 
 */
@interface I3GestureCoordinator : NSObject


/**
 
 The area: contains the superview and the I3Collections. Required to be injected as a hard
 dependency.
 
 */
@property (nonatomic, strong, readonly) I3DragArena *arena;


/**
 
 The pan gesture regonizer. If not injected via the ctor one is created automatically 'behind
 the scenes' for convenience.
 
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *gestureRecognizer;


/**
 
 The I3Collection that is currently being dragged (or nil)
 
 */
@property (nonatomic, weak, readonly) id<I3Collection> currentDraggingCollection;


/**
 
 The point at which the current drag started. CGPointZero if we're not dragging.
 
 */
@property (nonatomic, readonly) CGPoint currentDragOrigin;


/**
 
 The render delegate. 
 
 @note One of the language features of objective-c is that calling a method on nil objects 
 doesn't cause crash. Therefore we have not bothered to unit test the scenarios whereby there
 has been no render delegate injected into the coordinator yet a render event occurs, because we
 know exactly what will happen.
 
 */
@property (nonatomic, weak) id<I3DragRenderDelegate> renderDelegate;


/**

 The data source
 
 The delegate object that provides data about draggabillity of the collections and their
 items. It has the responsibillity of providing dynamic draggabillity config.
 
 @note For the same reason that we haven't covered the absence of `renderDelegate`, we're not
 covering the absense of the `dragDataSource` with unit tests because delegate calls will just
 return NO. Therefore all draggabillity configuration (can I drag this? can I drop this here?
 can I delete this?) will just be assumed to be NO if there is no data source. Its a language
 feature and does not require tests.
 
 */
@property (nonatomic, weak) id<I3DragDataSource> dragDataSource;


/**
 
 Ctor.
 
 @param arena               The area within which we are dragging
 @param gestureRecognizer   The gesture recognizer that we're listening to. Can be nil.
 @return id
 
 */
-(id) initWithDragArena:(I3DragArena *)arena withGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;


/**
 
 Dtor. Implemented to detach the coordinator from the gesture recongizer.
 
 */
-(void) dealloc;


/**
 
 Entry point for pan gestures that are coordinated to the I3Collections.
 
 @note This method is in the public interface mainly for unit testing purposes. Previously
 I tried indirectly triggering this selector by calling the UIGestureRecognizer's `touchesBegan:withEvent:`
 selector but it was too dependent on `UITouch` and `UIEvent`, which I could not mock affectively
 without knowing the inner workings of the UIGestureRecognizer.
 
 */
-(void) handlePan:(UIPanGestureRecognizer*) gestureRecognizer;


@end
