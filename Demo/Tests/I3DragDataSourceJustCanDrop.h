//
//  I3DragDataSourceJustCanDrop.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>

@interface I3DragDataSourceJustCanDrop : NSObject <I3DragDataSource>

@end

@implementation I3DragDataSourceJustCanDrop

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint) from fromCollection:(id<I3Collection>) fromCollection beDroppedToPoint:(CGPoint) to inCollection:(id<I3Collection>) collection{
    return YES;
}

@end