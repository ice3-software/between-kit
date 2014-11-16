//
//  I3ViewController.m
//  BetweenKit
//
//  Created by stephen fortune on 09/14/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32RearrangeableTablesViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I32RearrangeableTablesViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) I3DragArena *arena;

@property (nonatomic, strong) I3BasicRenderDelegate *renderDelegate;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32RearrangeableTablesViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];

    
    /** Setup the table views with their data */

    NSArray *data = @[@1, @2, @3, @4, @5];
    self.leftData = [NSMutableArray arrayWithArray:data];
    self.rightData = [NSMutableArray arrayWithArray:data];

    [self.leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    /** Setup the coordinator with its dependencies */
    
    self.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    self.arena = [[I3DragArena alloc] initWithSuperview:self.view containingCollections:@[self.leftTableView, self.rightTableView]];
    
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:self.arena withGestureRecognizer:nil];
    self.dragCoordinator.renderDelegate = self.renderDelegate;
    self.dragCoordinator = self;
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSNumber *value;
    
    if(tableView == self.leftTableView){
        value = [self.leftData objectAtIndex:indexPath.row];
    }
    else{
        value = [self.rightData objectAtIndex:indexPath.row];
    }

    return (value.integerValue % 2) ? 50.0f : 100.0f;
};


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    
    if(tableView == self.leftTableView){
        return [self.leftData count];
    }
    else{
        return [self.rightData count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell
                                                            forIndexPath:indexPath];
    
    if(tableView == self.leftTableView){
        NSInteger row = [indexPath row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ left", [self.leftData objectAtIndex:row]];
    }
    else{
        NSInteger row = [indexPath row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ right", [self.rightData objectAtIndex:row]];
    }
    
    return cell;
}



#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}


-(BOOL) canItemFromPoint:(CGPoint)from beRearrangedWithItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    return YES;
}


-(void) rearrangeItemAtPoint:(CGPoint)from withItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    
    UITableView *targetTableView = (UITableView *)collection.collectionView;
    
    NSIndexPath *toIndex = [targetTableView indexPathForRowAtPoint:to];
    NSIndexPath *fromIndex = [targetTableView indexPathForRowAtPoint:from];

    NSMutableArray *targetDataset = targetTableView == self.leftTableView ? self.leftData : self.rightData;
    
    [targetDataset exchangeObjectAtIndex:toIndex.row withObjectAtIndex:fromIndex.row];
    [targetTableView reloadRowsAtIndexPaths:@[toIndex, fromIndex] withRowAnimation:UITableViewRowAnimationFade];
}


@end
