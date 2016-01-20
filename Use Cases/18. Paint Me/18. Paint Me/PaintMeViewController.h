//
//  ViewController.h
//  18. Paint Me
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>

@interface PaintMeViewController : UIViewController<UITableViewDataSource, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *notesTable;

@property (nonatomic, weak) IBOutlet UICollectionView *palletCollection;

@end

