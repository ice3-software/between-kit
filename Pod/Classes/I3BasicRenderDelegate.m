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


@end
