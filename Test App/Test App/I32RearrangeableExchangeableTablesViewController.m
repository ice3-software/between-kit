//
//  I32RearrangeableExchangeableTablesViewController.m
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I32RearrangeableExchangeableTablesViewController.h"

static NSString* DequeueReusableCell = @"DequeueReusableCell";


/** These constants are used to identify various 'special' drag cells */

static NSString* kLeftUndraggableValue = @"Left - Undraggable";
static NSString* kLeftUnrearrangeableValue = @"Left - Unrearrangeable";
static NSString* kLeftUndraggableUnrearrangeableValue = @"Left - Undraggable & Unrearrangeable";

static NSString* kRightUndraggableValue = @"Right - Undraggable";
static NSString* kRightUnrearrangeableValue = @"Right - Unrearrangeable";
static NSString* kRightUndraggableUnrearrangeableValue = @"Right - Undraggable & Unrearrangeable";



@interface I32RearrangeableExchangeableTablesViewController()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

/** Dummy data */

@property (nonatomic, strong) NSMutableOrderedSet* leftData;

@property (nonatomic, strong) NSMutableOrderedSet* rightData;

@end



@implementation I32RearrangeableExchangeableTablesViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    
    /* The table data sources and delegates */
    
    NSArray* leftData = @[
                          @"Left 1",
                          @"Left 2",
                          @"Left 3",
                          @"Left 4",
                          @"Left 5",
                          kLeftUndraggableValue,
                          kLeftUnrearrangeableValue,
                          kLeftUndraggableUnrearrangeableValue,
                          ];
    
    NSArray* rightData = @[
                           @"Right 1",
                           @"Right 2",
                           @"Right 3",
                           @"Right 4",
                           @"Right 5",
                           kRightUndraggableValue,
                           kRightUnrearrangeableValue,
                           kRightUndraggableUnrearrangeableValue,
                           ];
    
    self.leftData = [NSMutableOrderedSet orderedSetWithArray:leftData];
    self.rightData = [NSMutableOrderedSet orderedSetWithArray:rightData];
    
    
    [self.leftTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view // The UIView we're draggin around in
                                                         srcView:self.leftTable // The Src
                                                         dstView:self.rightTable]; // The Dst
    
    self.helper.delegate = self;
    
        
    /* Both are rearrangeable and accept each other */
    
    self.helper.isDstRearrangeable = YES;
    self.helper.isSrcRearrangeable = YES;
    
    self.helper.doesSrcRecieveDst = YES;
    self.helper.doesDstRecieveSrc = YES;
    
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}



#pragma mark - Drag n Drop rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    [self.rightData exchangeObjectAtIndex:toRow withObjectAtIndex:fromRow];
}

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*) from{
        
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    [self.leftData exchangeObjectAtIndex:toRow withObjectAtIndex:fromRow];
    
}



#pragma mark - Drag n drop exchange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from{
    
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    
    /* Grab the data we're adding to the Dst table */
    
    NSString* fromData = [self.leftData objectAtIndex:fromRow];
    
    
    /* Add it to the Dst table data source */
    
    [self.rightData insertObject:fromData atIndex:toRow];
    [self.leftData removeObjectAtIndex:fromRow];
    
    
    /* Unlike with rearranging, we are left responsible for updating the
        table view for exchanges.
     
       'Why?' you might ask. Well if the data is inconsistent with the
        table view cell arrangement an exception will be throw by the
        table/collection view. We delegate this to the user so that the
        helper isn't responsible for any hidden inconsistency exceptions */
    
    [self.rightTable insertRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationFade];
    [self.leftTable deleteRowsAtIndexPaths:@[from] withRowAnimation:UITableViewRowAnimationFade];
    
}


-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    
    /* Grab the data we're adding to the Dst table */
    
    NSString* fromData = [self.rightData objectAtIndex:fromRow];
    
    
    /* Add it to the Dst table data source */
    
    [self.leftData insertObject:fromData atIndex:toRow];
    [self.rightData removeObjectAtIndex:fromRow];
    
    [self.leftTable insertRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationFade];
    [self.rightTable deleteRowsAtIndexPaths:@[from] withRowAnimation:UITableViewRowAnimationFade];
    
    
}


#pragma mark - Undraggable/Unrearrangeable cell implementations

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container{

    NSString* dataValue;
    
    if(container == self.leftTable){
        
        /* We know from the container pointer passed that we're dealing with the left
            table*/
        
        NSInteger row = [index row];
        dataValue = [self.leftData objectAtIndex:row];
        

    }
    else{
    
        /* We know from the container pointer passed that we're dealing with the right
            table*/
        
        NSInteger row = [index row];
        dataValue = [self.rightData objectAtIndex:row];
        
    }
    
    
    /** If the cell doesn't have the specific undraggable value, or the undraggable/
        unrearrangeable value then its OK to drag */
    
    return ![dataValue isEqualToString:kLeftUndraggableValue] &&
            ![dataValue isEqualToString:kLeftUndraggableUnrearrangeableValue] &&
            ![dataValue isEqualToString:kRightUndraggableValue] &&
            ![dataValue isEqualToString:kRightUndraggableUnrearrangeableValue];

}


-(BOOL) isCellInDstAtIndexPathExchangable:(NSIndexPath*) to withCellAtIndexPath:(NSIndexPath*) from{
    
    
    NSInteger row = [to row];
    NSString* dataValue = [self.rightData objectAtIndex:row];
    
    /** If the cell doesn't have the specific unrearrangeable value, or the undraggable/
         unrearrangeable value then its OK to rearrange */
    
    return ![dataValue isEqualToString:kRightUnrearrangeableValue] &&
            ![dataValue isEqualToString:kRightUndraggableUnrearrangeableValue]&&
            ![dataValue isEqualToString:kLeftUnrearrangeableValue] &&
            ![dataValue isEqualToString:kLeftUndraggableUnrearrangeableValue];

}


-(BOOL) isCellInSrcAtIndexPathExchangable:(NSIndexPath*) to withCellAtIndexPath:(NSIndexPath*) from{
    
    NSInteger row = [to row];
    NSString* dataValue = [self.leftData objectAtIndex:row];
    
    /** If the cell doesn't have the specific unrearrangeable value, or the undraggable/
        unrearrangeable value then its OK to rearrange */
    
    return ![dataValue isEqualToString:kRightUnrearrangeableValue] &&
            ![dataValue isEqualToString:kRightUndraggableUnrearrangeableValue]&&
            ![dataValue isEqualToString:kLeftUnrearrangeableValue] &&
            ![dataValue isEqualToString:kLeftUndraggableUnrearrangeableValue];
}



#pragma mark - Table view delegate and datasource implementations


-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section{
    
    if(tableView == self.leftTable){
        
        return [self.leftData count];
    }
    else{
        
        return [self.rightData count];
    }
}


-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell
                                                            forIndexPath:indexPath];
    
    if(tableView == self.leftTable){
        
        NSInteger row = [indexPath row];
        cell.textLabel.text = [self.leftData objectAtIndex:row];
        
    }
    else{
        
        NSInteger row = [indexPath row];
        cell.textLabel.text = [self.rightData objectAtIndex:row];
        
    }
    
    return cell;
}

@end
