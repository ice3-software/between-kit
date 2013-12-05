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
                  atPoint:(CGPoint) point
                 makeCopy:(BOOL) makeCopy;

-(void) snapBackToSuperview:(UIView*) superview;
-(void) dissappearFromDraggingView;

-(void) transitionView:(UIView*) view
               toFrame:(CGRect) frame
           toSuperview:(UIView*) superview;

/** Changes a view's superview - should be noted that it also
     retranslates the view into its new superview's local coords
     (ie the view will not appear to change position) */

-(void) changeSuperviewForView:(UIView*) view forSuperview:(UIView*) superview;

-(NSIndexPath*) determineIndexForContainer:(UIView*) container
                                   atPoint:(CGPoint) point
                                   forCell:(UIView**) cell;

/** Implemented to add and remove from various superviews */

-(void) setDraggingView:(UIView*) draggingView;

/** Reload tabel/collection view completely */

-(void) reloadDataInView:(UIView*) view;


/** Main entry point for pan recognition for routing */

-(void) handlePan:(UIPanGestureRecognizer*) gestureRecognizer;

/** Routes drag start events */

-(void) handleDragStarted:(UIPanGestureRecognizer*) gestureRecognizer;

/** Routes drag stop events */

-(void) handleDragStopped:(UIPanGestureRecognizer*) gestureRecognizer;



/* Bottom level handling methods - these call the delegate */

-(void) handleDrag:(UIPanGestureRecognizer*) gestureRecognizer;

-(void) handleDragAnimationComplete;

-(void) handleDragStartedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragFromSrcStoppedAtPoint:(CGPoint) point;  // Point local to Src

-(void) handleDragFromSrcStoppedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragFromDstStoppedInSrcAtPoint:(CGPoint) point; // Point local to Src

-(void) handleDragStartedInDstAtPoint:(CGPoint) point; // Point local to Dst

-(void) handleDragFromDstStoppedAtPoint:(CGPoint) point; // Point local to superview

-(void) handleDragFromSrcStoppedInDstAtPoint:(CGPoint) point; // Point local to Dst

-(void) handleDragFromDstStoppedInDstAtPoint:(CGPoint) point; // Point local to Dst


@end


@implementation I3DragBetweenHelper


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

        self.isDragViewFromDstDuplicate = NO;
        self.isDragViewFromSrcDuplicate = YES;
        
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


-(BOOL) startDragFromView:(UIView*) container atPoint:(CGPoint) point makeCopy:(BOOL) makeCopy{


    UIView* cell;
    NSIndexPath* index = [self determineIndexForContainer:container
                                                  atPoint:point
                                                  forCell:&cell];
    BOOL isDraggable = index != nil;
    
    NSLog(@"Dragging at item:%d section:%d", [index item], [index section]);
        
    /* Check in the delegate whether its draggable */
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(isCellAtIndexPathDraggable:inContainer:)]){
        
        NSLog(@"Draggable %@ from delegate? %@", container, [self.delegate isCellAtIndexPathDraggable:index
                                                                                          inContainer:container] ? @"YES" : @"NO");
        isDraggable = isDraggable && [self.delegate isCellAtIndexPathDraggable:index
                                                                       inContainer:container];
    }
    
    if(!isDraggable){
        NSLog(@"Invalid Cell or Cell not Draggable.");
        return NO;
    }
    
    /* Find the origin inside the window */
    
    CGPoint cellPoint = cell.frame.origin;
    CGRect containerFrame = container.frame;
    CGRect cellFrame = cell.frame;
    
    cellPoint.x += containerFrame.origin.x;
    cellPoint.y += containerFrame.origin.x;
    
    if(makeCopy){
        
        /* This is a bit hacky. Consider using KV coding to copy all the properties
            of the CollectionView cell into the temporary dragging cell dynamically */
        
        UIView* cellCopy;

        if([container isKindOfClass:[UICollectionView class]]){
        
            UICollectionViewCell* cell = [(UICollectionView*)container cellForItemAtIndexPath:index];
            [cell setHighlighted:NO];
            NSData* viewCopyData = [NSKeyedArchiver archivedDataWithRootObject:cell];
            cellCopy = [NSKeyedUnarchiver unarchiveObjectWithData:viewCopyData];
            
        }
        else if([container isKindOfClass:[UITableView class]]){
        
            UITableViewCell* cell = [(UITableView*)container cellForRowAtIndexPath:index];
            [cell setHighlighted:NO];
            NSData* viewCopyData = [NSKeyedArchiver archivedDataWithRootObject:cell];
            cellCopy = [NSKeyedUnarchiver unarchiveObjectWithData:viewCopyData];

        }
        
        self.draggingView = cellCopy;

    }
    else{
        self.draggingView = cell;
    }
    self.draggingViewPreviousRect = cellFrame;
    self.draggingIndexPath = index;
    
    
    /* Translate the cell's coords to global coords */
    
    self.draggingView.frame = [self.superview convertRect:cellFrame fromView:container];
    
    [self.draggingView setHidden:NO];
    NSLog(@"Adding dragging data: %d, draggingView %@", [index row], self.draggingView);
    NSLog(@"Dragging view opactiy %f, is hidden", self.draggingView.alpha);
    
    return YES;

}


