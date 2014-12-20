//
//  I3MasterViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3MasterViewController.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3DragArena.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I3MasterViewController ()

@property (nonatomic, strong) I3GestureCoordinator *coordinator;

@property (nonatomic, strong) I3DragArena *arena;

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecongizer;

@end


@implementation I3MasterViewController


-(void) viewDidLoad{

    [super viewDidLoad];
    
    self.data = [NSMutableArray arrayWithArray:@[
                                                 @"Master - 1",
                                                 @"Master - 2",
                                                 @"Master - 3",
                                                 @"Master - 4",
                                                 @"Master - 5",
                                                 ]];
    
    self.detailController = (I3DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;

    /// So here we need to construct our own drag arena and gesture coordinator with dependencies
    /// that span accross multiple controllers. We grab the main application window, create our
    /// own gesture recognizer and use these dependencies to construct our own drag arena and
    /// coordinator.
    
    UIWindow *applicationWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.gestureRecongizer = [[UILongPressGestureRecognizer alloc] init];
    self.arena = [[I3DragArena alloc] initWithSuperview:applicationWindow containingCollections:@[self.tableView, self.detailController.collectionView]];

}


-(void)viewDidAppear:(BOOL) animated{
    
    [super viewDidAppear:animated];
    
    /// Initialise our coordinator - note that this coordinator will only be listening for the
    /// durination that the master controller is visible on the screen. This has the effect that
    /// when the master controller is hidden, no drag / dropping will occur between the controllers.
    /// This, asside from demonstrating an interesting use case, is also required. As we are in a
    /// tab group and we are listening to the application's main window, if this coordinator were
    /// to persist, it would detect long-press gestures whilst we are on other tab controllers, which
    /// has the undesired effect of adding cloned views to the main application window whilst in
    /// completed different interfaces
    
    self.coordinator = [[I3GestureCoordinator alloc] initWithDragArena:self.arena withGestureRecognizer:self.gestureRecongizer];
    
    self.coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    self.coordinator.dragDataSource = self;
    
}


-(void) viewDidDisappear:(BOOL) animated{

    /// Nil out the coordinator to deallocate it and stop our listening whilst the master view is
    /// hidden.
    
    self.coordinator = nil;
}


-(void) didReceiveMemoryWarning{

    [super didReceiveMemoryWarning];
    
}


#pragma mark - Table view data source


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return self.data.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];

    cell.textLabel.text = self.data[indexPath.row];
    
    return cell;
}


#pragma mark - I3DragDataSource Impl.


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    return YES;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}


-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{

    BOOL isFromMaster = (UITableView *)fromCollection == self.tableView;
    
    NSMutableArray *fromData = isFromMaster ? self.data : self.detailController.data;
    NSMutableArray *toData = isFromMaster ? self.detailController.data : self.data;
    
    NSIndexPath *toIndex = [NSIndexPath indexPathForItem:toData.count inSection:0];
    NSString *fromDatum = fromData[from.row];
    
    [fromData removeObject:fromDatum];
    [toData insertObject:fromDatum atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[toIndex]];

}


#pragma mark - Navigation


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id) sender{
    
    /// ...
}


@end
