//
//  UIView+I3Collection.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/UIView+I3Collection.h>


SpecBegin(UIViewI3Collection)

    describe(@"I3Collection interface", ^{

        it(@"should return self as the collection view", ^{
        
            UIView *view = [[UIView alloc] init];
            expect(view.collectionView).to.equal(view);
            
        });
        
        it(@"should return subview at given point", ^{
        
            id view = OCMPartialMock([[UIView alloc] init]);
            
            id subview1 = OCMPartialMock([[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]);
            id subview2 = OCMPartialMock([[UIView alloc] initWithFrame:CGRectMake(10, 0, 10, 10)]);
            id subview3 = OCMPartialMock([[UIView alloc] initWithFrame:CGRectMake(20, 0, 10, 10)]);
            
            NSArray *subviews = @[subview1, subview2, subview3];
            OCMStub([view subviews]).andReturn(subviews);

            expect([view itemAtPoint:CGPointMake(5, 5)]).to.equal(subview1);
            expect([view itemAtPoint:CGPointMake(5, 15)]).to.equal(subview2);
            expect([view itemAtPoint:CGPointMake(5, 25)]).to.equal(subview3);
            
        });

    });

SpecEnd