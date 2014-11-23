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
@property (nonatomic, weak, readwrite) id<I3Collection> currentDraggingCollection;


/**
 
 Sets the current dragging collection from its origin.
 
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
 
 Called when a drag has stopped on a origin within a collection.
 
 */
-(void) handleDragStoppedInCollection:(id<I3Collection>) to atPoint:(CGPoint) at;


@end


@implementation I3GestureCoordinator


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
    
    for (id<I3Collection> collection in self.arena.collections){
        
        UIView* collectionView = collection.collectionView;
        CGPoint pointInCollection = [self.gestureRecognizer locationInView:collectionView];
        
        if([collectionView pointInside:pointInCollection withEvent:nil]){
            
            DND_LOG(@"We're dragging in a collection!");
            
            if(
               [collection itemAtPoint:pointInCollection] &&
               [self.dragDataSource canItemBeDraggedAtPoint:pointInCollection inCollection:collection]
            ){
                
                DND_LOG(@"We can drag item %d in collection", [self.arena.collections indexOfObject:collection]);

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
       [self.dragDataSource respondsToSelector:@selector(canItemAtPoint:beDeletedFromCollection:atPoint:)] &&
       [self.dragDataSource respondsToSelector:@selector(deleteItemAtPoint:inCollection:)] &&
       [self.dragDataSource canItemAtPoint:self.currentDragOrigin beDeletedFromCollection:self.currentDraggingCollection atPoint:locationInSuperview]
       ){
        
        DND_LOG(@"Data source wants us to delete this! Deleting...");
        [self.dragDataSource deleteItemAtPoint:self.currentDragOrigin inCollection:self.currentDraggingCollection];
        [self.renderDelegate renderDeletionAtPoint:locationInSuperview fromCoordinator:self];
        
    }
    else{

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
            DND_LOG(@"Didn't find a target collection to drop on. Snapping back.");
            [self.renderDelegate renderResetFromPoint:locationInSuperview fromCoordinator:self];
        }

    }

    self.currentDraggingCollection = nil;
    
}


-(void) handleDragStoppedInCollection:(id<I3Collection>) to atPoint:(CGPoint) at{
    
    BOOL isRearrange = to == self.currentDraggingCollection;
    UIView *destinationItemView = [to itemAtPoint:at];

    DND_LOG(@"Determining what to do with this drop.");
    
    if(
       destinationItemView &&
       isRearrange &&
       [self.dragDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)] &&
       [self.dragDataSource respondsToSelector:@selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:)] &&
       [self.dragDataSource canItemFromPoint:self.currentDragOrigin beRearrangedWithItemAtPoint:at inCollection:self.currentDraggingCollection]
    ){
        
        UIView *draggingItemView = [self.currentDraggingCollection itemAtPoint:self.currentDragOrigin];
        
        DND_LOG(@"Is %@ equal to %@?", draggingItemView, destinationItemView);
        
        if([draggingItemView isEqual:destinationItemView]){
            DND_LOG(@"Rearranging the same views. Snapping back.");
            [self.renderDelegate renderResetFromPoint:at fromCoordinator:self];
        }
        else{
            DND_LOG(@"Rearranging items in a collection.");
            [self.renderDelegate renderRearrangeOnPoint:at fromCoordinator:self];
            [self.dragDataSource rearrangeItemAtPoint:self.currentDragOrigin withItemAtPoint:at inCollection:self.currentDraggingCollection];
        }

    }
    else if(
        destinationItemView &&
        !isRearrange &&
        [self.dragDataSource respondsToSelector:@selector(canItemAtPoint:fromCollection:beExchangedWithItemAtPoint:inCollection:)] &&
        [self.dragDataSource respondsToSelector:@selector(exchangeItemAtPoint:inCollection:withItemAtPoint:inCollection:)] &&
        [self.dragDataSource canItemAtPoint:self.currentDragOrigin fromCollection:self.currentDraggingCollection beExchangedWithItemAtPoint:at inCollection:to]
    ){
    
        DND_LOG(@"Exchanging items between collections.");
        [self.dragDataSource exchangeItemAtPoint:self.currentDragOrigin inCollection:self.currentDraggingCollection withItemAtPoint:at inCollection:to];
        [self.renderDelegate renderExchangeToCollection:to atPoint:at fromCoordinator:self];

    }
    else if(
        !isRearrange &&
        [self.dragDataSource respondsToSelector:@selector(canItemAtPoint:fromCollection:beAppendedToCollection:atPoint:)] &&
        [self.dragDataSource respondsToSelector:@selector(appendItemAtPoint:fromCollection:toPoint:onCollection:)] &&
        [self.dragDataSource canItemAtPoint:self.currentDragOrigin fromCollection:self.currentDraggingCollection beAppendedToCollection:to atPoint:at]
    ){
        
        DND_LOG(@"Appending item onto collection from another collection.");
        [self.dragDataSource appendItemAtPoint:self.currentDragOrigin fromCollection:self.currentDraggingCollection toPoint:at onCollection:to];
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


#pragma mark - Accessor methods


-(void) setCurrentDraggingCollection:(id<I3Collection>) currentDraggingCollection{
    
    [self setCurrentDraggingCollection:currentDraggingCollection atPoint:CGPointZero];
}


-(void) setCurrentDraggingCollection:(id<I3Collection>) collection atPoint:(CGPoint) at{

    _currentDraggingCollection = collection;
    _currentDragOrigin = at;

}


#pragma mark - Class methods


+(instancetype) basicGestureCoordinatorFromViewController:(UIViewController *)viewController withCollections:(NSArray *)collections{
    
    I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:viewController.view containingCollections:collections];
    I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:nil];
    coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    
    if([viewController conformsToProtocol:@protocol(I3DragDataSource)]){
        coordinator.dragDataSource = (id<I3DragDataSource>)viewController;
    }
    
    return coordinator;
    
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
