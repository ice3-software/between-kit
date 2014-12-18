//
//  I33CollectionsComplexConfigurationViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

/// @note
/// tl = top left
/// tr = top right
/// b = bottom

@interface I33CollectionsComplexConfigurationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tlTable;

@property (nonatomic, weak) IBOutlet UICollectionView *trCollection;

@property (nonatomic, weak) IBOutlet UICollectionView *bCollection;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
