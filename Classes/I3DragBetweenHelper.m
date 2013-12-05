//
//  I3DragBetweenHelper.m
//  ResourceMoney Client
//
//  Created by Stephen Fortune on 31/08/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3DragBetweenHelper.h"

@interface I3DragBetweenHelper()

/* Redeclaration of 'private' properties */

@property (nonatomic, readwrite, retain) NSIndexPath* draggingIndexPath;

@property (nonatomic, readwrite) CGRect draggingViewPreviousRect;

@property (nonatomic, readwrite) BOOL isDraggingFromSrcCollection;

@property (nonatomic, readwrite) BOOL isDragging;

@property (nonatomic, readwrite, retain) UIPanGestureRecognizer* currentGestureRecognizer;



/** Throws an exception if the view passed in is niether an 
     instance of UITableView nor UICollectionView */

-(void) checkViewIsTableOrCollection:(UIView*) view;

-(BOOL) startDragFromView:(UIView*) container
                  atPoint:(CGPoint) point;

-(void) snapDraggingViewBack;
-(void) shrinkDraggingView;

-(NSIndexPath*) determineIndexForContainer:(UIView*) container
                                   atPoint:(CGPoint) point
                                   forCell:(UIView**) cell;

/** Implemented to add and remove from various superviews */

-(void) setDraggingView:(UIView*) draggingView;


/** Main entry point for pan recognition for routing */

-(void) handlePan:(UIPanGestureRecognizer*) gestureRecognizer;

/** Routes drag start events */

-(void) handleDragStarted:(UIPanGestureRecognizer*) gestureRecognizer;

/** Routes drag stop events */

-(void) handleDragStopped:(UIPanGestureRecognizer*) gestureRecognizer;



/* Bottom level handling methods - these call the delegate */

-(void) handleDrag:(UIPanGestureRecognizer*) gestureRecognizer;

-(void) handleDragStartedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragFromSrcStoppedAtPoint:(CGPoint) point;  // Point local to Src

-(void) handleDragFromSrcStoppedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragFromDstStoppedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragStartedInDstAtPoint:(CGPoint) point; // Point local to Dst

-(void) handleDragFromDstStoppedAtPoint:(CGPoint) point; // Point local to superview

-(void) handleDragFromSrcStoppedInDstAtPoint:(CGPoint) point; // Point local to Dst

-(void) handleDragFromDstStoppedInDstAtPoint:(CGPoint) point; // Point local to Dst



/* Table/collection view helpers */

-(void) reloadCellInContainer:(UIView*) view atIndexPaths:(NSArray*) paths;

-(UIView*) copyOfView:(UIView*) viewToCopy;

-(void) animateDummyExchange:(UIView*) exchange
                 inContainer:(UIView*) container
         withCompletionBlock:(void(^)()) complete;

@end


@implementation I3DragBetweenHelper


-(void) reloadCellInContainer:(UIView*) view atIndexPaths:(NSArray*) paths{

    
    if([view isKindOfClass:[UITableView class]]){

        [(UITableView*)view reloadData];
        //[(UITableView*)view reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];

    }
    else if([view isKindOfClass:[UICollectionView class]]){
        
        [(UICollectionView*)view reloadItemsAtIndexPaths:paths];

    }
}

-(UIView*) copyOfView:(UIView*) viewToCopy{
    
    if([viewToCopy isKindOfClass:[UICollectionViewCell class]]){

        [(UICollectionViewCell*)viewToCopy setHighlighted:NO];
        
        NSData* viewCopyData = [NSKeyedArchiver archivedDataWithRootObject:viewToCopy];
        return [NSKeyedUnarchiver unarchiveObjectWithData:viewCopyData];
        
    }
    else if([viewToCopy isKindOfClass:[UITableViewCell class]]){
        
        [(UITableViewCell*)viewToCopy setHighlighted:NO];
        
        NSData* viewCopyData = [NSKeyedArchiver archivedDataWithRootObject:viewToCopy];
        return [NSKeyedUnarchiver unarchiveObjectWithData:viewCopyData];
        
    }

    
    /* If its not a UITableView or UICollectionView cell then return nil */
    
    return nil;
    
}

