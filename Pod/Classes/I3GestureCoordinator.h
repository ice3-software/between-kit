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
 
 The gesture coordinator! The business object responsible for calculating and maintaining the
 state of drag and dropping. It also interacts with various delegate objects to update things
 such as the user interface and data sources.
 
 It requires most of its external dependencies to conform to various protocols, in order promote 
 loose coupling and extensibillity. Namely `I3DragDataSource`, `I3DragRenderDelegate` and 
 `I3Collection`.
 
 All of its dependencies are inject-able using either constructor injection or property injection.
 _None_ of the class' dependencies are static, global or implicit which further promotes loose 
 coupling and testabillity.
 
 To setup a basic drag / dropping environment, we offer some class factory methods.
 
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
@property (nonatomic, strong, readonly) UIGestureRecognizer *gestureRecognizer;


/**
 
 The I3Collection that is currently being dragged (or nil)
 
 */
@property (nonatomic, weak, readonly) UIView<I3Collection> *currentDraggingCollection;


/**
 
 The point at which the current drag started. CGPointZero if we're not dragging.
 
 */
@property (nonatomic, readonly) CGPoint currentDragOrigin;


/**
 
 Dynamic property for the index path of the current dragging item in the current dragging collection
 
 */
@property (nonatomic, strong, readonly) NSIndexPath *currentDraggingIndexPath;


/**
 
 Dynamic property for the view for the current item being dragged.
 
 */
@property (nonatomic, strong, readonly) UIView *currentDraggingItem;


/**
 
 Dynamic property that resolves to the current dragging location in the superview.
 
 */
@property (nonatomic, assign, readonly) CGPoint currentDragLocation;


/**
 
 The render delegate.
 
 This is a strong reference to the delegate object because in most cases, we don't want
 to be responsible for retaining a reference to it. A common example ...
 
 ```Objective-C
 
 coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
 
 ```
 
 If we didn't retain the renderer here it wouldn't work out. The result is that if the object
 designated as the render delegate ever retains a strong reference to its coordinator (directly 
 or indirectly), then a retain cycle will occur. Users should take you to design customer 
 delegates to nil out any cycical dependencies.
 
 @see I3DragRenderDelegate
 
 */
@property (nonatomic, strong) id<I3DragRenderDelegate> renderDelegate;


/**

 The data source
 
 The delegate object that provides data about draggabillity of the collections and their
 items as well as updating the data when different drag / drop event occur.
 
 @see I3DragDataSource
 
 */
@property (nonatomic, weak) id<I3DragDataSource> dragDataSource;


/**
 
 Ctor.
 
 @param arena               The area within which we are dragging
 @param gestureRecognizer   The gesture recognizer that we're listening to. Can be nil, in which
                            case a UIPanGestureRecognizer will be created by default.
 @return id
 
 */
-(id) initWithDragArena:(I3DragArena *)arena withGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;


/**
 
 Entry point for pan gestures that are coordinated to the I3Collections. This is public for 
 testing purposes; ordinarily this should not be called directly and is instead attached as
 a target to the `gestureRecognizer` injected into the coordinator.
 
 @param gestureRecognizer   The gesture recongizer that calls this selector as a target.
 
 */
-(void) handlePan:(UIGestureRecognizer*) gestureRecognizer;



/**
 
 Helper factory method for setting up a basic coordinator for a controller. Sets the environment
 up with a basic drag render, a new coordinator, and an area spanning the controller's main
 view.
 
 @param viewController      This controller's main view is used as the arena's superview
 @param collection          An array of UIView<I3Collection> objects
 @param recognizer          The recognizer to listen to.
 
 */
+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections withRecognizer:(UIGestureRecognizer *)recognizer;


/**
 
 Equivillent of calling `basicGestureCoordinatorFromViewController:withCollections:withRecognizer:`
 with a nil recognizer.
 
 @param viewController      This controller's main view is used as the arena's superview
 @param collection          An array of UIView<I3Collection> objects
 
 */
+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections;


@end
