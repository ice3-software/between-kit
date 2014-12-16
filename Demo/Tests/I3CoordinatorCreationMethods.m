//
//  I3CoordinatorFixtures.m
//  BetweenKit
//
//  Created by Stephen Fortune on 15/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CoordinatorCreationMethods.h"
#import "I3CollectionFixture.h"


I3GestureCoordinator *I3GestureCoordinatorSetupMock(id<I3DragDataSource> dataSource){
    
    UIView *superview = OCMPartialMock([[UIView alloc] init]);
    UIPanGestureRecognizer *panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
    
    I3DragArena *dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
    I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
    
    coordinator.dragDataSource = dataSource;
    coordinator.renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));
    
    return coordinator;
}

I3GestureCoordinator *I3GestureCoordinatorSetupDraggingMock(id<I3DragDataSource> dataSource){

    CGPoint dragOrigin = CGPointMake(10, 10);

    I3GestureCoordinator *coordinator = I3GestureCoordinatorSetupMock(dataSource);
    I3CollectionFixture *draggingCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
    
    [draggingCollection mockItemAtPoint:dragOrigin];
    
    [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
    [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
    
    return coordinator;
    
    return nil;

}