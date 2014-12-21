//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3BasicRenderDelegate.h>
#import <BetweenKit/I3CloneView.h>
#import "I3CollectionFixture.h"
#import "I3CoordinatorCreationMethods.h"


SpecBegin(I3BasicRenderDelegate)

        
    __block I3BasicRenderDelegate *renderDelegate;
    __block I3GestureCoordinator *coordinator;
    __block id dragDataSource;
    
    
    beforeEach(^{
        
        renderDelegate = [[I3BasicRenderDelegate alloc] init];
        dragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
        
        /// @todo Better setup method
        
        coordinator = I3GestureCoordinatorSetupDraggingMock(dragDataSource);
        coordinator.renderDelegate = renderDelegate;
        
    });
    
    afterEach(^{
        
        renderDelegate = nil;
        coordinator = nil;
        dragDataSource = nil;
        
    });
    
    
    describe(@"ctor", ^{
    
        it(@"should initialise draggingItemOpacity to 0.01", ^{
            expect(renderDelegate.draggingItemOpacity).to.equal(0.01);
        });
    
        it(@"should initialise the draggingViewOpacity to 1", ^{
            expect(renderDelegate.draggingViewOpacity).to.equal(1);
        });
        
    });
    
    
    describe(@"begin drag", ^{

        it(@"should construct a dragging view from an item in the dragging collection on start", ^{
            
            [renderDelegate renderDragStart:coordinator];
            
            expect(renderDelegate.draggingView).to.beInstanceOf([I3CloneView class]);
            expect([[coordinator.arena.superview subviews] containsObject:renderDelegate.draggingView]).to.beTruthy();
            
        });

        it(@"should clone the source view into the dragging view straight away", ^{
        
            [renderDelegate renderDragStart:coordinator];
            
            NSLog(@"DraggingView source image is %@", renderDelegate.draggingView.sourceViewImage);
            
            expect(renderDelegate.draggingView.sourceViewImage).notTo.beNil();
            expect(renderDelegate.draggingView.sourceView).to.beNil();

        });
        
        it(@"should set the original item's opacity to draggingItemOpacity", ^{

            renderDelegate.draggingItemOpacity = 0.5f;
            [renderDelegate renderDragStart:coordinator];
            
            expect(coordinator.currentDraggingItem.alpha).to.equal(0.5f);
            
        });
        
        it(@"should set the cloned draggingView to draggingViewOpacity", ^{
            
            renderDelegate.draggingViewOpacity = 0.3f;
            [renderDelegate renderDragStart:coordinator];
            
            expect(renderDelegate.draggingView.alpha).to.equal(0.3f);
            
        });
        
        /// @note that this could be a shared behaviour...
        
        it(@"should animate the dragging view to the initial gesture location", ^{
            
            I3CollectionFixture *collectionView = (I3CollectionFixture *)coordinator.currentDraggingCollection;
            UIView *superview = coordinator.arena.superview;
            UIView *draggingItem = coordinator.currentDraggingItem;
            
            CGPoint translation = CGPointMake(5, 5);
            CGRect convertedRect = CGRectMake(10, 10, 20, 20);

            id uiViewMock = OCMClassMock([UIView class]);
            
            OCMStub([coordinator.gestureRecognizer locationInView:superview]).andReturn(translation);
            OCMStub([superview convertRect:draggingItem.frame fromView:collectionView]).andReturn(convertedRect);

            OCMStub([uiViewMock animateWithDuration:0.5 animations:[OCMArg any]]).andDo(^(NSInvocation *invocation){
                
                expect(renderDelegate.draggingView.frame).to.equal(convertedRect);
                
                void (^animateBlock)();
                [invocation getArgument:&animateBlock atIndex:3];
                animateBlock();
                
                expect(renderDelegate.draggingView.center).to.equal(translation);
                
            });
            
            [renderDelegate renderDragStart:coordinator];
            
            OCMVerify([uiViewMock animateWithDuration:0.05 animations:[OCMArg any]]);
            [uiViewMock stopMocking];
            
        });

    });


    describe(@"dragging", ^{
    
        it(@"should animate the current dragging view to the gesture location", ^{

            CGPoint translation = CGPointMake(5, 5);
            [renderDelegate renderDragStart:coordinator];
            [renderDelegate.draggingView setCenter:CGPointMake(50, 50)];

            id uiViewMock = OCMClassMock([UIView class]);

            OCMStub([coordinator.gestureRecognizer locationInView:coordinator.arena.superview]).andReturn(translation);
            OCMStub([uiViewMock animateWithDuration:0.5 animations:[OCMArg any]]).andDo(^(NSInvocation *invocation){
                
                void (^animateBlock)();
                [invocation getArgument:&animateBlock atIndex:3];
                
                animateBlock();
                
                expect(renderDelegate.draggingView.center).to.equal(translation);
                
            });
            
            [renderDelegate renderDraggingFromCoordinator:coordinator];
            
            OCMVerify([uiViewMock animateWithDuration:0.05 animations:[OCMArg any]]);
            [uiViewMock stopMocking];

        });
    
    });


    describe(@"reset from point", ^{

        it(@"should release strong reference to the dragging view, whilst animating it back to the origin in an async animation", ^{
            
            [renderDelegate renderDragStart:coordinator];
            
            I3CollectionFixture *collectionView = (I3CollectionFixture *)coordinator.currentDraggingCollection;
            UIView *draggingItem = coordinator.currentDraggingItem;
            UIView *draggingView = renderDelegate.draggingView;
            UIView *superview = coordinator.arena.superview;
            
            CGPoint resetPoint = CGPointMake(25, 25);
            CGRect resetRect = CGRectMake(0, 0, 100, 100);
            double duration = 0.15;
            
            OCMStub([superview convertRect:draggingItem.frame fromView:collectionView]).andReturn(resetRect);
            
            id uiViewMock = OCMClassMock([UIView class]);

            OCMStub([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
                
                void (^animateBlock)();
                void (^completionBlock)();
                
                [invocation getArgument:&animateBlock atIndex:3];
                [invocation getArgument:&completionBlock atIndex:4];
                
                animateBlock();
                completionBlock();

                expect(draggingView.frame).to.equal(resetRect);
                expect(draggingView.superview).to.beNil();
                expect(draggingItem.alpha).to.equal(1);

            });
            
            [renderDelegate renderResetFromPoint:resetPoint fromCoordinator:coordinator];
            
            expect(renderDelegate.draggingView).to.beNil();
            OCMVerify([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]);
            
            [uiViewMock stopMocking];
            
        });
        
    });

    
    describe(@"drop", ^{
        
        beforeEach(^{
            
            [renderDelegate renderDragStart:coordinator];
            
        });
        
        it(@"should release reference to dragging view and remove it from superview on drop on collection", ^{
            
            id dstCollection = [[I3CollectionFixture alloc] init];
            
            [renderDelegate renderDropOnCollection:dstCollection atPoint:CGPointMake(0, 0) fromCoordinator:coordinator];
            
            expect([[coordinator.arena.superview subviews] containsObject:renderDelegate.draggingView]).to.beFalsy();
            expect(renderDelegate.draggingView).to.beNil();
            
        });
        
        it(@"should re-show the hidden item in the collection", ^{
            
            id dstCollection = [[I3CollectionFixture alloc] init];
            UIView *draggingItem = coordinator.currentDraggingItem;
            
            draggingItem.alpha = 0.3;
            
            [renderDelegate renderDropOnCollection:dstCollection atPoint:CGPointMake(0, 0) fromCoordinator:coordinator];
            
            expect(draggingItem.alpha).to.equal(1);
            
        });
        
    });


    describe(@"rearrange", ^{
    
        it(@"should animate an rearrange between the dragging view and the destination item", ^{
        
            [renderDelegate renderDragStart:coordinator];
            
            I3CollectionFixture *currentDraggingCollection = (I3CollectionFixture *)coordinator.currentDraggingCollection;
            UIView *superview = coordinator.arena.superview;
            UIView *draggingItem = coordinator.currentDraggingItem;
            I3CloneView *draggingView = renderDelegate.draggingView;

            
            /// @note that these rect dimensions are really meaningless, that is, their only requirements is
            /// that they are different so that OCMStub can tell the different between the different invokations
            /// of `convertRect:fromView:`

            CGRect exchangeItemSuperRect = CGRectMake(0, 0, 100, 100);
            CGRect draggingItemSuperRect = CGRectMake(0, 100, 100, 100);
            CGPoint rearrangePoint = CGPointMake(50, 50);

            NSIndexPath *rearrangeIndex = [currentDraggingCollection mockItemAtPoint:rearrangePoint];
            UIView *exchangeItem = [currentDraggingCollection itemAtIndexPath:rearrangeIndex];
            
            
            exchangeItem.frame = CGRectMake(1, 1, 99, 99);
            draggingItem.frame = CGRectMake(2, 2, 88, 88);
            
            double duration = 0.15;
            id uiViewMock = OCMClassMock([UIView class]);

            OCMStub([superview convertRect:exchangeItem.frame fromView:currentDraggingCollection]).andReturn(exchangeItemSuperRect);
            OCMStub([superview convertRect:draggingItem.frame fromView:currentDraggingCollection]).andReturn(draggingItemSuperRect);

            OCMStub([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
                
                void (^animateBlock)();
                void (^completionBlock)();
                
                [invocation getArgument:&animateBlock atIndex:3];
                [invocation getArgument:&completionBlock atIndex:4];
                
                animateBlock();
                
                /// Here we need to map the array of subviews to an array of _just_ the cloned views. We
                /// do this by filtering in the array using a predicate that checks against the class type
                /// This is so that we can then deduce the cloned exchanging view.
                
                NSPredicate *clonedViewPredicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject] rightExpression:[NSExpression expressionForConstantValue:[I3CloneView class]] customSelector:@selector(isMemberOfClass:)];
                NSArray *clonedViews = [[superview subviews] filteredArrayUsingPredicate:clonedViewPredicate];
                
                /// As we've constructed the superview, it should be guarenteed that it only has 2 I3ClonedView
                /// subviews. Note that in a real-world scenario this may not be the case: a user of the framework
                /// may add an I3ClonedView to the superview themselves, so this is not a robust assertion to
                /// make elsewhere.
                
                expect(clonedViews.count).to.equal(2);
                
                I3CloneView *firstClonedView = [clonedViews firstObject];
                I3CloneView *exchangeView = firstClonedView.sourceView == draggingItem ? clonedViews.lastObject : firstClonedView;
                
                expect(exchangeView.sourceViewImage).notTo.beNil();
                expect(exchangeView.center).to.equal(CGPointMake(CGRectGetMidX(draggingItemSuperRect), CGRectGetMidY(draggingItemSuperRect)));
                expect(draggingView.center).to.equal(CGPointMake(CGRectGetMidX(exchangeItemSuperRect), CGRectGetMidY(exchangeItemSuperRect)));
                expect([exchangeView.superview isEqual:superview]).to.beTruthy;
                
                completionBlock();
                
                expect(exchangeView.superview).to.beNil();
                expect(draggingView.superview).to.beNil();
                
            });
            
            [renderDelegate renderRearrangeOnPoint:rearrangePoint fromCoordinator:coordinator];
            
            expect(renderDelegate.draggingView).to.beNil();
            OCMVerify([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]);
            
            [uiViewMock stopMocking];

        });

        it(@"should just destroy dragging view if rearrangeIsExchange is NO", ^{
        
            CGPoint rearrangePoint = CGPointMake(50, 50);
            
            renderDelegate.rearrangeIsExchange = NO;
            
            [renderDelegate renderDragStart:coordinator];
            [renderDelegate renderRearrangeOnPoint:rearrangePoint fromCoordinator:coordinator];
            
            expect([[coordinator.arena.superview subviews] containsObject:renderDelegate.draggingView]).to.beFalsy();
            expect(renderDelegate.draggingView).to.beNil();

        });
        
    });


    describe(@"delete", ^{
        
        it(@"should apply a 'shrinking' animation to the dragging view", ^{
            
            [renderDelegate renderDragStart:coordinator];
            I3CloneView *draggingView = renderDelegate.draggingView;
            
            CGFloat midX = CGRectGetMidX(draggingView.frame);
            CGFloat midY = CGRectGetMidY(draggingView.frame);
            CGRect shrunkFrame = CGRectMake(midX, midY, 0, 0);
            
            double duration = 0.15;
            id uiViewMock = OCMClassMock([UIView class]);
            
            OCMStub([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation){

                void (^animateBlock)();
                void (^completionBlock)();
                
                [invocation getArgument:&animateBlock atIndex:3];
                [invocation getArgument:&completionBlock atIndex:4];
                
                animateBlock();
                
                expect(draggingView.frame).to.equal(shrunkFrame);
                
                completionBlock();
                
                expect(draggingView.superview).to.beNil();
                
            });
            
            [renderDelegate renderDeletionAtPoint:coordinator.currentDragOrigin fromCoordinator:coordinator];

            expect(renderDelegate.draggingView).to.beNil();
            OCMVerify([uiViewMock animateWithDuration:duration animations:[OCMArg any] completion:[OCMArg any]]);
            
            [uiViewMock stopMocking];
            
        });
        
    });


SpecEnd
