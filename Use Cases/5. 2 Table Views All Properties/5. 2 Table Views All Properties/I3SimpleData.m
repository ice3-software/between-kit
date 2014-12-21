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
    
        self.colour = colour ?: LIGHT_BLUE_COLOUR;
        self.title = title ?: @"Item";
        self.subtitle = subtitle ?: @"This is an item";
        self.canDelete = canDelete;
        self.canMove = canMove;
        
    }

    return self;
    
}


-(id) copyWithZone:(NSZone *) zone{
    
    return [[[self class] alloc] initWithColor:self.colour withTitle:self.title withSubtitle:self.subtitle withCanDelete:self.canDelete withCanMove:self.canMove];
    
}


@end
