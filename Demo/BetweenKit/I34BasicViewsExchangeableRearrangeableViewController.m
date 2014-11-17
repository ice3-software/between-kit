//
//  I34BasicViewsExchangeableRearrangeableViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I34BasicViewsExchangeableRearrangeableViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3DragArena.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


@interface I34BasicViewsExchangeableRearrangeableViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) I3DragArena *arena;

@property (nonatomic, strong) I3BasicRenderDelegate *renderDelegate;

@end


@implementation I34BasicViewsExchangeableRearrangeableViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    /** Setup the coordinator with its dependencies */
    
    self.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    self.arena = [[I3DragArena alloc] initWithSuperview:self.view containingCollections:@[self.topLeft, self.topRight, self.bottomLeft, self.bottomRight]];
    
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:self.arena withGestureRecognizer:nil];
    self.dragCoordinator.renderDelegate = self.renderDelegate;
    self.dragCoordinator.dragDataSource = self;
    
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - I3DragDataSource Assertions

-(BOOL) canItemAtPoint:(CGPoint) from beDeletedIfDroppedOutsideOfCollection:(id<I3Collection>) collection atPoint:(CGPoint) to{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection beDroppedToPoint:(CGPoint) to inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}


-(BOOL) canItemFromPoint:(CGPoint)from beRearrangedWithItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    return YES;
}


#pragma mark - I3DragDataSource Mutators

-(void) rearrangeItemAtPoint:(CGPoint)from withItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    
    UIView *targetCollection = collection.collectionView;

    UIView *draggingSubview = [targetCollection itemAtPoint:from];
    UIView *targetSubview = [targetCollection itemAtPoint:to];
    
    CGRect targetFrame = targetSubview.frame;
    CGRect draggingFrame = draggingSubview.frame;
    
    draggingSubview.frame = targetFrame;
    targetSubview.frame = draggingFrame;

}

-(void) dropItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection toPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection{

    UIView *toCollectionView = toCollection.collectionView;
    UIView *fromCollectionView = fromCollection.collectionView;
    
    UIView *fromSubview = [fromCollectionView itemAtPoint:from];
    UIView *toSubview = [toCollectionView itemAtPoint:to];
    
    [fromSubview removeFromSuperview];
    [toCollectionView addSubview:fromSubview];
    
    fromSubview.center = toSubview.center;
    
}

-(void) deleteItemAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    
    UIView *draggingView = [collection.collectionView itemAtPoint:at];
    [draggingView removeFromSuperview];
    
}


@end
