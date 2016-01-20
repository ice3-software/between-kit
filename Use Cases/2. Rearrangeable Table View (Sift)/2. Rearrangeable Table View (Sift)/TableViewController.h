//
//  TableViewController.h
//  2. Rearrangeable Table View (Sift)
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface TableViewController : UITableViewController<I3DragDataSource>

@end
