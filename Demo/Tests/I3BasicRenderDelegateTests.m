//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3BasicRenderDelegate.h>
#import <BetweenKit/I3CloneView.h>


SpecBegin(I3BasicRenderDelegate)


    __block I3BasicRenderDelegate *renderDelegate;
    __block UIView *superview;
    __block id coordinator;
    __block id arena;
    __block id gestureRecognizer;
    __block id currentDraggingCollection;
    __block id currentDragDataSource;
    __block UIView *draggingItem;
    __block UIView *collectionView;
    CGPoint touchPoint = CGPointMake(10, 10);


    beforeEach(^{
        
        renderDelegate = [[I3BasicRenderDelegate alloc] init];
        coordinator = OCMClassMock([I3GestureCoordinator class]);
        arena = OCMClassMock([I3DragArena class]);
        superview = OCMPartialMock([[UIView alloc] init]);
        currentDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
        currentDragDataSource = OCMProtocolMock(@protocol(I3DragDataSource));
        draggingItem = [[UIView alloc] init];
        collectionView = [[UIView alloc] init];
        gestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
        
        OCMStub([arena superview]).andReturn(superview);
        OCMStub([coordinator arena]).andReturn(arena);
        OCMStub([currentDraggingCollection itemAtPoint:touchPoint]).andReturn(draggingItem);
        OCMStub([currentDraggingCollection collectionView]).andReturn(collectionView);
        OCMStub([currentDraggingCollection dragDataSource]).andReturn(currentDragDataSource);
        OCMStub([coordinator currentDragOrigin]).andReturn(touchPoint);
        OCMStub([coordinator currentDraggingCollection]).andReturn(currentDraggingCollection);
        OCMStub([coordinator gestureRecognizer]).andReturn(gestureRecognizer);
        
    });

    afterEach(^{
    
        renderDelegate = nil;
        coordinator = nil;
        arena = nil;
        currentDraggingCollection = nil;
        draggingItem = nil;
        gestureRecognizer = nil;
        currentDragDataSource = nil;
        
    });


    describe(@"rendering", ^{

        
        describe(@"begin drag", ^{
        
            
            it(@"should construct a dragging view from an item in the dragging collection on start", ^{
                
                CGRect convertedRect = CGRectMake(100, 100, 100, 100);
                OCMStub([superview convertRect:draggingItem.frame fromView:collectionView]).andReturn(convertedRect);
                
                [renderDelegate renderDragStart:coordinator];
                
                expect(renderDelegate.draggingView).to.beInstanceOf([I3CloneView class]);
                expect(renderDelegate.draggingView.sourceView).to.equal(draggingItem);
                expect([renderDelegate.draggingView.superview isEqual:superview]).to.beTruthy;
                expect(renderDelegate.draggingView.frame).to.equal(convertedRect);
                
                OCMVerify([superview convertRect:draggingItem.frame fromView:collectionView]);
                
            });

            
            it(@"should hide the original item if required by the datasource", ^{
            
                CGPoint draggingPoint = CGPointMake(10, 10);
                OCMStub([currentDragDataSource hidesItemWhileDraggingAtPoint:draggingPoint inCollection:currentDraggingCollection]).andReturn(YES);
                
                [renderDelegate renderDragStart:coordinator];
                
                expect(draggingItem.alpha).to.equal(0.01f);
                OCMVerify([currentDragDataSource hidesItemWhileDraggingAtPoint:draggingPoint inCollection:currentDraggingCollection]);
                
            });
            
            it(@"should not hide the original item if specified by the datasource", ^{
                
                CGPoint draggingPoint = CGPointMake(10, 10);
                OCMStub([currentDragDataSource hidesItemWhileDraggingAtPoint:draggingPoint inCollection:currentDraggingCollection]).andReturn(NO);
                
                [renderDelegate renderDragStart:coordinator];
                
                expect(draggingItem.alpha).notTo.equal(0.01f);
                OCMVerify([currentDragDataSource hidesItemWhileDraggingAtPoint:draggingPoint inCollection:currentDraggingCollection]);
                
            });
            
        });

        it(@"should translate the current dragging view and then reset the recognizer's translation", ^{
            
            CGPoint translation = CGPointMake(5, 5);
            [renderDelegate renderDragStart:coordinator];
            [renderDelegate.draggingView setCenter:CGPointMake(50, 50)];
            
            OCMStub([gestureRecognizer translationInView:superview]).andReturn(translation);
            
            [renderDelegate renderDraggingFromCoordinator:coordinator];
            
            expect(renderDelegate.draggingView.center).to.equal(CGPointMake(55, 55));
            
        });
        
        it(@"should release strong reference to the dragging view, whilst animating it back to the origin in an async animation", ^AsyncBlock {
        
            [renderDelegate renderDragStart:coordinator];

            CGPoint resetPoint = CGPointMake(25, 25);
            CGRect resetRect = CGRectMake(0, 0, 100, 100);
            OCMStub([superview convertRect:draggingItem.frame fromView:collectionView]).andReturn(resetRect);
            
            renderDelegate.completeResetBlock = ^(UIView *draggingView){
                expect(draggingView.frame).to.equal(resetRect);
                expect(draggingView.superview).to.beNil();
                done();
            };
            
            [renderDelegate renderResetFromPoint:resetPoint fromCoordinator:coordinator];
            
            expect(renderDelegate.draggingView).to.beNil();

        });
        
        it(@"should release reference to dragging view and remove it from superview on exchange between collections", ^{
        
            id dstCollection = OCMProtocolMock(@protocol(I3Collection));
            
            [renderDelegate renderDragStart:coordinator];
            [renderDelegate renderDropOnCollection:dstCollection atPoint:CGPointMake(0, 0) fromCoordinator:coordinator];
            
            expect([superview.subviews containsObject:renderDelegate.draggingView]).to.beFalsy;
            expect(renderDelegate.draggingView).to.beNil();
            
        });
        
    });


SpecEnd
