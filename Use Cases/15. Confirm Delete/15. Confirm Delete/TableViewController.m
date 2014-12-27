//
//  TableViewController.m
//  3. Deletable Table View
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

@property (nonatomic, strong) UIAlertView *confirmDialog;

@property (nonatomic, strong) NSIndexPath *deletingIndexPath;

@end


@implementation TableViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    self.data = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8]];
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.tableView] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];

}


-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Accessors


-(UIAlertView *)confirmDialog{

    if(!_confirmDialog){
    
        _confirmDialog = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    return _confirmDialog;
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


#pragma mark - UIAlertViewDelegate


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex != self.confirmDialog.cancelButtonIndex){
        
        [self.data removeObjectAtIndex:self.deletingIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.deletingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        self.deletingIndexPath = nil;
    
    }
    else{
    
        [self.tableView reloadItemsAtIndexPaths:@[self.deletingIndexPath]];
    }
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    CGPoint localPoint = [self.deleteArea convertPoint:to fromView:self.view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    self.deletingIndexPath = at;
    [self.confirmDialog show];
}


@end
