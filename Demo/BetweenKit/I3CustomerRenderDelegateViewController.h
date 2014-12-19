//
//  I3CustomerRenderDelegateViewController.h
//  BetweenKit
//
//  Created by Stephen Fortune on 19/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/I3DragRenderDelegate.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>

@interface I3CustomerRenderDelegateViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *leftTable;

@property (nonatomic, weak) IBOutlet UICollectionView *rightCollection;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
