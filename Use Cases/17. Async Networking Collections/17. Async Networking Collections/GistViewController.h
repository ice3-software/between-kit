//
//  GistViewController.h
//  17. Async Networking Collections
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

@interface GistViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *availableGistCollection;

@property (nonatomic, weak) IBOutlet UICollectionView *userGistCollection;

@end
