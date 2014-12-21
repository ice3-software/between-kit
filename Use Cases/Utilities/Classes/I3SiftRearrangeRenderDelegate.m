//
//  I3SiftRearrangeRenderDelegate.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3SiftRearrangeRenderDelegate.h"

@implementation I3SiftRearrangeRenderDelegate

-(void) renderRearrangeOnPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{

    I3CloneView *draggingView = self.draggingView;
    
    [UIView animateWithDuration:0.2 animations:^{
        draggingView.alpha = 0;
    } completion:^(BOOL finished) {
        [draggingView removeFromSuperview];
    }];
    
    self.draggingView = nil;
}

@end