-(void) dissappearFromDraggingView{

    if(!self.draggingView){
    
        return;
    }
    
    
    /* 'Deleting' animation */
    
    self.draggingView.clipsToBounds = YES;
    
    CGRect goneFrame = self.draggingView.frame;
    goneFrame.origin.x += goneFrame.size.width/2;
    goneFrame.origin.y += goneFrame.size.height/2;
    goneFrame.size.width = 0;
    goneFrame.size.height = 0;
    
    BOOL isSrc = self.isDraggingFromSrcCollection;
    
    /* Completion block delcared up here so the automatic indentation doesn't
        make this totally unreadable. */
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        
        
        /* Calls delegate to delete item at index path*/
        
        if(isSrc &&
           self.delegate &&
           [self.delegate respondsToSelector:@selector(itemFromSrcDeletedAtIndexPath:)]){
            
            NSLog(@"Deletion handler for Src triggered");
            
            [self.delegate performSelector:@selector(itemFromSrcDeletedAtIndexPath:)
                                withObject:self.draggingIndexPath];
        }
        else if(!isSrc
                && self.delegate
                && [self.delegate respondsToSelector:@selector(itemFromDstDeletedAtIndexPath:)]){
            
            NSLog(@"Deletion handler for Dst triggered");

            [self.delegate performSelector:@selector(itemFromDstDeletedAtIndexPath:)
                                withObject:self.draggingIndexPath];
            
        }
        else{
            NSLog(@"Deletion occured but no itemDeletion handler was present.");
        }
        
        /* After its deleted the data its removes the view completely
         without returning it to its owning view. */
        
        [self changeSuperviewForView:self.draggingView
                        forSuperview:nil];
        [self handleDragAnimationComplete];
        
    };
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.draggingView.frame = goneFrame;
                     }
                     completion:completionBlock];

}


-(void) snapBackToSuperview:(UIView*) superview{
    

    /* This is ugly - we determing the previous view based on the
        _isDraggingFromSrcCollection flag */
    
    UIView* previousSuperview = self.isDraggingFromSrcCollection ? self.srcView : self.dstView;
    
    
    /* Check for duplicate views and delete them so that we don't attach them
     to their duplicate's superview */
    
    if((self.isDraggingFromSrcCollection && self.isDragViewFromSrcDuplicate) ||
       (!self.isDraggingFromSrcCollection && self.isDragViewFromDstDuplicate)){
        
        NSLog(@"Dragging duplicate view");
        
        /* Find the superview that the previous rect is relative to and pass it down */
        
        CGRect previousGlobalRect = [self.superview convertRect:self.draggingViewPreviousRect
                                                       fromView:previousSuperview];
        
        [self transitionView:self.draggingView
                     toFrame:previousGlobalRect
                 toSuperview:nil];
        
    }
    else{
        
        /* Find the superview that the previous rect is relative to and pass it down */
        
        CGRect previousGlobalRect = [self.superview convertRect:self.draggingViewPreviousRect
                                                       fromView:previousSuperview];
        
        [self transitionView:self.draggingView
                     toFrame:previousGlobalRect
                 toSuperview:superview];
        
    }
    
    
    self.draggingView = nil;


}


-(void) reloadDataInView:(UIView*) view{
    
    if([view isKindOfClass:[UITableView class]]){
        
        [(UITableView*)view reloadData];
        
    }
    else if([view isKindOfClass:[UICollectionView class]]){
        
        [(UICollectionView*)view reloadData];
        
    }
    
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
                       atPoint:point
                      makeCopy:self.isDragViewFromSrcDuplicate]){
        
        /* Any extra starting translations should be applied in the delegate */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(dragFromSrcStartedAtPoint:)]){
            [self.delegate dragFromSrcStartedAtPoint:point];
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
        [self snapBackToSuperview:self.srcView];
    }
    else{
        [self dissappearFromDraggingView];
    }
    
}


