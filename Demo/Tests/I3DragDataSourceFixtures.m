//
//  I3DragDataSourceFixtures.m
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3DragDataSourceFixtures.h"



@implementation I3DragDataSourceJustCanDelete

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(id<I3Collection>)collection atPoint:(CGPoint)to{
    return YES;
}

@end



@implementation I3DragDataSourceJustDelete

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) deleteItemAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{}

@end



@implementation I3DragDataSourceJustCanRearrange

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)collection{
    return YES;
}

@end



@implementation I3DragDataSourceJustRearrange

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)collection{}

@end



@implementation I3DragDataSourceJustCanExchange

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection beExchangedWithItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)toCollection{
    return YES;
}

@end



@implementation I3DragDataSourceJustExchange

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) exchangeItemAt:(NSIndexPath *)from inCollection:(id<I3Collection>)fromCollection withItemAt:(NSIndexPath *)to inCollection:(id<I3Collection>)toCollection{}

@end



@implementation I3DragDataSourceJustCanAppend

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection beAppendedToCollection:(id<I3Collection>)toCollection atPoint:(CGPoint)to{
    return YES;
}

@end



@implementation I3DragDataSourceJustAppend

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) appendItemAt:(NSIndexPath *)from fromCollection:(id<I3Collection>)fromCollection toPoint:(CGPoint)to onCollection:(id<I3Collection>)onCollection{}

@end

