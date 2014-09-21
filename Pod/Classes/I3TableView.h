//
//  I3TableView.h
//  Pods
//
//  Created by Stephen Fortune on 21/09/2014.
//
//

#import <UIKit/UIKit.h>
#import "I3Collection.h"


/**
 
 Subclass of UITableView that implements the I3Collection protocol.

 @note We've opted to subclass instead of create a catgeory on UITableView so that we
 don't have to rely on the objective C runtime to add the additional dragDataSource 
 property to the class.
 
 @see http://stackoverflow.com/a/8733320
 
 */
@interface I3TableView : UITableView <I3Collection>


/**
 
 @copydoc I3Collection::dragDataSource
 
 */
@property (nonatomic, weak) id<I3DragDataSource> dragDataSource;


@end
