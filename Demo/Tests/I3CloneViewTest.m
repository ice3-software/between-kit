//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3CloneView.h>


SpecBegin(I3CloneView)


    __block I3CloneView *view;
    __block UIView *sourceView;


    beforeEach(^{
    
        sourceView = OCMPartialMock([[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]);
        view = [[I3CloneView alloc] initWithSourceView:sourceView];
    
    });


    describe(@"constructor", ^{
        
        
        it(@"should setup the view with the source view", ^{
            expect(view.sourceView).to.equal(sourceView);
        });
        
        it(@"should set the clone view up with the same frame as the source view", ^{
            expect(view.frame).to.equal(sourceView.frame);
        });
        
    });


    describe(@"drawing the clone view", ^{

        it(@"should draw the source view in the cloned view on drawRect", ^{
        
            id layer = OCMClassMock([CALayer class]);
            OCMStub([sourceView layer]).andReturn(layer);

            [view drawRect:CGRectMake(0, 0, 10, 10)];
            
            OCMVerify([layer renderInContext:UIGraphicsGetCurrentContext()]);

        });
        
    });


SpecEnd
