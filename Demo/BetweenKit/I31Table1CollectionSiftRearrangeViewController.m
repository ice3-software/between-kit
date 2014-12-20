//
//  I31Table1CollectionSiftRearrangeViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I31Table1CollectionSiftRearrangeViewController.h"
#import "I3SiftRearrangeRenderDelegate.h"


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I31Table1CollectionSiftRearrangeViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I31Table1CollectionSiftRearrangeViewController


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
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:nil];
    
    self.dragCoordinator.renderDelegate = [[I3SiftRearrangeRenderDelegate alloc] init];
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


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{

    NSMutableArray *data = collection == self.leftTable ? self.leftData : self.rightData;
    UIColor *colour = [data objectAtIndex:from.row];
    
    if([collection isKindOfClass:[UITableView class]]){
        
        [data removeObject:colour];
        [data insertObject:colour atIndex:to.row];

        UITableView *tableView = (UITableView *)collection;
        
        [tableView beginUpdates];
        [tableView deleteItemsAtIndexPaths:@[from]];
        [tableView insertItemsAtIndexPaths:@[to]];
        [tableView endUpdates];
        
    }
    else{
        
        UICollectionView *collectionView = (UICollectionView *)collection;
        
        [data removeObject:colour];
        [collectionView deleteItemsAtIndexPaths:@[from]];
        
        [data insertObject:colour atIndex:to.row];
        [collectionView insertItemsAtIndexPaths:@[to]];
        
    }

}


@end
