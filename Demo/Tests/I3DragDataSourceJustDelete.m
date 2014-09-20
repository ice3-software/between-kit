//
//  I3DragDataSourceJustDelete.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3DragDataSourceJustDelete.h"

@implementation I3DragDataSourceJustDelete

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) deleteItemAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
}

@end
