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


@implementation I3DragDataSourceJustCanDropOnIndex

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedTo:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}

@end


@implementation I3DragDataSourceJustDropOnIndex

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toItemAt:(NSIndexPath *)to onCollection:(UIView<I3Collection> *)toCollection{}

@end


@implementation I3DragDataSourceJustCanDropOnPoint

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beDroppedAtPoint:(CGPoint)at onCollection:(UIView<I3Collection> *)toCollection{
    return YES;
}

@end


@implementation I3DragDataSourceJustDropOnPoint

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>)collection{
    return YES;
}

-(void) dropItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)toCollection{}

@end



