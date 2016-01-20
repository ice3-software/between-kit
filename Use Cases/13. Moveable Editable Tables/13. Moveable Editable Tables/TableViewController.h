//
//  TableViewController.h
//  13. Moveable Editable Tables
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface TableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *leftTable;

@property (nonatomic, weak) IBOutlet UITableView *rightTable;

-(IBAction) toggleEditMode:(id) sender;

@end
