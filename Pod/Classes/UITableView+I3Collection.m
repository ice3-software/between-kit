//
//  UITableView+I3Collection.m
//  Pods
//
//  Created by Stephen Fortune on 17/11/2014.
//
//

#import "UITableView+I3Collection.h"


@implementation UITableView (I3Collection)


#pragma mark - I3Collection implementation


-(UIView *)collectionView{
    return self;
}


-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at{
    return [self indexPathForRowAtPoint:at];
}


-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    return [self cellForRowAtIndexPath:index];
}


@end