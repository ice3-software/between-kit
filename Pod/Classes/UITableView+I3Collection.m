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


-(NSIndexPath *)indexPathForItemAtPoint:(CGPoint) at{
    return [self indexPathForRowAtPoint:at];
}


-(UIView *)itemAtIndexPath:(NSIndexPath *)index{
    return [self cellForRowAtIndexPath:index];
}


-(void) deleteItemsAtIndexPaths:(NSArray *)indeces{
    [self deleteRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade];
}


-(void) reloadItemsAtIndexPaths:(NSArray *)indeces{
    [self reloadRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade];
}


-(void) insertItemsAtIndexPaths:(NSArray *)indeces{
    [self insertRowsAtIndexPaths:indeces withRowAnimation:UITableViewRowAnimationFade];
}


@end