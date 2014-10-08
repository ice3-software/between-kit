//
//  I3ViewController.h
//  BetweenKit
//
//  Created by stephen fortune on 09/14/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3TableView.h>
#import <BetweenKit/I3DragDataSource.h>


@interface I32RearrangeableTablesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet I3TableView *leftTableView;

@property (nonatomic, weak) IBOutlet I3TableView *rightTableView;

@end
