//
//  I3CloneView.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <UIKit/UIKit.h>


/**
 
 This is a 'cloned' view. It takes a source view and renders the source into itself 
 in order to make a clone of the source view.
 
 @see http://stackoverflow.com/a/10367029
 
 */
@interface I3CloneView : UIView


/**
 
 The source view to be rendered into this view.
 
 @note This is a strong reference.
 
 */
@property (nonatomic, strong, readonly) UIView *sourceView;


/**
 
 Init.
 
 @param sourceView  The 'source' view. This view is rendered into the I3CloneView in its 
                    `drawRect:` method.
 
 */
-(id) initWithSourceView:(UIView *)sourceView;

@end
