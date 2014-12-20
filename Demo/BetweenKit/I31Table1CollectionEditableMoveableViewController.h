//
//  I31Table1CollectionEditableMoveableViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>


@interface I31Table1CollectionEditableMoveableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *leftTable;

@property (nonatomic, weak) IBOutlet UITableView *rightTable;

-(IBAction) toggleEditMode:(id) sender;

@end
