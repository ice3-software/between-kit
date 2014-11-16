//
//  I3DragDataSourceFixtures.m
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3DragDataSourceFixtures.h"



@implementation I3DragDataSourceJustCanDelete

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint) from beDeletedIfDroppedOutsideOfCollection:(id<I3Collection>) collection atPoint:(CGPoint) to{
    return YES;
}

@end



@implementation I3DragDataSourceJustDelete

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) deleteItemAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
}

@end



@implementation I3DragDataSourceJustCanRearrange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemFromPoint:(CGPoint)from beRearrangedWithItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    return YES;
}

@end



@implementation I3DragDataSourceJustRearrange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) rearrangeItemAtPoint:(CGPoint) from withItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) collection{
}

@end



@implementation I3DragDataSourceJustCanDrop

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection beDroppedToPoint:(CGPoint) to inCollection:(id<I3Collection>) collection{
    return YES;
}

@end



@implementation I3DragDataSourceJustDrop

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) dropItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection toPoint:(CGPoint) to inCollection:(id<I3Collection>) toCollection{
}

@end

