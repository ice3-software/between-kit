//
//  I3CoordinatorFixtures.m
//  BetweenKit
//
//  Created by Stephen Fortune on 15/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CoordinatorCreationMethods.h"
#import "I3CollectionFixture.h"


I3GestureCoordinator *I3GestureCoordinatorSetupMockWithDataSource(id<I3DragDataSource> dataSource){
    
    UIView *superview = OCMPartialMock([[UIView alloc] init]);
    UIPanGestureRecognizer *panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
    
    I3DragArena *dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
    I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
    
    coordinator.dragDataSource = dataSource;
    coordinator.renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));
    
    return coordinator;
}
