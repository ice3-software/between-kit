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
#import "I3FunkRenderDelegate.h"


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I3CustomerRenderDelegateViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

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
                                                      [UIColor grayColor],
                                                      [UIColor darkTextColor],
                                                      [UIColor darkGrayColor],
                                                      [UIColor redColor],
                                                      [UIColor greenColor],
                                                      [UIColor blueColor],
                                                      [UIColor yellowColor],
                                                      [UIColor orangeColor],
                                                      [UIColor purpleColor],
                                                      ]];
    
    
    I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:self.view containingCollections:@[self.leftTable, self.rightCollection]];
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
    self.dragCoordinator.renderDelegate = [[I3FunkRenderDelegate alloc] initWithPotentialDstViews:@[self.leftTable, self.rightCollection, self.deleteArea] andDeleteArea:self.deleteArea];
    self.dragCoordinator.dragDataSource = self;
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


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
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


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    NSInteger toIndex = [[self dataForCollectionView:toCollection] count];
    NSIndexPath *toIndexPath = [toCollection isKindOfClass:[UITableView class]] ? [NSIndexPath indexPathForRow:toIndex inSection:0] : [NSIndexPath indexPathForItem:toIndex inSection:0];

    NSMutableArray *fromData = [self dataForCollectionView:fromCollection];
    NSMutableArray *toData = [self dataForCollectionView:toCollection];
    
    UIColor *exchangingDatum = [fromData objectAtIndex:from.row];
    
    [fromData removeObjectAtIndex:from.row];
    [toData insertObject:exchangingDatum atIndex:toIndexPath.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[toIndexPath]];
    
    [self logUpdatedData];
}


@end
