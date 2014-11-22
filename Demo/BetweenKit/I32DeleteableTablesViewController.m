//
//  I32DeleteableTablesViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 22/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32DeleteableTablesViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I32DeleteableTablesViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32DeleteableTablesViewController


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


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
};


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


-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}


-(BOOL) canItemAtPoint:(CGPoint)from beDeletedFromCollection:(id<I3Collection>) collection atPoint:(CGPoint) to{
    
    CGPoint localPoint = [self.deleteArea convertPoint:to fromView:self.view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) deleteItemAtPoint:(CGPoint)at inCollection:(id<I3Collection>)collection{

    UITableView *fromTable = (UITableView *)collection.collectionView;
    NSIndexPath *fromIndex = [fromTable indexPathForRowAtPoint:at];
    
    BOOL isFromLeftTable = fromTable == self.leftTableView;
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    
    [fromDataset removeObjectAtIndex:fromIndex.row];
    [fromTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:fromIndex.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

}

@end
