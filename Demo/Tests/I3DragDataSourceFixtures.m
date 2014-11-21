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



@implementation I3DragDataSourceJustCanExchange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint)from fromCollection:(id<I3Collection>)fromCollection beExchangedWithItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)toCollection{
    return YES;
}

@end



@implementation I3DragDataSourceJustExchange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) exchangeItemAtPoint:(CGPoint)from inCollection:(id<I3Collection>)fromCollection withItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)toCollection{
}

@end



@implementation I3DragDataSourceJustCanAppend

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint)from fromCollection:(id<I3Collection>)fromCollection beAppendedToCollection:(id<I3Collection>)toCollection atPoint:(CGPoint)to{
    return YES;
}

@end



@implementation I3DragDataSourceJustAppend

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) appendItemAtPoint:(CGPoint)from fromCollection:(id<I3Collection>)fromCollection toPoint:(CGPoint)to onCollection:(id<I3Collection>)onCollection{
}

@end

