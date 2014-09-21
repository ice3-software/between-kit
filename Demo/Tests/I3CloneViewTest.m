//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3CloneView.h>


SpecBegin(I3CloneViewTest)


    __block I3CloneView *view;


    describe(@"constructor", ^{

        it(@"should setup the view with the source view", ^{
            
            UIView *sourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            view = [[I3CloneView alloc] initWithSourceView:sourceView];
            
            expect(view.sourceView).to.equal(sourceView);
            expect(view.frame).to.equal(sourceView.frame);
        
        });
        
    });


SpecEnd
