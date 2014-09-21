//
//  UITableView+I3Collection.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "UITableView+I3Collection.h"


@implementation UITableView (I3Collection)



#pragma mark I3Collection implementation


-(void) setDragDataSource:(id<I3DragDataSource>) dragDataSource{
    objc_setAssociatedObject(self, @selector(dragDataSource), dragDataSource, OBJC_ASSOCIATION_WEAL_NONATOMIC);
}


-(UIView *)collectionView{
    return self;
}


-(UIView *)itemAtPoint:(CGPoint) at{
    
    NSIndexPath *index = [self indexPathForRowAtPoint:at];
    return [self cellForRowAtIndexPath:index];
}

@end
