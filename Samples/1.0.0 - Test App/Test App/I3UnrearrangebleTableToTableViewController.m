//
//  I3UnrearrangebleTableToTableViewController.m
//  Test App
//
//  Created by Stephen Fortune on 05/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3UnrearrangebleTableToTableViewController.h"


static NSString* DequeueReusableCell = @"DequeueReusableCell";


/** This is the value/id for the undraggable, unrearrangeable placeholder cell
     on the right hand table */

static NSString* kPlaceholderCell = @"Drag here to add...";


@interface I3UnrearrangebleTableToTableViewController ()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

/** Dummy data */

@property (nonatomic, strong) NSArray* leftData;

@property (nonatomic, strong) NSMutableOrderedSet* rightData;

/** Alerts the user that they can't have duplicate data in the right hand table
     via a UIAlertDialog */

-(void) alertDuplicate;

@end


@implementation I3UnrearrangebleTableToTableViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    
    /* The table data sources and delegates */
    
    NSArray* leftData = @[
                          @"Left 1",
                          @"Left 2",
                          @"Left 3",
                          @"Left 4",
                          @"Left 5",
                          ];
    
    NSArray* rightData = @[
                           kPlaceholderCell,
                           ];
    
    self.leftData = leftData;
    self.rightData = [NSMutableOrderedSet orderedSetWithArray:rightData];
    
    
    [self.leftTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.leftTable
                                                         dstView:self.rightTable];
    
    self.helper.delegate = self;

    
    /* Configure the helper accordingly - if you are unfamiliar with any of this
        refer to other previous example cases */
    
    self.helper.isDstRearrangeable = YES;
    self.helper.isSrcRearrangeable = NO;
    
    self.helper.doesSrcRecieveDst = NO;
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


#pragma mark - Drag n drop exchange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from{
    
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    
    NSString* fromData = [self.leftData objectAtIndex:fromRow];
    
    if(![self.rightData containsObject:fromData]){

        /* Prevent duplicate cells */
        
        [self.rightData insertObject:fromData atIndex:toRow];
        [self.rightTable insertRowsAtIndexPaths:@[to] withRowAnimation:UITableViewRowAnimationFade];

    }
    else{
    
        [self alertDuplicate];
    }
    
}


#pragma mark - Undraggable/Unrearrangeable cell implementations

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container{
    
    if(container == self.rightTable){
        
        /* We only care about cell draggabillity config for the right hand table */
        
        NSInteger row = [index row];
        NSString* dataValue = [self.rightData objectAtIndex:row];
        
        return ![dataValue isEqualToString:kPlaceholderCell];
        
    }

    return YES;
}


-(BOOL) isCellInDstAtIndexPathExchangable:(NSIndexPath*) to withCellAtIndexPath:(NSIndexPath*) from{
    
    NSInteger row = [to row];
    NSString* dataValue = [self.rightData objectAtIndex:row];
    
    return ![dataValue isEqualToString:kPlaceholderCell];
    
}


#pragma mark - Drop outside delete functionallity

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from{

    /* Return NO to trigger the helper's delete animation (shrink) - NOTE:
        we don't do any data handling in here as the helper has no finished
        its animation. We do that in itemFromDstDeletedAtIndexPath */
    
    return NO;
}

-(void) itemFromDstDeletedAtIndexPath:(NSIndexPath*) path{

    /* The deletion animation from the helper is finished so update the data accordingly */
    
    NSInteger fromIndex = [path row];
    [self.rightData removeObjectAtIndex:fromIndex];
    [self.rightTable deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromSrcIndexPath:(NSIndexPath*) from{
    
    /* Uncomment this line to implemented the shrink animation for Src items that
        are dropped outside of the correct bounds... just to show off. */
    
    return YES; // NO;
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
