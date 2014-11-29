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
 
 Should be implemented to retrieve the actual item view for a given NSIndexPath. Note that 
 if this returns nil where the index is given by `indexPathForItemAtPoint:` it will be assumed
 that there is not a valid item here.
 
 @param     index   NSIndexPath
 @return    UIView
 
 */
-(UIView *)itemAtIndexPath:(NSIndexPath *)index;


@end
