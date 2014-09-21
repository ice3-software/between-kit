//
//  I3CloneView.m
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import "I3CloneView.h"

@implementation I3CloneView


-(id) initWithSourceView:(UIView *)sourceView{

    self = [super initWithFrame:sourceView.frame];
    
    if(self){
        
        _sourceView = sourceView;
        
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
