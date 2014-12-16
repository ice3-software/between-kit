//
//  I3CollectionFixture.m
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3CollectionFixture.h"

@implementation I3CollectionFixture

-(id) init{

    self = [super init];
    
    if(self){
        
        _collectionView = OCMPartialMock([[UIView alloc] init]);
        _indexPathViewMap = [[NSMutableDictionary alloc] init];
        _pointIndexPathMap = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}

-(void) dealloc{

    [_indexPathViewMap removeAllObjects];
    [_pointIndexPathMap removeAllObjects];
}

-(id) initInArena:(I3DragArena *)arena{

    self = [self init];

    if(self){
        [arena.collections addObject:self];
    }
        
    return self;
}

-(NSString *)keyFromPoint:(CGPoint) point{
    return NSStringFromCGPoint(point);
}

-(UIView *)collectionView{
    return _collectionView;
}

-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at{
    return [_pointIndexPathMap objectForKey:[self keyFromPoint:at]];
}

-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    return [_indexPathViewMap objectForKey:index];
}

-(void) mockPoint:(CGPoint) point isInside:(BOOL) isInside{
    OCMStub([_collectionView pointInside:point withEvent:nil]).andReturn(YES);
}

-(NSIndexPath *)mockItemAtPoint:(CGPoint) point{
    return [self mockItemAtPoint:point withIndexPath:nil];
}

-(NSIndexPath *)mockItemAtPoint:(CGPoint) point withIndexPath:(NSIndexPath *)index{

    NSIndexPath *indexPath = index ?: [NSIndexPath indexPathForItem:_pointIndexPathMap.count inSection:0];
    UIView *itemView = [[UIView alloc] init];
    
    [_pointIndexPathMap setObject:indexPath forKey:[self keyFromPoint:point]];
    [_indexPathViewMap setObject:itemView forKey:indexPath];
    
    [self mockPoint:point isInside:YES];

    return indexPath;
    
}

-(NSIndexPath *)mockIndexPathAtPoint:(CGPoint) point{

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_pointIndexPathMap.count inSection:0];
    [_pointIndexPathMap setObject:indexPath forKey:[self keyFromPoint:point]];

    [self mockPoint:point isInside:YES];
    
    return indexPath;
}

@end