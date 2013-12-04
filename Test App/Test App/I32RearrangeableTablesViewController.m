//
//  I3FirstViewController.m
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I32RearrangeableTablesViewController.h"

static NSString* DequeueReusableCell = @"DequeueReusableCell";

@interface I32RearrangeableTablesViewController ()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

@property (nonatomic, strong) NSMutableArray* leftData;

@property (nonatomic, strong) NSMutableArray* rightData;

@end


@implementation I32RearrangeableTablesViewController

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
                           @"Right 1",
                           @"Right 2",
                           @"Right 3",
                           @"Right 4",
                           @"Right 5",
                           ];
    
    self.leftData = [NSMutableArray arrayWithArray:leftData];
    self.rightData = [NSMutableArray arrayWithArray:rightData];

    
    [self.leftTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTable registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    
    
    
    /* Configure the helper */

    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view // The UIView we're draggin around in
                                                         srcView:self.leftTable // The Src
                                                         dstView:self.rightTable]; // The Dst
    
    self.helper.delegate = self;
    
    
    
    /** The source table, by default, creates a duplicate view whilst dragging.
         Changing the following property makes the Src table dragging view genuine. 
        
        Comment out the line to make the draggin Src views duplicates*/
    
    self.helper.isDragViewFromSrcDuplicate = NO;
    
    /** Similarly, uncomment this line to make the Dst table dragging view a duplicate */
    
    //self.helper.isDragViewFromDstDuplicate = YES;

    
    
    /* Makes the Dst table rearrangeable. Also see droppedOnDstAtIndexPath:fromDstIndexPath: */

    self.helper.isDstRearrangeable = YES;
    
    
    /* Makes the Src table rearrangeable. Also see droppedOnDstAtIndexPath:fromDstIndexPath: */
    
    self.helper.isSrcRearrangeable = YES;
    
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}



#pragma mark - Drag n Drop rearrange delegate methods

/** This is implemented in accordance with isDstRearrangeable */

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{

    /** The drag helper handles all the view stuff for us, but it delegates
         the data-handling responsibillity to us */
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    [self.rightData exchangeObjectAtIndex:toRow withObjectAtIndex:fromRow];
}

/** This is implemented in accordance with isSrcRearrangeable */

-(void) droppedOnSrcAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*) from{

    /** The drag helper handles all the view stuff for us, but it delegates
         the data-handling responsibillity to us */
    
    NSInteger fromRow = [from row];
    NSInteger toRow = [to row];
    
    [self.leftData exchangeObjectAtIndex:toRow withObjectAtIndex:fromRow];

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
