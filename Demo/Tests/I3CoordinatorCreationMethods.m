//
//  I3CoordinatorFixtures.m
//  BetweenKit
//
//  Created by Stephen Fortune on 15/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CoordinatorCreationMethods.h"
#import "I3CollectionFixture.h"


I3GestureCoordinator *I3GestureCoordinatorSetupMock(){
    
    UIView *superview = OCMPartialMock([[UIView alloc] init]);
    UIPanGestureRecognizer *panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
    I3DragArena *dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);

    return [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
    
}

I3GestureCoordinator *I3GestureCoordinatorSetupDraggingMock(){

    I3GestureCoordinator *coordinator = I3GestureCoordinatorSetupMock();
    I3CollectionFixture *draggingCollection = [[I3CollectionFixture alloc] initInArea:coordinator.arena];
    
    CGPoint dragOrigin = CGPointMake(10, 10);
    
    [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
    [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
    
    return coordinator;

}