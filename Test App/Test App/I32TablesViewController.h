//
//  I3FirstViewController.h
//  Test App
//
//  Created by Stephen Fortune on 04/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/* The different test draggable/exchangable cases. Comment/Uncomment
    these to see the various available configurations */

#define TEST_LEFT_IS_EXCHANGEABLE
#define TEST_RIGHT_IS_EXCHANGEABLE
#define TEST_LEFT_TO_RIGHT
#define TEST_RIGHT_TO_LEFT

/** This test demonstrates dragging and dropping between 2 UITableViews. 
     The Tables are both configured to be rearrangeable by default */

@interface I32TablesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

/** This is the Source table */

@property (nonatomic, strong) IBOutlet UITableView* leftTable;

/** This is the Destination table */

@property (nonatomic, strong) IBOutlet UITableView* rightTable;

@end
