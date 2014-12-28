//
//  UICollectionView+I3CollectionTest.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <BetweenKit/UICollectionView+I3Collection.h>


SpecBegin(UICollectionViewI3Collection)


    describe(@"I3Collection interface", ^{
        
        it(@"should return a UICollectionViewCell for a given index", ^{
            
            UICollectionView *collectionView = OCMPartialMock([[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]);
            
            UICollectionViewCell *cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
            
            OCMStub([collectionView cellForItemAtIndexPath:index]).andReturn(cell);
            expect([collectionView itemAtIndexPath:index]).to.equal(cell);
            
        });
          
    });


SpecEnd