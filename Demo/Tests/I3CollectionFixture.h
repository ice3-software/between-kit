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

-(id) initInArea:(I3DragArena *)arena;

-(id) initWithMockPoint:(CGPoint) point inArena:(I3DragArena *)arena;

-(void) mockPoint:(CGPoint) point isInside:(BOOL) isInside;

-(NSIndexPath *) mockItemAtPoint:(CGPoint) point;

@end
