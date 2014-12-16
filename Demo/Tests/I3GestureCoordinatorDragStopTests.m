//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3CoordinatorCreationMethods.h"
#import "I3DragDataSourceFixtures.h"
#import "I3CollectionFixture.h"
#import "EXPMatchers+haveStartedDrag.h"

SpecBegin(I3GestureCoordinatorDragStop)

    describe(@"handle gesture recognizer states", ^{

        __block I3GestureCoordinator *coordinator;
        __block CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
        });
        
        afterEach(^{
            coordinator = nil;
        });
        
        it(@"should handle drop for UIGestureRecognizerStateEnded", ^{
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
            [coordinator handlePan:coordinator.gestureRecognizer];
            expect(coordinator).to.haveEmptyDrag();

        });
        
        it(@"should handle drop for UIGestureRecognizerStateFailed", ^{
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            [coordinator handlePan:coordinator.gestureRecognizer];
            expect(coordinator).to.haveEmptyDrag();
            
        });
        
        it(@"should handle drop for UIGestureRecognizerStateCancelled", ^{
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateCancelled);
            [coordinator handlePan:coordinator.gestureRecognizer];
            expect(coordinator).to.haveEmptyDrag();
            
        });
    
    });

    describe(@"successful delete", ^{
        
        __block I3GestureCoordinator *coordinator;
        __block id dragDataSource;
        __block CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);

            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
            OCMStub([dragDataSource canItemAt:[OCMArg any] beDeletedFromCollection:[OCMArg any] atPoint:dropOrigin]).andReturn(YES);
            
        });

        afterEach(^{
            
            dragDataSource = nil;
            coordinator = nil;
        });
        
        it(@"should delete item if its deleteable under the data source", ^{
            
            NSIndexPath *dragIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
            
        });
        
        it(@"should render deletion if successfully delete", ^{
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([coordinator.renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);
            
        });
        
        it(@"should still delete if the gesture stops on a valid droppable collection", ^{
            
            /// @note This test isn't entirely necessary, but is here to demonstrate that one can
            /// successfully implement a 'deletion area' over the top of another collection
            
            NSIndexPath *dragIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            
            I3CollectionFixture *dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            
            [dstCollection mockPoint:dropOrigin isInside:YES];
            [dstCollection mockItemAtPoint:dropOrigin];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
            
        });
    
    });

    describe(@"unsuccessful delete", ^{
    
        __block I3GestureCoordinator *coordinator;
        __block CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });
        
        afterEach(^{
            coordinator = nil;
        });

        it(@"should not delete if data source does not implement can delete selector", ^{
            
            id dragDataSource = OCMClassMock([I3DragDataSourceJustDelete class]);
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath beDeletedFromCollection:coordinator.currentDraggingCollection atPoint:dropOrigin]).andReturn(YES);

            [[dragDataSource reject] deleteItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not delete if the data source does not implement the delete selector", ^{
            
            id dragDataSource = OCMClassMock([I3DragDataSourceJustCanDelete class]);
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath beDeletedFromCollection:coordinator.currentDraggingCollection atPoint:dropOrigin]).andReturn(YES);
            
            [[dragDataSource reject] deleteItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not delete if the item in the data source is not deleteable", ^{
            
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath beDeletedFromCollection:coordinator.currentDraggingCollection atPoint:dropOrigin]).andReturn(NO);
            
            [[dragDataSource reject] deleteItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });

    });

    describe(@"successful rearrange", ^{
        
        __block I3GestureCoordinator *coordinator;
        __block CGPoint dropOrigin = CGPointMake(50, 50);
        __block id dragDataSource;
      
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
            OCMStub([dragDataSource canItemFrom:[OCMArg any] beRearrangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
            
        });
        
        afterEach(^{
            coordinator = nil;
        });

        it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
            
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator.dragDataSource = dragDataSource;
            
            I3CollectionFixture *draggingCollection = (I3CollectionFixture *)coordinator.currentDraggingCollection;
            NSIndexPath *dstIndex = [draggingCollection mockItemAtPoint:dropOrigin];
            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            
            [coordinator handlePan:coordinator.gestureRecognizer];

            OCMVerify([dragDataSource rearrangeItemAt:draggingIndex withItemAt:dstIndex inCollection:draggingCollection]);
            
        });
        
    });

    describe(@"unsuccessful rearrange", ^{});

    describe(@"successful exchange", ^{});

    describe(@"unsuccessful exchange", ^{});

    describe(@"successful append", ^{});

    describe(@"unsuccessful append", ^{});

    describe(@"stopping a valid drag", ^{
        
        __block I3GestureCoordinator *coordinator;
        __block CGPoint dropOrigin;
        
        beforeAll(^{
            dropOrigin = CGPointMake(50, 50);
        });
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });

        it(@"should reset the drag and render if there was no valid destination", ^{
            
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockPoint:dropOrigin isInside:NO];
            [coordinator handlePan:coordinator.gestureRecognizer];

            expect(coordinator).to.haveEmptyDrag();
            
            OCMVerify([coordinator.renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

        });
        
    });

    describe(@"stopping an invalid drag", ^{

    });

SpecEnd
