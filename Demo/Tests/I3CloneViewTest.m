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
        
        it(@"should inject the source view", ^{
            
            expect(view.sourceView).to.equal(sourceView);
        
        });
    
    });


    describe(@"lazily render sourceView", ^{

        it(@"should be nil before first call to getter", ^{
            
            expect([view valueForKey:@"_sourceViewImage"]).to.beNil;
        
        });
        
        it(@"should set up the UIImage on first call to getter", ^{

            UIGraphicsBeginImageContext(sourceView.frame.size);
            
            [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *compareImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            NSData *compareData = UIImagePNGRepresentation(compareImage);
            NSData *clonedCompareData = UIImagePNGRepresentation(view.sourceViewImage);
            
            expect([compareData isEqual:clonedCompareData]).to.beTruthy;
        
        });
        
        it(@"should not re-setup the UIImage on subsequent calls to getter", ^{
        
            id layer = OCMClassMock([CALayer class]);
            OCMStub([sourceView layer]).andReturn(layer);
            
            [view sourceViewImage];
            
            [[layer reject] renderInContext:UIGraphicsGetCurrentContext()];

            [view sourceViewImage];
            
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
