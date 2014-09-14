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

        __block id dragArena;
        __block id panGestureRecognizer;
        
        beforeEach(^{
            
            dragArena = OCMClassMock([I3DragArena class]);
            panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
        
        });
        
        afterEach(^{
            
            dragArena = nil;
            panGestureRecognizer = nil;
        
        });
        
        it(@"should inject dependencies", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:nil];
            
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
        it(@"should add self as a target to with recognizer with the appropriate selector", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            OCMVerify([panGestureRecognizer addTarget:coordinator action:[OCMArg anySelector]]);
            
        });
        
    });

SpecEnd