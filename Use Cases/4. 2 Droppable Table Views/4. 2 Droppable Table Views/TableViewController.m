//
//  TableViewController.m
//  4. 2 Droppable Table Views
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import "TableViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface TableViewController ()

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation TableViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    self.leftData = [NSMutableArray arrayWithArray:@[@"1 Left", @"2 Left", @"3 Left", @"4 Left", @"5 Left", @"6 Left", @"7 Left", @"8 Left"]];
    self.rightData = [NSMutableArray arrayWithArray:@[@"1 Right", @"2 Right", @"3 Right", @"4 Right", @"5 Right", @"6 Right", @"7 Right", @"8 Right"]];

    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftTable, self.rightTable]];
    
    [self.leftTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


-(NSMutableArray *)dataForTable:(UIView *)table{
    return table == self.leftTable ? self.leftData : self.rightData;
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return [self dataForTable:tableView].count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self dataForTable:tableView] objectAtIndex:indexPath.row]];
    
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
    
    NSMutableArray *fromDataset = [self dataForTable:fromCollection];
    NSMutableArray *toDataset = [self dataForTable:toCollection];
    NSString *exchangingData = fromDataset[from.row];
    
    [fromDataset removeObjectAtIndex:from.row];
    [toDataset insertObject:exchangingData atIndex:to.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[to]];

}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:[self dataForTable:toCollection].count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
