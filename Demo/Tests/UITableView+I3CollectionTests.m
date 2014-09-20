//
//  I3GestureCoordinatorTests.m
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/UITableView+I3Collection.h>


SpecBegin(UITableViewI3Collection)


    __block UITableView *tableViewCollection;

    beforeEach(^{
        tableViewCollection = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    });

    afterEach(^{
        tableViewCollection = nil;
    });


    describe(@"I3Collection interface", ^{

        it(@"should return a UITableView (itself) for the collectionView", ^{
            
            expect(tableViewCollection.collectionView).to.beInstanceOf([UITableView class]);
            expect(tableViewCollection.collectionView).to.equal(tableViewCollection);
            
        });
        
        it(@"should return on of its UITableViewCells for a valid point within it", ^{
        
            UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            [tableViewCollection insertRowsAtIndexPaths:@[cell] withRowAnimation:UITableViewRowAnimationNone];
            
            UIView *item = [tableViewCollection itemAtPoint:CGPointMake(5, 5)];
            
            expect(item).to.beInstanceOf([UITableViewCell class]);
            expect(item).to.equal(cell);
            
        });
        
    });


SpecEnd
