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


    beforeEach(^{
        
        renderDelegate = [[I3BasicRenderDelegate alloc] init];
        coordinator = OCMClassMock([I3GestureCoordinator class]);
        arena = OCMClassMock([I3DragArena class]);
        superview = [[UIView alloc] init];
        
        OCMStub([arena superview]).andReturn(superview);
        OCMStub([coordinator arena]).andReturn(arena);
    
    });

    afterEach(^{
        renderDelegate = nil;
        coordinator = nil;
        arena = nil;
    });


    describe(@"rendering a drag start", ^{

        it(@"should construct a dragging view from an item in the dragging collection on start", ^{
            
            id currentDraggingCollection = OCMProtocolMock(@protocol(I3Collection));
            UIView *draggingItem = [[UIView alloc] init];
            CGPoint touchPoint = CGPointMake(10, 10);
            
            OCMStub([currentDraggingCollection itemAtPoint:touchPoint]).andReturn(draggingItem);
            OCMStub([coordinator currentDragOrigin]).andReturn(touchPoint);
            OCMStub([coordinator currentDraggingCollection]).andReturn(currentDraggingCollection);
            
            [renderDelegate renderDragStart:coordinator];
            
            expect(renderDelegate.draggingView).to.beInstanceOf([I3CloneView class]);
            expect(renderDelegate.draggingView.sourceView).to.equal(draggingItem);
            expect(renderDelegate.draggingView.superview).to.equal(superview);


        });

    });


SpecEnd
