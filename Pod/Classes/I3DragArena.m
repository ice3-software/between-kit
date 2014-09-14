//
//  I3DragArena.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3DragArena.h"


@implementation I3DragArena


-(id) initWithSuperview:(UIView *)superview containingCollections:(NSArray *)collections{

    self = [super init];
    
    if(self){
        
        _superview = superview;
        _collections = [[NSMutableOrderedSet alloc] initWithCapacity:collections.count];

        [self.collections addObjectsFromArray:collections];
        
    }

    return self;
}

@end
