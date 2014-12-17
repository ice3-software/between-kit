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
        __block CGPoint dragOrigin = CGPointMake(10, 10);
    
        
        beforeAll(^{
            
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
        
            /// @note This tests successful drags - we set the data source up to return positively for eveything.
            /// scenarios where the data source denies a drag are tested in the unsuccessful drag suits.
            
            OCMStub([dragDataSource canItemBeDraggedAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
        });
        
        afterAll(^{
            
            dragDataSource = nil;
        });
        
        
        beforeEach(^{

            coordinator = I3GestureCoordinatorSetupMock(dragDataSource);
            
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
        __block CGPoint dragOrigin = CGPointMake(10, 10);

        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupMock(dragDataSource);
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

        it(@"should not start dragging if the point is outside of the collection view", ^{
        
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockPoint:dragOrigin isInside:NO];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            expect(coordinator).to.haveEmptyDrag();
        
        });
        
        it(@"should not call data source access method if the point is outside of the collection view", ^{
            
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockPoint:dragOrigin isInside:NO];
            
            [[dragDataSource reject] canItemBeDraggedAt:[OCMArg any] inCollection:collection];
            
            [coordinator handlePan:coordinator.gestureRecognizer];

        });
        
        it(@"should not start dragging if no valid index path at point in collection", ^{

            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockPoint:dragOrigin isInside:YES];

            /// @note Explicitly don't call `mockItemAtPoint`
            
            [coordinator handlePan:coordinator.gestureRecognizer];

            expect(coordinator).to.haveEmptyDrag();
        });
        
        it(@"should not start dragging if no valid item view at index path in collection", ^{
            
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockIndexPathAtPoint:dragOrigin];

            [coordinator handlePan:coordinator.gestureRecognizer];

            expect(coordinator).to.haveEmptyDrag();
        });
        
        it(@"should not call data source access method if no valid item view for index path", ^{
        
            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockIndexPathAtPoint:dragOrigin];

            [[dragDataSource reject] canItemBeDraggedAt:[OCMArg any] inCollection:collection];
            
            [coordinator handlePan:coordinator.gestureRecognizer];

        });
        
        it(@"should not call data source access method if no valid index path for point in the collection", ^{

            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockPoint:dragOrigin isInside:YES];
            /// @note Explicitly don't call `mockItemAtPoint`
            
            [[dragDataSource reject] canItemBeDraggedAt:[OCMArg any] inCollection:collection];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
        
        });
        
        it(@"should not call the render delegate on failed drag start", ^{

            I3CollectionFixture *collection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [collection mockPoint:dragOrigin isInside:NO];

            [[(id)coordinator.renderDelegate reject] renderDragStart:coordinator];

            [coordinator handlePan:coordinator.gestureRecognizer];

        });
        
    });


    describe(@"current drag index", ^{
        
        it(@"should return index path for dragging point in dragging collection", ^{
        
            I3GestureCoordinator *coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            CGPoint dragOrigin = coordinator.currentDragOrigin;
            NSIndexPath *dragIndex = [coordinator.currentDraggingCollection indexPathForItemAtPoint:dragOrigin];
            
            expect(coordinator.currentDraggingIndexPath).to.equal(dragIndex);
            
        });

    });

    describe(@"current drag item view", ^{
        
        it(@"should return item view at dragging point in dragging collection", ^{

            I3GestureCoordinator *coordinator = I3GestureCoordinatorSetupDraggingMock(nil);

            NSIndexPath *dragIndex = [coordinator.currentDraggingCollection indexPathForItemAtPoint:coordinator.currentDragOrigin];
            UIView *draggingItemView = [coordinator.currentDraggingCollection itemAtIndexPath:dragIndex];
            
            expect(coordinator.currentDraggingItem).to.equal(draggingItemView);
            
        });
        
    });


SpecEnd
