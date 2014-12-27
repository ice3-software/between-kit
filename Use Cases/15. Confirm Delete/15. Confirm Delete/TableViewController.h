//
//  TableViewController.h
//  3. Deletable Table View
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface TableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
