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
 
 @todo Right now, the implementation is repsonsable for mapping a CGPoint to a given item
       in the collection so that the coordinator and the rendered aren't dependent on 
       `UITableView`/`UICollectionView`-specific point->index convertion methods. We need to
       provide some sort of separate helper utility that allows users to do this easily without
       having to implement the same boilerplate for all of their `UITableView`/
       `UICollectionView`s.
 @todo How do we enforce the constraint the items's are subviews of the collection view?
       1.* didn't enforce this but I feel we should.
 @todo Should all the methods returning instances, infact me readonly properties?
 
 */
@protocol I3Draggable <NSObject>

@required


/**
 
 Returns YES or NO based on whether the item at a given index in the collection.
 
 @name Rendering
 @name Coordination
 @param at The point at which the item is.
 @return UIView * | nil if one does not exist
 
 */
-(BOOL) isItemRearrangeableAtPoint:(CGPoint) at;


/**
 
 Returns the containing UIView that has is the superview of the 'items'. This can be
 used to access the bounds of the collection for coordination as well as the for 
 rendering.

 @name Rendering
 @name Coordination
 @return UIView
 
 */
-(UIView *)collection;


/**
 
 Returns the view for an item in the collection at a specified index path. This can
 be used to access individual item bounds as well as individual item views for rendering.
 
 @name Rendering
 @name Coordination
 @param at The point at which the item is.
 @return UIView * | nil if one does not exist
 
 */
-(UIView *)itemAtPoint:(CGPoint) at;


/**
 
 Should an item's original view be 'hidden' whilst it is being dragged? If YES, the item
 view will appear to have been lifted off the collection and be dragged about. If NO, a
 'ghost' duplicate will appear to track around with the user's pan gesture.
 
 @name Rendering
 @param at The point at which the item is.
 @return BOOL

 */
-(BOOL) hideWhileDraggingItemAtPoint:(CGPoint) at;


@optional


/**
 
 Can be implemented to further customise the styling of a given dragging view. E.g.
 a red filter way want to be applied to the view whilst dragging.
 
 @todo I'm not sure if this is a good idea yet. What happens if a user messes with
       properties of the view that being used by the rendered?
 @warning This is not implemented yet
 @name Rendering
 @param draggingView The view to apply styling to.

 */
-(void) applyStylingToDraggingView:(UIView *)draggingView;


@end
