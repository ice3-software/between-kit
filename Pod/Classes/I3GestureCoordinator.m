//
//  I3GestureCoordinator.m
//  
//
//  Created by Stephen Fortune on 14/09/2014.
//
//

#import "I3GestureCoordinator.h"


@interface I3GestureCoordinator (Private)


/**
 
 Redeclaration of private properties
 
 */
@property (nonatomic, strong, readonly) I3DragArena* arena;
@property (nonatomic, strong, readonly) UIPanGestureRegonizer* gestureRecognizer;


/**
 
 Entry point for pan gestures that are coordinated to the I3Collections.
 
 */
-(void) coordPan:(UIPanGestureRecognizer*) gestureRecognizer;


/**
 
 The drag has started! This method determines which collection (if any) the drag started in
 and how then that may be handled.
 
 */
-(void) coordDragStarted;


/**
 
 A drag gesture has stopped! This method determines which collection (if any) the drag has
 stopped in and how that may be handled.
 
 */
-(void) coordDragStopped;


/**
 
 Called whilst we are dragging. It basically just emits notifications such that an external
 rendered can render the drag event.
 
 */
-(void) coordDrag;

@end


@implementation I3GestureCoordinator


-(id) initWithDragArena:(I3DragArena *)arena withGestureRecognizer:(UIPanGestureRegonizer *)gestureRecognizer{

    self = [super init];
    
    if(self){
        
        self.arena = arena;
        self.gestureRecognizer = gestureRecognizer;
        
    }

    return self;
}


#pragma mark - Coordination methods


-(void) coordPan:(UIPanGestureRecognizer*) gestureRecognizer{

    switch([gestureRecognizer state]){
            
        case UIGestureRecognizerStateBegan:
            
            DND_LOG(@"Drag Started");
            break;
            
        case UIGestureRecognizerStateChanged:
            
            DND_LOG(@"Dragging");
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            DND_LOG(@"Drag Stopped");
            break;
            
        default:
            break;
            
    }

}



#pragma mark - UIPanGestureRecognizer acessor methods.


-(void) setGestureRecognizer:(UIPanGestureRecognizer *)recognizer{

    if(recognizer != _gestureRecognizer){
    
        _gestureRecognizer = recognizer;
        
        SEL panSelector = @selector(coordPan:);
        [_gestureRecognizer addTarget:self action:panSelector];
        
    }
}


-(UIPanGestureRecognizer *)gestureRecognizer{

    if(!_gestureRecognizer){
        self.gestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    }
    
    return _gestureRecognizer;
}

@end
