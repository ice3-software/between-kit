//
//  I32DroppableCollectionViewsController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32DroppableCollectionViewsController.h"
#import "I3MoveableCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>


@interface I32DroppableCollectionViewsController()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32DroppableCollectionViewsController


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


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{

    NSMutableArray *fromData = [self dataForCollectionView:fromCollection];
    NSMutableArray *toData = [self dataForCollectionView:toCollection];
    
    UIColor *exchangingDatum = [fromData objectAtIndex:fromIndex.row];
    
    [fromData removeObjectAtIndex:fromIndex.row];
    [toData insertObject:exchangingDatum atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[fromIndex]];
    [toCollection insertItemsAtIndexPaths:@[toIndex]];
    
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    
    NSInteger toIndex = [[self dataForCollectionView:toCollection] count];
    NSIndexPath *toIndexPath = [toCollection isKindOfClass:[UITableView class]] ? [NSIndexPath indexPathForRow:toIndex inSection:0] : [NSIndexPath indexPathForItem:toIndex inSection:0];
    
    [self dropItemAt:fromIndex fromCollection:fromCollection toItemAt:toIndexPath onCollection:toCollection];
}


@end
