//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3DragDataSourceJustCanDelete.h"
#import "I3DragDataSourceJustDelete.h"
#import "I3DragDataSourceJustCanRearrange.h"
#import "I3DragDataSourceJustRearrange.h"
#import "I3DragDataSourceJustCanDrop.h"
#import "I3DragDataSourceJustDrop.h"
#import "I3CollectionFixture.h"


/// @note We've opted to go for a high redundancy in these tests for the sake of readabillity.
/// That is, there is a large amount of duplicate setup/mocking/stubbing code. We could reduce
/// this code so that the setup / teardown occurs only in one place but in the past that has
/// created too much risk of interdependence between tests. For example, if I set up a mockof the
/// panGestureRecognizer in the root describe block, we may want to stub different methods to return
/// different values under different conditions in subsequent tests. Now the tests are dependent on
/// whether a test before them has stubbed a certain method and whether the mock of tha recognizer
/// has been stopped before it.
///
/// Its cleaner and easier just to re-setup the dependencies locally in each describe block and
/// makes the tests much more readable.

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
        

    describe(@"starting a drag", ^{
        
        
        __block NSMutableOrderedSet *collections;
        __block I3GestureCoordinator *coordinator;
        __block id renderDelegate;
        __block id dragDataSource;
        __block id dragArena;
        __block id superview;
        __block id panGestureRecognizer;

        CGPoint dragOrigin = CGPointMake(10, 10);

        
        beforeEach(^{
            
            superview = OCMPartialMock([[UIView alloc] init]);
            panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
            dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
            collections = [[NSMutableOrderedSet alloc] init];

            renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            coordinator.renderDelegate = renderDelegate;
            coordinator.dragDataSource = dragDataSource;

            OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
            OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dragOrigin);
            OCMStub([dragArena collections]).andReturn(collections);
            
        });
        
        afterEach(^{
            
            collections = nil;
            coordinator = nil;
            renderDelegate = nil;
            dragDataSource = nil;
            dragArena = nil;
            superview = nil;
            panGestureRecognizer = nil;
            
        });
        
        
        it(@"should start and render a drag on a collection if the point is inside its bounds and the item is draggable", ^{
            
            id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
            id collectionView = OCMPartialMock([[UIView alloc] init]);
            
            OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]).andReturn(YES);
            OCMStub([draggingCollection collectionView]).andReturn(collectionView);
            OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
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
            
            /// Configure the draggingDataSource to allow for the given item at the dragOrigin to be
            /// dragged

            OCMStub([draggingCollection collectionView]).andReturn(collectionView);
            OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(YES);
            OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]).andReturn(NO);
            [[dragArena collections] addObject:draggingCollection];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            expect(coordinator.currentDraggingCollection).to.beNil();
            expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
            
            OCMVerify([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:draggingCollection]);
            
        });
        
        it(@"should start and render dragging on the top-most intersecting collection and none underneith", ^{
            
            id topDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
            id bottomDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
            
            id topCollectionView = OCMPartialMock([[UIView alloc] init]);
            
            OCMStub([dragDataSource canItemBeDraggedAtPoint:dragOrigin inCollection:topDraggingCollection]).andReturn(YES);
            OCMStub([topDraggingCollection collectionView]).andReturn(topCollectionView);
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
        
    });


    describe(@"routing a valid stop", ^{

        __block NSMutableOrderedSet *collections;
        __block I3GestureCoordinator *coordinator;
        __block id renderDelegate;
        __block id dragArena;
        __block id superview;
        __block id panGestureRecognizer;
        __block id draggingCollection;
        
        CGPoint dropOrigin = CGPointMake(50, 50);
        CGPoint dragOrigin = CGPointMake(10, 10);
        
        
        beforeEach(^{
            
            superview = OCMPartialMock([[UIView alloc] init]);
            panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
            dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
            collections = [[NSMutableOrderedSet alloc] init];
            renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));
            draggingCollection = OCMProtocolMock(@protocol(I3Collection));
            
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            coordinator.renderDelegate = renderDelegate;
            
            [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
            [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
            [collections addObject:draggingCollection];
            
            OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([dragArena collections]).andReturn(collections);
            
        });
        
        afterEach(^{
            
            collections = nil;
            coordinator = nil;
            renderDelegate = nil;
            dragArena = nil;
            superview = nil;
            panGestureRecognizer = nil;
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

        /// The coorindator and its core dependencies
        
        __block NSMutableOrderedSet *collections;
        __block I3GestureCoordinator *coordinator;
        __block id renderDelegate;
        __block id dragDataSource;
        __block id dragArena;
        __block id superview;
        __block id panGestureRecognizer;
        
        /// The current collection being draged and its collection view
        
        __block id draggingCollection;
        __block id collectionView;

        /// Immutable origin data
        
        CGPoint dropOrigin = CGPointMake(50, 50);
        CGPoint dragOrigin = CGPointMake(10, 10);

    
        beforeEach(^{

            /// Initialise the coordinator and all of its core dependencies
            
            superview = OCMPartialMock([[UIView alloc] init]);
            panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
            dragArena = OCMPartialMock([[I3DragArena alloc] initWithSuperview:superview containingCollections:nil]);
            collections = [[NSMutableOrderedSet alloc] init];
            
            renderDelegate = OCMProtocolMock(@protocol(I3DragRenderDelegate));
            dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            coordinator.renderDelegate = renderDelegate;
            coordinator.dragDataSource = dragDataSource;
            
            
            /// Here we set up the coordinator as if its already executed a successful drag start
            /// and holds a reference to a dragging collection.
            /// @note that this setup is almost identical to how we setup the coordinator in most of
            /// the drag start tests
            
            draggingCollection = OCMPartialMock([[I3CollectionFixture alloc] init]);
            collectionView = OCMPartialMock([[UIView alloc] init]);
            
            [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
            [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
            [collections addObject:draggingCollection];
            
            OCMStub([draggingCollection collectionView]).andReturn(collectionView);
            //OCMStub([panGestureRecognizer locationInView:collectionView]).andReturn(dropOrigin);
            OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
            OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);
            OCMStub([dragArena collections]).andReturn(collections);

        });
        
        afterEach(^{
            
            collections = nil;
            coordinator = nil;
            renderDelegate = nil;
            dragDataSource = nil;
            dragArena = nil;
            superview = nil;
            panGestureRecognizer = nil;
            draggingCollection = nil;
            collectionView = nil;
            
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
            
            id topCollection = OCMPartialMock([[I3CollectionFixture alloc] init]);
            id topCollectionView = OCMPartialMock([[UIView alloc] init]);
            
            [collections insertObjects:@[topCollection, bottomCollection] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
            
            OCMStub([bottomCollection collectionView]).andReturn(bottomCollectionView);
            OCMStub([topCollection collectionView]).andReturn(topCollectionView);
            
            /// Set both of the new dragging views to respond positively to the drop in the data source and their
            /// collection views. @note the new change in the way data sources are dealt with (there is 1 data source
            /// now)
            
            OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:bottomCollection]).andReturn(YES);
            OCMStub([dragDataSource canItemAtPoint:dragOrigin fromCollection:draggingCollection beDroppedToPoint:dropOrigin inCollection:topCollection]).andReturn(YES);
            OCMStub([bottomCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
            OCMStub([topCollectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
            
            [[dragDataSource reject] dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:bottomCollection];
            [[renderDelegate reject] renderDropOnCollection:bottomCollection atPoint:dropOrigin fromCoordinator:coordinator];
            
            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([dragDataSource dropItemAtPoint:dragOrigin fromCollection:draggingCollection toPoint:dropOrigin inCollection:topCollection]);
            OCMVerify([renderDelegate renderDropOnCollection:topCollection atPoint:dropOrigin fromCoordinator:coordinator]);
            
        });

    });


    /*

    describe(@"stopping an invalid drag", ^{

     
    });

    describe(@"drag/drop coordination", ^{
        
        describe(@"stopping a drag", ^{

            /// Here we set up the coordinator as if its already executed a successful drag start
            /// and holds a reference to a dragging collection.
            /// @note that this setup is almost identical to how we setup the coordinator in most of
            /// the drag start tests
            
            __block id draggingCollection;
            __block id draggingDataSource;
            __block id collectionView;
            
            CGPoint dropOrigin = CGPointMake(50, 50);
            
            beforeEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                draggingDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
                collectionView = OCMPartialMock([[UIView alloc] init]);
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:dragOrigin] forKey:@"_currentDragOrigin"];
                [collections addObject:draggingCollection];

                OCMStub([panGestureRecognizer locationInView:collectionView]).andReturn(dropOrigin);
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(dropOrigin);

            });

            afterEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                draggingDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
                collectionView = OCMPartialMock([[UIView alloc] init]);
            
            });
            
            it(@"should do handle drops for all appropriate states", ^{
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateFailed);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateCancelled);
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
     
            it(@"should not delete and render reset if data source does not implement can delete selector", ^{

                id dragSource = OCMClassMock([I3DragDataSourceJustDelete class]);
                
                OCMStub([collectionView pointInside:dragOrigin withEvent:nil]).andReturn(NO);
                /// @note Re-stubbing method
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                
                [[dragSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should not delete and render reset if data source does not implement delete selector", ^{

                id dragSource = OCMClassMock([I3DragDataSourceJustCanDelete class]);
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                /// @note Re-stubbing method
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                OCMStub([dragSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);
                
                [[dragSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should not delete and render reset if the item in the data source is not deleteable", ^{
            
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([draggingDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(NO);
                
                [[draggingDataSource reject] deleteItemAtPoint:dragOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should delete item if its deleteable under the data source", ^{
            
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(NO);
                OCMStub([draggingDataSource canItemAtPoint:dragOrigin beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:dropOrigin]).andReturn(YES);

                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource deleteItemAtPoint:dragOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderDeletionAtPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);

                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderRearrangeOnPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if the data source does not implement can rearrange", ^{

                id dragSource = OCMClassMock([I3DragDataSourceJustRearrange class]);
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                /// @note Re-stubbed method
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                
                [[dragSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should not rearrange and render reset if the data source does not implement rearrange method", ^{
            
                id dragSource = OCMClassMock([I3DragDataSourceJustCanRearrange class]);

                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                /// @note Re-stubbed method
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                OCMStub([dragSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                
                [[dragSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should not rearrange and render reset if the data source specifies the items as un-rearrangeable", ^{

                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(NO);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);

            });
            
            it(@"should not rearrange and render reset if we're dropping on the same item in the collection", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);
                
                UIView *commonCollectionItem = [[UIView alloc] init];
                
                OCMStub([draggingCollection itemAtPoint:dragOrigin]).andReturn(commonCollectionItem);
                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(commonCollectionItem);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection itemAtPoint:dragOrigin]);
                OCMVerify([draggingCollection itemAtPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
            
            it(@"should not rearrange and render reset if we're dropping on an invalid location in the collection", ^{
                
                OCMStub([collectionView pointInside:dropOrigin withEvent:nil]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:dragOrigin beRearrangedWithItemAtPoint:dropOrigin inCollection:draggingCollection]).andReturn(YES);

                OCMStub([draggingCollection itemAtPoint:dropOrigin]).andReturn(nil);
                //OCMStub([draggingCollection itemAtPoint:dragOrigin]).andReturn([[UIView alloc] init]);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:dragOrigin withItemAtPoint:dropOrigin inCollection:draggingCollection];
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection itemAtPoint:dropOrigin]);
                OCMVerify([renderDelegate renderResetFromPoint:dropOrigin fromCoordinator:coordinator]);
                
            });
        });
        
        
            it(@"should exchange between collections if we're drag/dropping between different collections and data source allows", ^{
            
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                OCMStub([dstCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                [collections insertObject:dstCollection atIndex:0];
                
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource canItemAtPoint:touchPoint fromCollection:draggingCollection beDroppedToPoint:touchPoint inCollection:dstCollection]).andReturn(YES);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource canItemAtPoint:touchPoint fromCollection:draggingCollection beDroppedToPoint:touchPoint inCollection:dstCollection]);
                OCMVerify([draggingDataSource dropItemAtPoint:touchPoint fromCollection:draggingCollection toPoint:touchPoint inCollection:dstCollection]);
                OCMVerify([renderDelegate renderDropOnCollection:dstCollection atPoint:touchPoint fromCoordinator:coordinator]);

            });
            
            it(@"should not exchange between and render reset if data source does not implement drop selector", ^{

                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                OCMStub([dstCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                [collections insertObject:dstCollection atIndex:0];
                
                id dragSource = OCMClassMock([I3DragDataSourceJustCanDrop class]);
                OCMStub([dragSource canItemAtPoint:touchPoint fromCollection:draggingCollection beDroppedToPoint:touchPoint inCollection:dstCollection]).andReturn(YES);
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                
                [[draggingDataSource reject] dropItemAtPoint:touchPoint fromCollection:draggingCollection toPoint:touchPoint inCollection:dstCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                OCMVerify([renderDelegate renderResetFromPoint:touchPoint fromCoordinator:coordinator]);

            });
            
            it(@"should not exchange between and render reset if data source does not implement can drop selector", ^{

                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                OCMStub([dstCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                [collections insertObject:dstCollection atIndex:0];
                
                id dragSource = OCMClassMock([I3DragDataSourceJustDrop class]);
                OCMStub([draggingCollection dragDataSource]).andReturn(dragSource);
                
                [[draggingDataSource reject] dropItemAtPoint:touchPoint fromCollection:draggingCollection toPoint:touchPoint inCollection:dstCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([renderDelegate renderResetFromPoint:touchPoint fromCoordinator:coordinator]);

            });
            
            it(@"should not exchange between and render reset if data source specifies that cell is not exchangeable", ^{
                
                id dstCollection = OCMProtocolMock(@protocol(I3Collection));
                OCMStub([dstCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                [collections insertObject:dstCollection atIndex:0];
                
                OCMStub([draggingDataSource canItemAtPoint:touchPoint fromCollection:draggingCollection beDroppedToPoint:touchPoint inCollection:dstCollection]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                
                [[draggingDataSource reject] dropItemAtPoint:touchPoint fromCollection:draggingCollection toPoint:touchPoint inCollection:dstCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([renderDelegate renderResetFromPoint:touchPoint fromCoordinator:coordinator]);

            });
            
            it(@"should not exchange and render reset if we're dropping on an invalid location in the dst collection", ^{
                
                expect(NO).to.beTruthy;
                /// @todo ...
            });
            
        });
        
        
        /// @note This describes different behaviour of the above describe block in that it
        /// it defines how the gesture should respond to the stopping of a drag that was never
        /// started in a valid state. This might occur, for example, if we drag from an empty area
        /// in a collection.
        
        describe(@"stopping a pan gesture", ^{
            
            it(@"should do nothing if no collection is currently being dragged", ^{
                
                [[renderDelegate reject] renderResetFromPoint:dragOrigin fromCoordinator:coordinator];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
            });
            
        });

        describe(@"dragging", ^{
            
            it(@"should do nothing if no collection is current being dragged", ^{
                
                [[renderDelegate reject] renderDraggingFromCoordinator:coordinator];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
            });
            
            it(@"should render dragging", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:touchPoint] forKey:@"_currentDragOrigin"];
                
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateChanged);
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([renderDelegate renderDraggingFromCoordinator:coordinator]);
                
            });
            
        });
        
    });*/

SpecEnd
