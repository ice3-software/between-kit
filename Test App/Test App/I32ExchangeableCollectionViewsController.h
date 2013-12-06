//
//  I32ExchangeableCollectionViewsController.h
//  Test App
//
//  Created by Stephen Fortune on 05/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"


/** This test case demonstrates the first use of collection views with the helper.
     They are fully exchangeable and reorderable. */

@interface I32ExchangeableCollectionViewsController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, I3DragBetweenDelegate>

/** This is the Source collection */

@property (nonatomic, strong) IBOutlet UICollectionView* leftCollection;

/** This is the Destination collection */

@property (nonatomic, strong) IBOutlet UICollectionView* rightCollection;


@end
