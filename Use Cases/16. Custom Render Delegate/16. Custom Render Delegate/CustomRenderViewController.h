//
//  CustomRenderViewController.h
//  16. Custom Render Delegate
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/I3DragRenderDelegate.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>

@interface CustomRenderViewController : UIViewController<UITableViewDataSource, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *leftTable;

@property (nonatomic, weak) IBOutlet UICollectionView *rightCollection;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
