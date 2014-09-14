//
//  I32RearrangeableExchangeableTablesViewController.h
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"


/** This is a bit more of a complex exmaple: it consists of 2 exchangeable,     
     rearrangeable table views. These table views also have cells specifically
     configured to be undraggable, unrearrangeable, and both. */

@interface I32RearrangeableExchangeableTablesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, I3DragBetweenDelegate>

/** This is the Source table */

@property (nonatomic, strong) IBOutlet UITableView* leftTable;

/** This is the Destination table */

@property (nonatomic, strong) IBOutlet UITableView* rightTable;

@end
