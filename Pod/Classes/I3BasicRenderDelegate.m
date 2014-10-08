//
//  I3BasicRenderDelegate.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3BasicRenderDelegate.h"
#import "I3Logging.h"


@implementation I3BasicRenderDelegate


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{
    
    UIView *sourceView = [coordinator.currentDraggingCollection itemAtPoint:coordinator.currentDragOrigin];
        
    _draggingView = [[I3CloneView alloc] initWithSourceView:sourceView];
    [coordinator.arena.superview addSubview:_draggingView];
    
}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{

    CGPoint translation = [coordinator.gestureRecognizer translationInView:[_draggingView superview]];
    NSInteger xTranslation = self.draggingView.center.x + translation.x;
    NSInteger yTranslation = self.draggingView.center.y + translation.y;
    
    [_draggingView setCenter:CGPointMake(xTranslation, yTranslation)];
    [coordinator.gestureRecognizer setTranslation:CGPointZero inView:[_draggingView superview]];
    
}


-(void) renderResetFromPoint:(CGPoint) at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    CGPoint dragOrigin = [coordinator currentDragOrigin];
    I3CloneView *draggingView = _draggingView;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.15 animations:^{
    
        draggingView.center = dragOrigin;
    
    } completion:^(BOOL finished){
        
        [draggingView removeFromSuperview];
        
        if(weakSelf.completeResetBlock){
            weakSelf.completeResetBlock(draggingView);
        }
    
    }];

    _draggingView = nil;
    
}


@end