-(void) handleDragFromSrcStoppedInSrcAtPoint:(CGPoint) point{
    
    if(self.isSrcRearrangeable && self.draggingView){
        
        /* Rearrange source collection/table */

        UIView* cell;
        NSIndexPath* index = [self determineIndexForContainer:self.srcView
                                                      atPoint:point
                                                      forCell:&cell];
        
        BOOL isExchangable = YES;//(BOOL)cell;
        
        
        /* Check in the delegate whether its exchangable */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(isCellInSrcAtIndexPathExchangable:withCellAtIndexPath:)]){
            
            isExchangable = /*isExchangable &&*/ [self.delegate isCellInSrcAtIndexPathExchangable:index
                                                                          withCellAtIndexPath:self.draggingIndexPath];
        }
        
        if(!isExchangable){
            NSLog(@"Invalid Cell or not Exchangable.");
            
            [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];

            return;
        }
        
        NSLog(@"Cell row: %d", [index row]);
        
        /* Catch dropping on the same cell - this causes an an inconistency exception
            if not caught. Also catch invalid droop indexes (nil) */
        
        if(([index row] == [self.draggingIndexPath row] &&
            [index section] == [self.draggingIndexPath section]) ||
            index == nil){
            
            NSLog(@"Invaliditiy caught, index: %@", index);

            [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];

            return;
            
        }
        
        
        CGRect cellFrame = cell.frame;
        CGRect draggingRect = self.draggingViewPreviousRect;
        UIView* dragginView = self.draggingView;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             dragginView.frame = [self.superview convertRect:cellFrame fromView:self.srcView];
                             cell.frame = draggingRect;
                         }
                         completion:^(BOOL finished){
                             
                             if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromSrcIndexPath:)]){
                                 [self.delegate droppedOnSrcAtIndexPath:index fromSrcIndexPath:self.draggingIndexPath];
                             }
                             
                             [self changeSuperviewForView:dragginView forSuperview:nil];
                             //[self reloadDataInView:self.dstView atIndeces:@[index, self.draggingIndexPath]];
                             [self reloadDataInView:self.srcView];
                             [self handleDragAnimationComplete];
                             
                             
                         }];


    }
    else{
    
        /* Snap view back */
        
        [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];
        
    }
    
    

}


-(void) handleDragFromSrcStoppedInDstAtPoint:(CGPoint) point{
    
    if(self.doesDstRecieveSrc
       && self.delegate
       && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromSrcIndexPath:)]
       && self.draggingView){
        
        NSIndexPath* index = [self determineIndexForContainer:self.dstView atPoint:point forCell:nil];
        
        /* Catching invalid cells being dropped */
        
        if(!index){
            
            NSLog(@"Bad drop caught.");
            [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];
            return;
            
        }

        if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromSrcIndexPath:)]){
            [self.delegate droppedOnDstAtIndexPath:index fromSrcIndexPath:self.draggingIndexPath];
        }
        
        // TODO Implement drop animation here
        
        if(self.isDraggingFromSrcCollection){
            [self changeSuperviewForView:self.draggingView forSuperview:nil];
        }
        else{
            [self changeSuperviewForView:self.draggingView forSuperview:self.srcView];
        }

    }
    else{
    
        /* Snap view back */
        
        [self handleDragFromSrcStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];
    }
    

}


-(void) handleDragStartedInDstAtPoint:(CGPoint) point{
    
    self.isDraggingFromSrcCollection = NO;

    if([self startDragFromView:self.dstView atPoint:point makeCopy:self.isDragViewFromDstDuplicate]){
        
        /* Any extra starting translations should be applied in the delegate */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(dragFromDstStartedAtPoint:)]){
            [self.delegate dragFromDstStartedAtPoint:point];
        }
        
    }
    else{

        /* If its an invalid cell then no dragging is started */

        //self.isDragging = NO;
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
        [self snapBackToSuperview:self.dstView];
    }
    else{
        [self dissappearFromDraggingView];
    }

    
}


-(void) handleDragFromDstStoppedInSrcAtPoint:(CGPoint) point{
    
    if(self.doesSrcRecieveDst
       && self.delegate
       && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromDstIndexPath:)]
       && self.draggingView){
    
        NSIndexPath* index = [self determineIndexForContainer:self.srcView atPoint:point forCell:nil];
        
        /* Catching invalid cells being dropped */
        
        if(!index){
            
            [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];
            return;
            
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnSrcAtIndexPath:fromDstIndexPath:)]){
            [self.delegate droppedOnSrcAtIndexPath:index fromDstIndexPath:self.draggingIndexPath];
        }
        
        /* Put the draggin view back in its superview or diguard
            of it if needs be. */
        
        if(self.isDragViewFromDstDuplicate){
            [self changeSuperviewForView:self.draggingView forSuperview:nil];
        }
        else{
            [self changeSuperviewForView:self.draggingView forSuperview:self.dstView];
        }
        
        // TODO Implement drop animation here
        
    }
    else{
        
        [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.srcView]];
    }
    
    
}


