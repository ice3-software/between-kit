//
//  CollectionViewController.m
//  12. Collections With Sections
//
//  Created by Stephen Fortune on 22/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import "CollectionViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface CollectionViewController ()

@property (nonatomic, strong) NSArray *leftData;

@property (nonatomic, strong) NSArray *rightData;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation CollectionViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    NSArray *data = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor purpleColor]];
    
    self.leftData = @[[[NSMutableArray alloc] initWithArray:data copyItems:YES], [[NSMutableArray alloc] initWithArray:data copyItems:YES], [[NSMutableArray alloc] initWithArray:data copyItems:YES]];
    self.rightData = @[[[NSMutableArray alloc] initWithArray:data copyItems:YES], [[NSMutableArray alloc] initWithArray:data copyItems:YES], [[NSMutableArray alloc] initWithArray:data copyItems:YES]];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftCollection, self.rightCollection]];
    
    [self.leftCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.rightCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


-(NSArray *)sectionDataForCollection:(UIView *)collection{
    return collection == self.leftCollection ? self.leftData : self.rightData;
}


-(NSMutableArray *)dataForCollection:(UIView *)collection atIndexPath:(NSIndexPath *)index{
    
    NSArray *sectionData = [self sectionDataForCollection:collection];
    return [sectionData objectAtIndex:index.section];
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource


-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self sectionDataForCollection:collectionView].count;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray *sectionData = [self sectionDataForCollection:collectionView];
    return ((NSArray *)sectionData[section]).count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell forIndexPath:indexPath];
    
    cell.backgroundColor = [self dataForCollection:collectionView atIndexPath:indexPath][indexPath.item];
    
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
    
    NSMutableArray *fromDataset = [self dataForCollection:fromCollection atIndexPath:from];
    NSMutableArray *toDataset = [self dataForCollection:toCollection atIndexPath:to];
    UIColor *exchangingData = fromDataset[from.item];
    
    [fromDataset removeObjectAtIndex:from.item];
    [toDataset insertObject:exchangingData atIndex:to.item];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[to]];
    
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSArray *sectionData = [self sectionDataForCollection:toCollection];
    NSInteger sectionIndex = sectionData.count - 1;
    NSArray *data = sectionData[sectionIndex];
    
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:data.count inSection:sectionIndex];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