-(void) animateDummyExchange:(UIView*) exchange inContainer:(UIView*) container withCompletionBlock:(void(^)()) complete{

    
    /* Create another dummy view and animate the dummy views while the
        actual reloading takes place underneith */
    
    UIView* cellDummy = [self copyOfView:exchange];
    [cellDummy removeFromSuperview];
    [self.superview addSubview:cellDummy];
    
    cellDummy.frame = [self.superview convertRect:exchange.frame fromView:container];
    
    UIView* oldDragginView = self.draggingView;
    
    /* Remove and then readd to superview so it appears ontop */
    
    [oldDragginView removeFromSuperview];
    [self.superview addSubview:oldDragginView];
    
    [UIView animateWithDuration:0.225 animations:^{
        
        oldDragginView.frame = cellDummy.frame;
        cellDummy.frame = [self.superview convertRect:self.draggingViewPreviousRect fromView:container];
        
    } completion:^(BOOL finished) {
        
        [oldDragginView removeFromSuperview];
        [cellDummy removeFromSuperview];
        
        if(complete){
            complete();
        }
        
    }];

}



-(id) initWithSuperview:(UIView*) superview
                srcView:(UIView*) srcView
                dstView:(UIView*) dstView{

    self = [super init];
    
    if(self){
        
        self.superview = superview;
        self.dstView = dstView;
        self.srcView = srcView;
        
        self.isDstRearrangeable = YES;
        self.doesDstRecieveSrc = YES;
        
        self.isSrcRearrangeable = NO;
        self.doesSrcRecieveDst = NO;
        
        self.isDragging = NO;
    }
    
    return self;
}


-(void) checkViewIsTableOrCollection:(UIView*) view{

    if(![view isKindOfClass:[UITableView class]] &&
       ![view isKindOfClass:[UICollectionView class]]){
        
        [NSException raise:@"View is invalid type"
                    format:@"View object passed must either be a table or collection view."];
    }


}


-(NSIndexPath*) determineIndexForContainer:(UIView*) container
                                   atPoint:(CGPoint) point
                                   forCell:(UIView**) cell{

    NSIndexPath* index;

    if([container isKindOfClass:[UITableView class]]){
        
        index = [(UITableView*)container indexPathForRowAtPoint:point];
        if(cell){
            *cell = [(UITableView*)container cellForRowAtIndexPath:index];
        }
    }
    else if([container isKindOfClass:[UICollectionView class]]){
        
        index = [(UICollectionView*)container indexPathForItemAtPoint:point];
        if(cell){
            *cell = [(UICollectionView*)container cellForItemAtIndexPath:index];
        }
    }

    
    return index;
}


-(BOOL) startDragFromView:(UIView*) container atPoint:(CGPoint) point{


    UIView* cell;
    NSIndexPath* index = [self determineIndexForContainer:container
                                                  atPoint:point
                                                  forCell:&cell];

    if(index == nil){
    
        NSLog(@"Invalid Cell.");

        return NO;
    }
    
    BOOL isDraggable = YES;
    
    NSLog(@"Dragging at item:%d section:%d", [index item], [index section]);

    /* Check in the delegate whether its draggable */
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(isCellAtIndexPathDraggable:inContainer:)]){
        
        NSLog(@"Draggable %@ from delegate? %@", container, [self.delegate isCellAtIndexPathDraggable:index inContainer:container] ? @"YES" : @"NO");
        
        isDraggable = isDraggable && [self.delegate isCellAtIndexPathDraggable:index inContainer:container];
    }
    
    
    if(!isDraggable){
        
        NSLog(@"Cell not draggable");
        
        return NO;
    }
    
    
    /* Find the origin inside the window */
    
    CGPoint cellPoint = cell.frame.origin;
    CGRect containerFrame = container.frame;
    CGRect cellFrame = cell.frame;
    
    cellPoint.x += containerFrame.origin.x;
    cellPoint.y += containerFrame.origin.x;
    
    
    /* This is a bit hacky. Consider using KV coding to copy all the properties
        of the CollectionView cell into the temporary dragging cell dynamically */
    
    UIView* cellCopy;
    
    if([container isKindOfClass:[UICollectionView class]]){
        
        UICollectionViewCell* cell = [(UICollectionView*)container cellForItemAtIndexPath:index];
        cellCopy = [self copyOfView:cell];
        
    }
    else if([container isKindOfClass:[UITableView class]]){
        
        UITableViewCell* cell = [(UITableView*)container cellForRowAtIndexPath:index];
        cellCopy = [self copyOfView:cell];
        
    }
    
    self.draggingView = cellCopy;

    self.draggingViewPreviousRect = cellFrame;
    self.draggingIndexPath = index;
    
    
    /* Translate the cell's coords to global coords */
    
    self.draggingView.frame = [self.superview convertRect:cellFrame fromView:container];
    
    [self.draggingView setHidden:NO];
    
    NSLog(@"Adding dragging data: %d, draggingView %@", [index row], self.draggingView);
    
    return YES;

}


