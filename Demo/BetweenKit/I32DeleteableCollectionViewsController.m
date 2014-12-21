//
//  I32DeleteableCollectionViewsController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32DeleteableCollectionViewsController.h"
#import "I3MoveableCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>


@interface I32DeleteableCollectionViewsController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32DeleteableCollectionViewsController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    [self.leftCollection registerNib:[UINib nibWithNibName:I3MoveableCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3MoveableCollectionViewCellIdentifier];
    [self.rightCollection registerNib:[UINib nibWithNibName:I3MoveableCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3MoveableCollectionViewCellIdentifier];
    
    NSArray *data = @[
                      [UIColor redColor],
                      [UIColor greenColor],
                      [UIColor blueColor],
                      [UIColor yellowColor],
                      [UIColor orangeColor],
                      [UIColor purpleColor],
                      ];
    
    self.leftData = [NSMutableArray arrayWithArray:data];
    self.rightData = [NSMutableArray arrayWithArray:data];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftCollection, self.rightCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSMutableArray *)dataForCollectionView:(UIView *)collectionView{
    
    NSMutableArray *data = nil;
    
    if(collectionView == self.leftCollection){
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
    
    I3MoveableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3MoveableCollectionViewCellIdentifier forIndexPath:indexPath];
    NSArray *data = [self dataForCollectionView:collectionView];
    
    cell.backgroundColor = [data objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    I3MoveableCollectionViewCell *cell = (I3MoveableCollectionViewCell *)[collection itemAtIndexPath:at];
    
    return [cell.moveAccessory pointInside:[self.dragCoordinator.gestureRecognizer locationInView:cell.moveAccessory] withEvent:nil];
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    CGPoint localPoint = [self.deleteArea convertPoint:to fromView:self.view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
   
    NSMutableArray *fromData = [self dataForCollectionView:collection];
    
    [fromData removeObjectAtIndex:at.row];
    [collection deleteItemsAtIndexPaths:@[at]];
}


@end
