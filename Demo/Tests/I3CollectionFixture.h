//
//  I3CollectionFixture.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/11/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3Collection.h>

@interface I3CollectionFixture : NSObject <I3Collection>

@end

@implementation I3CollectionFixture

/**
 
 Implementation returns nil. These methods should be stubbed to return valid values
 in the tests.
 
 */

-(UIView *)collectionView{
    return nil;
}

-(UIView *)itemAtPoint:(CGPoint) at{
    return nil;
}

@end