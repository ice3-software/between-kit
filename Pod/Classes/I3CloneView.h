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
 
 The cached source view. This is lazily rendered into the clonedImage property the first
 time the clonedImage property is requested.
 
 */
@property (nonatomic, readonly, weak) UIView *sourceView;


/**
 
 The source view injected in the ctor, rendered into a UIImage.
 
 */
@property (nonatomic, readonly) UIImage *sourceViewImage;


/**
 
 Init.
 
 @param sourceView  The 'source' view. This view is rendered into a UIImage and draw via
                    drawRect.
 
 */
-(id) initWithSourceView:(UIView *)sourceView;

@end
