//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/I3TableView.h>


SpecBegin(I3TableViewTests)


    __block id tableView;

    beforeEach(^{
        I3TableView *collectionTableView = [[I3TableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        tableView = OCMPartialMock(collectionTableView);
    });

    afterEach(^{
        tableView = nil;
    });


    describe(@"I3Collection interface", ^{

        it(@"should return a UITableView (itself) for the collectionView", ^{

            /// @note These are not going to be the same intances because we are using a partial
            //  mock.
            
            expect([tableView collectionView]).to.beInstanceOf([I3TableView class]);
            
        });
        
        it(@"should return on of its UITableViewCells for a valid point within it", ^{
        
            CGPoint point = CGPointMake(5, 5);
            NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
            UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            OCMStub([tableView convertPoint:point toView:[tableView collectionView]]).andReturn(point);
            OCMStub([tableView indexPathForRowAtPoint:point]).andReturn(index);
            OCMStub([tableView cellForRowAtIndexPath:index]).andReturn(cell);
            
            UIView *item = [tableView itemAtPoint:point];
            
            expect(item).to.equal(cell);
            
        });
        
    });


SpecEnd
