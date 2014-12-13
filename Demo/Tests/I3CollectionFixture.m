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

-(id) initWithMockPoint:(CGPoint) point{

    self = [self init];
    [self mockItemAtPoint:point];
    return self;
}

-(id) initInArea:(I3DragArena *)arena{

    self = [self init];
    [self appendToArena:arena];
    return self;
}

-(id) initWithMockPoint:(CGPoint) point inArena:(I3DragArena *)arena{

    self = [self init];
    [self mockItemAtPoint:point];
    [self appendToArena:arena];
    return self;
}

-(void) appendToArena:(I3DragArena *)arena{
    [arena.collections addObject:self];
}

-(NSString *)keyFromPoint:(CGPoint) point{
    return NSStringFromCGPoint(point);
}

-(UIView *)collectionView{
    return _collectionView;
}

-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at{
    NSLog(@"Finding index path %@ for point %@", [_pointIndexPathMap objectForKey:[self keyFromPoint:at]], NSStringFromCGPoint(at));
    return [_pointIndexPathMap objectForKey:[self keyFromPoint:at]];
}

-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    NSLog(@"Finding view %@ for index for %@", [_indexPathViewMap objectForKey:index], index);
    return [_indexPathViewMap objectForKey:index];
}

-(void) mockPoint:(CGPoint) point isInside:(BOOL) isInside{
    OCMStub([_collectionView pointInside:point withEvent:nil]).andReturn(YES);
}

-(NSIndexPath *)mockItemAtPoint:(CGPoint) point{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_pointIndexPathMap.count inSection:0];
    UIView *itemView = OCMPartialMock([[UIView alloc] init]);
    
    [_pointIndexPathMap setObject:indexPath forKey:[self keyFromPoint:point]];
    [_indexPathViewMap setObject:itemView forKey:indexPath];

    NSLog(@"Mocking point %@, index path %@, view %@", [self keyFromPoint:point], indexPath, itemView);
    NSLog(@"Has index path for point? %@", [_pointIndexPathMap objectForKey:[self keyFromPoint:point]]);
    NSLog(@"Has view for index path? %@", [_indexPathViewMap objectForKey:indexPath]);
    
    [self mockPoint:point isInside:YES];
    
    return indexPath;
}

@end