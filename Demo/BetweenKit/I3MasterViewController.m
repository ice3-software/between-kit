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

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecongizer;

@end


@implementation I3MasterViewController


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.data = [NSMutableArray arrayWithArray:@[
                                                 @"Master - 1",
                                                 @"Master - 2",
                                                 @"Master - 3",
                                                 @"Master - 4",
                                                 @"Master - 5",
                                                 ]];
    
    /// Customize our split screen controller - this would ordinarily probably be done in the
    /// app delegate, but because all the use cases for this app run in a single app, we've opted
    /// to configure it here.
    
    self.detailController = [self.splitViewController.viewControllers lastObject];

    /// So here we need to construct our own drag arena and gesture coordinator with dependencies
    /// that span accross multiple controllers. We grab the main application window, create our
    /// own gesture recognizer and use these dependencies to construct our own drag arena and
    /// coordinator.
    
    UIWindow *applicationWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.gestureRecongizer = [[UILongPressGestureRecognizer alloc] init];

    
    I3DragArena *arena = [[I3DragArena alloc] initWithSuperview:applicationWindow containingCollections:@[self.tableView, self.detailController.collectionView]];
    I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:arena withGestureRecognizer:self.gestureRecongizer];
    
    coordinator.renderDelegate = [[I3BasicRenderDelegate alloc] init];
    coordinator.dragDataSource = self;
    
    self.dragCoordinator = coordinator;

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


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beAppendedToCollection:(UIView<I3Collection> *)toCollection atPoint:(CGPoint)to{
    return YES;
}


-(void) appendItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)onCollection{

    BOOL isFromMaster = (UITableView *)fromCollection == self.tableView;
    
    NSMutableArray *fromData;
    NSMutableArray *toData;
    NSIndexPath *toIndex;
    
    if(isFromMaster){
        fromData = self.data;
        toIndex = [NSIndexPath indexPathForItem:self.detailController.secondSectionData.count inSection:1];
        toData = self.detailController.secondSectionData;
    }
    else{
        fromData = !from.section ? self.detailController.firstSectionData : self.detailController.secondSectionData;
        toIndex = [NSIndexPath indexPathForItem:self.data.count inSection:0];
        toData = self.data;
    }
    
    NSString *fromDatum = fromData[from.row];

    [fromData removeObject:fromDatum];
    [toData insertObject:fromDatum atIndex:toIndex.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [onCollection insertItemsAtIndexPaths:@[toIndex]];

}


#pragma mark - Navigation


-(BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    
    NSLog(@"should I hide this? %@", !!self.dragCoordinator.currentDraggingCollection ? @"YES" : @"NO");
    return !!self.dragCoordinator.currentDraggingCollection;
}


#pragma mark - Navigation


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id) sender{
    
    /// ...
}


@end
