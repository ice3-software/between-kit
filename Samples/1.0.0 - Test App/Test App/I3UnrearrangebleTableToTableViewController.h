//
//  I3UnrearrangebleTableToTableViewController.h
//  Test App
//
//  Created by Stephen Fortune on 05/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"


/** This test case demonstrates a source->destination table relationship
     where the source contains fixed content (ie non exchangeable, non rearrangeable)
     and the destination is only in place to recieve the source table items.
 
    Here the helper's 'delete' functionallity is also demonstrated - you can drag
     the cells from the destination anywhere outside of the tables to delete it from
     the dst. */

@interface I3UnrearrangebleTableToTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragBetweenDelegate>

/** This is the Source table */

@property (nonatomic, strong) IBOutlet UITableView* leftTable;

/** This is the Destination table */

@property (nonatomic, strong) IBOutlet UITableView* rightTable;

@end
