//
//  CollectionViewController.h
//  8. Deletable Collection
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface CollectionViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
