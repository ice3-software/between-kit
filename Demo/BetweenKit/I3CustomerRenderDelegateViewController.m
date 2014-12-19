//
//  I3CustomerRenderDelegateViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 19/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CustomerRenderDelegateViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


#define DEGREES_TO_RADIANS(angle) ((angle)/180.0*M_PI)


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I3CustomerRenderDelegateViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@property (nonatomic, strong) I3CloneView *draggingView;

@property (nonatomic, strong) CABasicAnimation *pulse;

@property (nonatomic, strong) CABasicAnimation *shake;

@end


@implementation I3CustomerRenderDelegateViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    [self.leftTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];

    self.leftData = [NSMutableArray arrayWithArray:@[
                                                    [UIColor redColor],
                                                    [UIColor greenColor],
                                                    [UIColor blueColor],
                                                    [UIColor yellowColor],
                                                    [UIColor orangeColor],
                                                    [UIColor purpleColor],
                                                    [UIColor colorWithRed:0.3 green:0.25 blue:0.4 alpha:1],
                                                    ]];
    
    self.rightData = [NSMutableArray arrayWithArray:@[
                                                      [UIColor whiteColor],
                                                      [UIColor lightTextColor],
                                                      [UIColor lightGrayColor],
                                                      [UIColor grayColor],
                                                      [UIColor darkTextColor],
                                                      [UIColor darkGrayColor],
                                                      [UIColor colorWithRed:0.3 green:0.25 blue:0.4 alpha:1],
                                                      ]];
    
    
    I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:self.view containingCollections:@[self.leftTable, self.rightCollection]];
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:nil];
    
    self.dragCoordinator.renderDelegate = self;
    self.dragCoordinator.dragDataSource = self;
    
    
    /// Setup some basic animations for the render delegate methods
    
    self.pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    self.pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.pulse.duration = 0.5;
    self.pulse.repeatCount = HUGE_VAL;
    self.pulse.autoreverses = YES;
    self.pulse.fromValue = [NSNumber numberWithFloat:1];
    self.pulse.toValue = [NSNumber numberWithFloat:0.9];
    
    
    self.shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    self.shake.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.shake.duration = 0.1;
    self.shake.repeatCount = HUGE_VAL;
    self.shake.autoreverses = YES;
    self.shake.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(-7)];
    self.shake.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(7)];

}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return [[self dataForCollectionView:tableView] count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSArray *data = [self dataForCollectionView:tableView];
    
    cell.backgroundColor = [data objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSMutableArray *)dataForCollectionView:(UIView *)collectionView{
    
    NSMutableArray *data = nil;
    
    if(collectionView == self.leftTable){
        data = self.leftData;
    }
    else if(collectionView == self.rightCollection){
        data = self.rightData;
    }

    return data;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    return [[self dataForCollectionView:collectionView] count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSArray *data = [self dataForCollectionView:collectionView];
    
    cell.backgroundColor = [data objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Helpers


-(BOOL) isPointInDeletionArea:(CGPoint) point fromView:(UIView *)view{
    
    CGPoint localPoint = [self.deleteArea convertPoint:point fromView:view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) logUpdatedData{
    NSLog(@"Left : %@, Right: %@", self.leftData, self.rightData);
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection to:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromData = [self dataForCollectionView:fromCollection];
    NSMutableArray *toData = [self dataForCollectionView:toCollection];
    
    UIColor *exchangingDatum = [fromData objectAtIndex:fromIndex.row];
    
    [fromData removeObjectAtIndex:fromIndex.row];
    [toData insertObject:exchangingDatum atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[fromIndex]];
    [toCollection insertItemsAtIndexPaths:@[toIndex]];
    
    [self logUpdatedData];
    
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beAppendedToCollection:(UIView<I3Collection> *)toCollection atPoint:(CGPoint)to{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beExchangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    return [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *fromData = [self dataForCollectionView:collection];
    
    [fromData removeObjectAtIndex:at.row];
    [collection deleteItemsAtIndexPaths:@[at]];
    
    [self logUpdatedData];
}


-(void) appendItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)onCollection{
    
    NSInteger toIndex = [[self dataForCollectionView:onCollection] count];
    NSIndexPath *toIndexPath = [onCollection isKindOfClass:[UITableView class]] ? [NSIndexPath indexPathForRow:toIndex inSection:0] : [NSIndexPath indexPathForItem:toIndex inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection to:toIndexPath onCollection:onCollection];
    [self logUpdatedData];
}


-(void) exchangeItemAt:(NSIndexPath *)from inCollection:(UIView<I3Collection> *)fromCollection withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)toCollection{
    
    [self dropItemAt:from fromCollection:fromCollection to:to onCollection:toCollection];
    [self logUpdatedData];
    
}


#pragma mark - I3DragRenderDelegate


-(void) renderDragStart:(I3GestureCoordinator *)coordinator{

    /// Clone the original view
    
    UIView<I3Collection> *draggingCollection = coordinator.currentDraggingCollection;
    UIView *sourceView = coordinator.currentDraggingItem;
    
    self.draggingView = [[I3CloneView alloc] initWithSourceView:sourceView];
    self.draggingView.frame = [coordinator.arena.superview convertRect:sourceView.frame fromView:draggingCollection];
    [self.draggingView cloneSourceView];
    
    [coordinator.arena.superview addSubview:self.draggingView];
    
    sourceView.alpha = 0.001;
    
    [self renderDraggingFromCoordinator:coordinator];
    
    /// Start the pulse
    
    [self.draggingView.layer addAnimation:self.pulse forKey:@"scale"];

}


-(void) renderDraggingFromCoordinator:(I3GestureCoordinator *)coordinator{
    
    
    CGPoint globalLocation = [coordinator.gestureRecognizer locationInView:coordinator.arena.superview];
    
    
    /// Translate the dragging view
    
    self.draggingView.center = globalLocation;
    
    
    /// Highlight possible dst

    NSArray *destinations = @[self.deleteArea, self.leftTable, self.rightCollection];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    for(UIView *destinationView in destinations){
        
        CGPoint localCollectionPoint = [destinationView convertPoint:globalLocation fromView:self.view];
        CGFloat targetOpacity = [destinationView pointInside:localCollectionPoint withEvent:nil] ? 1 : 0.2;
        destinationView.alpha = targetOpacity;

    }
    
    [UIView commitAnimations];
    
    
    /// Start / end shake based on whether we are over the deletion area
    
    BOOL inDeletion = [self isPointInDeletionArea:globalLocation fromView:self.view];
    BOOL hasAnimation = !![self.draggingView.layer animationForKey:@"rotation"];
    
    if(inDeletion && !hasAnimation){
        [self.draggingView.layer addAnimation:self.shake forKey:@"rotation"];
    }
    else if(!inDeletion && hasAnimation){
        [self.draggingView.layer removeAnimationForKey:@"rotation"];
    }
    
}


@end
