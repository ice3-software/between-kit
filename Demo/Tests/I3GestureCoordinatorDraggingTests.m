//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3GestureCoordinator.h>
#import "I3CoordinatorCreationMethods.h"


SpecBegin(I3GestureCoordinatorDragging)


    describe(@"dragging", ^{
        
        it(@"should render dragging", ^{
            
            I3GestureCoordinator *coordinator = I3GestureCoordinatorSetupDraggingMock(nil);
            
            OCMStub([coordinator.gestureRecognizer state]).andReturn(UIGestureRecognizerStateChanged);

            [coordinator handlePan:coordinator.gestureRecognizer];
            
            OCMVerify([coordinator.renderDelegate renderDraggingFromCoordinator:coordinator]);
            
        });
        
    });


SpecEnd
