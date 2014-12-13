//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3CollectionFixture.h"


SpecBegin(I3GestureCoordinator)


    __block I3DragArena *dragArena;
    __block id superview;
    __block id panGestureRecognizer;


    beforeEach(^{
        superview = OCMPartialMock([[UIView alloc] init]);
        panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
        dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
    });

    afterEach(^{
        dragArena = nil;
        superview = nil;
        panGestureRecognizer = nil;
    });


    describe(@"ctor", ^{
        
        it(@"should inject dependencies", ^{
        
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:nil];
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
        it(@"should setup the gesture recognizer's target and superview correctly", ^{
        
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            OCMVerify([panGestureRecognizer addTarget:coordinator action:[OCMArg anySelector]]);
            OCMVerify([superview addGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attach the gesture recognizer to the superview if its already attached", ^{

            [superview addGestureRecognizer:panGestureRecognizer];
            
            I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect([superview gestureRecognizers]).to.haveCountOf(1);

        });

    });

    describe(@"dtor", ^{

        
        /** @note Here we use pragma to ignore warnings about weak variables being assigned and
            then released immediately after as this is exactly what we are trying to achieve. In
            order for 'dealloc' to be triggered under ARC we must invoke the ctor by creating a
            weak reference that will unasigned immediately. */
        
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


    describe(@"dynamic properties", ^{
        
        __block I3GestureCoordinator *coordinator;
        __block I3CollectionFixture *draggingCollection;
        __block NSIndexPath *index;
        
        
        beforeEach(^{
            
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            draggingCollection = [[I3CollectionFixture alloc] initInArea:dragArena];

            CGPoint dragOrigin = CGPointMake(10, 10);
            index = [draggingCollection mockItemAtPoint:dragOrigin];
            
            [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
            [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
            
        });
        
        afterEach(^{
            
            draggingCollection = nil;
            coordinator = nil;
        
        });
        
        it(@"should return index path for dragging point in dragging collection", ^{
            
            expect(coordinator.currentDraggingIndexPath).to.equal(index);

        });
        
        it(@"should return item at dragging point in dragging collection", ^{

            expect(coordinator.currentDraggingItem).to.equal([draggingCollection itemAtIndexPath:index]);
        
        });
        
    });

SpecEnd
