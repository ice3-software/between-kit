//
//  MultipleCollectionsViewController.h
//  
//
//  Created by Stephen Fortune on 27/12/2014.
//
//

#import <UIKit/UIKit.h>
#import <BetweenKit/UITableView+I3Collection.h>
#import <BetweenKit/UICollectionView+I3Collection.h>
#import <BetweenKit/I3DragDataSource.h>

/// @note
/// tl = top left
/// tr = top right
/// b = bottom

@interface MultipleCollectionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, I3DragDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tlTable;

@property (nonatomic, weak) IBOutlet UICollectionView *trCollection;

@property (nonatomic, weak) IBOutlet UICollectionView *bCollection;

@property (nonatomic, weak) IBOutlet UIView *deleteArea;

@end
