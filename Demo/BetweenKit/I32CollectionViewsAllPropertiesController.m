//
//  I32CollectionViewsAllPropertiesController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32CollectionViewsAllPropertiesController.h"
#import "I3SimpleData.h"
#import "I3SubtitleCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


@interface I32CollectionViewsAllPropertiesController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32CollectionViewsAllPropertiesController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    NSArray *data = @[
                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 1" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 3" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Left Item 4" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 5" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 6" withSubtitle:@"Oh hey there, I'm also normal" withCanDelete:YES withCanMove:YES],
                      [[I3SimpleData alloc] initWithColor:[UIColor redColor] withTitle:@"Left Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
                      ];
    
    self.leftData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
    self.rightData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
    
    [self.leftCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    [self.rightCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftCollection, self.rightCollection]];
        
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    return [[self dataForCollectionView:collectionView] count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    I3SubtitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier forIndexPath:indexPath];
    
    I3SimpleData *data = [[self dataForCollectionView:collectionView] objectAtIndex:indexPath.item];
    
    cell.backgroundColor = data.colour;
    cell.title.text = data.title;
    cell.subtitle.text = data.subtitle;

    return cell;
}


#pragma mark - Helpers


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


-(BOOL) isPointInDeletionArea:(CGPoint) point fromView:(UIView *)view{
    
    CGPoint localPoint = [self.deleteArea convertPoint:point fromView:view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    I3SimpleData *fromDatum = [[self dataForCollectionView:collection] objectAtIndex:at.item];
    
    return fromDatum.canMove;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    I3SimpleData *fromDatum = [[self dataForCollectionView:collection] objectAtIndex:from.item];
    I3SimpleData *toDatum = [[self dataForCollectionView:collection] objectAtIndex:to.item];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    I3SimpleData *fromDatum = [[self dataForCollectionView:fromCollection] objectAtIndex:from.item];
    I3SimpleData *toDatum = [[self dataForCollectionView:toCollection] objectAtIndex:to.item];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    
    I3SimpleData *fromDatum = [[self dataForCollectionView:fromCollection] objectAtIndex:from.item];
    
    return fromDatum.canMove && ![self isPointInDeletionArea:at fromView:toCollection];
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    I3SimpleData *fromDatum = [[self dataForCollectionView:collection] objectAtIndex:from.item];
    
    return fromDatum.canDelete && [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *fromDataset = [self dataForCollectionView:collection];
    
    [fromDataset removeObjectAtIndex:at.item];
    [collection deleteItemsAtIndexPaths:@[at]];
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *targetDataset = [self dataForCollectionView:collection];
    [targetDataset exchangeObjectAtIndex:to.item withObjectAtIndex:from.item];
    [collection reloadItemsAtIndexPaths:@[to, from]];
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromDataset = [self dataForCollectionView:fromCollection];
    NSMutableArray *toDataset = [self dataForCollectionView:toCollection];

    I3SimpleData *exchangingData = [fromDataset objectAtIndex:fromIndex.item];
    
    [fromDataset removeObjectAtIndex:fromIndex.item];
    [toDataset insertObject:exchangingData atIndex:toIndex.item];
    
    [fromCollection deleteItemsAtIndexPaths:@[fromIndex]];
    [toCollection insertItemsAtIndexPaths:@[toIndex]];
    
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:[self dataForCollectionView:toCollection].count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
