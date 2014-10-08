//
//  I3ViewController.m
//  BetweenKit
//
//  Created by stephen fortune on 09/14/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I32RearrangeableTablesViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I32RearrangeableTablesViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) I3DragArena *arena;

@property (nonatomic, strong) I3BasicRenderDelegate *renderDelegate;

@property (nonatomic, strong) NSMutableArray *leftData;

@property (nonatomic, strong) NSMutableArray *rightData;

@end


@implementation I32RearrangeableTablesViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];

    
    /** Setup the table views with their data */
    
    self.leftData = [NSMutableArray arrayWithArray:@[
                                                     @"Left 1",
                                                     @"Left 2",
                                                     @"Left 3",
                                                     @"Left 4",
                                                     @"Left 5",
                                                     ]];
    
    self.rightData = [NSMutableArray arrayWithArray:@[
                                                      @"Right 1",
                                                      @"Right 2",
                                                      @"Right 3",
                                                      @"Right 4",
                                                      @"Right 5",
                                                      ]];

    [self.leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DequeueReusableCell];
    

    
    /** Setup the collections with their data source (this class) */
    
    self.leftTableView.dragDataSource = self;
    self.rightTableView.dragDataSource = self;
    
    
    /** Setup the coordinator with its dependencies */
    
    self.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    self.arena = [[I3DragArena alloc] initWithSuperview:self.view containingCollections:@[self.leftTableView, self.rightTableView]];
    
    self.dragCoordinator = [[I3GestureCoordinator alloc] initWithDragArena:self.arena withGestureRecognizer:nil];
    self.dragCoordinator.renderDelegate = self.renderDelegate;
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    
    if(tableView == self.leftTableView){
        return [self.leftData count];
    }
    else{
        return [self.rightData count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell
                                                            forIndexPath:indexPath];
    
    if(tableView == self.leftTableView){
        NSInteger row = [indexPath row];
        cell.textLabel.text = [self.leftData objectAtIndex:row];
    }
    else{
        NSInteger row = [indexPath row];
        cell.textLabel.text = [self.rightData objectAtIndex:row];
    }
    
    return cell;
}



#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}


@end
