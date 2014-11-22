//
//  I32DeleteableTablesViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 22/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>


@interface I32DeleteableTablesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *leftTableView;

@property (nonatomic, weak) IBOutlet UITableView *rightTableView;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
