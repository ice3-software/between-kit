//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>
#import "I3DataSourceControllerFixture.h"
#import "I3CollectionFixture.h"


SpecBegin(I3GestureCoordinator)


    describe(@"ctor", ^{

        it(@"should inject dependencies", ^{
        
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            I3DragArena *dragArena = [[I3DragArena alloc] init];
            
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect(coordinator.gestureRecognizer).to.equal(panGestureRecognizer);
            expect(coordinator.arena).to.equal(dragArena);
        
        });
    
        it(@"should create a UIPanGestureRecognizer by default", ^{
        
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:[[I3DragArena alloc] init] withGestureRecognizer:nil];
            expect(coordinator.gestureRecognizer).to.beInstanceOf([UIPanGestureRecognizer class]);
            
        });
        
        it(@"should setup the gesture recognizer's target and superview correctly", ^{
        
            UIPanGestureRecognizer *panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
            UIView *superview = OCMClassMock([UIView class]);
            I3DragArena *dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];
            
            I3GestureCoordinator *coordinator = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            OCMVerify([panGestureRecognizer addTarget:coordinator action:[OCMArg anySelector]]);
            OCMVerify([superview addGestureRecognizer:panGestureRecognizer]);
            
        });
        
        it(@"should not attach the gesture recognizer to the superview if its already attached", ^{

            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            UIView *superview = [[UIView alloc] init];
            I3DragArena *dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];

            [superview addGestureRecognizer:panGestureRecognizer];
            
            I3GestureCoordinator *coordinator __unused = [[I3GestureCoordinator alloc] initWithDragArena:dragArena withGestureRecognizer:panGestureRecognizer];
            
            expect([superview gestureRecognizers]).to.haveCountOf(1);

        });

    });


    describe(@"dtor", ^{
        

        __block id panGestureRecognizer;
        __block id superview;
        __block I3DragArena *dragArena;

        
        beforeEach(^{
            
            panGestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
            superview = OCMPartialMock([[UIView alloc] init]);
            dragArena = [[I3DragArena alloc] initWithSuperview:superview containingCollections:nil];
        
        });
        
        afterEach(^{
        
            panGestureRecognizer = nil;
            superview = nil;
            dragArena = nil;
        
        });
        
        
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


    describe(@"basic factory method with gesture", ^{
        
        /// @note All this data is immutable. We don't need to wrap it in a beforeEach block
        
        I3DataSourceControllerFixture* controller = [[I3DataSourceControllerFixture alloc] init];
        I3CollectionFixture *collection1 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection2 = [[I3CollectionFixture alloc] init];
        I3CollectionFixture *collection3 = [[I3CollectionFixture alloc] init];
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] init];
        I3GestureCoordinator *coordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:controller withCollections:@[collection1, collection2, collection3] withRecognizer:recognizer];
        
        
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
            
            expect([[coordinator arena].collections containsObject:collection1]).to.beTruthy();
            expect([[coordinator arena].collections containsObject:collection2]).to.beTruthy();
            expect([[coordinator arena].collections containsObject:collection3]).to.beTruthy();
        
        });
        
        it(@"should initialise the coordinator with a long press gesture recognizer", ^{
        
            expect(coordinator.gestureRecognizer).to.equal(recognizer);
        
        });

    });


SpecEnd
