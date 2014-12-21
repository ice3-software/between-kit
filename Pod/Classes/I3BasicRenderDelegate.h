//
//  I3BasicRenderDelegate.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <Foundation/Foundation.h>
#import "I3DragRenderDelegate.h"
#import "I3GestureCoordinator.h"
#import "I3CloneView.h"


/**
 
 This class is the framework-provided drag render delegate. This renders a basic 'ghost'
 dragging view during a drag. Note the loose coupling between the coordinator and its rendering
 delegate ! Users of this framework will be able to provide their own rendering delegates if
 they wish, that implement the I3DragRenderDelegate protocol. For convenience, users of the
 framework can extend this class to apply 'extra' styling to the rendering.
  
 */
@interface I3BasicRenderDelegate : NSObject <I3DragRenderDelegate>


/**
 
 The opacity that the dragging item in the collection will be set to on drag start. This is _not_ 
 the opacity of the cloned dragging, its the opacity of cell grounded in the collection whilst
 that cloned view is being dragged about in the superview.
 
 */
@property (nonatomic, assign) CGFloat draggingItemOpacity;


/**
 
 The opacity of the cloned draggingView whilst dragging occurs.
 
 */
@property (nonatomic, assign) CGFloat draggingViewOpacity;


/**
 
 The cloned view that is current being rendered according to the drag position.
 
 */
@property (nonatomic, strong) I3CloneView *draggingView;


/**
 
 Defaults to YES. If this is YES a rearrange will be rendered as an exchange. If it is NO, a
 rearrange will just be rendered as an ordinary drop.
 
 */
@property (nonatomic) BOOL rearrangeIsExchange;


@end
