//
//  I32DropableTablesViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 21/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32DropableTablesViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I32DropableTablesViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32DropableTablesViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    /** Setup the table views with their data */

    self.leftData = [NSMutableArray arrayWithArray:@[@"1 Left", @"2 Left", @"3 Left", @"4 Left", @"5 Left"]];
    self.rightData = [NSMutableArray arrayWithArray:@[@"1 Right", @"2 Right", @"3 Right", @"4 Right", @"5 Right"]];
    
    [self.leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    /** Create the basic drag coordinator */
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftTableView, self.rightTableView]];
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return [(tableView == self.leftTableView ? self.leftData : self.rightData) count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    NSArray *data = tableView == self.leftTableView ? self.leftData : self.rightData;
    
    cell.textLabel.text = [data objectAtIndex:row];
    
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


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{

    /** Determine the `from` and `to` datasets */
    
    BOOL isFromLeftTable = fromCollection == self.leftTableView;
    
    NSNumber *exchangingData = isFromLeftTable ? [self.leftData objectAtIndex:fromIndex.row] : [self.rightData objectAtIndex:fromIndex.row];
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    NSMutableArray *toDataset = isFromLeftTable ? self.rightData : self.leftData;
    
    
    /** Update the data source and the individual table view rows */
    
    [fromDataset removeObjectAtIndex:fromIndex.row];
    [toDataset insertObject:exchangingData atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:fromIndex.row inSection:0]]];
    [toCollection insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:toIndex.row inSection:0]]];

}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    BOOL isFromLeftTable = fromCollection == self.leftTableView;
    
    NSArray *toData = isFromLeftTable ? self.rightData : self.leftData;
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:toData.count inSection:0];

    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
