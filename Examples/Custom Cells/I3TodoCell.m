//
//  I3TodoCell.m
//
//  Created by Stephen Fortune on 13/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.


/**
 *  This snippet is an example of a custom UITableViewCell that has implemented NSCoder* so
 *  that is can be archived/unarchived by the i3-dragndrop helper. It is taken directly from
 *  a production application targetted at iOS 6 and 7 using the helper to achieve 
 *  dragndrop-abillity.
 */

#import "I3TodoCell.h"

@interface I3TodoCell ()

/**
 *  A custom Label. UIInsetLabel is a subclass of UILabel that allows for padding edge 
 *  insets.
 */

@property (nonatomic, readwrite, strong) UIInsetLabel* label;

@end


@implementation I3TodoCell

-(id) initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString*) reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        NSLog(@"Cell ctor");
        
    }
    return self;
}

-(id) initWithCoder:(NSCoder*) aDecoder{

    self = [super initWithCoder:aDecoder];
    
    if(self){
        

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        /**
         *  This is the most important part of this example snippet - if we are loading the view
         *  from an NSCoder (as would be the case if it were being un-archived by the helper) we
         *  check to see if the custom subview has been encoded. If it has been then we populate 
         *  the UIInsetLabel property.
         */
        
        UIInsetLabel* decodedLabel = [aDecoder decodeObjectForKey:@"__OverLabel"]; //TODO: Move to constant

        if(decodedLabel){
        
            /* Grab decoded label object */
            
            self.label = decodedLabel;
        }
        else{
        
            
            /* Initialize the label from scratch */
            
            CGRect labelFrame = self.contentView.frame;

            self.label = [[UIInsetLabel alloc] initWithFrame:labelFrame];
            [self addSubview:self.label];

        }
        
        
        /* Set rounded corner and shadow */
        
        self.label.layer.shadowColor = [UIColor blackColor].CGColor;
        self.label.layer.shadowOpacity = 0.3f;
        self.label.layer.shadowOffset = CGSizeMake(0.95, 0.95);
        self.label.layer.shadowRadius = 1.0f;
        
        self.label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.label.shadowOffset = CGSizeMake(1, 1);
        
        self.label.font = [UIFont systemFontOfSize:20];
        
        self.label.clipsToBounds = NO;
        self.label.layer.shouldRasterize = YES;
        self.label.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.label.textColor = [UIColor whiteColor];

    }
    
    return self;
}

-(void) awakeFromNib{

    [super awakeFromNib];
    
    /* Initialize the clear background */
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

}

-(void) setSelected:(BOOL) selected animated:(BOOL) animated{
    

}

-(void) setHighlighted:(BOOL) highlighted{

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

}

-(void) layoutSubviews{

    [super layoutSubviews];
    
    CGRect labelFrame = self.contentView.frame;
    labelFrame.origin.x += 15;
    labelFrame.size.width -= 30;
    labelFrame.origin.y += 10;
    labelFrame.size.height -= 20;
    
    self.label.frame = labelFrame;
    self.label.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.label.bounds].CGPath;

}

-(void) setCellColour:(UIColor*) cellColour{

    if(cellColour == nil){
    
        self.label.backgroundColor = [UIColor lightGrayColor];

    }
    else{
        
        self.label.backgroundColor = cellColour;

    }
    
    _cellColour = cellColour;

}

-(void) encodeWithCoder:(NSCoder*) aCoder{

    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.label forKey:@"__OverLabel"];
}

@end
