//
//  I3DragBetweenHelper.h
//  ResourceMoney Client
//
//  Created by Stephen Fortune on 31/08/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol I3DragBetweenDelegate

@optional


/** Called when the dragging view has been dropped nowhere and the
     snap-back animation has ended. */

-(void) dragFromDstSnappedBackFromIndexPath:(NSIndexPath*) path;


/** Called when the dragging view has been dropped nowhere and the
     snap-back animation has ended. */

-(void) dragFromSrcSnappedBackFromIndexPath:(NSIndexPath*) path;


/** Called if you implement droppedOutsideAtPoint:fromDstIndexPath: to return
     NO after the 'deletion' animation sequence. */

-(void) itemFromDstDeletedAtIndexPath:(NSIndexPath*) path;


/** Called if you implement droppedOutsideAtPoint:fromSrcIndexPath: to return
     NO after the 'deletion' animation sequence. */

-(void) itemFromSrcDeletedAtIndexPath:(NSIndexPath*) path;


/** A drag from the destination table/collection was started */

-(void) dragFromDstStartedAtIndexPath:(NSIndexPath*) path;


/** A drag from the source table/collection was stopped inside of the
     src view. This should be implemented to make data changes. */

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from;


/** A drag from the source table/collection was stopped inside of the
     destination view. */

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from;


/** A drag from the destination table/collection was stopped ouside of 
     both src and dst table/collections. Should return a BOOL indicating
     whether or not to snap the view back or transition it 'out' with
     the default scale animation. */

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from;

/** Implemented to determine whether two cells are exchangable inside of
     a the dst collection/table. */

-(BOOL) isCellInDstAtIndexPathExchangable:(NSIndexPath*) to
                      withCellAtIndexPath:(NSIndexPath*) from;



/** A drag from the srource table/collection was started */

-(void) dragFromSrcStartedAtIndexPath:(NSIndexPath*) path;


/** A drag from the source table/collection was stopped inside of the
     src view. This should be implemented to make data changes. */

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*) from;


/** A drag from the source table/collection was stopped inside of the
     destination view. */

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*) from;


/** A drag from the source table/collection was stopped ouside of both
     src and dst table/collections. Should return a BOOL indicating
     whether or not to snap the view back or transition it 'out' with 
     the default scale animation. */

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromSrcIndexPath:(NSIndexPath*) from;


/** Implemented to determine whether two cells are exchangable inside of
     a the src collection/table. */


-(BOOL) isCellInSrcAtIndexPathExchangable:(NSIndexPath*) to
                      withCellAtIndexPath:(NSIndexPath*) from;




/** Implemented to determine whether a specific cell is draggable from
     a container. The container will either be srcView or dstView - logic
     should be implemented in the delegate to determine which one the delegate
     applies to. If not implemented assumed YES.
 
    This is implemented as a generic handler for both dst and src so that
     we can call it effectively in startDragFromView without having to hack
     isDraggingFromSrcCollection. */

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container;




/* Generic view draggin handler */

-(void) dragginAtPoint:(CGPoint) pointIn;




@end




/** Class that handles routing logic for dragging between two table/collection
     views.
 
    It encapsulates re-ordering of the dst view, delegation of drag beginning and 
     stopping, etc.
 
    Also offers 'deletion' functionallity - if you implement one of the droppedOutsideAtPoint
     to return NO then the view won't 'snap back' to its original position, it will be 
     'deleted' (shrink animation). To update your data and table/collection accordingly, 
     you MUST implement a itemFromDstDeletedAtIndexPath method in your delegate. This is 
     called specifically on animation completion. */

@interface I3DragBetweenHelper : NSObject

@property (atomic, readonly) BOOL isDragging;

@property (nonatomic, readonly, retain) UIPanGestureRecognizer* currentGestureRecognizer;


/* The 'live' draggin properties, these are only stable to
    reference while dragging is taking place. */

@property (nonatomic, readonly, retain) NSIndexPath* draggingIndexPath;

@property (nonatomic, retain) UIView* draggingView;

@property (nonatomic, readonly) CGRect draggingViewPreviousRect;

@property (nonatomic, readonly) BOOL isDraggingFromSrcCollection;


/** Indicates whether the source should be rearrangeable. Does NOT
     check for the delegate's implementation of droppedOnSrcAtIndexPath:fromSrcIndexPath: 
     to determine whether the Src is rearrangeable. */

@property (nonatomic) BOOL isSrcRearrangeable;

/** Indicates whether the source should recieve destination
     items. The delegate also needs to have implemented droppedOnDstAtIndexPath:fromSrcIndexPath: 
     for this to have an effect */

@property (nonatomic) BOOL doesSrcRecieveDst;

/** Indicates whether the source should be rearrangeable. Does NOT
     check for the delegate's implementation of droppedOnDstAtIndexPath:fromDstIndexPath:
     to determine whether the Dst is rearrangeable. */

@property (nonatomic) BOOL isDstRearrangeable;

/** Indicates whether the destination should recieve source
    items. */

@property (nonatomic) BOOL doesDstRecieveSrc;

/** The view that will contain the draggingView whilst dragging */

@property (nonatomic, weak) UIView* superview;

/** Must be an instance of UITableView or UICollectionView */

@property (nonatomic, weak) UIView* srcView;

/** Must be an instance of UITableView or UICollectionView */

@property (nonatomic, weak) UIView* dstView;

/** Delegate object for the drag routing */

@property (nonatomic, weak) NSObject<I3DragBetweenDelegate>* delegate;



/** Initializes a UIPanGestureRecognizer for the superview, src and dst
     views. Should be noted that it throw either of the src or dst views
     aren't table or collection views. */

-(id) initWithSuperview:(UIView*) superview
                srcView:(UIView*) srcView
                dstView:(UIView*) dstView;

/* Setters */

/** Implemented to re-iniatlize UIPanGestureRecognizer */

-(void) setSuperview:(UIView*) superview;

/** Implemented to check type for table/collection */

-(void) setSrcView:(UIView*) srcView;

/** Implemented to check type for table/collection */

-(void) setDstView:(UIView*) dstView;



/** Removes UIPanGestureRecognizer from superview */

-(void) dealloc;

@end
