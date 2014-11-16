//
//  I3TableView.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3TableView.h"

@implementation I3TableView


#pragma mark - I3Collection implementation


-(UIView *)collectionView{
    return self;
}


-(UIView *)itemAtPoint:(CGPoint) at{
    
    CGPoint localAt = [self convertPoint:at toView:self];
    NSIndexPath *index = [self indexPathForRowAtPoint:localAt];
    return [self cellForRowAtIndexPath:index];
}


@end
