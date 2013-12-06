//
//  I3UnrarranreableToRearrangeableCollectionsViewController.h
//  Test App
//
//  Created by Stephen Fortune on 06/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"


/** This example case demonstrates a source->demonstration relationship between
     2 collection views, where to the source contains fixed static content and 
     the destination is treated as a place to recieve the src.
 
    It shows off the delete functionallity of the helper as well - if you drag
     a cell from the destination outside of the dst view bounds it will be deleted */

@interface I3UnrarranreableToRearrangeableCollectionsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, I3DragBetweenDelegate>

/** This is the Source collection */

@property (nonatomic, strong) IBOutlet UICollectionView* leftCollection;

/** This is the Destination collection */

@property (nonatomic, strong) IBOutlet UICollectionView* rightCollection;

@end
