//
//  I3CloneView.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3CloneView.h"


@interface I3CloneView ()


@property (nonatomic, readwrite) UIImage *sourceViewImage;


@end


@implementation I3CloneView


-(id) initWithSourceView:(UIView *)sourceView{

    self = [super initWithFrame:sourceView.frame];
    
    if(self){
        
        _sourceView = sourceView;
        
    }
    
    return self;
}


-(void) cloneSourceView{

    if(!_sourceViewImage){
    
        UIGraphicsBeginImageContext(self.sourceView.frame.size);
        [self.sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
        _sourceViewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _sourceView = nil;
    }
}


-(void) drawRect:(CGRect) rect{
    [self.sourceViewImage drawInRect:rect];
}


@end
