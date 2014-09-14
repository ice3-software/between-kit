//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3DragArena.h>

SpecBegin(I3GestureCoordinator)

    describe(@"constructor", ^{

        it(@"should inject dependencies", ^{
        
            id dragArena = OCMClassMock([I3DragArena class]);
            id panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            id dragArena = OCMClassMock([I3DragArena class]);
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:nil];
            
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
    });

SpecEnd