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
        CGPoint dropOrigin = CGPointMake(50, 50);
        
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
        CGPoint dropOrigin = CGPointMake(50, 50);
        
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
        CGPoint dropOrigin = CGPointMake(50, 50);
        
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
        CGPoint dropOrigin = CGPointMake(50, 50);
        __block id dragDataSource;
      
        beforeEach(^{
            
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
            OCMStub([dragDataSource canItemFrom:[OCMArg any] beRearrangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
            
        });
        
        afterEach(^{
            coordinator = nil;
        });

        it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
            
            I3CollectionFixture *draggingCollection = (I3CollectionFixture *)coordinator.currentDraggingCollection;
            NSIndexPath *dstIndex = [draggingCollection mockItemAtPoint:dropOrigin];
            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            
            [coordinator handlePan:coordinator.gestureRecognizer];

            OCMVerify([dragDataSource rearrangeItemAt:draggingIndex withItemAt:dstIndex inCollection:draggingCollection]);
            
        });
        
        it(@"should render rearrange if successfully rearranged", ^{

            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockItemAtPoint:dropOrigin];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([coordinator.renderDelegate renderRearrangeOnPoint:dropOrigin fromCoordinator:coordinator]);

        });
        
    });

    describe(@"unsuccessful rearrange", ^{
    
        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });
        
        afterEach(^{
            coordinator = nil;
        });

        it(@"should not rearrange if the data source does not implement can rearrange", ^{
        
            id dragDataSource = OCMPartialMock([[I3DragDataSourceJustRearrange alloc] init]);
            coordinator.dragDataSource = dragDataSource;
            
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockItemAtPoint:dropOrigin];
            
            [[dragDataSource reject] rearrangeItemAt:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });

        it(@"should not rearrange if the data source does not implement rearrange method", ^{
            
            id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanRearrange alloc] init]);
            coordinator.dragDataSource = dragDataSource;
            
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockItemAtPoint:dropOrigin];
            
            [[dragDataSource reject] rearrangeItemAt:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not rearrange if the data source specifies the items as un-rearrangeable", ^{
        
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;

            NSIndexPath *dstIndex = [(I3CollectionFixture *)coordinator.currentDraggingCollection mockItemAtPoint:dropOrigin];
            OCMStub([dragDataSource canItemFrom:coordinator.currentDraggingIndexPath beRearrangedWithItemAt:dstIndex inCollection:coordinator.currentDraggingCollection]).andReturn(NO);

            [[dragDataSource reject] rearrangeItemAt:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
        
        });
        
        it(@"should not rearrange if we're dropping on the same item in the collection", ^{
        
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            NSIndexPath *dragIndex = coordinator.currentDraggingIndexPath;
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockItemAtPoint:dropOrigin withIndexPath:dragIndex];
            OCMStub([dragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dragIndex inCollection:coordinator.currentDraggingCollection]).andReturn(YES);
            
            [[dragDataSource reject] rearrangeItemAt:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
        
        });
        
        it(@"should not rearrange if we're dropping on an invalid location in the collection", ^{
        
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockIndexPathAtPoint:dropOrigin];
            OCMStub([dragDataSource canItemFrom:[OCMArg any] beRearrangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);

            [[dragDataSource reject] rearrangeItemAt:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
    });

    describe(@"successful exchange", ^{
        
        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        __block NSIndexPath *dstIndex;
        __block id dstCollection;
        __block id dragDataSource;

        beforeEach(^{
        
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);
            dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            dstIndex = [dstCollection mockItemAtPoint:dropOrigin];
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
            OCMStub([dragDataSource canItemAt:[OCMArg any] fromCollection:[OCMArg any] beExchangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
            
        });
        
        afterEach(^{
            coordinator = nil;
            dragDataSource = nil;
            dstCollection = nil;
        });
        
        it(@"should exchange between collections", ^{
        
            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource exchangeItemAt:draggingIndex inCollection:draggingCollection withItemAt:dstIndex inCollection:dstCollection]);
        });
        
        it(@"should render successfull exchange", ^{

            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([coordinator.renderDelegate renderExchangeToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
        
        });

    });

    describe(@"unsuccessful exchange", ^{
    
        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        __block id dstCollection;
        
        beforeEach(^{

            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [dstCollection mockPoint:dropOrigin isInside:YES];
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });
        
        afterEach(^{
            coordinator = nil;
            dstCollection = nil;
        });
        
        it(@"should not exchange if data source does not implement exchange selector", ^{
        
            id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanExchange alloc] init]);
            coordinator.dragDataSource = dragDataSource;
            
            [dstCollection mockItemAtPoint:dropOrigin];

            [[dragDataSource reject] exchangeItemAt:[OCMArg any] inCollection:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];

        });
        
        it(@"should not exchange if data source does not implement can exchange selector", ^{
            
            id dragDataSource = OCMPartialMock([[I3DragDataSourceJustExchange alloc] init]);
            coordinator.dragDataSource = dragDataSource;
            
            [dstCollection mockItemAtPoint:dropOrigin];
            
            [[dragDataSource reject] exchangeItemAt:[OCMArg any] inCollection:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not exchange if data source specifies that cell is not exchangeable", ^{
            
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            NSIndexPath *dstIndex = [dstCollection mockItemAtPoint:dropOrigin];
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath fromCollection:coordinator.currentDraggingCollection beExchangedWithItemAt:dstIndex inCollection:dstCollection]).andReturn(NO);
            
            [[dragDataSource reject] exchangeItemAt:[OCMArg any] inCollection:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not exchange if we're dropping on an invalid location in the dst collection", ^{
            
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            [dstCollection mockIndexPathAtPoint:dropOrigin];
            
            OCMStub([dragDataSource canItemAt:[OCMArg any] fromCollection:[OCMArg any] beExchangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);

            [[dragDataSource reject] exchangeItemAt:[OCMArg any] inCollection:[OCMArg any] withItemAt:[OCMArg any] inCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
    });

    describe(@"successful append", ^{
    
        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        __block id dstCollection;
        __block id dragDataSource;
        
        beforeEach(^{
            
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);
            dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
            OCMStub([dragDataSource canItemAt:[OCMArg any] fromCollection:[OCMArg any] beAppendedToCollection:[OCMArg any] atPoint:dropOrigin]).andReturn(YES);
            
        });
        
        afterEach(^{
            coordinator = nil;
            dragDataSource = nil;
            dstCollection = nil;
        });
        
        it(@"should append onto collection if we're drag/dropping between collections, there is no drag item and the data source allows", ^{
            
            [dstCollection mockPoint:dropOrigin isInside:YES];

            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource appendItemAt:draggingIndex fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection]);
            
        });
        
        it(@"should append onto collection if we're dropping onto an item that is not exchangeable and the data source allows", ^{
        
            NSIndexPath *dstIndex = [dstCollection mockItemAtPoint:dropOrigin];
            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            id draggingCollection = coordinator.currentDraggingCollection;
            
            OCMStub([dragDataSource canItemAt:draggingIndex fromCollection:draggingCollection beExchangedWithItemAt:dstIndex inCollection:dstCollection]).andReturn(NO);
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource appendItemAt:draggingIndex fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection]);

        });
        
        it(@"should render appendation", ^{
        
            [dstCollection mockPoint:dropOrigin isInside:YES];

            [coordinator handlePan:coordinator.gestureRecognizer];
        
            OCMVerify([coordinator.renderDelegate renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
        });
    
    });

    describe(@"unsuccessful append", ^{
    
        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        __block id dstCollection;
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            dstCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            [dstCollection mockPoint:dropOrigin isInside:YES];
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });
        
        afterEach(^{
            coordinator = nil;
            dstCollection = nil;
        });

        it(@"should not append onto collection if the data source does not allow", ^{
        
            id dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath fromCollection:coordinator.currentDraggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(NO);
            
            [[dragDataSource reject] appendItemAt:[OCMArg any] fromCollection:[OCMArg any] toPoint:dropOrigin onCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not append onto collection if the data source does not implement append selector", ^{
        
            id dragDataSource = OCMPartialMock([I3DragDataSourceJustCanAppend alloc]);
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath fromCollection:coordinator.currentDraggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(YES);
            
            [[dragDataSource reject] appendItemAt:[OCMArg any] fromCollection:[OCMArg any] toPoint:dropOrigin onCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
        it(@"should not append onto collection if the data source does not implement can append selector", ^{
            
            id dragDataSource = OCMPartialMock([I3DragDataSourceJustAppend alloc]);
            coordinator.dragDataSource = dragDataSource;
            
            OCMStub([dragDataSource canItemAt:coordinator.currentDraggingIndexPath fromCollection:coordinator.currentDraggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(YES);
            
            [[dragDataSource reject] appendItemAt:[OCMArg any] fromCollection:[OCMArg any] toPoint:dropOrigin onCollection:[OCMArg any]];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
    });

    describe(@"generic drops", ^{
        
        __block I3GestureCoordinator *coordinator;
        __block id dragDataSource;
        CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);
            
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
            
        });

        afterEach(^{
            
            dragDataSource = nil;
            coordinator = nil;
            
        });
        
        it(@"should reset the drag and render if there was no valid destination", ^{
            
            [(I3CollectionFixture *)coordinator.currentDraggingCollection mockPoint:dropOrigin isInside:NO];
            [coordinator handlePan:coordinator.gestureRecognizer];

            expect(coordinator).to.haveEmptyDrag();
            
            OCMVerify([coordinator.renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

        });
        
        it(@"should handle drop for the top-most intersecting collection and none underneith", ^{
        
            id topCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            id bottomCollection = [[I3CollectionFixture alloc] initInArena:coordinator.arena];
            id draggingCollection = coordinator.currentDraggingCollection;

            NSIndexPath *bottomIndex = [bottomCollection mockItemAtPoint:dropOrigin];
            NSIndexPath *topIndex = [topCollection mockItemAtPoint:dropOrigin];
            NSIndexPath *draggingIndex = coordinator.currentDraggingIndexPath;
            
            OCMStub([dragDataSource canItemAt:[OCMArg any] fromCollection:[OCMArg any] beExchangedWithItemAt:[OCMArg any] inCollection:[OCMArg any]]).andReturn(YES);
                    
            [[dragDataSource reject] exchangeItemAt:coordinator.currentDraggingIndexPath inCollection:coordinator.currentDraggingCollection withItemAt:bottomIndex inCollection:bottomCollection];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource exchangeItemAt:draggingIndex inCollection:draggingCollection withItemAt:topIndex inCollection:topCollection]);
        });
        
    });

    describe(@"stopping an invalid drag", ^{

        __block I3GestureCoordinator *coordinator;
        CGPoint dropOrigin = CGPointMake(50, 50);
        
        beforeEach(^{
            
            coordinator = I3GestureCoordinatorSetupMock(nil);
        
            OCMStub([coordinator.gestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);

        });
        
        it(@"should do nothing if no collection is being dragged", ^{
        
            [[(id)coordinator.renderDelegate reject] renderResetFromPoint:dropOrigin fromCoordinator:coordinator];
            [coordinator handlePan:coordinator.gestureRecognizer];
            
        });
        
    });

SpecEnd
