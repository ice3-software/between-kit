//
//  I3GestureCoordinator.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3GestureCoordinator.h"
#import "I3Logging.h"


@interface I3GestureCoordinator ()


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

        DND_LOG(@"Superview: %@", _arena.superview);
        [_arena.superview backgroundColor];
        DND_LOG(@"Gesture recognizers: %@", _arena.superview.gestureRecognizers);
        
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
            
            DND_LOG(@"We're dragging in a collection!");
            
            if([self.dragDataSource canItemBeDraggedAtPoint:pointInCollection inCollection:collection]){
                
                DND_LOG(@"We can drag item %d in collection", [self.arena.collections indexOfObject:collection]);

                [self setCurrentDraggingCollection:collection atPoint:pointInCollection];
                [self.renderDelegate renderDragStart:self];
                
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
        
        DND_LOG(@"Testing whether %@ is in %@", NSStringFromCGPoint(pointInCollection), collectionView);
        
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
    
    SEL canDeleteSelector = @selector(canItemAtPoint:beDeletedIfDroppedOutsideOfCollection:atPoint:);
    SEL deleteSelector = @selector(deleteItemAtPoint:inCollection:);
    
    if(
       [self.dragDataSource respondsToSelector:canDeleteSelector] &&
       [self.dragDataSource respondsToSelector:deleteSelector] &&
       [self.dragDataSource canItemAtPoint:_currentDragOrigin beDeletedIfDroppedOutsideOfCollection:_currentDraggingCollection atPoint:at]
    ){
        
        DND_LOG(@"Dragged nowhere so deleting");
        [self.dragDataSource deleteItemAtPoint:_currentDragOrigin inCollection:_currentDraggingCollection];
        [self.renderDelegate renderDeletionAtPoint:at fromCoordinator:self];
    }
    else{
        
        DND_LOG(@"Dragged nowhere and can't delete. Snapping back");
        [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
    }
    
}


-(void) handleDragStoppedInCollection:(id<I3Collection>) to atPoint:(CGPoint) at{
    
    BOOL isRearrange = to == _currentDraggingCollection;
    
    SEL canItemRearrangeSelector = @selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:);
    SEL canDropSelector = @selector(canItemAtPoint:fromCollection:beDroppedToPoint:inCollection:);
    
    SEL itemRearrangeSelector = @selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:);
    SEL dropSelector = @selector(dropItemAtPoint:fromCollection:toPoint:inCollection:);
    
    
    if(
       isRearrange &&
       [self.dragDataSource respondsToSelector:canItemRearrangeSelector] &&
       [self.dragDataSource respondsToSelector:itemRearrangeSelector] &&
       [self.dragDataSource canItemFromPoint:_currentDragOrigin beRearrangedWithItemAtPoint:at inCollection:_currentDraggingCollection]
    ){
        
        UIView *draggingItemView = [_currentDraggingCollection itemAtPoint:_currentDragOrigin];
        UIView *destinationItemView = [_currentDraggingCollection itemAtPoint:at];
        
        
        DND_LOG(@"Is %@ equal to %@?", draggingItemView, destinationItemView);
        
        if([draggingItemView isEqual:destinationItemView]){
            DND_LOG(@"Rearranging the same views. Snapping back.");
            [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
        }
        else{
            DND_LOG(@"Rearranging items in a collection.");
            [self.renderDelegate renderRearrangeOnPoint:at fromCoordinator:self];
            [self.dragDataSource rearrangeItemAtPoint:_currentDragOrigin withItemAtPoint:at inCollection:_currentDraggingCollection];
        }

    }
    else if(
        !isRearrange &&
        [self.dragDataSource respondsToSelector:canDropSelector] &&
        [self.dragDataSource respondsToSelector:dropSelector] &&
        [self.dragDataSource canItemAtPoint:_currentDragOrigin fromCollection:_currentDraggingCollection beDroppedToPoint:at inCollection:to]
    ){
    
        DND_LOG(@"Exchanging items between collections.");
        [self.dragDataSource dropItemAtPoint:_currentDragOrigin fromCollection:_currentDraggingCollection toPoint:at inCollection:to];
        [self.renderDelegate renderDropOnCollection:to atPoint:at fromCoordinator:self];
    }
    else{
        
        DND_LOG(@"Can't do anything with these 2.");
        [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
    }
    
}


-(void) handleDrag{
    
    if(!_currentDraggingCollection){
        
        DND_LOG(@"Handle drag but we're not dragging.");
        return;
    }

    [self.renderDelegate renderDraggingFromCoordinator:self];
    
}


#pragma mark Accessor methods


-(void) setCurrentDraggingCollection:(id<I3Collection>) collection atPoint:(CGPoint) at{

    _currentDraggingCollection = collection;
    _currentDragOrigin = at;
}


@end
