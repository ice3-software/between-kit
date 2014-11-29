//
//  I3Collection.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I3DragDataSource.h"


/**
 
 Protocol defining a common interface for 'collection's. Collections represent views that
 contain draggable child items.
 
 This interface exposes methods for accessing properties of the collection and its child
 items. It is used to abstract away the details of the collection, e.g. a custom UICollectionView
 could implement this protocol, as could a UITableView, or even a custom UIView.
 
 @todo How do we enforce the constraint the items's are subviews of the collection view?
 1.* didn't enforce this but I feel we should.

 */
@protocol I3Collection <NSObject>


/**
 
 Returns the containing UIView that has is the superview of the 'items'. This can be
 used to access the bounds of the collection for coordination as well as the for
 rendering.
 
 @todo Get rid of this as per #42
 
 */
@property (nonatomic, strong, readonly) UIView *collectionView;


/**
 
 Should be implemented to map a given point to an NSIndexPath. Should return nil if an
 item does not exist at the given index path.
 
 @param     at      CGPoint
 @return    NSIndexPath
 
 */
-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at;


/**
 
 Should be implemented to retrieve the actual item view for a given NSIndexPath. 
 
 @note that whether or not an item actual exists at a given index path depends on the return 
 value of this method. If `indexPathForItemAtPoint:` return an NSIndexPath and this method 
 does not, we should assume that there is no valid index path here. Therefore
 `indexPathForItemAtPoint:` should not be used to check whether a valid item exists.
 
 @note follow on from above, this method may be called with a nil value for index. More often
 than not (particularly in the coordinator) the return value of `indexPathForItemAtPoint:` will
 be passed straight to this method to check whether an item exists. If `indexPathForItemAtPoint:`
 returns nil it will be forward to this method.
 
 @param     index   NSIndexPath
 @return    UIView
 
 */
-(UIView *)itemAtIndexPath:(NSIndexPath *)index;


@end
