//
//  I3DragDataSourceJustRearrange.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>

@interface I3DragDataSourceJustRearrange : NSObject<I3DragDataSource>

@end

@implementation I3DragDataSourceJustRearrange

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(void) rearrangeItemAtPoint:(CGPoint) from withItemAtPoint:(CGPoint) to inCollection:(id<I3Collection>) collection{
}

@end
