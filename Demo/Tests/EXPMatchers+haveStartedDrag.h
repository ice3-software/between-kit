//
//  EXPMatchers+haveStartedDrag.h
//  BetweenKit
//
//  Created by Stephen Fortune on 16/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BetweenKit/I3GestureCoordinator.h>
#import "Expecta.h"

EXPMatcherInterface(haveStartedDrag, (id<I3Collection> collection, CGPoint origin));

#define haveEmptyDrag() haveStartedDrag(nil, CGPointZero)