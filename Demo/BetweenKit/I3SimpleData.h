//
//  I3SimpleData.h
//  BetweenKit
//
//  Created by Stephen Fortune on 17/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface I3SimpleData : NSObject

@property (nonatomic, strong) UIColor *colour;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) BOOL canDelete;

@property (nonatomic, assign) BOOL canMove;

-(id) initWithColor:(UIColor *)colour withTitle:(NSString *)title withSubtitle:(NSString *)subtitle withCanDelete:(BOOL) canDelete withCanMove:(BOOL) canMove;

@end
