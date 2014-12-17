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
        
        it(@"should return one of its NSIndexPath s for a given point", ^{
            
            UITableView *tableView = OCMPartialMock([[UITableView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)]);
            
            CGPoint point = CGPointMake(5, 5);
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            
            OCMStub([tableView indexPathForRowAtPoint:point]).andReturn(index);
            
            expect([tableView indexPathForItemAtPoint:point]).to.equal(index);
        
        });
        
        it(@"should return a UITableViewCell for a given index", ^{
            
            UITableView *tableView = OCMPartialMock([[UITableView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)]);

            UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            
            OCMStub([tableView cellForRowAtIndexPath:index]).andReturn(cell);
            expect([tableView itemAtIndexPath:index]).to.equal(cell);
        
        });
        
    });


SpecEnd