-(void) shrinkDraggingView{

    if(!self.draggingView){
    
        return;
    }
    
    
    UIView* draggingView = self.draggingView;
    
    /* 'Deleting' animation */
    
    draggingView.clipsToBounds = YES;
    
    CGRect goneFrame = self.draggingView.frame;
    goneFrame.origin.x += goneFrame.size.width/2;
    goneFrame.origin.y += goneFrame.size.height/2;
    goneFrame.size.width = 0;
    goneFrame.size.height = 0;
    
    BOOL isSrc = self.isDraggingFromSrcCollection;
    

    /* Animation completion block */
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        
        
        /* Calls delegate to delete item at index path*/
        
        if(isSrc && [self.delegate respondsToSelector:@selector(itemFromSrcDeletedAtIndexPath:)]){
            
            NSLog(@"Deletion handler for Src triggered");
            
            [self.delegate performSelector:@selector(itemFromSrcDeletedAtIndexPath:)
                                withObject:self.draggingIndexPath];
        }
        else if(!isSrc && [self.delegate respondsToSelector:@selector(itemFromDstDeletedAtIndexPath:)]){
            
            NSLog(@"Deletion handler for Dst triggered");

            [self.delegate performSelector:@selector(itemFromDstDeletedAtIndexPath:)
                                withObject:self.draggingIndexPath];
            
        }
        else{
            NSLog(@"Deletion occured but no item deletion handler was present.");
        }
        
        /* Remove the dummy view from the superview. */
        
        [draggingView removeFromSuperview];
        
    };
    
    [UIView animateWithDuration:0.2
    animations:^{
    
        draggingView.frame = goneFrame;
    
    } completion:completionBlock];

    self.draggingView = nil;
}


-(void) snapDraggingViewBack{
    

    UIView* previousSuperview = self.isDraggingFromSrcCollection ? self.srcView : self.dstView;
    UIView* dragginView = self.draggingView;
    NSIndexPath* dragginIndex = self.draggingIndexPath;
    
    CGRect previousGlobalRect = [self.superview convertRect:self.draggingViewPreviousRect
                                                   fromView:previousSuperview];
    
    

    void (^completion)(BOOL finished) = ^(BOOL finished){
        
        NSLog(@"Animation complete!");
        
        
        
        if(self.isDraggingFromSrcCollection && self.delegate &&
           [self.delegate respondsToSelector:@selector(dragFromSrcSnappedBackFromIndexPath:)]){
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:@selector(dragFromSrcSnappedBackFromIndexPath:) withObject:dragginIndex];
#pragma clang diagnostic pop
            
        }
        else if(!self.isDraggingFromSrcCollection && self.delegate &&
                [self.delegate respondsToSelector:@selector(dragFromDstSnappedBackFromIndexPath:)]){
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:@selector(dragFromDstSnappedBackFromIndexPath:) withObject:dragginIndex];
#pragma clang diagnostic pop
            
        }        

        [dragginView removeFromSuperview];
    };
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         dragginView.frame = previousGlobalRect;
                     }
                     completion:completion];
    
    
    self.draggingView = nil;

}


/* Handling and routing */

