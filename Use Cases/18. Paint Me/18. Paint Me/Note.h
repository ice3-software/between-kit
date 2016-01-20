//
//  Note.h
//  18. Paint Me
//
//  Created by Stephen Fortune on 30/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 Model for a note. These notes are rendered in a table view by the view controller
 and can assigned a colour to use as their background colour.
 
 */
@interface Note : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) UIColor *colour;

-(id) initWithTitle:(NSString *)title;

@end
