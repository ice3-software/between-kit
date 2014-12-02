//
//  I3CollectionFixture.m
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CollectionFixture.h"


@interface I3CollectionFixture () {
    
    UIView *_collectionView;    
}

@end

@implementation I3CollectionFixture

-(id) init{

    self = [super init];
    
    if(self){
        _collectionView = OCMPartialMock([[UIView alloc] init]);
    }

    return self;
}

-(id) initWithItemAtPoint:(CGPoint) at{

    self = [self init];
    
    if(self){
        [self setValidPointInsideCollection:at];
        [self setValidIndexPath:[NSIndexPath indexPathForItem:123 inSection:123] forPoint:at];
    }
    
    return self;
}

-(UIView *)collectionView{
    return _collectionView;
}

-(void) setValidPointInsideCollection:(CGPoint) point{
    OCMStub([_collectionView pointInside:point withEvent:nil]).andReturn(YES);
}

-(void) setValidIndexPath:(NSIndexPath *)index forPoint:(CGPoint) at{
    UIView *view = OCMPartialMock([[UIView alloc] init]);
    OCMStub([self itemAtIndexPath:index]).andReturn(view);
    OCMStub([self indexPathForItemAtPoint:at]).andReturn(index);
    _items[index] = view;
}

-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at{
    return nil;
}

-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    return nil;
}

@end