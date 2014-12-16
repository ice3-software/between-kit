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
        __block CGPoint dropOrigin;
        
        beforeAll(^{
            dropOrigin = CGPointMake(50, 50);
        });
        
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
        
        it(@"should not delete if data source does not implement can delete selector", ^{
            
            id dragDataSource = OCMClassMock([I3DragDataSourceJustDelete class]);
            coordinator.dragDataSource = dragDataSource;
            
            [[dragDataSource reject] deleteItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];

        });
        
        it(@"should not delete if the data source does not implement the delete selector", ^{
            
            id dragDataSource = OCMClassMock([I3DragDataSourceJustCanDelete class]);
            coordinator.dragDataSource = dragDataSource;
                        
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

        it(@"should delete item if its deleteable under the data source", ^{
            
            NSIndexPath *dragIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator.dragDataSource = dragDataSource;

            OCMStub([dragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
            
        });
        
        it(@"should render deletion if successfully delete", ^{

            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath beDeletedFromCollection:coordinator.currentDraggingCollection atPoint:dropOrigin]).andReturn(YES);
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([coordinator.renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);

        });
        
        it(@"should still delete if the gesture stops on a valid droppable collection", ^{
            
            /// @note This test isn't entirely necessary, but is here to demonstrate that one can
            /// successfully implement a 'deletion area' over the top of another collection

            NSIndexPath *dragIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator.dragDataSource = dragDataSource;

            I3CollectionFixture *dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];

            [dstCollection mockPoint:dropOrigin isInside:YES];
            [dstCollection mockItemAtPoint:dropOrigin];
            
            OCMStub([dragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
            
        });

    });

    describe(@"stopping an invalid drag", ^{

    });

SpecEnd
