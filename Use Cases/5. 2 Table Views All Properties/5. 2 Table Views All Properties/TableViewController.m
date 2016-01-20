//
//  TableViewController.m
//  5. 2 Table Views, All Properties
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import "TableViewController.h"
#import "I3SimpleData.h"
#import "I3SubtitleTableViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface TableViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation TableViewController


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
    
    [self.leftTable registerClass:[I3SubtitleTableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[I3SubtitleTableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftTable, self.rightTable]];
    
    /** Customize the rendering style a bit, because its Christmas */
    
    I3BasicRenderDelegate *renderDelegate = (I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate;
    renderDelegate.draggingItemOpacity = 0.3;
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    
    if(tableView == self.leftTable){
        return [self.leftData count];
    }
    else{
        return [self.rightData count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSArray *data = tableView == self.leftTable ? self.leftData : self.rightData;
    I3SimpleData *datum = [data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = datum.title;
    cell.detailTextLabel.text = datum.subtitle;
    cell.backgroundColor = datum.colour;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - Helpers


-(BOOL) isPointInDeletionArea:(CGPoint) point fromView:(UIView *)view{
    
    CGPoint localPoint = [self.deleteArea convertPoint:point fromView:view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) logUpdatedData{
    
    NSLog(@"Left: %@, right: %@", self.leftData, self.rightData);
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    BOOL isLeftCollection = collection == self.leftTable;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:at.row] : [self.rightData objectAtIndex:at.row];
    
    return fromDatum.canMove;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    BOOL isLeftCollection = collection == self.leftTable;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:to.row];
    I3SimpleData *toDatum = isLeftCollection ? [self.leftData objectAtIndex:to.row] : [self.rightData objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    BOOL isFromLeftCollection = fromCollection == self.leftTable;
    
    I3SimpleData *fromDatum = isFromLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    I3SimpleData *toDatum = isFromLeftCollection ? [self.rightData objectAtIndex:to.row] : [self.leftData objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    
    BOOL isLeftCollection = fromCollection == self.leftTable;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    
    return fromDatum.canMove && ![self isPointInDeletionArea:at fromView:toCollection];
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    BOOL isLeftCollection = collection == self.leftTable;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    
    return fromDatum.canDelete && [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    UITableView *fromTable = (UITableView *)collection;
    
    BOOL isFromLeftTable = fromTable == self.leftTable;
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    
    [fromDataset removeObjectAtIndex:at.row];
    [fromTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:at.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    UITableView *targetTableView = (UITableView *)collection;
    NSMutableArray *targetDataset = targetTableView == self.leftTable ? self.leftData : self.rightData;
    
    [targetDataset exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [targetTableView reloadRowsAtIndexPaths:@[to, from] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) dropItemAt:(NSIndexPath *)fromIndex fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)toIndex onCollection:(UIView<I3Collection> *)toCollection{
    
    UITableView *fromTable = (UITableView *)fromCollection;
    UITableView *toTable = (UITableView *)toCollection;
    
    /** Determine the `from` and `to` datasets */
    
    BOOL isFromLeftTable = fromTable == self.leftTable;
    
    NSNumber *exchangingData = isFromLeftTable ? [self.leftData objectAtIndex:fromIndex.row] : [self.rightData objectAtIndex:fromIndex.row];
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    NSMutableArray *toDataset = isFromLeftTable ? self.rightData : self.leftData;
    
    
    /** Update the data source and the individual table view rows */
    
    [fromDataset removeObjectAtIndex:fromIndex.row];
    [toDataset insertObject:exchangingData atIndex:toIndex.row];
    
    [fromTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:fromIndex.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [toTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:toIndex.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self logUpdatedData];
    
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    BOOL isFromLeftTable = fromCollection == self.leftTable;
    
    NSArray *toData = isFromLeftTable ? self.rightData : self.leftData;
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:toData.count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
