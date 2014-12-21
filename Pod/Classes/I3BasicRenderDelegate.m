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


-(id) init{

    self = [super init];
    
    if(self){
    
        _draggingItemOpacity = 0.01;
        _draggingViewOpacity = 1;
        _rearrangeIsExchange = YES;
        
    }

    return self;
}


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{
    
    UIView<I3Collection> *draggingCollection = coordinator.currentDraggingCollection;
    UIView *sourceView = coordinator.currentDraggingItem;
    
    _draggingView = [[I3CloneView alloc] initWithSourceView:sourceView];
    _draggingView.frame = [coordinator.arena.superview convertRect:sourceView.frame fromView:draggingCollection];
    [_draggingView cloneSourceView];

    [coordinator.arena.superview addSubview:_draggingView];
    
    _draggingView.alpha = _draggingViewOpacity;
    sourceView.alpha = _draggingItemOpacity;
    
    [self renderDraggingFromCoordinator:coordinator];
}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [UIView animateWithDuration:0.05 animations:^{
        self.draggingView.center = coordinator.currentDragLocation;
    }];
}


-(void) renderResetFromPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    UIView<I3Collection> *draggingCollection = coordinator.currentDraggingCollection;
    UIView *sourceView = coordinator.currentDraggingItem;

    CGRect dragOriginFrame = [coordinator.arena.superview convertRect:sourceView.frame fromView:draggingCollection];
    I3CloneView *draggingView = _draggingView;
    
    [UIView animateWithDuration:0.15 animations:^{

        draggingView.frame = dragOriginFrame;
    
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
        sourceView.alpha = 1;
    
        DND_LOG(@"Finished async reset");

    }];

    _draggingView = nil;
    
}


-(void) renderRearrangeOnPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    if(self.rearrangeIsExchange){
        
        UIView<I3Collection> *draggingCollection = coordinator.currentDraggingCollection;
        NSIndexPath *atIndex = [draggingCollection indexPathForItemAtPoint:at];
        
        UIView *superview = coordinator.arena.superview;
        UIView *dstSourceView = [draggingCollection itemAtIndexPath:atIndex];
        UIView *sourceView = coordinator.currentDraggingItem;
        
        I3CloneView *exchangeView = [[I3CloneView alloc] initWithSourceView:dstSourceView];
        exchangeView.frame = [superview convertRect:dstSourceView.frame fromView:draggingCollection];
        [superview addSubview:exchangeView];
        
        I3CloneView *draggingView = _draggingView;
        
        [superview bringSubviewToFront:draggingView];
        [exchangeView cloneSourceView];
        
        CGRect dragOriginFrame = [superview convertRect:sourceView.frame fromView:draggingCollection];
        CGPoint draggingViewTargetCenter = CGPointMake(CGRectGetMidX(exchangeView.frame), CGRectGetMidY(exchangeView.frame));
        CGPoint exchangeViewTargetCenter = CGPointMake(CGRectGetMidX(dragOriginFrame), CGRectGetMidY(dragOriginFrame));
        
        
        [UIView animateWithDuration:0.15 animations:^{
            
            draggingView.center = draggingViewTargetCenter;
            exchangeView.center = exchangeViewTargetCenter;
            
        } completion:^(BOOL finished) {
            
            [exchangeView removeFromSuperview];
            [draggingView removeFromSuperview];
            
            DND_LOG(@"Finished async rearrange");
            
        }];
        
        _draggingView = nil;
        
        DND_LOG(@"Finished sync rearrange");
        
    }
    else{
    
        [_draggingView removeFromSuperview];
        _draggingView = nil;
    }
    
}


-(void) renderDeletionAtPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{

    I3CloneView *draggingView = self.draggingView;
    
    CGFloat midX = CGRectGetMidX(draggingView.frame);
    CGFloat midY = CGRectGetMidY(draggingView.frame);
    CGRect shrunkFrame = CGRectMake(midX, midY, 0, 0);
    
    [UIView animateWithDuration:0.15 animations:^{
    
        draggingView.frame = shrunkFrame;
        
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
    
    }];
    
    _draggingView = nil;
    
}


-(void) renderDropOnCollection:(UIView<I3Collection> *)dstCollection atPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [_draggingView removeFromSuperview];
    _draggingView = nil;
    
    coordinator.currentDraggingItem.alpha = 1;
    
    DND_LOG(@"Finished rendering drop");
    
}


@end
