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

@property (nonatomic, readonly, copy) NSMutableDictionary *items;

-(id) initWithItemAtPoint:(CGPoint) at;

-(void) setValidPointInsideCollection:(CGPoint) point;

-(void) setValidIndexPath:(NSIndexPath *)index;

@end
