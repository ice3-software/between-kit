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
        sourceView.backgroundColor = [UIColor redColor];
        
        view = [[I3CloneView alloc] initWithSourceView:sourceView];
    
    });


    afterEach(^{
        
        sourceView = nil;
        
    });


    describe(@"constructor", ^{
        
        it(@"should inject the source view", ^{
            
            expect(view.sourceView).to.equal(sourceView);
        
        });
        
        it(@"should set the frame to the source view's frame", ^{
        
            expect(view.frame).to.equal(sourceView.frame);
            
        });
        
        it(@"should itself and the sourceView to be not opaque", ^{
            
            expect(view.opaque).to.beFalsy();
            expect(view.sourceView.opaque).to.beFalsy();
            
        });
    
    });


    describe(@"render sourceView", ^{

        it(@"should be nil before first clone", ^{
            
            expect(view.sourceViewImage).to.beNil();
        
        });
        
        it(@"should set up the UIImage on first clone", ^{

            UIGraphicsBeginImageContext(sourceView.frame.size);
            [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIGraphicsEndImageContext();
            
            [view cloneSourceView];
            
            expect(view.sourceViewImage).toNot.beNil();
            
            /// @todo.. Assert images are similar
        });
        
        it(@"should release weak reference to the sourceView on first call", ^{
        
            [view cloneSourceView];
            expect(view.sourceView).to.beNil();
            
        });
        
        it(@"should not re-setup the UIImage on subsequent calls to getter", ^{
        
            id layer = OCMClassMock([CALayer class]);
            OCMStub([sourceView layer]).andReturn(layer);
            
            [view cloneSourceView];
            
            [[layer reject] renderInContext:UIGraphicsGetCurrentContext()];

            [view cloneSourceView];
            
        });
        
    });


    describe(@"drawing the clone view", ^{

        it(@"should draw the source view in the cloned view on drawRect", ^{
        
            id mockImage = OCMClassMock([UIImage class]);
            CGRect mockRect = CGRectMake(0, 0, 200, 200);
            
            [view setValue:mockImage forKey:@"_sourceViewImage"];
            [view drawRect:mockRect];
            
            OCMVerify([mockImage drawInRect:mockRect]);
            
        });
        
    });


SpecEnd
