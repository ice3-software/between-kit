//
//  I3FunkRenderDelegate.m
//  BetweenKit
//
//  Created by Stephen Fortune on 19/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "FunkRenderDelegate.h"


#define DEGREES_TO_RADIANS(angle) ((angle)/180.0*M_PI)


@interface HighlightedViewModel : NSObject

@property (nonatomic, strong) UIView *dstView;

@property (nonatomic) BOOL isHighlighted;

-(void) setIsHighlighted:(BOOL)isHighlighted;

@end


@implementation HighlightedViewModel

-(void) setIsHighlighted:(BOOL)isHighlighted{

    _isHighlighted = isHighlighted;
    _dstView.alpha = _isHighlighted ? 1 : 0.2;
    
}

@end


@interface FunkRenderDelegate ()

@property (nonatomic, strong) NSArray *potentialDestinations;

@property (nonatomic, strong) CABasicAnimation *pulse;

@property (nonatomic, strong) CABasicAnimation *shake;

@property (nonatomic, strong) CABasicAnimation *destroyRotate;

@property (nonatomic, strong) CABasicAnimation *destroyScale;

@property (nonatomic, strong) UIView *deleteArea;

@end


@implementation FunkRenderDelegate


-(id) initWithPotentialDstViews:(NSArray *)views andDeleteArea:(UIView *)deleteArea{

    self = [super init];
    
    if(self){
    
        NSMutableArray *potentialDsts = [[NSMutableArray alloc] init];
        
        [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            HighlightedViewModel *viewModel = [[HighlightedViewModel alloc] init];
            viewModel.dstView = obj;
            viewModel.isHighlighted = YES;
            [potentialDsts addObject:viewModel];
        }];

        _potentialDestinations = [NSArray arrayWithArray:potentialDsts];
        _deleteArea = deleteArea;
    }
    
    return self;
}


#pragma mark - Accessor methods


-(CABasicAnimation *)pulse{

    if(!_pulse){

        _pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        _pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pulse.duration = 0.35;
        _pulse.repeatCount = HUGE_VAL;
        _pulse.autoreverses = YES;
        _pulse.fromValue = [NSNumber numberWithFloat:1.05];
        _pulse.toValue = [NSNumber numberWithFloat:0.86];
    
    }
    
    return _pulse;
}


-(CABasicAnimation *)shake{
    
    if(!_shake){
        
        _shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _shake.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _shake.duration = 0.1;
        _shake.repeatCount = HUGE_VAL;
        _shake.autoreverses = YES;
        _shake.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(-7)];
        _shake.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(7)];
    
    }
    
    return _shake;
}


-(CABasicAnimation *)destroyScale{

    if(!_destroyScale){
        
        _destroyScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        _destroyScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        _destroyScale.duration = 0.2;
        _destroyScale.removedOnCompletion = NO;
        _destroyScale.fromValue = [NSNumber numberWithFloat:1];
        _destroyScale.toValue = [NSNumber numberWithFloat:0];
        _destroyScale.fillMode = kCAFillModeBoth;

    }

    return _destroyScale;
}


-(CABasicAnimation *)destroyRotate{
    
    if(!_destroyRotate){

        _destroyRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _destroyRotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        _destroyRotate.duration = 0.2;
        _destroyRotate.removedOnCompletion = NO;
        _destroyRotate.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(0)];
        _destroyRotate.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(-360)];
        _destroyRotate.fillMode = kCAFillModeBoth;
    
    }

    return _destroyRotate;
}


#pragma mark - Animation helpers


-(void) startPulse{
    
    static NSString *PulseKey = @"pulse";
    [self.draggingView.layer addAnimation:self.pulse forKey:PulseKey];
    
}


-(void) invalidateShakingAtPoint:(CGPoint) globalPoint inCoordinator:(I3GestureCoordinator *)coordinator{
    
    static NSString *ShakeKey = @"shake";
    CGPoint localPoint = [self.deleteArea convertPoint:globalPoint fromView:coordinator.arena.superview];
    BOOL isDeleteArea = [self.deleteArea pointInside:localPoint withEvent:nil];
    BOOL hasAnimation = !![self.draggingView.layer animationForKey:ShakeKey];
    
    if(isDeleteArea && !hasAnimation){
        [self.draggingView.layer addAnimation:self.shake forKey:ShakeKey];
    }
    else if(!isDeleteArea && hasAnimation){
        [self.draggingView.layer removeAnimationForKey:ShakeKey];
    }
    
}


-(void) invalidatedHightlighteDstAt:(CGPoint) globalPoint inCoordinator:(I3GestureCoordinator *)coordinator{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    for(HighlightedViewModel *viewModel in self.potentialDestinations){
        
        CGPoint localCollectionPoint = [viewModel.dstView convertPoint:globalPoint fromView:coordinator.arena.superview];
        BOOL pointInside = [viewModel.dstView pointInside:localCollectionPoint withEvent:nil];
        
        if(!viewModel.isHighlighted && pointInside){
            viewModel.isHighlighted = YES;
        }
        else if(viewModel.isHighlighted && !pointInside){
            viewModel.isHighlighted = NO;
        }
        
    }
    
    [UIView commitAnimations];
    
}


-(void) highlightAll{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    for(HighlightedViewModel *viewModel in self.potentialDestinations){
        viewModel.isHighlighted = YES;
    }
    
    [UIView commitAnimations];

}


#pragma mark - I3DragRenderDelegate


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{
    
    [super renderDragStart:coordinator];
    [self startPulse];
}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{
    
    CGPoint globalPoint = [coordinator.gestureRecognizer locationInView:coordinator.arena.superview];
    
    [super renderDraggingFromCoordinator:coordinator];
    [self invalidatedHightlighteDstAt:globalPoint inCoordinator:coordinator];
    [self invalidateShakingAtPoint:globalPoint inCoordinator:coordinator];
    
}


-(void) renderDeletionAtPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    static NSString *DestroyRotateKey = @"destroy.rotate";
    static NSString *DestroyScaleKey = @"destroy.scale";
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        [self.draggingView removeFromSuperview];
        self.draggingView = nil;
        [self highlightAll];
        
    }];
    
    [self.draggingView.layer addAnimation:self.destroyRotate forKey:DestroyRotateKey];
    [self.draggingView.layer addAnimation:self.destroyScale forKey:DestroyScaleKey];
    
    [CATransaction commit];
}


-(void) renderDropOnCollection:(UIView<I3Collection> *)dstCollection atPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [super renderDropOnCollection:dstCollection atPoint:at fromCoordinator:coordinator];
    [self highlightAll];
}

-(void) renderRearrangeOnPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{

    [super renderRearrangeOnPoint:at fromCoordinator:coordinator];
    [self highlightAll];
}


-(void) renderResetFromPoint:(CGPoint)at fromCoordinator:(I3GestureCoordinator *)coordinator{
    
    [super renderResetFromPoint:at fromCoordinator:coordinator];
    [self highlightAll];
}


@end
