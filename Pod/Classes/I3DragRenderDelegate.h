//
//  I3DragRenderDelegate.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <Foundation/Foundation.h>


/**
 
 This is a protocol for a class that is delegated out the responsibillity by the coordinator 
 of rendering various drag / drop events. For now, I have decided that the coordinator-renderer
 relationship is one-to-one (i.e. there will only be one class rendering the events emitted by
 the coordinator).
 
 All methods defined in this protocol are required because all rendering events must actually
 be rendered.
 
 @see I3GestureCoordinator
 
 @note The idea is that the framework will provide a 'default' render delegate that implements
 this protocol, but users can also define their own by extending the default delegate or even 
 implementing their own from scratch if they wish to fully customize how the drag dropping is 
 rendered.
 
 @note The coordinator will never 'rely' on the render delegate. That is, the results of a render
 method called on the delegate will never actually affect the state of the coordinator's routines.
 Therefore it will be 'safe' for there not to be a render delegate injected into the coordinator.
 
 */
@protocol I3DragRenderDelegate <NSObject>

/// @todo Implement contract interface

@end
