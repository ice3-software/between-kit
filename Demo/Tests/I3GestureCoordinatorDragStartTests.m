//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3CoordinatorCreationMethods.h"
#import "I3CollectionFixture.h"
#import "EXPMatchers+haveStartedDrag.h"


SpecBegin(I3GestureCoordinatorDragStart)


    describe(@"successful drag start", ^{

        
        __block I3GestureCoordinator *coordinator;
        __block id dragDataSource;
        __block CGPoint dragOrigin;
        
    
        beforeAll(^{
            
            dragOrigin = CGPointMake(10, 10);
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
        
            /// @note This tests successful drags - we set the data source up to return positively for eveything.
            /// scenarios where the data source denies a drag are tested in the unsuccessful drag suits.
            
            OCMStub([dragDataSource canItemBeDraggedAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
        });
        
        afterAll(^{
            
            dragDataSource = nil;
        });
        
        beforeEach(^{

            coordinator = I3GestureCoordinatorSetupMockWithDataSource(dragDataSource);
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dragOrigin);

        });

        afterEach(^{
            
            coordinator = nil;
        });
        
        it(@"should start a drag on a collection with an item at a valid point", ^{
            
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockItemAtPoint:dragOrigin];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            expect(coordinator).to.haveStartedDrag(collection, dragOrigin);
            
        });
        
        it(@"should start and render dragging on the top-most intersecting collection and none underneith", ^{
        
            I3CollectionFixture *topCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            I3CollectionFixture *bottomCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            
            [topCollection mockItemAtPoint:dragOrigin];
            [bottomCollection mockItemAtPoint:dragOrigin];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
        
            expect(coordinator).to.haveStartedDrag(topCollection, dragOrigin);

        });
        
        it(@"should call the render delegate on successful drag start", ^{
            
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockItemAtPoint:dragOrigin];

            [coordinator handlePan:coordinator.gestureRecognizer];

            OCMVerify([coordinator.renderDelegate renderDragStart:coordinator]);
        
        });
        
    });

    describe(@"unsuccessful drag start", ^{

        
        __block I3GestureCoordinator *coordinator;
        __block id dragDataSource;
        __block CGPoint dragOrigin;
        
        
        beforeAll(^{
            dragOrigin = CGPointMake(10, 10);
        });
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupMockWithDataSource(dragDataSource);
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dragOrigin);
            
        });
        
        afterEach(^{
            
            coordinator = nil;
        });
        
        it(@"should not start dragging an undraggable item", ^{
        
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            NSIndexPath *dragIndex = [collection mockItemAtPoint:dragOrigin];
            
            OCMStub([dragDataSource canItemBeDraggedAt:dragIndex inCollection:collection]).andReturn(NO);
            
            [coordinator handlePan:coordinator.gestureRecognizer];

            expect(coordinator).to.haveEmptyDrag();
        });

        
        
        it(@"should not call the render delegate on failed drag start", ^{
        });
        
    });

    describe(@"current drag index", ^{

    });

    describe(@"current drag item view", ^{

    });

SpecEnd
