//
//  CollectionViewController.m
//  9. 2 Droppable Collection Views
//
//  Created by Stephen Fortune on 22/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "CollectionViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface CollectionViewController ()

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation CollectionViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    NSArray *data = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor purpleColor]];

    self.leftData = [NSMutableArray arrayWithArray:data];
    self.rightData = [NSMutableArray arrayWithArray:data];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftCollection, self.rightCollection]];
    
    [self.leftCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.rightCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


-(NSMutableArray *)dataForCollection:(UIView *)collection{
    return collection == self.leftCollection ? self.leftData : self.rightData;
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self dataForCollection:collectionView].count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell forIndexPath:indexPath];
    
    cell.backgroundColor = [[self dataForCollection:collectionView] objectAtIndex:indexPath.item];
    
    return cell;
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromDataset = [self dataForCollection:fromCollection];
    NSMutableArray *toDataset = [self dataForCollection:toCollection];
    NSString *exchangingData = fromDataset[from.row];
    
    [fromDataset removeObjectAtIndex:from.row];
    [toDataset insertObject:exchangingData atIndex:to.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[to]];
    
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:[self dataForCollection:toCollection].count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
