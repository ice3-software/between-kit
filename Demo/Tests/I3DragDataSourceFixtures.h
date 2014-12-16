//
//  I3DragDataSourceFixtures.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
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


@interface I3DragDataSourceJustCanExchange : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustExchange : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustCanAppend : NSObject <I3DragDataSource>
@end


@interface I3DragDataSourceJustAppend : NSObject <I3DragDataSource>
@end
