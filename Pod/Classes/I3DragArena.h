//
//  I3DragArena.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 
 Represents the domain for an 'area' (e.g. a `UIViewController`) within which 'items'
 (e.g. `UITableViewCell`s or `UICollectionViewCells`) can be dragged around freely
 and exchanged between different 'collections' (i.e. views implementing `I3Collection`).
 
 @todo How do we enforce the constraint draggable collections must be subviews of the given
 superview? 1.* didn't enforce this but I feel we should.
 
 @see I3Collection
 
 */
@interface I3DragArena : NSObject


/**
 
 The 'arena', i.e. the main superview within which drag/dropping will occure. This will
 be used in listening for gestures and calculating relative bound rects.
 
 */
@property (nonatomic, strong, readonly) UIView *superview;


/**
 
 A mutable ordered set of `I3Collection` instances that drag/dropping will occur
 between.
 
 The order of the draggables in this set will determine their 'priority', i.e. if n collections 
 are overlapping, the one highest in the set will recieve drag / drop events and the lowers 
 incepting collections will be ignored.
 
 Users can even mutate this set dynamically if, for example, they wanted to reorder the z-index
 of a collection.
 
 */
@property (nonatomic, strong) NSMutableOrderedSet *collections;


/**
 
 Ctor. Init the arena with a superview and subsequent collections.
 
 @param superview   The superview containing all the collections.
 @param collections An array of all the `I3Collection` instances to initialise the arena with,
                    may be nil.
 @return id
 
 */
-(id) initWithSuperview:(UIView *)superview containingCollections:(NSArray *)collections;

@end
