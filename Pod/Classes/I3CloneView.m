//
//  I3CloneView.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3CloneView.h"


@interface I3CloneView (){
    
    UIImage *_sourceImageView;
}

@end


@implementation I3CloneView


-(id) initWithSourceView:(UIView *)sourceView{

    self = [super initWithFrame:sourceView.frame];
    
    if(self){
        
        UIGraphicsBeginImageContext(sourceView.frame.size);
        [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
        _sourceImageView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return self;
}


-(void) drawRect:(CGRect) rect{
    [_sourceImageView drawInRect:rect];
}


@end
