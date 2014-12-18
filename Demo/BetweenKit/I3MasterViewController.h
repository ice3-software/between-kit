//
//  I3MasterViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import "I3DetailViewController.h"

@interface I3MasterViewController : UITableViewController <I3DragDataSource>

@property (nonatomic, strong) I3DetailViewController *detailController;

@property (nonatomic, strong) NSMutableArray *data;

@end
