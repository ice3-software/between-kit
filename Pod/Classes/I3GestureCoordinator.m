//
//  I3GestureCoordinator.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3GestureCoordinator.h"
#import "I3Logging.h"


@interface I3GestureCoordinator (Private)


/**
 
 Sets the current dragging view and point.
 
 */
-(void) setCurrentDraggingCollection:(id<I3Collection>) collection atPoint:(CGPoint) at;


/**
 
 The drag has started! This method determines which collection (if any) the drag started in
 and how then that may be handled.
 
 */
-(void) handleDragStarted;


/**
 
 A drag gesture has stopped! This method determines which collection (if any) the drag has
 stopped in and how that may be handled.
 
 */
-(void) handleDragStopped;


/**
 
 Called whilst we are dragging. It basically just emits notifications such that an external
 rendered can render the drag event.
 
 */
-(void) handleDrag;


/**
 
 Called when a drag, started from a collection has stopped outside of all valid collections at
 a particular point.
 
 */
-(void) handleDragStoppedOutsideAtPoint:(CGPoint) at;


/**
 
 Called when a drag from a collection has stopped on another collection at a given point.
 
 */
-(void) handleDragStoppedInCollection:(id<I3Collection>) to atPoint:(CGPoint) at;


@end


@implementation I3GestureCoordinator


-(id) initWithDragArena:(I3DragArena *)arena withGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer{

    self = [super init];
    
    if(self){
        
        _arena = arena;
        _gestureRecognizer = gestureRecognizer ?: [[UIPanGestureRecognizer alloc] init];

        SEL panSelector = @selector(handlePan:);
        [_gestureRecognizer addTarget:self action:panSelector];

        if(![[_arena.superview gestureRecognizers] containsObject:_gestureRecognizer]){
            [_arena.superview addGestureRecognizer:_gestureRecognizer];
        }
        
    }

    return self;
}


-(void) dealloc{

    [_gestureRecognizer removeTarget:self action:NULL];

    if([[_arena.superview gestureRecognizers] containsObject:_gestureRecognizer]){
        [_arena.superview removeGestureRecognizer:_gestureRecognizer];
    }
}


#pragma mark - Coordination methods


-(void) handlePan:(UIPanGestureRecognizer*) gestureRecognizer{
    
    switch([gestureRecognizer state]){
            
        case UIGestureRecognizerStateBegan:
            
            DND_LOG(@"Drag Started");
            [self handleDragStarted];
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            DND_LOG(@"Dragging");
            [self handleDrag];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            DND_LOG(@"Drag Stopped");
            [self handleDragStopped];
            break;
            
        default:
            break;
            
    }
}


-(void) handleDragStarted{
    
    for (id<I3Collection> collection in self.arena.collections){
        
        UIView* collectionView = collection.collectionView;
        CGPoint pointInCollection = [self.gestureRecognizer locationInView:collectionView];
        
        if([collectionView pointInside:pointInCollection withEvent:nil]){
            
            DND_LOG(@"We're dragging in a collection! Data source: point %@ collection %@", NSStringFromCGPoint(pointInCollection), collection);
            DND_LOG(@"Data source: %@", collection.dragDataSource);
            DND_LOG(@"Results: %@", [collection.dragDataSource canItemBeDraggedAtPoint:pointInCollection inCollection:collection] ? @"YES" : @"NO");
            
            if(collection.dragDataSource && [collection.dragDataSource canItemBeDraggedAtPoint:pointInCollection inCollection:collection]){
                
                DND_LOG(@"We can drag a given item in a collection");

                [self setCurrentDraggingCollection:collection atPoint:pointInCollection];
                /// @todo Render drag starting
            }
            else{
 
                [self setCurrentDraggingCollection:nil atPoint:CGPointZero];
                DND_LOG(@"Can't drag this item so calling it a day.");
            }

            break;
            /// @todo I want to be able to handle transparency here. I3DragDataSource should
            /// implement some BOOL method for whether we're transparent in a particular
            /// place
        }
    }
    
}


