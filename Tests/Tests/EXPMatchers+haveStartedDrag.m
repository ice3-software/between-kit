//
//  EXPMatchers+haveStartedDrag.m
//  BetweenKit
//
//  Created by Stephen Fortune on 16/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "EXPMatchers+haveStartedDrag.h"

EXPMatcherImplementationBegin(haveStartedDrag, (UIView<I3Collection> *collection, CGPoint origin)){
    
    
    BOOL actualIsNil = (actual == nil);

    
    /**
     
     Returns a failure message as an NSString if the matches does not meet the pre
     -requisites.
     
     @return NSString
     
     */
    NSString *(^mapPrerequisiteFailureMessage)() = ^NSString *{

        NSString *failureMessage = nil;
        
        if(actualIsNil){
            failureMessage = @"Actual coordinator is nil";
        }

        return failureMessage;
    };
    
    
    prerequisite(^BOOL {
        return !actualIsNil;
    });
    
    
    match(^BOOL {
        return
            CGPointEqualToPoint([actual currentDragOrigin], origin) &&
            [actual currentDraggingCollection] == collection;
    });
    
    
    failureMessageForTo(^NSString *{
        
        NSString *failureMessage = mapPrerequisiteFailureMessage() ?: [NSString stringWithFormat:@"Expected drag to have started from %@ in the collection %@, instead started at %@ in the collection %@", NSStringFromCGPoint(origin), collection, NSStringFromCGPoint([actual currentDragOrigin]), [actual currentDraggingCollection]];
        
        return failureMessage;
        
    });
    
    
    failureMessageForNotTo(^NSString * {

        NSString *failureMessage = mapPrerequisiteFailureMessage() ?: [NSString stringWithFormat:@"Expected drag not to have started from %@ in the collection %@, but it did", NSStringFromCGPoint(origin), collection];
        
        return failureMessage;
    
    });
    
}

EXPMatcherImplementationEnd
