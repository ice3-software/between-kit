//
//  I3CollectionFixture.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3Collection.h>

@interface I3CollectionFixture : NSObject <I3Collection>

@end

@implementation I3CollectionFixture

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) dropItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection toPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection{
}

@end