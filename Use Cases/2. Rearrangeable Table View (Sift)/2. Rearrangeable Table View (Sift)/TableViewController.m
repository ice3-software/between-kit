//
//  TableViewController.m
//  2. Rearrangeable Table View (Sift)
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "TableViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface TableViewController()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *data;

@end


@implementation TableViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    self.data = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8]];
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.tableView] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    ((I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate).rearrangeIsExchange = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];

}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return self.data.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.data[indexPath.row]];
    
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

    NSNumber *data = self.data[from.row];
    [self.data removeObject:data];
    [self.data insertObject:data atIndex:to.row];
    
    [self.tableView beginUpdates];
    [self.tableView deleteItemsAtIndexPaths:@[from]];
    [self.tableView insertRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

}


@end
