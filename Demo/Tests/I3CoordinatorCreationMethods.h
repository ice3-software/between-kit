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
I3GestureCoordinator *I3GestureCoordinatorSetupMockWithDataSource(id<I3DragDataSource> dataSource);
