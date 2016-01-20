//
//  CollectionViewController.m
//  10. 2 Collection Views All Properties
//
//  Created by Stephen Fortune on 22/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import "CollectionViewController.h"
#import "I3SubtitleCollectionViewCell.h"
#import "I3SimpleData.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


@interface CollectionViewController ()

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation CollectionViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    self.leftData = [NSMutableArray arrayWithArray:@[
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 1" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 3" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:LIGHT_GREEN_COLOUR withTitle:@"Left Item 4" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 5" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 6" withSubtitle:@"Oh hey there, I'm also normal" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:LIGHT_RED_COLOUR withTitle:@"Left Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
                                                     ]];
    
    self.rightData = [NSMutableArray arrayWithArray:@[
                                                      [[I3SimpleData alloc] initWithColor:LIGHT_GREEN_COLOUR withTitle:@"Right Item 1" withSubtitle:@"I'm a bit edgey. Don't think you can just throw me around" withCanDelete:NO withCanMove:YES],
                                                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Right Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                      [[I3SimpleData alloc] initWithColor:LIGHT_RED_COLOUR withTitle:@"Right Item 3" withSubtitle:@"Seriously, don't touch me." withCanDelete:NO withCanMove:NO],
                                                      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Right Item 4" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
                                                      [[I3SimpleData alloc] initWithColor:LIGHT_GREEN_COLOUR withTitle:@"Right Item 5" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
                                                      [[I3SimpleData alloc] initWithColor:LIGHT_GREEN_COLOUR withTitle:@"Right Item 6" withSubtitle:@"I ain't afraid of no ghost." withCanDelete:NO withCanMove:YES],
                                                      [[I3SimpleData alloc] initWithColor:LIGHT_RED_COLOUR withTitle:@"Right Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
                                                      ]];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftCollection, self.rightCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
    [self.leftCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    [self.rightCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    
    I3BasicRenderDelegate *renderDelegate = (I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate;
    renderDelegate.draggingItemOpacity = 0.3;

}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


-(NSMutableArray *)dataForCollection:(UIView *)collection{
    return collection == self.leftCollection ? self.leftData : self.rightData;
}


-(BOOL) isPointInDeletionArea:(CGPoint) point fromView:(UIView *)view{
    
    CGPoint localPoint = [self.deleteArea convertPoint:point fromView:view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self dataForCollection:collectionView].count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    I3SubtitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier forIndexPath:indexPath];
    I3SimpleData *datum = [[self dataForCollection:collectionView] objectAtIndex:indexPath.row];
    
    cell.title.text = datum.title;
    cell.subtitle.text = datum.subtitle;
    cell.backgroundColor = datum.colour;
    
    return cell;
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    I3SimpleData *fromDatum = [[self dataForCollection:collection] objectAtIndex:at.item];
    
    return fromDatum.canMove;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    NSArray *data = [self dataForCollection:collection];
    
    I3SimpleData *fromDatum = [data objectAtIndex:from.item];
    I3SimpleData *toDatum = [data objectAtIndex:to.item];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSArray *fromData = [self dataForCollection:fromCollection];
    NSArray *toData = [self dataForCollection:toCollection];
    
    I3SimpleData *fromDatum = [fromData objectAtIndex:from.item];
    I3SimpleData *toDatum = [toData objectAtIndex:to.item];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    
    I3SimpleData *fromDatum = [[self dataForCollection:fromCollection] objectAtIndex:from.item];
    return fromDatum.canMove && ![self isPointInDeletionArea:at fromView:toCollection];
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    I3SimpleData *fromDatum = [[self dataForCollection:collection] objectAtIndex:from.item];
    return fromDatum.canDelete && [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *fromDataset = [self dataForCollection:collection];
    
    [fromDataset removeObjectAtIndex:at.row];
    [collection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:at.row inSection:0]]];
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{

    NSMutableArray *targetDataset = [self dataForCollection:collection];
    
    [targetDataset exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [collection reloadItemsAtIndexPaths:@[to, from]];
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromDataset = [self dataForCollection:fromCollection];
    NSMutableArray *toDataset = [self dataForCollection:toCollection];
    NSNumber *exchangingData = [fromDataset objectAtIndex:fromIndex.row];
    
    [fromDataset removeObjectAtIndex:fromIndex.row];
    [toDataset insertObject:exchangingData atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[fromIndex]];
    [toCollection insertItemsAtIndexPaths:@[toIndex]];
     
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    NSArray *toData = [self dataForCollection:toCollection];
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:toData.count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