-(void) handlePan:(UIPanGestureRecognizer*) gestureRecognizer{

    switch([gestureRecognizer state]){
            
        case UIGestureRecognizerStateBegan:
            
            NSLog(@"Drag Started");

            [self handleDragStarted:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateChanged:

            //NSLog(@"Dragging");
            
            [self handleDrag:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            NSLog(@"Drag Stopped");
            
            [self handleDragStopped:gestureRecognizer];
            break;
            
        default:
            break;
            
    }

}


-(void) handleDragStarted:(UIPanGestureRecognizer*) gestureRecognizer{
        
    CGPoint pointInDst = [gestureRecognizer locationInView:self.dstView];
    CGPoint pointInSrc = [gestureRecognizer locationInView:self.srcView];
    self.isDragging = YES;
    
    if([self.dstView pointInside:pointInDst withEvent:nil]){
        
        /* Route to Dst view handler */
        
        [self handleDragStartedInDstAtPoint:pointInDst];
        
    }
    else if([self.srcView pointInside:pointInSrc withEvent:nil]){
        
        /* Route to Src view handler */
        
        [self handleDragStartedInSrcAtPoint:pointInSrc];
    }

    /* If its anywhere else then ignore */
}


-(void) handleDragStopped:(UIPanGestureRecognizer*) gestureRecognizer{
 
    if(!self.isDragging){
        NSLog(@"Invalid drag stopped.");
        return;
    }
    
    self.isDragging = NO;
    
    CGPoint point = [gestureRecognizer locationInView:self.superview];
    CGPoint positionInSrc = [self.srcView convertPoint:point fromView:self.superview];
    CGPoint positionInDst = [self.dstView convertPoint:point fromView:self.superview];
    
    if(self.isDraggingFromSrcCollection
       && [self.srcView pointInside:positionInSrc withEvent:nil]){
        
        NSLog(@"Dragging from source to source.");
        
        /* Dragged from the source to the source */
        
        [self handleDragFromSrcStoppedInSrcAtPoint:positionInSrc];
    }
    else if(self.isDraggingFromSrcCollection
            && [self.dstView pointInside:positionInDst withEvent:nil]){
        
        NSLog(@"Dragging from source to destination.");

        /* Dragged from the source to the destination */
        
        [self handleDragFromSrcStoppedInDstAtPoint:positionInDst];
        
    }
    else if(self.isDraggingFromSrcCollection){
        
        NSLog(@"Dragging from source to nowhere.");

        /* Dragged from the source to nowhere */
        
        [self handleDragFromSrcStoppedAtPoint:point];
        
    }
    else if(!self.isDraggingFromSrcCollection
            && [self.srcView pointInside:positionInSrc withEvent:nil]){
        
        NSLog(@"Dragging from destination to source.");

        /* Dragged from the destination to the source */
        
        [self handleDragFromDstStoppedInSrcAtPoint:positionInSrc];
    }
    else if(!self.isDraggingFromSrcCollection
            && [self.dstView pointInside:positionInDst withEvent:nil]){
        
        NSLog(@"Dragging from destination to destination.");

        /* Dragged from the destination to the destination */
        
        [self handleDragFromDstStoppedInDstAtPoint:positionInDst];
        
    }
    else if(!self.isDraggingFromSrcCollection){
        
        NSLog(@"Dragging from destination to nowhere.");

        /* Dragged from the destination to nowhere */
        
        [self handleDragFromDstStoppedAtPoint:point];
        
    }

}


-(void) handleDrag:(UIPanGestureRecognizer*) gestureRecognizer{

    if(!self.isDragging){
        
        /* Catch erronious dragging gestures */
        
        NSLog(@"Handle drag but we're not dragging.");
        return;
    }
    
    /* Translate */
    
    CGPoint translation = [gestureRecognizer translationInView:[self.draggingView superview]];
    [self.draggingView setCenter:CGPointMake([self.draggingView center].x + translation.x,
                                             [self.draggingView center].y + translation.y)];
    [gestureRecognizer setTranslation:CGPointZero inView:[self.draggingView superview]];

}


-(void) handleDragStartedInSrcAtPoint:(CGPoint) point{
    
    self.isDraggingFromSrcCollection = YES;

    if([self startDragFromView:self.srcView
                       atPoint:point]){
        
        /* Any extra starting translations should be applied in the delegate */
        
        if([self.delegate respondsToSelector:@selector(dragFromSrcStartedAtIndexPath:)]){
            
            NSIndexPath* path = [self determineIndexForContainer:self.dstView atPoint:point forCell:nil];
            [self.delegate dragFromSrcStartedAtIndexPath:path];
        }

    }
    else{
        
        /* If its an invalid cell then no dragging is started */
        
        //self.isDragging = NO;
        self.draggingView = nil;

    }

}


-(void) handleDragFromSrcStoppedAtPoint:(CGPoint) point{
    
    /* Determine from the delegate whether the view should be snapped
        back or disappear */
    
    BOOL shouldSnapBack = YES;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOutsideAtPoint:fromSrcIndexPath:)]){
        shouldSnapBack = [self.delegate droppedOutsideAtPoint:point fromSrcIndexPath:self.draggingIndexPath];
    }

    if(shouldSnapBack){
        [self snapDraggingViewBack];
    }
    else{
        [self shrinkDraggingView];
    }
    
}


