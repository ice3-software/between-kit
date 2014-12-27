//
//  MasterViewController.h
//  20. Split View Controller
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <I3DragDataSource>

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

