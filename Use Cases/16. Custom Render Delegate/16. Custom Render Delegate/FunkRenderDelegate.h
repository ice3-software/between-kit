//
//  I3FunkRenderDelegate.h
//  BetweenKit
//
//  Created by Stephen Fortune on 19/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BetweenKit/I3BasicRenderDelegate.h>

/**
 
 This class provides a funky example of how you can implement your own render delegate on-top of
 the framework to tailor 'drag / drop' styling.
 
 It inherits from the basic render delegate, but users can also build a custom render delegate 
 just by conforming to the I3DragRenderDelegate protocol.
 
 Rendering features:
 
 - Pulsing view whilst dragging
 - Highlights the destination that you're hovering over
 - Shakes to warn the user whilst hovering over a delete area
 - Cool 'implode' transition when deleted
 
 */
@interface FunkRenderDelegate : I3BasicRenderDelegate

-(id) initWithPotentialDstViews:(NSArray *)views andDeleteArea:(UIView *)deleteArea;

@end
