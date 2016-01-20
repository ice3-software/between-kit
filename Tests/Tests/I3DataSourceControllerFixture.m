//
//  I3DataSourceControllerFixture.m
//  BetweenKit
//
//  Created by Stephen Fortune on 21/11/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import "I3DataSourceControllerFixture.h"

@interface I3DataSourceControllerFixture ()

@end

@implementation I3DataSourceControllerFixture

-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(id<I3Collection>) collection{
    return YES;
}

@end
