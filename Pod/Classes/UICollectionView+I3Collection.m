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


-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    return [self cellForItemAtIndexPath:index];
}


@end
