//
//  UITableView+I3Collection.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <UIKit/UIKit.h>
#import "I3Collection.h"


/**
 
 Category for UITableView that implements the I3Collection protocol. We have had 
 to use `objc_setAssociatedObject` for the dragDataSource property implementation as
 this is a category.
 
 @note 'Why is this a category? Why don't we just extend UITableView instead?'
 I'm not sure yet. My thoughts are that category's on core UIKit components like
 UITableView and UICollectionView are easier to integrate with existing applications
 as it does not require that you migrate all the type names from 'UITableView' to
 'I3TableView' in your code / storyboards / xibs. Not sure if its worth it yet. We'll
 see how it plays out.
 
 @see http://stackoverflow.com/a/8733320
 
 */
@interface UITableView (I3Collection) <I3Collection>


/**
 
 @copydoc I3Collection::dragDataSource
 
 */
@property (nonatomic, weak) id<I3DragDataSource> dragDataSource;


@end
