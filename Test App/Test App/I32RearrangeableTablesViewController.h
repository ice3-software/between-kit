//
//  I3FirstViewController.h
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"

/** This test demonstrates 2 table views, both rearrangeable but which 
     you cannot drag and drop between */

@interface I32RearrangeableTablesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragBetweenDelegate>

/** This is the Source table */

@property (nonatomic, strong) IBOutlet UITableView* leftTable;

/** This is the Destination table */

@property (nonatomic, strong) IBOutlet UITableView* rightTable;

@end
