//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3CoordinatorCreationMethods.h"
#import "EXPMatchers+haveStartedDrag.h"


SpecBegin(I3GestureCoordinatorDragStop)

    describe(@"handle gesture recognizer states", ^{

        __block I3GestureCoordinator *coordinator;
        __block CGPoint dropOrigin;
        
        beforeAll(^{
            dropOrigin = CGPointMake(50, 50);
        });
        
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

SpecEnd
