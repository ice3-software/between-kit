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


-(UIView *)itemAtPoint:(CGPoint) at{
    
    NSIndexPath *index = [self indexPathForRowAtPoint:at];
    return [self cellForRowAtIndexPath:index];
}


@end