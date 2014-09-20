//
//  I3DragDataSourceJustCanRearrange.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>

@interface I3DragDataSourceJustCanRearrange : NSObject <I3DragDataSource>

@end

@implementation I3DragDataSourceJustCanRearrange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemFromPoint:(CGPoint)from beRearrangedWithItemAtPoint:(CGPoint)to inCollection:(id<I3Collection>)collection{
    return YES;
}

@end
