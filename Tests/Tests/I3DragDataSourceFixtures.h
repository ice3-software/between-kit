//
//  I3DragDataSourceFixtures.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3DragDataSource.h>


/** @note - All can* delegate methods are implemented to return YES */


@interface I3DragDataSourceJustCanDelete : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustDelete : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustCanRearrange : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustRearrange : NSObject<I3DragDataSource>
@end


@interface I3DragDataSourceJustCanDropOnIndex : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustDropOnIndex : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustCanDropOnPoint : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustDropOnPoint : NSObject <I3DragDataSource>
@end
