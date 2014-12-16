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
 
 Helper fixture that mocks a collection. Creates mocks behind the scenes for all of the collection's
 dependencies that may need to be spied upon, include item views, index paths, and the collection view.
 
 */
@interface I3CollectionFixture : NSObject <I3Collection>{
    
    UIView *_collectionView;
    NSMutableDictionary *_pointIndexPathMap;
    NSMutableDictionary *_indexPathViewMap;
    
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
 
 @return The auto-generated NSIndexPath for assertions
 
 */
-(NSIndexPath *) mockItemAtPoint:(CGPoint) point;

@end
