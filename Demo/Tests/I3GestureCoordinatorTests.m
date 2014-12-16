//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>


SpecBegin(I3GestureCoordinator)

    describe(@"ctor", ^{

        it(@"should inject dependencies", ^{
        
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            I3DragArena *dragArena = [[I3DragArena alloc] init];
            
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:[[I3DragArena alloc] init] withGestureRecognizer:nil];
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
        it(@"should setup the gesture recognizer's target and superview correctly", ^{
        
            UIPanGestureRecognizer *panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
            UIView *superview = OCMClassMock([UIView class]);
            I3DragArena *dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];
            
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            OCMVerify([panGestureRecognizer addTarget:coordinator action:[OCMArg anySelector]]);
            OCMVerify([superview addGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attach the gesture recognizer to the superview if its already attached", ^{

            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            UIView *superview = [[UIView alloc] init];
            I3DragArena *dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];

            [superview addGestureRecognizer:panGestureRecognizer];
            
            I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect([superview gestureRecognizers]).to.haveCountOf(1);

        });

    });

    describe(@"dtor", ^{

        __block id panGestureRecognizer;
        __block id superview;
        __block I3DragArena *dragArena;

        beforeEach(^{
            panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
            superview = OCMPartialMock([[UIView alloc] init]);
            dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];
        });
        
        afterEach(^{
            panGestureRecognizer = nil;
            superview = nil;
            dragArena = nil;
        });
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
        
        
        it(@"should unbind gesture recognizer from coordinator and superview", ^{
            
            [superview addGestureRecognizer:panGestureRecognizer];
            
            __weak I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            OCMVerify([panGestureRecognizer removeTarget:[OCMArg any] action:NULL]);
            OCMVerify([superview removeGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attempt to remove gesture recognizer from superview if it is no longer present", ^{
            
            NSArray *emptyArray = @[];
            
            [[superview reject] removeGestureRecognizer:panGestureRecognizer];
            OCMStub([superview gestureRecognizers]).andReturn(emptyArray);
            
            __weak I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
        });
        
#pragma clang diagnostic pop

    });

SpecEnd
