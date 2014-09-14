//
//  I3CollectionToRearrangeableTableViewController.h
//  Test App
//
//  Created by Stephen Fortune on 06/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"


/** And now for something just a bit cooler.. Mixing collection views and
     table views. In this example, you can drag item from the collection view
     to the table view. The collection view is unrearrangeable but the table
     view is.
    
    Delegate methods are also implemented to be called when the dst is dropped
     outside of the dst view.
 
    The resulting functionallity is a 'paintable' table view, where you can
     color its various list items with colours from the collection view pallet.
     You can rearrange and play with the paintable table view as you wish. 
     You can also 'clean' the cells by dragging them outside of the dst table -
     this will set them back to white.
 
    .. cool ey? Feel free to Fork and hack around. */

@interface I3CollectionToRearrangeableTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, I3DragBetweenDelegate>

/** This is the Destination table */

@property (nonatomic, strong) IBOutlet UITableView* rightTable;


/** This is the Source collection */

@property (nonatomic, strong) IBOutlet UICollectionView* leftCollection;


@end