-(void) handleDragFromSrcStoppedInSrcAtPoint:(CGPoint) point{
    
    if(self.isSrcRearrangeable && self.draggingView){
        
        /* Rearrange source collection/table */

        UIView* cell;
        NSIndexPath* index = [self determineIndexForContainer:self.srcView atPoint:point forCell:&cell];
        
        if(index == nil){
            
            NSLog(@"Invalid Cell");
            
            [self snapDraggingViewBack];
            
            return;
        }
        
        BOOL isExchangable = YES;
        
        /* Check in the delegate whether its exchangable */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(isCellInSrcAtIndexPathExchangable:withCellAtIndexPath:)]){
            isExchangable =  [self.delegate isCellInSrcAtIndexPathExchangable:index withCellAtIndexPath:self.draggingIndexPath];
        }
        
        if(!isExchangable){
            
            NSLog(@"Cell not Exchangable.");
            
            [self snapDraggingViewBack];

            return;
        }
        
        
        NSLog(@"Cell row: %d", [index row]);
        
        
        /* Catch dropping on the same cell - this causes an an inconistency exception
            if not caught. */
        
        if(([index row] == [self.draggingIndexPath row] &&
            [index section] == [self.draggingIndexPath section])){
            
            NSLog(@"Invaliditiy caught, index: %@", index);

            [self snapDraggingViewBack];

            return;
            
        }

        
        /* Trigger a separate 'dummy' animation for the exchange */
        
        [self animateDummyExchange:cell inContainer:self.srcView withCompletionBlock:^{
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromSrcIndexPath:)]){
                
                [self.delegate droppedOnSrcAtIndexPath:index fromSrcIndexPath:self.draggingIndexPath];
                [self reloadCellInContainer:self.srcView atIndexPaths:@[index, self.draggingIndexPath]];
            }
            
        }];
        
        
        self.draggingView = nil;

    }
    else if(self.draggingView){
    
        /* Snap view back */
        
        [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];
        
    }
    
    

}


-(void) handleDragFromSrcStoppedInDstAtPoint:(CGPoint) point{
    
    if(self.doesDstRecieveSrc
       && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromSrcIndexPath:)]
       && self.draggingView){
        
        NSIndexPath* index = [self determineIndexForContainer:self.dstView atPoint:point forCell:nil];
        
        /* Catching invalid cells being dropped */
        
        if(index == nil){
            
            [self snapDraggingViewBack];
            return;
            
        }

        if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromSrcIndexPath:)]){
            [self.delegate droppedOnDstAtIndexPath:index fromSrcIndexPath:self.draggingIndexPath];
        }
        
        // TODO Implement drop animation here
        
        [self.draggingView removeFromSuperview];
        self.draggingView = nil;

    }
    else if(self.draggingView){
    
        /* Snap view back */
        
        [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];
    }
    

}


-(void) handleDragStartedInDstAtPoint:(CGPoint) point{
    
    self.isDraggingFromSrcCollection = NO;

    if([self startDragFromView:self.dstView atPoint:point]){
        
        /* Any extra starting translations should be applied in the delegate */
        
        if([self.delegate respondsToSelector:@selector(dragFromDstStartedAtIndexPath:)]){
            
            NSIndexPath* path = [self determineIndexForContainer:self.dstView atPoint:point forCell:nil];
            [self.delegate dragFromDstStartedAtIndexPath:path];
            
        }
        
    }
    else{

        /* If its an invalid cell then no dragging is started */

        self.draggingView = nil;
    }
    
}


