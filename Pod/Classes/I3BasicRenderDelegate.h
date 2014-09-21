//
//  I3BasicRenderDelegate.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <Foundation/Foundation.h>
#import "I3DragRenderDelegate.h"


/**
 
 This class is the framework-provided drag render delegate. This renders a basic 'ghost'
 dragging view during a drag. Note the loose coupling between the coordinator and its rendering
 delegate ! Users of this framework will be able to provide their own rendering delegates if
 they wish, that implement the I3DragRenderDelegate protocol. For convenience, users of the
 framework can extend this class to apply 'extra' styling to the rendering.
 
 @todo Provide various examples of approaches to using custom render delegates
 
 */
@interface I3BasicRenderDelegate : NSObject <I3DragRenderDelegate>

@end
