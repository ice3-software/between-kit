//
//  I3BasicRenderDelegate.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3BasicRenderDelegate.h"
#import "I3Logging.h"


@interface I3BasicRenderDelegate ()

@end


@implementation I3BasicRenderDelegate


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{
    
    id<I3Collection> draggingCollection = coordinator.currentDraggingCollection;
    CGPoint dragOrigin = coordinator.currentDragOrigin;
    
    UIView *sourceView = [draggingCollection itemAtPoint:dragOrigin];
    UIView *collectionView = draggingCollection.collectionView;
        
    _draggingView = [[I3CloneView alloc] initWithSourceView:sourceView];
    _draggingView.frame = [coordinator.arena.superview convertRect:sourceView.frame fromView:collectionView];
    [coordinator.arena.superview addSubview:_draggingView];
    
    if([draggingCollection.dragDataSource hidesItemWhileDraggingAtPoint:dragOrigin inCollection:draggingCollection]){
        sourceView.alpha = 0.01f;
    }
}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{

    CGPoint translation = [coordinator.gestureRecognizer translationInView:coordinator.arena.superview];
    NSInteger xTranslation = self.draggingView.center.x + translation.x;
    NSInteger yTranslation = self.draggingView.center.y + translation.y;
    
    self.draggingView.center = CGPointMake(xTranslation, yTranslation);
    [coordinator.gestureRecognizer setTranslation:CGPointZero inView:coordinator.arena.superview];
    
}


-(void) renderResetFromPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    UIView *sourceView = [coordinator.currentDraggingCollection itemAtPoint:coordinator.currentDragOrigin];
    UIView *collectionView = coordinator.currentDraggingCollection.collectionView;

    CGRect dragOriginFrame = [coordinator.arena.superview convertRect:sourceView.frame fromView:collectionView];
    I3CloneView *draggingView = _draggingView;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.15 animations:^{
    
        draggingView.frame = dragOriginFrame;
    
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
        
        if(weakSelf.completeResetBlock){
            weakSelf.completeResetBlock(draggingView);
        }
    
    }];

    _draggingView = nil;
    
}


-(void) renderDropOnCollection:(id<I3Collection>) dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{

    [_draggingView removeFromSuperview];
    _draggingView = nil;
 
    id<I3Collection> draggingCollection = coordinator.currentDraggingCollection;
    CGPoint dragOrigin = coordinator.currentDragOrigin;

    if([draggingCollection.dragDataSource hidesItemWhileDraggingAtPoint:dragOrigin inCollection:draggingCollection]){
        
        UIView *sourceView = [draggingCollection itemAtPoint:dragOrigin];
        sourceView.alpha = 1;
    
    }

}


@end