-(void) handleDragStopped{

    if(!_currentDraggingCollection){
        DND_LOG(@"Invalid drag stopped.");
        return;
    }
    
    id<I3Collection> dstCollection;
    
    for(id<I3Collection> collection in self.arena.collections){
        
        UIView* collectionView = collection.collectionView;
        CGPoint pointInCollection = [self.gestureRecognizer locationInView:collectionView];
        
        if([collectionView pointInside:pointInCollection withEvent:nil]){
            
            DND_LOG(@"Found a target collection to drop on!");

            [self handleDragStoppedInCollection:collection atPoint:pointInCollection];
            dstCollection = collection;
            break;
            /// @todo see the todo in handleDragStarted
            
        }
    }
    
    if(!dstCollection){
        
        DND_LOG(@"Didn't find a target collection to drop on.");

        CGPoint point = [_gestureRecognizer locationInView:self.arena.superview];
        [self handleDragStoppedOutsideAtPoint:point];
    }
    
    [self setCurrentDraggingCollection:nil atPoint:CGPointZero];
    
}


-(void) handleDragStoppedOutsideAtPoint:(CGPoint) at{
    
    id<I3DragDataSource> dataSource = _currentDraggingCollection.dragDataSource;

    SEL canDeleteSelector = @selector(canItemAtPoint:beDeletedIfDroppedOutsideOfCollection:atPoint:);
    SEL deleteSelector = @selector(deleteItemAtPoint:inCollection:);

    if(
       dataSource &&
       [dataSource respondsToSelector:canDeleteSelector] &&
       [dataSource respondsToSelector:deleteSelector] &&
       [dataSource canItemAtPoint:_currentDragOrigin beDeletedIfDroppedOutsideOfCollection:_currentDraggingCollection atPoint:at]
    ){
        
        DND_LOG(@"Dragged nowhere so deleting");
        [dataSource deleteItemAtPoint:_currentDragOrigin inCollection:_currentDraggingCollection];
        /// @todo Render deletion
    }
    else{
        
        DND_LOG(@"Dragged nowhere and can't delete. Snapping back");
        /// @todo Render snap back
    }
    
    [self setCurrentDraggingCollection:nil atPoint:CGPointZero];
    
}


-(void) handleDragStoppedInCollection:(id<I3Collection>) to atPoint:(CGPoint) at{
    
    BOOL isRearrange = to == _currentDraggingCollection;
    id<I3DragDataSource> dataSource = _currentDraggingCollection.dragDataSource;
    
    SEL canItemRearrangeSelector = @selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:);
    SEL canDropSelector = @selector(canItemAtPoint:fromCollection:beDroppedToPoint:inCollection:);
    
    SEL itemRearrangeSelector = @selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:);
    SEL dropSelector = @selector(dropItemAtPoint:fromCollection:toPoint:inCollection:);
    
    if(
       isRearrange &&
       [dataSource respondsToSelector:itemRearrangeSelector] &&
       [dataSource respondsToSelector:canItemRearrangeSelector] &&
       [dataSource canItemFromPoint:_currentDragOrigin beRearrangedWithItemAtPoint:at inCollection:_currentDraggingCollection]
    ){
        
        DND_LOG(@"Rearranging items in a collection.");
        [dataSource rearrangeItemAtPoint:_currentDragOrigin withItemAtPoint:at inCollection:_currentDraggingCollection];
        /// @todo Render rearrange
    }
    else if(
        !isRearrange &&
        [dataSource respondsToSelector:canDropSelector] &&
        [dataSource respondsToSelector:dropSelector] &&
        [dataSource canItemAtPoint:_currentDragOrigin fromCollection:_currentDraggingCollection beDroppedToPoint:at inCollection:to]
    ){
    
        DND_LOG(@"Exchanging items between collections.");
        [dataSource dropItemAtPoint:_currentDragOrigin fromCollection:_currentDraggingCollection toPoint:at inCollection:to];
        /// @todo Render drop exchange between 2 collections
    }
    else{
        
        DND_LOG(@"Can do anything with these 2.");
        /// @todo Render snap back
    }
    
    [self setCurrentDraggingCollection:nil atPoint:CGPointZero];
    
}


-(void) handleDrag{
    
    if(!_currentDraggingCollection){
        
        DND_LOG(@"Handle drag but we're not dragging.");
        return;
    }
    
    /// @todo Render drag movement
    
}


#pragma mark Accessor methods


-(void) setCurrentDraggingCollection:(id<I3Collection>) collection atPoint:(CGPoint) at{

    _currentDraggingCollection = collection;
    _currentDragOrigin = at;
}


@end
