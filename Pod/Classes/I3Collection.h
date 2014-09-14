//
//  I3Collection.h
//  I3DragNDrop
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class I3DragDataSource


/**
 
 Protocol defining a common interface for 'collection's. Collections represent views that
 contain draggable child items.
 
 This interface exposes methods for accessing properties of the collection and its child
 items. It is used to abstract away the details of the collection, e.g. a custom UICollectionView
 could implement this protocol, as could a UITableView, or even a custom UIView.
 
 @todo How do we enforce the constraint the items's are subviews of the collection view?
 1.* didn't enforce this but I feel we should.
 
 @todo Right now, the implementation is repsonsable for mapping a CGPoint to a given item
 in the collection so that the coordinator and the rendered aren't dependent on
 `UITableView`/`UICollectionView`-specific point->index convertion methods. We need to
 provide some sort of separate helper utility that allows users to do this easily without
 having to implement the same boilerplate for all of their `UITableView`/
 `UICollectionView`s.

 */
@protocol I3Collection <NSObject>


/**
 
 Returns the containing UIView that has is the superview of the 'items'. This can be
 used to access the bounds of the collection for coordination as well as the for
 rendering.
 
 */
@property (nonatomic, strong, readonly) UIView *collection;


/**
 
 The delegate object that provides data about draggabillity of the collection and its
 items. The I3Collection interface abstract way 'what' the collection view is and the
 I3DragDataSource is delegated the responsibillity of providing dynamic draggabillity config.
 
 @note This is primarily used by the I3GestureCoordinator to determine draggable properties
 for the collection view. It isn't really meant to be used directly by the I3Collection 
 implementation.
 
 */
@property (nonatomic, weak) id<I3DragDataSource> dragDataSource;


/**
 
 Returns the view for an item in the collection at a specified index path. This can
 be used to access individual item bounds as well as individual item views for rendering.
 
 @param at The point at which the item is.
 @return UIView * | nil if one does not exist
 
 */
-(UIView *)itemAtPoint:(CGPoint) at;


@end
