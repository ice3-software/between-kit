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

        
        describe(@"starting a drag", ^{
            
            
            __block id dragDataSource;
            CGPoint dragOrigin = CGPointMake(10, 10);
            
            
            beforeEach(^{
                
                dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
                coordinator.dragDataSource = dragDataSource;
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
                OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dragOrigin);
                
            });
            
            afterEach(^{

                dragDataSource = nil;
                
            });
            
            
            it(@"should start and render a drag on a collection if the point is inside its bounds and the item is draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                id collectionItemView = [[UIView alloc] init];
                
                OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection itemAtPoint:dragOrigin]).andReturn(collectionItemView);
                [[dragArena collections] addObject:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(draggingCollection);
                expect(coordinator.currentDragOrigin).to.equal(dragOrigin);
                
                OCMVerify([renderDelegate renderDragStart:coordinator]);
                OCMVerify([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]);
                
            });
            
            it(@"should not start dragging an item in a collection that is not draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                id collectionItemView = [[UIView alloc] init];

                /// Configure the draggingDataSource to allow for the given item at the dragOrigin to be
                /// dragged
                
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]).andReturn(NO);
                OCMStub([draggingCollection itemAtPoint:dragOrigin]).andReturn(collectionItemView);
                [[dragArena collections] addObject:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerify([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]);
                
            });
            
            it(@"should start and render dragging on the top-most intersecting collection and none underneith", ^{
                
                id topDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id bottomDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                id topCollectionItemView = [[UIView alloc] init];
                id topCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:topDraggingCollection]).andReturn(YES);
                OCMStub([topDraggingCollection collectionView]).andReturn(topCollectionView);
                OCMStub([topDraggingCollection itemAtPoint:dragOrigin]).andReturn(topCollectionItemView);
                OCMStub([topCollectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                [[dragArena collections] addObjectsFromArray:@[topDraggingCollection, bottomDraggingCollection]];
                
                /// Verify that the bottom drag data source's methods are not called
                
                [[dragDataSource reject] canItemBeDraggedAtPoint:dragOrigin inCollection:bottomDraggingCollection];
                [[bottomDraggingCollection reject] collectionView];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(topDraggingCollection);
                
                OCMVerify([renderDelegate renderDragStart:coordinator]);
                OCMVerify([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:topDraggingCollection]);
                
            });
            
            it(@"should not start dragging or call the data source if the point is outside of the collection view", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id collectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                [[dragArena collections] addObject:draggingCollection];
                
                [[dragDataSource reject] canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection];
                
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
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObject:draggingCollection];

                [[dragDataSource reject] canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection];
                
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
                OCMStub([draggingCollection itemAtPoint:dragOrigin]).andReturn(draggingItemView);
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
            
            it(@"should delegate the drop to the top-most intersecting collection and none underneith", ^{
                
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
                
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:bottomCollection]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:topCollection]).andReturn(YES);
                OCMStub([bottomCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([topCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([topCollection itemAtPoint:dropOrigin]).andReturn(topCollectionItemView);
                
                [[defaultDragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:bottomCollection];
                [[renderDelegate reject] renderDropOnCollection:bottomCollection atPoint:dropOrigin fromCoordinator:coordinator];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:topCollection]);
                OCMVerify([renderDelegate renderDropOnCollection:topCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if data source does not implement can delete selector", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustDelete alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                
                [[dragDataSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if the data source does not implement the delete selector", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanDelete alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                OCMStub([dragDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                
                [[dragDataSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not delete and render reset if the item in the data source is not deleteable", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(NO);
                
                [[defaultDragDataSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should delete item if its deleteable under the data source", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource deleteItemAtPoint:dragOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
                
                UIView *targetItemView = [[UIView alloc] init];
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(targetItemView);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderRearrangeOnPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source does not implement can rearrange", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustRearrange alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                UIView *targetItemView = [[UIView alloc] init];

                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(targetItemView);

                [[dragDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source does not implement rearrange method", ^{

                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanRearrange alloc] init]);
                coordinator.dragDataSource = dragDataSource;

                UIView *targetItemView = [[UIView alloc] init];

                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(targetItemView);

                [[defaultDragDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source specifies the items as un-rearrangeable", ^{
                
                UIView *targetItemView = [[UIView alloc] init];
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(NO);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(targetItemView);
                
                [[defaultDragDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if we're dropping on the same item in the collection", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(draggingItemView);
                
                [[defaultDragDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection itemAtPoint:dragOrigin]);
                OCMVerify([draggingCollection itemAtPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if we're dropping on an invalid location in the collection", ^{
                
                /// @note We've stubbed out pointInside to return YES but we _haven't_ stubbed out itemAtPoint for
                /// the collection to return a valid UIView (it should instead return nil
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                
                [[defaultDragDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection itemAtPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should exchange between collections if we're drag/dropping between different collections and data source allows", ^{
                
                UIView *dstItemView = [[UIView alloc] init];
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                
                [collections insertObject:dstCollection atIndex:0];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]);
                OCMVerify([defaultDragDataSource dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:dstCollection]);
                OCMVerify([renderDelegate renderDropOnCollection:dstCollection atPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source does not implement drop selector", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustCanDrop alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = [[UIView alloc] init];

                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);

                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[dragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source does not implement can drop selector", ^{
                
                id dragDataSource = OCMPartialMock([[I3DragDataSourceJustDrop alloc] init]);
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = [[UIView alloc] init];
                
                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);
                
                coordinator.dragDataSource = dragDataSource;
                [collections insertObject:dstCollection atIndex:0];
                
                [[dragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not exchange between and render reset if data source specifies that cell is not exchangeable", ^{
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                id dstCollectionView = OCMPartialMock([[UIView alloc] init]);
                id dstCollectionItemView = OCMPartialMock([[UIView alloc] init]);

                OCMStub([dstCollection collectionView]).andReturn(dstCollectionView);
                OCMStub([dstCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]).andReturn(NO);
                OCMStub([dstCollection itemAtPoint:dropOrigin]).andReturn(dstCollectionItemView);
               
                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:dstCollection];
                
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
                OCMStub([defaultDragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:dstCollection]).andReturn(YES);

                [collections insertObject:dstCollection atIndex:0];
                
                [[defaultDragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:dstCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
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


    describe(@"basic facotry class method", ^{

        it(@"should create a new coodinator", ^{
            
            expect([I3GestureCoordinator basicGestureCoordinatorFromViewController:[[UIViewController alloc] init] withCollections:nil]).to.beInstanceOf([I3GestureCoordinator class]);
            
        });
        
        it(@"should create a new coordinator with a basic drag render delegate", ^{

            I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:[[UIViewController alloc] init] withCollections:nil];

            expect(coordinator.renderDelegate).to.beInstanceOf([I3BasicRenderDelegate class]);
            
        });
        
        it(@"should set the controller as the gesture's data source if it conforms to protocol", ^{
        
            I3DataSourceControllerFixture *controller = [[I3DataSourceControllerFixture alloc] init];
            I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:nil];
            
            expect(coordinator.dragDataSource).to.equal(controller);
            
        });
        
        it(@"should set up arena with the controller's main view as the superview", ^{
        
            UIViewController *controller = [[UIViewController alloc] init];
            I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:nil];
            
            expect(coordinator.arena.superview).to.equal(controller.view);
            
        });
        
        it(@"should set up the arena with collections", ^{
        
            id collection1 = [[I3CollectionFixture alloc] init];
            id collection2 = [[I3CollectionFixture alloc] init];
            id collection3 = [[I3CollectionFixture alloc] init];
            
            UIViewController *controller = [[UIViewController alloc] init];
            I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:@[collection1, collection2, collection3]];
            
            expect([coordinator.arena.collections containsObject:collection1]).to.beTruthy();
            expect([coordinator.arena.collections containsObject:collection2]).to.beTruthy();
            expect([coordinator.arena.collections containsObject:collection3]).to.beTruthy();
        });
        
    });

SpecEnd