-(void) handleDragFromDstStoppedAtPoint:(CGPoint) point{
    
    /* Determine from the delegate whether the view should be snapped 
        back or disappear */

    BOOL shouldSnapBack = YES;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOutsideAtPoint:fromDstIndexPath:)]){
        shouldSnapBack = [self.delegate droppedOutsideAtPoint:point fromDstIndexPath:self.draggingIndexPath];
    }
    
    if(shouldSnapBack){
        [self snapDraggingViewBack];
    }
    else{
        [self shrinkDraggingView];
    }

    
}


-(void) handleDragFromDstStoppedInSrcAtPoint:(CGPoint) point{
    
    if(self.doesSrcRecieveDst
       && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromDstIndexPath:)]
       && self.draggingView){
    
        NSIndexPath* index = [self determineIndexForContainer:self.srcView atPoint:point forCell:nil];
        
        /* Catching invalid cells being dropped */
        
        if(index == nil){
            
            [self snapDraggingViewBack];
            return;
            
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromDstIndexPath:)]){
            [self.delegate droppedOnSrcAtIndexPath:index fromDstIndexPath:self.draggingIndexPath];
        }
        

        /* Get rid of the dragging view */
        
        [self.draggingView removeFromSuperview];
        self.draggingView = nil;
        
        
    }
    else if(self.draggingView){
        
        [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];
    }
    
    
}


-(void) handleDragFromDstStoppedInDstAtPoint:(CGPoint) point{
    
    
    if(self.isDstRearrangeable
       && self.draggingView){
        
        NSLog(@"Rearrangeing dst");
        
        /* Rearrange source collection/table */
        
        UIView* cell;
        NSIndexPath* index = [self determineIndexForContainer:self.dstView atPoint:point forCell:&cell];
        
        
        /* Catch invalid cells */
        
        if(index == nil){
        
            NSLog(@"Invalid cell");
            
            [self snapDraggingViewBack];

            return;
        }
        
        BOOL isExchangable = YES;
        
        
        /* Check in the delegate whether its exchangable */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(isCellInDstAtIndexPathExchangable:withCellAtIndexPath:)]){
            
            isExchangable = [self.delegate isCellInDstAtIndexPathExchangable:index withCellAtIndexPath:self.draggingIndexPath];
        }
        
        if(!isExchangable){
            
            NSLog(@"Not Exchangable");
            
            [self snapDraggingViewBack];
            
            return;
        }
        
        
        NSLog(@"Cell row: %d", [index row]);

        /* Catch dropping on the same cell - this causes an an inconistency exception
            if not caught. */
        
        if(([index row] == [self.draggingIndexPath row] &&
            [index section] == [self.draggingIndexPath section])){
            
            NSLog(@"Invaliditiy caught, index: %@", index);
            
            [self snapDraggingViewBack];
            
            return;
        }
        
        
        /* Trigger a separate 'dummy' animation for the exchange */
        
        [self animateDummyExchange:cell inContainer:self.dstView withCompletionBlock:^{
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromDstIndexPath:)]){
                
                [self.delegate droppedOnDstAtIndexPath:index fromDstIndexPath:self.draggingIndexPath];
                [self reloadCellInContainer:self.dstView atIndexPaths:@[index, self.draggingIndexPath]];
                
            }
            
        }];
        
        
        self.draggingView = nil;
        
    }
    else if(self.draggingView){
        
        /* Snap view back */
        
        [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];

    }

}



/* Setters */

-(void) setSuperview:(UIView*) superview{

    [_superview removeGestureRecognizer:self.currentGestureRecognizer];
    
    _superview = superview;
    
    SEL dragSel = @selector(handlePan:);
    
    self.currentGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:dragSel];
    [_superview addGestureRecognizer:self.currentGestureRecognizer];

}


-(void) setSrcView:(UIView*) srcView{
    
    [self checkViewIsTableOrCollection:srcView];
    
    _srcView = srcView;
}


-(void) setDstView:(UIView*) dstView{

    [self checkViewIsTableOrCollection:dstView];
    
    _dstView = dstView;

}


-(void) setDraggingView:(UIView*) draggingView{
        
    if(draggingView){
        [self.superview addSubview:draggingView];
    }

    _draggingView = draggingView;
    
}

-(void) dealloc{

    [_superview removeGestureRecognizer:self.currentGestureRecognizer];

}


@end
