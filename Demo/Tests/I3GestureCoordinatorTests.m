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

    __block id dragArena;
    __block id superview;
    __block id panGestureRecognizer;

    beforeEach(^{
    
        panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
        dragArena = OCMClassMock([I3DragArena class]);
        superview = OCMClassMock([UIView class]);
    
        OCMStub([dragArena superview]).andReturn(superview);
    
    });

    afterEach(^{
    
        dragArena = nil;
        panGestureRecognizer = nil;
        superview = nil;
    
    });


    describe(@"constructor", ^{

        
        it(@"should inject dependencies", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:nil];
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
        it(@"should setup the gesture recognizer's target and superview correctly", ^{
        
            I3GestureCoordinator* coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            OCMVerify([panGestureRecognizer addTarget:coordinator action:[OCMArg anySelector]]);
            OCMVerify([superview addGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attach the gesture recognizer to the superview if its already attached", ^{

            [[superview reject] addGestureRecognizer:[OCMArg any]];
            OCMStub([superview gestureRecognizers]).andReturn(@[panGestureRecognizer]);
            I3GestureCoordinator* coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            OCMVerifyAll(superview);
       

        });

    });



    describe(@"destructor", ^{

        
        /** @note Here we use pragma to ignore warnings about weak variables being assigned and
            then released immediately after as this is exactly what we are trying to achieve. In
            order for 'dealloc' to be triggered under ARC we must invoke the ctor by creating a 
            weak reference that will unasigned immediately. */
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
        
        
        it(@"should unbind gesture recognizer from coordinator and superview", ^{
 
            OCMStub([superview gestureRecognizers]).andReturn(@[panGestureRecognizer]);

            __weak I3GestureCoordinator* coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];

            OCMVerify([panGestureRecognizer removeTarget:[OCMArg any] action:NULL]);
            OCMVerify([superview removeGestureRecognizer:panGestureRecognizer]);

        });
        
        it(@"should not attempt to remove gesture recognizer from superview if it is no long present", ^{
            
            [[superview reject] removeGestureRecognizer:panGestureRecognizer];
            OCMStub([superview gestureRecognizers]).andReturn(@[]);
            
            __weak I3GestureCoordinator* coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];

            OCMVerifyAll(superview);

        });

#pragma clang diagnostic pop
        
    });



SpecEnd