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


/**
 
 The gesture coordinator! This listens to a UIPanGestureRegonizer and calculates the state
 of dragging from the I3Collection instances in the I3DragArena.
 
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

@end
