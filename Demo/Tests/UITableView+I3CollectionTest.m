//
//  UITableView+I3Collection.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/UITableView+I3Collection.h>


SpecBegin(UITableViewI3Collection)


    describe(@"I3Collection interface", ^{

        
        it(@"should return a UITableView (itself) for the collectionView", ^{
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            expect([tableView collectionView]).to.equal(tableView);
            
        });
        
        it(@"should return one of its NSIndexPath s for a ")
        
        it(@"should return on of its UITableViewCells for a valid point within it", ^{
            
            id tableView = OCMPartialMock([[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]);

            CGPoint point = CGPointMake(5, 5);
            NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
            UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            OCMStub([tableView indexPathForRowAtPoint:point]).andReturn(index);
            OCMStub([tableView cellForRowAtIndexPath:index]).andReturn(cell);
            
            UIView *item = [tableView itemAtPoint:point];
            
            expect(item).to.equal(cell);
            
        });
        
    });

SpecEnd