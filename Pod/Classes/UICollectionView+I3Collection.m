//
//  UICollectionView+I3Collection.m
//  Pods
//
//  Created by Stephen Fortune on 17/11/2014.
//
//

#import "UICollectionView+I3Collection.h"


@implementation UICollectionView (I3Collection)


#pragma mark - I3Collection implementation


-(UIView *)collectionView{
    return self;
}


-(UIView *)itemAtPoint:(CGPoint) at{
    
    NSIndexPath *index = [self indexPathForItemAtPoint:at];
    return [self cellForItemAtIndexPath:index];
}


@end
