//
//  I32ExchangeableCollectionViewsController.m
//  Test App
//
//  Created by Stephen Fortune on 05/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I32ExchangeableCollectionViewsController.h"

static NSString* DequeueReusableCell = @"DequeueReusableCell";

@interface I32ExchangeableCollectionViewsController ()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

/** Dummy data */

@property (nonatomic, strong) NSMutableOrderedSet* leftData;

@property (nonatomic, strong) NSMutableOrderedSet* rightData;

@end

@implementation I32ExchangeableCollectionViewsController
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
                          ];
    
    NSArray* rightData = @[
                           [UIColor whiteColor],
                           [UIColor grayColor],
                           [UIColor darkGrayColor],
                           [UIColor darkTextColor],
                           [UIColor lightGrayColor],
                           [UIColor lightTextColor],
                           ];
    
    self.leftData = [NSMutableOrderedSet orderedSetWithArray:leftData];
    self.rightData = [NSMutableOrderedSet orderedSetWithArray:rightData];
    
    
    [self.leftCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    [self.rightCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view // The UIView we're draggin around in
                                                         srcView:self.leftCollection // The Src
                                                         dstView:self.rightCollection]; // The Dst
    
    self.helper.delegate = self;
    
    
    
    /* Both rearrangeable, exchangeable and hide the cells whilst dragging */
    
    self.helper.isDstRearrangeable = YES;
    self.helper.isSrcRearrangeable = YES;
    self.helper.doesSrcRecieveDst = YES;
    self.helper.doesDstRecieveSrc = YES;
    self.helper.hideDstDraggingCell = YES;
    self.helper.hideSrcDraggingCell = YES;
    
    
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

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*) from{
    
    [self.leftCollection cellForItemAtIndexPath:from].alpha = 1;

    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);

    [self.leftData exchangeObjectAtIndex:toIndex withObjectAtIndex:fromIndex];

}

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from{
    
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    UIColor* fromData = [self.leftData objectAtIndex:fromIndex];
    
    /* Update the data and collections accordingly */
    
    [self.rightData insertObject:fromData atIndex:toIndex];
    [self.leftData removeObjectAtIndex:fromIndex];
    
    [self.rightCollection insertItemsAtIndexPaths:@[to]];
    [self.leftCollection deleteItemsAtIndexPaths:@[from]];
    
    
}

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);

    UIColor* fromData = [self.rightData objectAtIndex:fromIndex];

    /* Update the data and collections accordingly */
    
    [self.leftData insertObject:fromData atIndex:toIndex];
    [self.rightData removeObjectAtIndex:fromIndex];
    
    [self.leftCollection insertItemsAtIndexPaths:@[to]];
    [self.rightCollection deleteItemsAtIndexPaths:@[from]];

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

@end
