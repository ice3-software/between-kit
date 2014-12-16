//
//  I3CoordinatorFixtures.h
//  BetweenKit
//
//  Created by Stephen Fortune on 15/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3GestureCoordinator.h>


/**
 
 Setup basic gesture coordinator, its dependencies mock dependencies with a given 
 dataSource.
 
 @name CreationMethod
 
 */
I3GestureCoordinator *I3GestureCoordinatorSetupMock(id<I3DragDataSource> dataSource);


/**
 
 Setup a gesture coordinator and its dependencies as if a drag has already started. The
 environment will already be populated with a collection that contains 1 valid item for
 the drag origin.
 
 @name CreationMethod
 @todo Implement if necessary
 
 */
I3GestureCoordinator *I3GestureCoordinatorSetupDraggingMock(id<I3DragDataSource> dataSource);