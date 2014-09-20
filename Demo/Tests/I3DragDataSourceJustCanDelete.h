//
//  I3DragDataSourceJustCanDelete.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>

@interface I3DragDataSourceJustCanDelete : NSObject <I3DragDataSource>

@end

@implementation I3DragDataSourceJustCanDelete

-(BOOL) canItemBeDraggedAtPoint:(CGPoint) at inCollection:(id<I3Collection>) collection{
    return YES;
}

-(BOOL) canItemAtPoint:(CGPoint) from beDeletedIfDroppedOutsideOfCollection:(id<I3Collection>) collection atPoint:(CGPoint) to{
    return YES;
}

@end
