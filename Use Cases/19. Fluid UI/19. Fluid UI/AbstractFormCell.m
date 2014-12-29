//
//  AbstractFormCell.m
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import "AbstractFormCell.h"

@implementation AbstractFormCell

-(void) setComponent:(id<ParentCellAware>) component{
    
    _component = component;
    _component.parentCell = self;
}

-(void) awakeFromNib{
    
    [super awakeFromNib];
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = NO;

    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 0.26f;
    self.contentView.layer.shadowOffset = CGSizeMake(1, 1);
    self.contentView.layer.shadowRadius = 0.8f;

}

@end
