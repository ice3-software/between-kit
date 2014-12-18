//
//  I3GestureCoordinator.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3GestureCoordinator.h"
#import "I3Logging.h"
#import "I3BasicRenderDelegate.h"


@interface I3GestureCoordinator ()


/**
 
 Redeclaration of 'private' properties. Custom setter is implemented to reset _currentDragOrigin
 appropriately.
 
 */
@property (nonatomic, weak, readwrite) UIView<I3Collection> *currentDraggingCollection;


/**
 
 Sets the current dragging collection from its origin.
 
 */
-(void) setCurrentDraggingCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint) at;


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
 
 Called when a drag has stopped on a origin within a collection.
 
 */
-(void) handleDragStoppedInCollection:(UIView<I3Collection> *)to atPoint:(CGPoint) at;


@end


@implementation I3GestureCoordinator


@dynamic currentDraggingIndexPath;
@dynamic currentDraggingItem;


#pragma Ctor / Dtor


-(id) initWithDragArena:(I3DragArena *)arena withGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{

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


-(void) handlePan:(UIGestureRecognizer*) gestureRecognizer{
    
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
    
    for (UIView<I3Collection> *collection in self.arena.collections){
        
        CGPoint pointInCollection = [self.gestureRecognizer locationInView:collection];
        
        if([collection pointInside:pointInCollection withEvent:nil]){
            
            NSIndexPath *index = [collection indexPathForItemAtPoint:pointInCollection];
            
            DND_LOG(@"We're dragging in a collection!");
            DND_LOG(@"Do we have an index path? %@", index);
            DND_LOG(@"Is there a cell for this index path? %@", [collection itemAtIndexPath:index]);
            
            if(
               [collection itemAtIndexPath:index] &&
               [self.dragDataSource canItemBeDraggedAt:index inCollection:collection]
            ){
                
                DND_LOG(@"We can drag item %lu in collection", (unsigned long)[self.arena.collections indexOfObject:collection]);

                [self setCurrentDraggingCollection:collection atPoint:pointInCollection];
                [self.renderDelegate renderDragStart:self];
                
            }
            else{
 
                self.currentDraggingCollection = nil;
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

    if(!self.currentDraggingCollection){
        DND_LOG(@"Invalid drag stopped.");
        return;
    }
    
    CGPoint locationInSuperview = [_gestureRecognizer locationInView:self.arena.superview];
    
    if(
       [self.dragDataSource respondsToSelector:@selector(canItemAt:beDeletedFromCollection:atPoint:)] &&
       [self.dragDataSource respondsToSelector:@selector(deleteItemAt:inCollection:)] &&
       [self.dragDataSource canItemAt:self.currentDraggingIndexPath beDeletedFromCollection:self.currentDraggingCollection atPoint:locationInSuperview]
       ){
        
        DND_LOG(@"Data source wants us to delete this! Deleting...");
        [self.dragDataSource deleteItemAt:self.currentDraggingIndexPath inCollection:self.currentDraggingCollection];
        [self.renderDelegate renderDeletionAtPoint:locationInSuperview fromCoordinator:self];
        
    }
    else{

        UIView<I3Collection> *dstCollection;
        
        for(UIView<I3Collection> *collection in self.arena.collections){
            
            CGPoint pointInCollection = [self.gestureRecognizer locationInView:collection];
            
            DND_LOG(@"Testing whether %@ is in %@", NSStringFromCGPoint(pointInCollection), collection);
            
            if([collection pointInside:pointInCollection withEvent:nil]){
                
                DND_LOG(@"Found a target collection to drop on!");
                
                [self handleDragStoppedInCollection:collection atPoint:pointInCollection];
                dstCollection = collection;
                break;
                /// @todo see the todo in handleDragStarted
                
            }
        }

        if(!dstCollection){
            DND_LOG(@"Didn't find a target collection to drop on. Snapping back.");
            [self.renderDelegate renderResetFromPoint:locationInSuperview fromCoordinator:self];
        }

    }

    self.currentDraggingCollection = nil;
    
}


-(void) handleDragStoppedInCollection:(UIView<I3Collection> *)to atPoint:(CGPoint) at{
    
    BOOL isRearrange = to == self.currentDraggingCollection;
    
    DND_LOG(@"Finding index path for item...");
    
    NSIndexPath *atIndex = [to indexPathForItemAtPoint:at];

    DND_LOG(@"Finding item view from index path...");

    UIView *destinationItemView = [to itemAtIndexPath:atIndex];

    DND_LOG(@"Determining what to do with this drop.");
    
    if(
       destinationItemView &&
       isRearrange &&
       [self.dragDataSource respondsToSelector:@selector(canItemFrom:beRearrangedWithItemAt:inCollection:)] &&
       [self.dragDataSource respondsToSelector:@selector(rearrangeItemAt:withItemAt:inCollection:)] &&
       [self.dragDataSource canItemFrom:self.currentDraggingIndexPath beRearrangedWithItemAt:atIndex inCollection:self.currentDraggingCollection]
    ){
        
        DND_LOG(@"Is %@ equal to %@?", self.currentDraggingItem, destinationItemView);
        
        if([self.currentDraggingItem isEqual:destinationItemView]){
            DND_LOG(@"Rearranging the same views. Snapping back.");
            [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
        }
        else{
            DND_LOG(@"Rearranging items in a collection.");
            [self.renderDelegate renderRearrangeOnPoint:at fromCoordinator:self];
            [self.dragDataSource rearrangeItemAt:self.currentDraggingIndexPath withItemAt:atIndex inCollection:self.currentDraggingCollection];
        }

    }
    else if(
        destinationItemView &&
        !isRearrange &&
        [self.dragDataSource respondsToSelector:@selector(canItemAt:fromCollection:beExchangedWithItemAt:inCollection:)] &&
        [self.dragDataSource respondsToSelector:@selector(exchangeItemAt:inCollection:withItemAt:inCollection:)] &&
        [self.dragDataSource canItemAt:self.currentDraggingIndexPath fromCollection:self.currentDraggingCollection beExchangedWithItemAt:atIndex inCollection:to]
    ){
    
        DND_LOG(@"Exchanging items between collections.");
        [self.dragDataSource exchangeItemAt:self.currentDraggingIndexPath inCollection:self.currentDraggingCollection withItemAt:atIndex inCollection:to];
        [self.renderDelegate renderExchangeToCollection:to atPoint:at fromCoordinator:self];

    }
    else if(
        !isRearrange &&
        [self.dragDataSource respondsToSelector:@selector(canItemAt:fromCollection:beAppendedToCollection:atPoint:)] &&
        [self.dragDataSource respondsToSelector:@selector(appendItemAt:fromCollection:toPoint:onCollection:)] &&
        [self.dragDataSource canItemAt:self.currentDraggingIndexPath fromCollection:self.currentDraggingCollection beAppendedToCollection:to atPoint:at]
    ){
        
        DND_LOG(@"Appending item onto collection from another collection.");
        [self.dragDataSource appendItemAt:self.currentDraggingIndexPath fromCollection:self.currentDraggingCollection toPoint:at onCollection:to];
        [self.renderDelegate renderAppendToCollection:to atPoint:at fromCoordinator:self];
        
    }
    else{
        DND_LOG(@"Nope. Can't do anything here - this may be for any number of reasons (see documentation). Snapping back.");
        [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
    }
    
}


-(void) handleDrag{
    
    if(!self.currentDraggingCollection){
        
        DND_LOG(@"Handle drag but we're not dragging.");
        return;
    }

    [self.renderDelegate renderDraggingFromCoordinator:self];
    
}


#pragma mark - Helper methods


/// ...


#pragma mark - Accessor methods


-(UIView *)currentDraggingItem{
    
    return [self.currentDraggingCollection itemAtIndexPath:self.currentDraggingIndexPath];
}


-(NSIndexPath *)currentDraggingIndexPath{
    
    return [self.currentDraggingCollection indexPathForItemAtPoint:self.currentDragOrigin];
}


-(void) setCurrentDraggingCollection:(UIView<I3Collection> *)currentDraggingCollection{
    
    [self setCurrentDraggingCollection:currentDraggingCollection atPoint:CGPointZero];
}


-(void) setCurrentDraggingCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint) at{

    _currentDraggingCollection = collection;
    _currentDragOrigin = at;

}


#pragma mark - Class methods


+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections{
    return [self basicGestureCoordinatorFromViewController:viewController withCollections:collections withRecognizer:nil];    
}


+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections withRecognizer:(UIGestureRecognizer *)recognizer{

    I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:viewController.view containingCollections:collections];
    I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:recognizer];
    coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    
    if([viewController conformsToProtocol:@protocol(I3DragDataSource)]){
        coordinator.dragDataSource = (id<I3DragDataSource>)viewController;
    }
    
    return coordinator;

}


@end
