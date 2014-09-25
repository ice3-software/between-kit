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


@end
