//
//  I3SimpleData.h
//  BetweenKit
//
//  Created by Stephen Fortune on 17/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LIGHT_GREEN_COLOUR [UIColor colorWithRed:0.4 green:0.9 blue:0.6 alpha:1]
#define LIGHT_BLUE_COLOUR [UIColor colorWithRed:0.4 green:0.7 blue:0.9 alpha:1]
#define LIGHT_RED_COLOUR [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:1]

@interface I3SimpleData : NSObject <NSCopying>

@property (nonatomic, copy) UIColor *colour;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) BOOL canDelete;

@property (nonatomic, assign) BOOL canMove;

-(id) initWithColor:(UIColor *)colour withTitle:(NSString *)title withSubtitle:(NSString *)subtitle withCanDelete:(BOOL) canDelete withCanMove:(BOOL) canMove;

@end
