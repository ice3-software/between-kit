//
//  I3SimpleData.m
//  BetweenKit
//
//  Created by Stephen Fortune on 17/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3SimpleData.h"

@implementation I3SimpleData

-(id) initWithColor:(UIColor *)colour withTitle:(NSString *)title withSubtitle:(NSString *)subtitle withCanDelete:(BOOL) canDelete withCanMove:(BOOL) canMove{

    self = [super init];
    
    if(self){
    
        _colour = colour ?: [UIColor blueColor];
        _title = title ?: @"Item";
        _subtitle = subtitle ?: @"This is an item";
        _canDelete = canDelete;
        _canMove = canMove;
        
    }

    return self;
    
}

@end
