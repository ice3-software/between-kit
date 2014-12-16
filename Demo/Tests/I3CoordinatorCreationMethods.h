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
 
 Helper function for unit tests. Sets up a gesture coodinator with all of its main 
 mock dependencies.
 
 Implemented to reduce all the boilerplate of repeatedly setting up mock coordinators
 
 */
I3GestureCoordinator *I3GestureCoordinatorSetupMock();


/**
 
 Helper function for unit tests. Sets up a gesture cooridnator as if a drag as already
 started.
 
 */
I3GestureCoordinator *I3GestureCoordinatorSetupDraggingMock();