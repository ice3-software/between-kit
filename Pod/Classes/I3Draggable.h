//
//  I3Draggable.h
//  
//
//  Created by Stephen Fortune on 13/09/2014.
//
//

#import <Foundation/Foundation.h>


/**
 
 Protocol for 'draggables'. These represent a view that contain 'items' (subviews) which
 can be dragged around.
 
 @todo How do we enforce the constraint the items's are subviews of the collection view?
       1.* didn't enforce this but I feel we should.
 
 */
@protocol I3Draggable <NSObject>

@required


/**
 
 Returns the containing UIView that has is the superview of the 'items'. This can be
 used to access the bounds of the collection for coordination as well as the for 
 rendering.

 @name Rendering
 @name Coordination

 */
-(UIView *)collection;


/**
 
 Returns the view for an item in the collection at a specified index path. This can
 be used to access individual item bounds as well as individual item views for rendering.
 
 @name Rendering
 @name Coordination
 
 */
-(UIView *)itemAtIndexPath:(NSIndexPath *)at;


/**
 
 Should an item's original view be 'hidden' whilst it is being dragged? If YES, the item
 view will appear to have been lifted off the collection and be dragged about. If NO, a
 'ghost' duplicate will appear to track around with the user's pan gesture.
 
 @name Rendering
 
 */
-(BOOL) hiddenItemWhileDragging;


@optional


/**
 
 Can be implemented to further customise the styling of a given dragging view. E.g.
 a red filter way want to be applied to the view whilst dragging.
 
 @todo I'm not sure if this is a good idea yet. What happens if a user messes with
       properties of the view that being used by the rendered?
 @warning This is not implemented yet
 @name Rendering
 
 */
-(void) applyStylingToDraggingView:(UIView *)draggingView;


@end
