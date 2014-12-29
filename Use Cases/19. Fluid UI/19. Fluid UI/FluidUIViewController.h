//
//  FluidUIViewController.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3DragDataSource.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/UITableView+I3Collection.h>

@interface FluidUIViewController : UIViewController <I3DragDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *formTable;

@property (nonatomic, weak) IBOutlet UICollectionView *tlToolbarCollection;

@property (nonatomic, weak) IBOutlet UICollectionView *bToolbarCollection;

@property (nonatomic, weak) IBOutlet UIView *scrapArea;

@end
