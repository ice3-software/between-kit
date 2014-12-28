//
//  FluidUIViewController.m
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "FluidUIViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";

NSString *const kCommentsIcon = @"icon_comments.png";
NSString *const kCubeIcon = @"icon_cube.png";
NSString *const kBombIcon = @"icon_bomb.png";
NSString *const kBugIcon = @"icon_bug.png";
NSString *const kBellIcon = @"icon_bell.png";
NSString *const kPlusTextFieldIcon = @"icon_plus_text_field.png";
NSString *const kPlusTextAreaIcon = @"icon_plus_text_area.png";
NSString *const kPlusButtonIcon = @"icon_plus_button.png";
NSString *const kPlusSwitchIcon = @"icon_plus_switch.png";


@interface FluidUIViewController ()

@property (nonatomic, strong) NSMutableArray *tlToolbarItems;

@property (nonatomic, strong) NSMutableArray *bToolbarItems;

@property (nonatomic, strong) NSMutableArray *formItems;

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@end


@implementation FluidUIViewController

-(void) viewDidLoad{

    [super viewDidLoad];

    
    /// Setup the data arrays
    
    self.tlToolbarItems = [NSMutableArray arrayWithArray:@[kCommentsIcon, kCubeIcon, kBombIcon, kBugIcon, kBellIcon]];
    self.bToolbarItems = [NSMutableArray arrayWithArray:@[kPlusTextFieldIcon, kPlusTextAreaIcon, kPlusButtonIcon, kPlusSwitchIcon]];
    self.formItems = [[NSMutableArray alloc] init];
    
    
    /// Setup the collection views and table view
    
    self.tlToolbarCollection.delegate = self;
    self.tlToolbarCollection.dataSource = self;
    
    self.bToolbarCollection.delegate = self;
    self.bToolbarCollection.dataSource = self;
    
    self.formTable.delegate = self;
    self.formTable.dataSource = self;
    
    [self.tlToolbarCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.bToolbarCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    /// @todo Register cells for table
    
    
    /// Setup the drag coordinator + customize rendering
    
    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.tlToolbarCollection, self.bToolbarCollection, self.formTable] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
    I3BasicRenderDelegate *renderDelegate = (I3BasicRenderDelegate *)self.dragCoordinator.renderDelegate;
    renderDelegate.draggingItemOpacity = 0.3;

    
}

-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helpers


-(NSMutableArray *)dataForCollectionView:(UIView *)collection{
    
    return collection == self.tlToolbarCollection ? self.tlToolbarItems : self.bToolbarItems;
}


-(BOOL) isPointInScrapArea:(CGPoint) at fromView:(UIView *)view{
    
    CGPoint localPoint = [view convertPoint:at fromView:view];
    return [self.scrapArea pointInside:localPoint withEvent:nil];
}


-(BOOL) isCollectionToolbar:(UIView *)collection{
    return collection == self.tlToolbarCollection || collection == self.bToolbarCollection;
}


-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self dataForCollectionView:collectionView].count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSArray *data = [self dataForCollectionView:collectionView];
    NSString *iconName = data[indexPath.item];

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell forIndexPath:indexPath];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    return cell;
}


-(BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    
    NSArray *data = [self dataForCollectionView:collectionView];
    NSString *iconName = data[indexPath.item];
    
    
    if([iconName isEqualToString:kBellIcon]){
        [self showAlertWithTitle:@"Bell" andMessage:@"Ding ding!"];
    }
    else if([iconName isEqualToString:kBombIcon]){
        [self showAlertWithTitle:@"Bomb" andMessage:@"Boooommmb."];
    }
    else if([iconName isEqualToString:kBugIcon]){
        [self showAlertWithTitle:@"Bug" andMessage:@"5 + 5 = 10.00000345"];
    }
    else if([iconName isEqualToString:kCubeIcon]){
        [self showAlertWithTitle:@"Cube" andMessage:@"IceCube Software Ltd."];
    }
    else if([iconName isEqualToString:kCommentsIcon]){
        [self showAlertWithTitle:@"Comments" andMessage:@"Hey... hows you?"];
    }
    else if([iconName isEqualToString:kPlusTextFieldIcon]){
        
    }
    else if([iconName isEqualToString:kPlusTextAreaIcon]){
        
    }
    else if([iconName isEqualToString:kPlusButtonIcon]){
        
    }
    else if([iconName isEqualToString:kPlusSwitchIcon]){
        
    }

    /// Cell selection animation
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundView.alpha = 0.4;
    
    [UIView animateWithDuration:0.5 animations:^{
        cell.backgroundView.alpha = 1;
    }];

}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    return collection == self.formTable  && [self isPointInScrapArea:to fromView:self.view];
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return [self isCollectionToolbar:fromCollection] && [self isCollectionToolbar:toCollection];
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    return [self isCollectionToolbar:fromCollection] && [self isCollectionToolbar:toCollection];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    if([collection isKindOfClass:[UICollectionView class]]){
        
        NSMutableArray *data = [self dataForCollectionView:collection];
        NSString *iconName = data[from.row];
        
        [data removeObject:iconName];
        [data insertObject:iconName atIndex:to.row];
        
        [(UICollectionView *)collection performBatchUpdates:^{
            
            [collection deleteItemsAtIndexPaths:@[from]];
            [collection insertItemsAtIndexPaths:@[to]];
            
        } completion:nil];
        
    }
    else{
        ///...
    }
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromDataset = [self dataForCollectionView:fromCollection];
    NSMutableArray *toDataset = [self dataForCollectionView:toCollection];
    NSString *exchangingData = fromDataset[from.row];
    
    [fromDataset removeObjectAtIndex:from.row];
    [toDataset insertObject:exchangingData atIndex:to.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[to]];
    
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{
    
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:[self dataForCollectionView:toCollection].count inSection:0];
    
    [self dropItemAt:from fromCollection:fromCollection toItemAt:toIndex onCollection:toCollection];
}


@end
