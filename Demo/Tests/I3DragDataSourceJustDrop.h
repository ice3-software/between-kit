//
//  I3DragDataSourceJustDrop.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>

@interface I3DragDataSourceJustDrop : NSObject <I3DragDataSource>

@end

@implementation I3DragDataSourceJustDrop

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) dropItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection toPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection{
}

@end