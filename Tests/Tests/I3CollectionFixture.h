//
//  I3CollectionFixture.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3Collection.h>
#import <BetweenKit/I3DragArena.h>

/**
 
 Helper fixture that mocks a collection.
 
 @note This no longer actually uses OCMock at all - originally this abstracted away off of
 the OCMock boilerplate when setting up a collection, but it seems to have evolved to be in-
 dependent of OCMock entirely. This occured most noteably when we refactored the I3Collection 
 protocol away from using the `collectionView` property and towards being passed as an actual
 view. The easiest way to get the tests to pass again was to implement out own stub of
 `pointInside:withEvent`
 
 */
@interface I3CollectionFixture : UIView <I3Collection>{
    
    NSMutableDictionary *_pointIndexPathMap;
    NSMutableDictionary *_indexPathViewMap;
    NSMutableArray *_pointsInside;
    
}


/**
 
 Inits the collection and appends it onto the given arena. This saves the boilerplate of having to
 append every collection fixture onto the arena.
 
 */
-(id) initInArena:(I3DragArena *)arena;


/**
 
 Stubs `collectionView` to return `isInside` for `pointIsInside`.
 
 */
-(void) mockPoint:(CGPoint) point isInside:(BOOL) isInside;


/**
 
 Sets up a mock item at a given point in the collection. Behind the scenes, this creates an associated
 NSIndexPath and partial mock UIView that will be used by the protocol impl.
 
 @note This implicitly calls `mockPoint:isInside:` as it is assumed that any item of a collection is inside
 its bounds.
 
 @return The auto-generated NSIndexPath
 
 */
-(NSIndexPath *)mockItemAtPoint:(CGPoint) point;


/**
 
 Same as `mockItemAtPoint:` but uses the given `index` as the index path.
 
 @see `mockItemAtPoint:`
 
 */
-(NSIndexPath *)mockItemAtPoint:(CGPoint) point withIndexPath:(NSIndexPath *)index;


/**
 
 Same as `mockItemAtPoint:` just does not create a mock for an associated view. Can be used in scenarios
 where you want to simulate the collection returning a valid index path but not a valid item view.
 
 @see `mockItemAtPoint:`
 
 @return The auto-generated NSIndexPath

 */
-(NSIndexPath *)mockIndexPathAtPoint:(CGPoint) point;

@end
