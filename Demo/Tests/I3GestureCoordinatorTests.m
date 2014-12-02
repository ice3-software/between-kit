//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>
#import "I3DragDataSourceFixtures.h"
#import "I3CollectionFixture.h"
#import "I3DataSourceControllerFixture.h"


SpecBegin(I3GestureCoordinator)


    describe(@"ctor / dtor", ^{

        __block id dragArena;
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


    describe(@"drag/drop", ^{

        /// Top level describe block that sets up all the 'base' dependencies. These are the
        /// dependencies required throughout all the drag / drop tests that are initialised in the
        /// same way across all of them.
        
        __block NSMutableOrderedSet *collections;
        __block I3GestureCoordinator *coordinator;
        __block id dragArena;
        __block id superview;
        __block id panGestureRecognizer;
        __block id renderDelegate;

        
        beforeEach(^{
            
            superview = OCMPartialMock([[UIView alloc] init]);
            panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
            dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
            collections = [[NSMutableOrderedSet alloc] init];
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));

            OCMStub([dragArena collections]).andReturn(collections);
            coordinator.renderDelegate = renderDelegate;
            
        });
        
        afterEach(^{
            
            collections = nil;
            superview = nil;
            panGestureRecognizer = nil;
            dragArena = nil;
            coordinator = nil;
            renderDelegate = nil;
            
        });
        
        
        describe(@"dynamic properties", ^{

            __block id draggingCollection;
            CGPoint dragOrigin = CGPointMake(10, 10);
            
            beforeEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
                
            });
            
            afterEach(^{
                
                draggingCollection = nil;
                
            });
            
            
            /// @note Haven't tested the interactions here, just the result of the dynamic property invokation
            
            it(@"should return index path for dragging point in dragging collection", ^{
            
                NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
                
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(index);

                expect(coordinator.currentDraggingIndexPath).to.equal(index);
                
            });
            
            it(@"should return item at dragging point in dragging collection", ^{
            
                NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
                UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(index);
                OCMStub([draggingCollection itemAtIndexPath:index]).andReturn(item);
                
                expect(coordinator.currentDraggingItem).to.equal(item);
            
            });

        });

        
        describe(@"starting a drag", ^{
            
            
            __block id dragDataSource;
            __block NSIndexPath *dragIndex;

            CGPoint dragOrigin = CGPointMake(10, 10);
            
            
            beforeEach(^{
                
                dragIndex = [NSIndexPath indexPathForItem:0 inSection:0];
                dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
                coordinator.dragDataSource = dragDataSource;
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
                OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dragOrigin);
                
            });
            
            afterEach(^{

                dragIndex = nil;
                dragDataSource = nil;
                
            });
            
            
            it(@"should start and render a drag on a collection if the point is inside its bounds and the item is draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                id collectionItemView = [[UIView alloc] init];
                
                OCMStub([dragDataSource canItemBeDraggedAt:dragIndex inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([draggingCollection itemAtIndexPath:dragIndex]).andReturn(collectionItemView);
                [[dragArena collections] addObject:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(draggingCollection);
                expect(coordinator.currentDragOrigin).to.equal(dragOrigin);
                
                OCMVerify([renderDelegate renderDragStart:coordinator]);
                OCMVerify([dragDataSource canItemBeDraggedAt:dragIndex inCollection:draggingCollection]);
                
            });
            
            it(@"should not start dragging an item in a collection that is not draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                id collectionItemView = [[UIView alloc] init];

                /// Configure the draggingDataSource to allow for the given item at the dragOrigin to be
                /// dragged
 
                OCMStub([dragDataSource canItemBeDraggedAt:dragIndex inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([draggingCollection itemAtIndexPath:dragIndex]).andReturn(collectionItemView);
                [[dragArena collections] addObject:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerify([dragDataSource canItemBeDraggedAt:dragIndex inCollection:draggingCollection]);
                
            });
            
            it(@"should start and render dragging on the top-most intersecting collection and none underneith", ^{
                
                id topDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id bottomDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                id topCollectionItemView = [[UIView alloc] init];
                id topCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dragDataSource canItemBeDraggedAt:dragIndex inCollection:topDraggingCollection]).andReturn(YES);
                OCMStub([topDraggingCollection collectionView]).andReturn(topCollectionView);
                OCMStub([topDraggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([topDraggingCollection itemAtIndexPath:dragIndex]).andReturn(topCollectionItemView);
                OCMStub([topCollectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                [[dragArena collections] addObjectsFromArray:@[topDraggingCollection, bottomDraggingCollection]];
                
                /// Verify that the bottom drag data source's methods are not called
                
                [[dragDataSource reject] canItemBeDraggedAt:dragIndex inCollection:bottomDraggingCollection];
                [[bottomDraggingCollection reject] collectionView];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(topDraggingCollection);
                
                OCMVerify([renderDelegate renderDragStart:coordinator]);
                OCMVerify([dragDataSource canItemBeDraggedAt:dragIndex inCollection:topDraggingCollection]);
                
            });
            
            it(@"should not start dragging or call the data source if the point is outside of the collection view", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
               [[dragArena collections] addObject:draggingCollection];
                
                [[dragDataSource reject] canItemBeDraggedAt:dragIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
            });
            
            it(@"should not start dragging if inside the collection view but no valid item", ^{
            
                /// @note that we have explicitly not stubbed itemAtPoint so that it returns nil
                /// indicating the the coordinator that we are not starting a drag in a valid place

                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObject:draggingCollection];

                [[dragDataSource reject] canItemBeDraggedAt:dragIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
            
            });
            
        });
        
        
        describe(@"routing a valid stop", ^{
            
            __block id draggingCollection;
            
            CGPoint dropOrigin = CGPointMake(50, 50);
            CGPoint dragOrigin = CGPointMake(10, 10);
            
            
            beforeEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
                [collections addObject:draggingCollection];
                
                OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
                
            });
            
            afterEach(^{
                
                draggingCollection = nil;
                
            });
            
            it(@"should handle drop for UIGestureRecognizerStateEnded", ^{
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should handle drop for UIGestureRecognizerStateFailed", ^{
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should handle drop for UIGestureRecognizerStateCancelled", ^{
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateCancelled);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
        });
        
        
        describe(@"stopping a valid drag", ^{
            
            __block id defaultDragDataSource;
            
            /// The current collection being draged and its collection view
            
            __block id draggingCollection;
            __block id collectionView;
            __block id draggingItemView;
            
            /// Immutable origin data
            
            CGPoint dropOrigin = CGPointMake(50, 50);
            CGPoint dragOrigin = CGPointMake(10, 10);
            NSIndexPath *dragIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            
            
            beforeEach(^{
                
                /// @note that the drag data source that we set up and configure is called named 'default' because
                /// in some of the subsequent tests we may setup and re-inject a drag data source fixture.
                
                defaultDragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
                coordinator.dragDataSource = defaultDragDataSource;
                
                /// Here we set up the coordinator as if its already executed a successful drag start
                /// and holds a reference to a dragging collection.
                /// @note that this setup is almost identical to how we setup the coordinator in most of
                /// the drag start tests
                
                draggingCollection = OCMPartialMock([[I3CollectionFixture alloc] init]);
                collectionView = OCMPartialMock([[UIView alloc] init]);
                draggingItemView = OCMPartialMock([[UIView alloc] init]);
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
                [collections addObject:draggingCollection];
                
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([draggingCollection indexPathForItemAtPoint:dragOrigin]).andReturn(dragIndex);
                OCMStub([draggingCollection itemAtIndexPath:dragIndex]).andReturn(draggingItemView);
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
                
            });
            
            afterEach(^{
                
                draggingCollection = nil;
                collectionView = nil;
                defaultDragDataSource = nil;
                draggingItemView = nil;
                
            });
            
            it(@"should reset the drag and render if there was no valid destination", ^{
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if data source does not implement can delete selector", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustDelete alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                
                [[dragDataSource reject] deleteItemAt:dragIndex inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if the data source does not implement the delete selector", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanDelete alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                OCMStub([dragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                
                [[dragDataSource reject] deleteItemAt:dragIndex inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if the item in the data source is not deleteable", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([defaultDragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(NO);
                
                [[defaultDragDataSource reject] deleteItemAt:dragIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should delete item if its deleteable under the data source", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([defaultDragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should still delete if the gesture stops on a valid droppable collection", ^{
            
                /// @note in the same way we test that drops are delegated to the top-most intersecting collection
                /// with the exchange interactions, we will test whether a delete succeeds or not over a 'valid droppable
                /// area' by choosing the exchange interactions to represent that property of the collection.
    
                UIView *dstItemView = [[UIView alloc] init];
                NSIndexPath *dstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dstIndex);
                OCMStub([dstCollection itemAtIndexPath:dstIndex]).andReturn(dstItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAt:dragIndex fromCollection:draggingCollection beExchangedWithItemAt:dstIndex inCollection:dstCollection]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAt:dragIndex beDeletedFromCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([defaultDragDataSource deleteItemAt:dragIndex inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
                
                UIView *targetItemView = [[UIView alloc] init];
                NSIndexPath *dropIndex = [NSIndexPath indexPathForItem:5 inSection:5];
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dropIndex);
                OCMStub([draggingCollection itemAtIndexPath:dropIndex]).andReturn(targetItemView);
                OCMStub([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]).andReturn(YES);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource rearrangeItemAt:dragIndex withItemAt:dropIndex inCollection:draggingCollection]);
                OCMVerify([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderRearrangeOnPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source does not implement can rearrange", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustRearrange alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                UIView *targetItemView = [[UIView alloc] init];
                NSIndexPath *dropIndex = [NSIndexPath indexPathForItem:5 inSection:5];

                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dropIndex);
                OCMStub([draggingCollection itemAtIndexPath:dropIndex]).andReturn(targetItemView);

                [[dragDataSource reject] rearrangeItemAt:dragIndex withItemAt:dropIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source does not implement rearrange method", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanRearrange alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                UIView *targetItemView = [[UIView alloc] init];
                NSIndexPath *dropIndex = [NSIndexPath indexPathForItem:5 inSection:5];

                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dropIndex);
                OCMStub([draggingCollection itemAtIndexPath:dropIndex]).andReturn(targetItemView);
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]).andReturn(YES);

                [[defaultDragDataSource reject] rearrangeItemAt:dragIndex withItemAt:dropIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source specifies the items as un-rearrangeable", ^{
                
                UIView *targetItemView = [[UIView alloc] init];
                NSIndexPath *dropIndex = [NSIndexPath indexPathForItem:5 inSection:5];
                
                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dropIndex);
                OCMStub([draggingCollection itemAtIndexPath:dropIndex]).andReturn(targetItemView);
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]).andReturn(NO);
                
                [[defaultDragDataSource reject] rearrangeItemAt:dragIndex withItemAt:dropIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            
            /// @note Should we test that this behviour occurs both if the item UIViews are the same and
            /// if the NSIndexPath s are the same... ?
            
            it(@"should not rearrange and render reset if we're dropping on the same item in the collection", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dragIndex);
                OCMStub([draggingCollection itemAtIndexPath:dragIndex]).andReturn(draggingItemView);
                OCMStub([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dragIndex inCollection:draggingCollection]).andReturn(YES);
                
                [[defaultDragDataSource reject] rearrangeItemAt:dragIndex withItemAt:dragIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection indexPathForItemAtPoint:dragOrigin]);
                OCMVerify([draggingCollection indexPathForItemAtPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if we're dropping on an invalid location in the collection", ^{
                
                /// @note We've stubbed out pointInside and indexPathForItemAtPoint to return valid values
                /// but we _haven't_ stubbed out itemAtPoint for the collection to return a valid UIView
                /// (it should instead return nil)
                
                NSIndexPath *dropIndex = [NSIndexPath indexPathForItem:0 inSection:7];
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection indexPathForItemAtPoint:dropOrigin]).andReturn(dropIndex);
                OCMStub([draggingCollection itemAtIndexPath:dropIndex]).andReturn(nil);
                OCMStub([defaultDragDataSource canItemFrom:dragIndex beRearrangedWithItemAt:dropIndex inCollection:draggingCollection]).andReturn(YES);
                
                [[defaultDragDataSource reject] rearrangeItemAt:dragIndex withItemAt:dropIndex inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection itemAtIndexPath:dropIndex]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            /*
            
            it(@"should exchange between collections if we're drag/dropping between different collections and data source allows", ^{
                
                UIView *dstItemView = [[UIView alloc] init];
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]);
                OCMVerify([defaultDragDataSource exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:dstCollection]);
                OCMVerify([renderDelegate renderExchangeToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source does not implement exchange selector", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanExchange alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = [[UIView alloc] init];

                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);

                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[dragDataSource reject] exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source does not implement can exchange selector", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustExchange alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = [[UIView alloc] init];
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                
                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[dragDataSource reject] exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source specifies that cell is not exchangeable", ^{
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = OCMPartialMock([[UIView alloc] init]);

                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(NO);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);
               
                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange and render reset if we're dropping on an invalid location in the dst collection", ^{
                
                /// @note similar to the rearrange tests, we excplicitly don't stub itemAtPoint for the destination
                /// collection so that it returns nil as if there is no valid item at that point.
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);

                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);

                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should append onto collection if we're drag/dropping between collections, there is no drag item and the data source allows", ^{
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(YES);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]);
                OCMVerify([defaultDragDataSource appendItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection]);
                OCMVerify([renderDelegate renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should append onto collection if we're dropping onto an item that is not exchangeable and the data source allows", ^{
            
                UIView *dstItemView = [[UIView alloc] init];
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:dstCollection]).andReturn(NO);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(YES);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]);
                OCMVerify([defaultDragDataSource appendItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection]);
                OCMVerify([renderDelegate renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });

            it(@"should not append onto collection if the data source does not allow", ^{
            
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(NO);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] appendItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection];
                [[renderDelegate reject] renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not append onto collection if the data source does not implement append selector", ^{
            
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanAppend alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(NO);
                
                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] appendItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection];
                [[renderDelegate reject] renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not append onto collection if the data source does not implement can append selector", ^{
            
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustAppend alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beAppendedToCollection:dstCollection atPoint:dropOrigin]).andReturn(NO);
                
                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] appendItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin onCollection:dstCollection];
                [[renderDelegate reject] renderAppendToCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should handle drop for the top-most intersecting collection and none underneith", ^{
                
                /// @note that we could have tested whether the coordinator interacts with the render delegate and data
                /// source based on appendation or rearranging. Testing on the basis of delegating exchanges was an arbitrary
                /// decision.
                
                id bottomCollection = OCMPartialMock([[I3CollectionFixture alloc] init]);
                id bottomCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                UIView *topCollectionItemView = [[UIView alloc] init];
                id topCollection = OCMPartialMock([[I3CollectionFixture alloc] init]);
                id topCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                [collections insertObjects:@[topCollection, bottomCollection] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
                
                OCMStub([bottomCollection collectionView]).andReturn(bottomCollectionView);
                OCMStub([topCollection collectionView]).andReturn(topCollectionView);
                
                /// Set both of the new dragging views to respond positively to the drop in the data source and their
                /// collection views. @note the new change in the way data sources are dealt with (there is 1 data source
                /// now)
                
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:topCollection]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beExchangedWithItemAtPoint:dropOrigin inCollection:bottomCollection]).andReturn(YES);
                
                OCMStub([bottomCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([topCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([topCollection itemAtPoint:dropOrigin]).andReturn(topCollectionItemView);
                
                [[defaultDragDataSource reject] exchangeItemAtPoint:dragOrigin inCollection:bottomCollection withItemAtPoint:dropOrigin inCollection:bottomCollection];
                [[renderDelegate reject] renderExchangeToCollection:bottomCollection atPoint:dropOrigin fromCoordinator:coordinator];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource exchangeItemAtPoint:dragOrigin inCollection:draggingCollection withItemAtPoint:dropOrigin inCollection:topCollection]);
                OCMVerify([renderDelegate renderExchangeToCollection:topCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });

        });
        
        describe(@"stopping an invalid drag", ^{
            
            CGPoint dragOrigin = CGPointMake(10, 10);
            
            beforeEach(^{
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                OCMStub([dragArena collections]).andReturn(collections);
                
            });
            
            afterEach(^{});
            
            it(@"should do nothing if no collection is currently being dragged", ^{
                
                [[renderDelegate reject] renderResetFromPoint:dragOrigin fromCoordinator:coordinator];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
            });
            
        });
        
        
        describe(@"dragging", ^{
            
            __block id draggingCollection;
            
            beforeEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:CGPointMake(10, 10)] forKey:@"_currentDragOrigin"];
                [collections addObject:draggingCollection];
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateChanged);
                
            });
            
            afterEach(^{
                
                draggingCollection = nil;
                
            });
            
            it(@"should render dragging", ^{
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderDraggingFromCoordinator:coordinator]);
                
            });
            
        });
        
    });


    sharedExamples(@"factory", ^(NSDictionary *data) {

        id coordinator = data[@"coordinator"];
        UIViewController *controller = data[@"controller"];
        
        it(@"should create a new coodinator", ^{
            expect(coordinator).to.beInstanceOf([I3GestureCoordinator class]);
        });
        
        it(@"should create a new coordinator with a basic drag render delegate", ^{
            expect([coordinator renderDelegate]).to.beInstanceOf([I3BasicRenderDelegate class]);
        });
        
        it(@"should set the controller as the gesture's data source if it conforms to protocol", ^{
            expect([coordinator dragDataSource]).to.equal(controller);
        });
        
        it(@"should set up arena with the controller's main view as the superview", ^{
            expect([coordinator arena].superview).to.equal(controller.view);
        });
        
        it(@"should set up the arena with collections", ^{
            
            I3CollectionFixture *collection1 = data[@"collection1"];
            I3CollectionFixture *collection2 = data[@"collection2"];
            I3CollectionFixture *collection3 = data[@"collection3"];
            
            expect([[coordinator arena].collections containsObject:collection1]).to.beTruthy();
            expect([[coordinator arena].collections containsObject:collection2]).to.beTruthy();
            expect([[coordinator arena].collections containsObject:collection3]).to.beTruthy();
            
        });
    
    });

    describe(@"basic factory method", ^{

        I3DataSourceControllerFixture* controller = [[I3DataSourceControllerFixture alloc] init];
        I3CollectionFixture *collection1 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection2 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection3 = [[I3CollectionFixture alloc] init];
        
        itShouldBehaveLike(@"factory", @{
                                         @"coordinator": [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:@[collection1, collection2, collection3]],
                                         @"controller":  controller,
                                         @"collection1": collection1,
                                         @"collection2": collection2,
                                         @"collection3": collection3,
                                         });
        
    });


    describe(@"basic factory method with gesture", ^{

        I3DataSourceControllerFixture* controller = [[I3DataSourceControllerFixture alloc] init];
        I3CollectionFixture *collection1 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection2 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection3 = [[I3CollectionFixture alloc] init];
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] init];
        I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:@[collection1, collection2, collection3] withRecognizer:recognizer];
        
        itShouldBehaveLike(@"factory", @{
                                         @"coordinator": coordinator,
                                         @"controller":  controller,
                                         @"collection1": collection1,
                                         @"collection2": collection2,
                                         @"collection3": collection3,
                                         });
        
        it(@"should initialise the coordinator with a long press gesture recognizer", ^{
            expect(coordinator.gestureRecognizer).to.equal(recognizer);
        });
    */
        });
    });

SpecEnd
