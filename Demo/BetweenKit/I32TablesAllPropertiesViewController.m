//
//  I3ViewController.m
//  BetweenKit
//
//  Created by stephen fortune on 09/14/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32TablesAllPropertiesViewController.h"
#import "I3SimpleData.h"
#import "I3SubtitleCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I32TablesAllPropertiesViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32TablesAllPropertiesViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];

    
    
    self.leftData = [NSMutableArray arrayWithArray:@[
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 1" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 3" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Left Item 4" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 5" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Left Item 6" withSubtitle:@"Oh hey there, I'm also normal" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor redColor] withTitle:@"Left Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
                                                     ]];
    
    self.rightData = [NSMutableArray arrayWithArray:@[
                                                     [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Right Item 1" withSubtitle:@"I'm a bit edgey. Don't think you can just throw me around" withCanDelete:NO withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Right Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor redColor] withTitle:@"Right Item 3" withSubtitle:@"Seriously, don't touch me." withCanDelete:NO withCanMove:NO],
                                                     [[I3SimpleData alloc] initWithColor:nil withTitle:@"Right Item 4" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Right Item 5" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Right Item 6" withSubtitle:@"I ain't afraid of no ghost." withCanDelete:NO withCanMove:YES],
                                                     [[I3SimpleData alloc] initWithColor:[UIColor redColor] withTitle:@"Right Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
                                                     ]];

    [self.leftTableView registerClass:[I3SubtitleCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTableView registerClass:[I3SubtitleCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.leftTableView, self.rightTableView]];
    
    /** Customize the rendering style a bit, because its Christmas */
    
    I3BasicRenderDelegate *renderDelegate = (I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate;
    renderDelegate.draggingItemOpacity = 0.3;
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSArray *data = tableView == self.leftTableView ? self.leftData : self.rightData;
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


-(void) dropRowFromTable:(UITableView *)fromTable atIndexPath:(NSIndexPath *)fromIndex toTable:(UITableView *)toTable toIndexPath:(NSIndexPath *)toIndex{
    
    /** Determine the `from` and `to` datasets */
    
    BOOL isFromLeftTable = fromTable == self.leftTableView;
    
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


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>) collection{

    BOOL isLeftCollection = collection.collectionView == self.leftTableView;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:at.row] : [self.rightData objectAtIndex:at.row];
    
    return fromDatum.canMove;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)collection{

    BOOL isLeftCollection = collection.collectionView == self.leftTableView;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:to.row];
    I3SimpleData *toDatum = isLeftCollection ? [self.leftData objectAtIndex:to.row] : [self.rightData objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection beAppendedToCollection:(id<I3Collection>)toCollection atPoint:(CGPoint)to{

    BOOL isLeftCollection = fromCollection.collectionView == self.leftTableView;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    
    return fromDatum.canMove && ![self isPointInDeletionArea:to fromView:toCollection.collectionView];
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection beExchangedWithItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)toCollection{

    BOOL isFromLeftCollection = fromCollection.collectionView == self.leftTableView;
    
    I3SimpleData *fromDatum = isFromLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    I3SimpleData *toDatum = isFromLeftCollection ? [self.rightData objectAtIndex:to.row] : [self.leftData objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(id<I3Collection>)collection atPoint:(CGPoint)to{

    BOOL isLeftCollection = collection.collectionView == self.leftTableView;
    
    I3SimpleData *fromDatum = isLeftCollection ? [self.leftData objectAtIndex:from.row] : [self.rightData objectAtIndex:from.row];
    
    return fromDatum.canDelete && [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(id<I3Collection>) collection{
    
    UITableView *fromTable = (UITableView *)collection.collectionView;
    
    BOOL isFromLeftTable = fromTable == self.leftTableView;
    NSMutableArray *fromDataset = isFromLeftTable ? self.leftData : self.rightData;
    
    [fromDataset removeObjectAtIndex:at.row];
    [fromTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:at.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)collection{
    
    UITableView *targetTableView = (UITableView *)collection.collectionView;
    NSMutableArray *targetDataset = targetTableView == self.leftTableView ? self.leftData : self.rightData;
    
    [targetDataset exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [targetTableView reloadRowsAtIndexPaths:@[to, from] withRowAnimation:UITableViewRowAnimationFade];
    [self logUpdatedData];
}


-(void) appendItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection toPoint:(CGPoint)to onCollection:(id<I3Collection>)onCollection{
    
    UITableView *fromTable = (UITableView *)fromCollection.collectionView;
    UITableView *toTable = (UITableView *)onCollection.collectionView;
    
    [self dropRowFromTable:fromTable atIndexPath:from toTable:toTable toIndexPath:[NSIndexPath indexPathForRow:[self tableView:toTable numberOfRowsInSection:0] inSection:0]];
}


-(void) exchangeItemAt:(NSIndexPath *)from inCollection:(id<I3Collection>)fromCollection withItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)toCollection{
    
    [self dropRowFromTable:(UITableView *)fromCollection.collectionView atIndexPath:from toTable:(UITableView *)toCollection.collectionView toIndexPath:to];
}


@end
