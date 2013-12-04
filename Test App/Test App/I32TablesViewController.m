//
//  I3FirstViewController.m
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I32TablesViewController.h"
#import "I3DragBetweenHelper.h"


@interface I32TablesViewController ()

/** The one and only drag helper! */

@property (nonatomic, strong) I3DragBetweenHelper* helper;

@property (nonatomic, strong) NSArray* leftData;

@property (nonatomic, strong) NSArray* rightData;

@end


@implementation I32TablesViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    /* The table data sources and delegates */
    
    self.leftData = @[
                      @"Left 1",
                      @"Left 2",
                      @"Left 3",
                      @"Left 4",
                      @"Left 5",
                      ];
    
    self.rightData = @[
                       @"Right 1",
                       @"Right 2",
                       @"Right 3",
                       @"Right 4",
                       @"Right 5",
                       ];
    
    self.leftTable.dataSource = self;
    self.leftTable.delegate = self;
    
    self.rightTable.dataSource = self;
    self.rightTable.delegate = self;
    
    
    /* Configure the helper */

    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view // The UIView we're draggin around in
                                                         srcView:self.leftTable // The Src
                                                         dstView:self.rightTable]; // The Dst
}

-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}



#pragma mark Table view delegate and datasource implementations


-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section{
    
    if(tableView == self.leftTable){
    
        return [self.leftData count];
    }
    else{
    
        return [self.rightData count];
    }
}





@end
