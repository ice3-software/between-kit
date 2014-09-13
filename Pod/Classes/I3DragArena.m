//
//  I3DragBetweenHelper.m
//  ResourceMoney Client
//
//  Created by Stephen Fortune on 31/08/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import "I3DragArena.h"


@implementation I3DragArena


-(id) initWithSuperview:(UIView *)superview containingCollections:(NSArray *)collections{

    self = [super init];
    
    if(self){
        
        self.superview = superview;
        
        self.collections = [[NSMutableOrderedSet alloc] initWithCapacity:collection.length];
        [self.collections addObjectsFromArray:collections];
        
    }

    return self;
}

@end
