//
//  UITableView+I3Collection.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <BetweenKit/UITableView+I3Collection.h>


SpecBegin(UITableViewI3Collection)


    describe(@"required methods", ^{
        
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


    describe(@"optional methods", ^{

        
        __block UITableView *tableView;
        __block NSArray *indeces = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]];
        
        
        beforeEach(^{
            
            tableView = OCMPartialMock([[UITableView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)]);
            
        });
        
        
        afterEach(^{
            
            tableView = nil;
            
        });
        
        
        it(@"should delete a set of rows for given indeces", ^{
            
            OCMStub([tableView deleteRowsAtIndexPaths:[OCMArg any] withRowAnimation:UITableViewRowAnimationFade]);
            
            [tableView deleteItemsAtIndexPaths:indeces];
            
            OCMVerify([tableView deleteRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade]);
            
        });
        
        it(@"should reload a set of rows for given indeces", ^{
            
            OCMStub([tableView reloadRowsAtIndexPaths:[OCMArg any] withRowAnimation:UITableViewRowAnimationFade]);
            
            [tableView reloadItemsAtIndexPaths:indeces];
            
            OCMVerify([tableView reloadRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade]);
            
        });

        it(@"should insert a set of rows for given indeces", ^{
        
            OCMStub([tableView insertRowsAtIndexPaths:[OCMArg any] withRowAnimation:UITableViewRowAnimationFade]);
            
            [tableView insertItemsAtIndexPaths:indeces];
            
            OCMVerify([tableView insertRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade]);

        });
        
    });


SpecEnd
