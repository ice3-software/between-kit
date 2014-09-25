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
    __block UIView *draggingItem;
    CGPoint touchPoint = CGPointMake(10, 10);


    beforeEach(^{
        
        renderDelegate = [[I3BasicRenderDelegate alloc] init];
        coordinator = OCMClassMock([I3GestureCoordinator class]);
        arena = OCMClassMock([I3DragArena class]);
        superview = [[UIView alloc] init];
        currentDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
        draggingItem = [[UIView alloc] init];
        gestureRecognizer = OCMClassMock([UIPanGestureRecognizer class]);
        
        OCMStub([arena superview]).andReturn(superview);
        OCMStub([coordinator arena]).andReturn(arena);
        OCMStub([currentDraggingCollection itemAtPoint:touchPoint]).andReturn(draggingItem);
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
        
    });


    describe(@"rendering", ^{

        it(@"should construct a dragging view from an item in the dragging collection on start", ^{
            
            [renderDelegate renderDragStart:coordinator];
            
            expect(renderDelegate.draggingView).to.beInstanceOf([I3CloneView class]);
            expect(renderDelegate.draggingView.sourceView).to.equal(draggingItem);
            expect(renderDelegate.draggingView.superview).to.equal(superview);

        });

        it(@"should translate the current dragging view and then reset the regognizer's translation", ^{
            
            CGPoint translation = CGPointMake(5, 5);
            [renderDelegate renderDragStart:coordinator];
            [renderDelegate.draggingView setCenter:CGPointMake(50, 50)];
            
            OCMStub([gestureRecognizer translationInView:superview]).andReturn(translation);
            
            [renderDelegate renderDraggingFromCoordinator:coordinator];
            
            expect(renderDelegate.draggingView.center).to.equal(CGPointMake(55, 55));
            
        });
        
    });


SpecEnd
