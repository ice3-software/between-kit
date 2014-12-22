//
//  CollectionViewController.h
//  9. 2 Droppable Collection Views
//
//  Created by Stephen Fortune on 22/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface CollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *leftCollection;

@property (nonatomic, weak) IBOutlet UICollectionView *rightCollection;

@end
