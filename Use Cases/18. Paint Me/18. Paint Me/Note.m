//
//  Note.m
//  18. Paint Me
//
//  Created by Stephen Fortune on 30/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import "Note.h"

@implementation Note

-(id) initWithTitle:(NSString *)title{

    self = [super init];
    
    if(self){
    
        self.title = title;
        self.colour = [UIColor whiteColor];
    }
    
    return self;
}

@end
