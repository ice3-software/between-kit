//
//  I3UnrarranreableToRearrangeableCollectionsViewController.m
//  Test App
//
//  Created by Stephen Fortune on 06/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3UnrarranreableToRearrangeableCollectionsViewController.h"

static NSString* DequeueReusableCell = @"DequeueReusableCell";

@interface I3UnrarranreableToRearrangeableCollectionsViewController ()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

/** Dummy data */

@property (nonatomic, strong) NSMutableOrderedSet* leftData;

@property (nonatomic, strong) NSMutableOrderedSet* rightData;

-(void) alertDuplicate;

@end


@implementation I3UnrarranreableToRearrangeableCollectionsViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    
    /* The data sources and delegates */
    
    NSArray* leftData = @[
                          [UIColor redColor],
                          [UIColor greenColor],
                          [UIColor blueColor],
                          [UIColor yellowColor],
                          [UIColor orangeColor],
                          [UIColor purpleColor],
                          [UIColor whiteColor],
                          [UIColor lightGrayColor],
                          [UIColor grayColor],
                          [UIColor darkGrayColor],
                          ];
    
    NSArray* rightData = @[
                           [UIColor colorWithRed:0.3 green:0.25 blue:0.4 alpha:1], // Placeholder
                           ];
    
    self.leftData = [NSMutableOrderedSet orderedSetWithArray:leftData];
    self.rightData = [NSMutableOrderedSet orderedSetWithArray:rightData];
    
    
    [self.leftCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.rightCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.leftCollection
                                                         dstView:self.rightCollection];
    
    self.helper.delegate = self;
    
    
    
    /* The source is not rearrangeable or exchangeable with the dest */
    
    self.helper.isSrcRearrangeable = NO;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.hideSrcDraggingCell = NO;

    self.helper.isDstRearrangeable = YES;
    self.helper.doesDstRecieveSrc = YES;
    self.helper.hideDstDraggingCell = YES;
    
    
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}



#pragma mark - Drag n drop exchange and rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    [self.rightCollection cellForItemAtIndexPath:from].alpha = 1;
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    [self.rightData exchangeObjectAtIndex:toIndex withObjectAtIndex:fromIndex];
    
}

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from{
    
    
    /* Grab the appropriate data */
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    UIColor* fromData = [self.leftData objectAtIndex:fromIndex];
    
    
    /* Update the data and collections accordingly */
    
    if(![self.rightData containsObject:fromData]){
    
        [self.rightData insertObject:fromData atIndex:toIndex];
        [self.rightCollection insertItemsAtIndexPaths:@[to]];

    }
    else{
    
        [self alertDuplicate];
    }
    
}


#pragma mark - Undraggable, unrearrangelble cell delegate methods

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container{
    
    if(container == self.rightCollection){
        
        /* Stop the last cell from dragging */

        return index.item != self.rightData.count - 1;

    }
    
    return YES;
}

-(BOOL) isCellInDstAtIndexPathExchangable:(NSIndexPath*) to withCellAtIndexPath:(NSIndexPath*) from{
    
    /* Stop the last cell from being exchangeable */
    
    return to.item != self.rightData.count - 1;
    
}


#pragma mark - Delete dropping outside the Dst's bounds

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from{
    
    /* Returning NO triggers the shrink */
    
    return NO;
}

-(void) itemFromDstDeletedAtIndexPath:(NSIndexPath*) path{
    
    /* The deletion animation from the helper is finished so update the data accordingly */
    
    NSInteger fromIndex = [path row];
    [self.rightData removeObjectAtIndex:fromIndex];
    [self.rightCollection deleteItemsAtIndexPaths:@[path]];
    
}





#pragma mark - Collection view delegate and datasource implementations


-(NSInteger) collectionView:(UICollectionView*) collectionView numberOfItemsInSection:(NSInteger) section{
    
    
    if(collectionView == self.leftCollection){
        
        return self.leftData.count;
    }
    else{
        
        return self.rightData.count;
    }
    
}

-(UICollectionViewCell*) collectionView:(UICollectionView*) collectionView cellForItemAtIndexPath:(NSIndexPath*) indexPath{
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DequeueReusableCell
                                                                           forIndexPath:indexPath];
    if(collectionView == self.leftCollection){
        
        cell.backgroundColor = [self.leftData objectAtIndex:indexPath.item];
        
    }
    else{
        
        cell.backgroundColor = [self.rightData objectAtIndex:indexPath.item];
        
    }
    
    return cell;
}


#pragma mark - Alert dialog

-(void) alertDuplicate{
    
    static UIAlertView* alert = nil;
    
    if(!alert){
        
        // TODO: Move the message to a config/txt file
        
        alert = [[UIAlertView alloc] initWithTitle:@"Duplicate!"
                                           message:@"The data you dragged from the source table (left) to the destination table (right) is already in there. NSOrederedSet doesn't allow duplicate objects"
                                          delegate:nil
                                 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    
    [alert show];
}


@end