-(void) handleDragFromDstStoppedInDstAtPoint:(CGPoint) point{
    
    
    if(self.isDstRearrangeable && self.draggingView){
        
        NSLog(@"Rearrangeing dst");
        
        /* Rearrange source collection/table */
        
        UIView* cell;
        NSIndexPath* index = [self determineIndexForContainer:self.dstView
                                                      atPoint:point
                                                      forCell:&cell];
        
        BOOL isExchangable = YES;//(BOOL)cell;
        
        
        /* Check in the delegate whether its exchangable */
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(isCellInDstAtIndexPathExchangable:withCellAtIndexPath:)]){
            
            isExchangable = /*isExchangable &&*/ [self.delegate isCellInDstAtIndexPathExchangable:index
                                                                          withCellAtIndexPath:self.draggingIndexPath];
        }
        
        if(!isExchangable){
            NSLog(@"Invalid Cell or Not Exchangable");
            
            [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];

            return;
        }
        
        NSLog(@"Cell row: %d", [index row]);

        /* Catch dropping on the same cell - this causes an an inconistency exception
         if not caught. Also catch invalid droop indexes (nil) */
        
        if(([index row] == [self.draggingIndexPath row] &&
            [index section] == [self.draggingIndexPath section]) ||
           index == nil){
            
            NSLog(@"Invaliditiy caught, index: %@", index);
            
            [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];
            
            return;
        }
        
        CGRect cellFrame = cell.frame;
        CGRect draggingRect = self.draggingViewPreviousRect;
        UIView* dragginView = self.draggingView;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             dragginView.frame = [self.superview convertRect:cellFrame fromView:self.dstView];
                             cell.frame = draggingRect;
                         }
                         completion:^(BOOL finished){
                             
                             if(self.delegate && [self.delegate respondsToSelector:@selector(droppedOnDstAtIndexPath:fromDstIndexPath:)]){
                                 [self.delegate droppedOnDstAtIndexPath:index fromDstIndexPath:self.draggingIndexPath];
                             }
                             
                             [self changeSuperviewForView:dragginView forSuperview:nil];
                             //[self reloadDataInView:self.dstView atIndeces:@[index, self.draggingIndexPath]];
                             [self reloadDataInView:self.dstView];
                             [self handleDragAnimationComplete];

                             
                         }];
        
        
        
    }
    else{
        
        /* Snap view back */
        
        [self handleDragFromDstStoppedAtPoint:[self.superview convertPoint:point fromView:self.dstView]];

    }

}


-(void) handleDragAnimationComplete{

    // TODO: Drag has finished its sequence

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
        [draggingView removeFromSuperview];
        [self.superview addSubview:draggingView];
    }
    else{
        self.draggingIndexPath = nil;
    }

    _draggingView = draggingView;
    
}


-(void) changeSuperviewForView:(UIView*) view forSuperview:(UIView*) superview{
    
    if(!superview){
        [view removeFromSuperview];
        return;
    }
    
    UIView* previousSuperview = [view superview];
    [view removeFromSuperview];
    [superview addSubview:view];
    view.frame = [superview convertRect:view.frame fromView:previousSuperview];

}



/* Animation methods */

-(void) transitionView:(UIView*) view
               toFrame:(CGRect) frame
           toSuperview:(UIView*) superview{


    if(view.superview == superview){
        NSLog(@"Transitioning view while in the same superview");
        return;
    }
    if(!view){
        NSLog(@"View is nil so can't transition.");
        return;    
    }
    
    
    /* Local variable declared here so that we don't read the value in the 
        completion block once its been changed. */
    
    BOOL isFromSrc = self.isDraggingFromSrcCollection;
    
    /* Completion block declared here so that the auto indeting doesn't
        make this totally unreadable. */
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
    
        NSLog(@"Animation complete!");
        
        
        [self changeSuperviewForView:view
                        forSuperview:superview];
        
        
        [self handleDragAnimationComplete];
        
        
        if(isFromSrc && self.delegate &&
           [self.delegate respondsToSelector:@selector(dragFromSrcSnappedBack:)]){
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:@selector(dragFromSrcSnappedBack:) withObject:view];
#pragma clang diagnostic pop
            
        }
        else if(!isFromSrc && self.delegate &&
                [self.delegate respondsToSelector:@selector(dragFromDstSnappedBack:)]){
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:@selector(dragFromDstSnappedBack:) withObject:view];
#pragma clang diagnostic pop
            
        }
        else{
            NSLog(@"Selector not valid, from Src %@, delegate %@, responds %@",
                  isFromSrc ? @"YES" : @"NO",
                  self.delegate,
                  [self.delegate respondsToSelector:@selector(dragFromSrcSnappedBack:)] ? @"YES" : @"NO");
        }


        CGRect localFrame = [superview convertRect:frame fromView:self.superview];
        view.frame = localFrame;
        

    };
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         view.frame = frame;
                     }
                     completion:completion];
    
}


-(void) dealloc{

    [_superview removeGestureRecognizer:self.currentGestureRecognizer];

}


@end
