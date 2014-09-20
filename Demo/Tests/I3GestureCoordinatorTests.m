//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>


SpecBegin(I3GestureCoordinator)

    __block NSMutableOrderedSet *collections;
    __block id dragArena;
    __block id superview;
    __block id panGestureRecognizer;


    beforeEach(^{
    
        dragArena = OCMClassMock([I3DragArena class]);
        superview = OCMClassMock([UIView class]);
        panGestureRecognizer = OCMPartialMock([[UIPanGestureRecognizer alloc] init]);
        collections = [[NSMutableOrderedSet alloc] init];
        
        OCMStub([dragArena superview]).andReturn(superview);
        OCMStub([dragArena collections]).andReturn(collections);
        
    });

    afterEach(^{
        
        dragArena = nil;
        superview = nil;
        panGestureRecognizer = nil;
        collections = nil;
    
    });


    describe(@"constructor", ^{
        
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

            [[superview reject] addGestureRecognizer:[OCMArg any]];
            OCMStub([superview gestureRecognizers]).andReturn(@[panGestureRecognizer]);
            I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];

        });
        
    });


    describe(@"destructor", ^{

    
        /** @note Here we use pragma to ignore warnings about weak variables being assigned and
         then released immediately after as this is exactly what we are trying to achieve. In
         order for 'dealloc' to be triggered under ARC we must invoke the ctor by creating a
         weak reference that will unasigned immediately. */
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
        
        
        it(@"should unbind gesture recognizer from coordinator and superview", ^{
            
            OCMStub([superview gestureRecognizers]).andReturn(@[panGestureRecognizer]);
            
            __weak I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            OCMVerify([panGestureRecognizer removeTarget:[OCMArg any] action:NULL]);
            OCMVerify([superview removeGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attempt to remove gesture recognizer from superview if it is no longer present", ^{
            
            [[superview reject] removeGestureRecognizer:panGestureRecognizer];
            OCMStub([superview gestureRecognizers]).andReturn(@[]);
            
            __weak I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            OCMVerifyAll(superview);
            
        });
        
#pragma clang diagnostic pop
        
    });


    describe(@"drag/drop coordination", ^{

        
        __block I3GestureCoordinator *coordinator;
        __block id collectionView;
        __block id draggingDataSource;

        CGPoint touchPoint = CGPointMake(10, 10);

        
        beforeEach(^{
            
            coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            collectionView = OCMClassMock([UIView class]);
            draggingDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
            
            OCMStub([panGestureRecognizer locationInView:[OCMArg any]]).andReturn(touchPoint);
            
        });
        
        afterEach(^{
            
            coordinator = nil;
            collectionView = nil;
            draggingDataSource = nil;
            
        });

        
        describe(@"starting a drag", ^{

            beforeEach(^{
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateBegan);
            });

            it(@"should start drag on a collection in the arena if the point is inside its bounds and the item is draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:draggingCollection]).andReturn(YES);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObject:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(draggingCollection);
                expect(coordinator.currentDragOrigin).to.equal(touchPoint);
                
                OCMVerify([draggingCollection dragDataSource]);
                OCMVerify([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:draggingCollection]);
                
            });
            
            it(@"should assume that a collection is completely un-draggable if there is no data source", ^{
                
                id undraggableCollection = OCMProtocolMock(@protocol(I3Collection));
                
                OCMStub([undraggableCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObject:undraggableCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerify([undraggableCollection dragDataSource]);
                
            });
            
            it(@"should not start dragging an item in a collection that is not draggable", ^{
                
                id draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                OCMStub([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:draggingCollection]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObject:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerify([draggingCollection dragDataSource]);
                OCMVerify([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:draggingCollection]);

            });
            
            it(@"should start dragging on the top-most intersecting collection and none underneith", ^{
                
                id topDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                id bottomDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                OCMStub([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:topDraggingCollection]).andReturn(YES);
                OCMStub([topDraggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([topDraggingCollection collectionView]).andReturn(collectionView);
                
                [[draggingDataSource reject] canItemBeDraggedAtPoint:touchPoint inCollection:bottomDraggingCollection];
                [[bottomDraggingCollection reject] dragDataSource];
                [[bottomDraggingCollection reject] collectionView];
                
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                
                [[dragArena collections] addObjectsFromArray:@[topDraggingCollection, bottomDraggingCollection]];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.equal(topDraggingCollection);
                
                OCMVerify([topDraggingCollection dragDataSource]);
                OCMVerify([draggingDataSource canItemBeDraggedAtPoint:touchPoint inCollection:topDraggingCollection]);

            });
            
            it(@"should not start dragging or call the data source if the point is outside of the collection view", ^{
                
                id collection = OCMProtocolMock(@protocol(I3Collection));
                
                [[draggingDataSource reject] canItemBeDraggedAtPoint:touchPoint inCollection:collection];
                [[collection reject] dragDataSource];
                
                OCMStub([collection collectionView]).andReturn(collectionView);
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                
                [[dragArena collections] addObject:collection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);
                
                OCMVerifyAll(collection);

            });
            
        });
        
        
        describe(@"stopping a drag", ^{

            __block id draggingCollection;
            
            beforeEach(^{
                
                draggingCollection = OCMProtocolMock(@protocol(I3Collection));
                
                [coordinator setValue:draggingCollection forKey:@"_currentDraggingCollection"];
                [coordinator setValue:[NSValue valueWithCGPoint:touchPoint] forKey:@"_currentDragOrigin"];
                [collections addObject:draggingCollection];

                OCMStub([draggingCollection collectionView]).andReturn(collectionView);
                OCMStub([panGestureRecognizer state]).andReturn(UIGestureRecognizerStateEnded);
                
            });

            afterEach(^{
                
                draggingCollection = nil;
                
            });
            
            
            it(@"should do handle drags for all appropriate gesture states", ^{
                /// @todo Test that all UIGestureRecognizerState(Ended | Cancelled | Failed) are recognized
            });
            
            it(@"should do nothing if no collection is current being dragged", ^{
                /// @todo Not sure how to implement this test yet
            });
            
            it(@"should reset the state of the drag if there was no valid destination", ^{
                
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                expect(coordinator.currentDraggingCollection).to.beNil();
                expect(coordinator.currentDragOrigin).to.equal(CGPointZero);

            });
            
            it(@"should delegate the drop to the top-most intersecting collection and none underneith", ^{

                id collectionUnderneither = OCMProtocolMock(@protocol(I3Collection));
                [collections addObject:collectionUnderneither];
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);

                [[collectionUnderneither reject] collectionView];
                [coordinator handlePan:coordinator.gestureRecognizer];

            });
            
            it(@"should not delete if collection dropped outside but there is no data source", ^{
                
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]);
                
                [[draggingDataSource reject] deleteItemAtPoint:touchPoint inCollection:[OCMArg any]];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingCollection dragDataSource]);
                
            });
            
            it(@"should not delete if data source does not implement can delete", ^{

                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:@selector(canItemAtPoint:beDeletedIfDroppedOutsideOfCollection:atPoint:)]).andReturn(NO);
                
                [[draggingDataSource reject] deleteItemAtPoint:touchPoint inCollection:[OCMArg any]];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource respondsToSelector:@selector(canItemAtPoint:beDeletedIfDroppedOutsideOfCollection:atPoint:)]);

            });
            
            it(@"should not delete if data source does not implement delete selector", ^{

                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:@selector(canItemAtPoint:beDeletedIfDroppedOutsideOfCollection:atPoint:)]).andReturn(YES);
                OCMStub([draggingDataSource respondsToSelector:@selector(deleteItemAtPoint:inCollection:)]).andReturn(NO);
                
                [[draggingDataSource reject] deleteItemAtPoint:touchPoint inCollection:[OCMArg any]];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource respondsToSelector:@selector(deleteItemAtPoint:inCollection:)]);

            });
            
            it(@"should not delete if the item in the data source is not deleteable", ^{
            
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:[OCMArg anySelector]]).andReturn(YES);
                OCMStub([draggingDataSource canItemAtPoint:touchPoint beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:touchPoint]).andReturn(NO);
                
                [[draggingDataSource reject] deleteItemAtPoint:touchPoint inCollection:[OCMArg any]];
                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource canItemAtPoint:touchPoint beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:touchPoint]);

            });
            
            it(@"should delete item if the its deleteable under the data source", ^{
            
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(NO);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:[OCMArg anySelector]]).andReturn(YES);
                OCMStub([draggingDataSource canItemAtPoint:touchPoint beDeletedIfDroppedOutsideOfCollection:draggingCollection atPoint:touchPoint]).andReturn(YES);

                [coordinator handlePan:coordinator.gestureRecognizer];

                OCMVerify([draggingDataSource deleteItemAtPoint:touchPoint inCollection:draggingCollection]);

            });
            
            it(@"should rearranging if we're drag/dropping on the same collection and the data source allows", ^{
                
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:[OCMArg anySelector]]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:touchPoint beRearrangedWithItemAtPoint:touchPoint inCollection:draggingCollection]).andReturn(YES);

                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource rearrangeItemAtPoint:touchPoint withItemAtPoint:touchPoint inCollection:draggingCollection]);
                OCMVerify([draggingDataSource canItemFromPoint:touchPoint beRearrangedWithItemAtPoint:touchPoint inCollection:draggingCollection]);

            });
            
            it(@"should not rearrange if there is no data source", ^{
                
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);

                [[draggingDataSource reject] rearrangeItemAtPoint:touchPoint withItemAtPoint:touchPoint inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingCollection dragDataSource]);
            
            });
            
            it(@"should not rearrange if the data source does not implement can rearrange", ^{

                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)]).andReturn(NO);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:touchPoint withItemAtPoint:touchPoint inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)]);

            });
            
            it(@"should not rearrange if the data source does not implement rearrange method", ^{
            
                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:@selector(canItemFromPoint:beRearrangedWithItemAtPoint:inCollection:)]).andReturn(YES);
                OCMStub([draggingDataSource respondsToSelector:@selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:)]).andReturn(NO);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:touchPoint withItemAtPoint:touchPoint inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource respondsToSelector:@selector(rearrangeItemAtPoint:withItemAtPoint:inCollection:)]);
                
            });
            
            it(@"should not rearrange if the data source specifies the items as un-rearrangeable", ^{

                OCMStub([collectionView pointInside:touchPoint withEvent:nil]).andReturn(YES);
                OCMStub([draggingCollection dragDataSource]).andReturn(draggingDataSource);
                OCMStub([draggingDataSource respondsToSelector:[OCMArg anySelector]]).andReturn(YES);
                OCMStub([draggingDataSource canItemFromPoint:touchPoint beRearrangedWithItemAtPoint:touchPoint inCollection:draggingCollection]).andReturn(NO);
                
                [[draggingDataSource reject] rearrangeItemAtPoint:touchPoint withItemAtPoint:touchPoint inCollection:draggingCollection];
                [coordinator handlePan:coordinator.gestureRecognizer];
                
                OCMVerify([draggingDataSource canItemFromPoint:touchPoint beRearrangedWithItemAtPoint:touchPoint inCollection:draggingCollection]);
            
            });
            
            it(@"should exchange between collections and not rearrange if we're not drag/dropping on the same collection and the data source allows", ^{
            });
            
            /// @todo Test all the different outcomes to the above based on the different possible
            /// data source implementations
            
        });
        
        
        describe(@"dragging", ^{
            
            it(@"should do nothing if no collection is current being dragged", ^{
                /// @todo Not sure how to implement this test yet
            });
            
        });

    });


SpecEnd
