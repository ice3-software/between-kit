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
        _sourceView.opaque = NO;
        
        self.opaque = NO;
        
    }
    
    return self;
}


-(void) cloneSourceView{

    if(!_sourceViewImage){
    
        UIGraphicsBeginImageContextWithOptions(self.sourceView.bounds.size, NO, 0.0);
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
