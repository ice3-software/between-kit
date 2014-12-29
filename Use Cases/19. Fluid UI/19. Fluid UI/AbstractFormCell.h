//
//  AbstractFormCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentCellAware.h"

/**
 
 Abstract base class for each form table view cell. Concrete subclasses 
 should re-declare the `component` property as a concrete type, e.g.
 
 ``` Object-C

 @property (nonatomic, weak) IBOutlet ParentAwareSwitch *component;

 ```
 
 Behind the scenes, this class also programmically sets the cells' 
 various `backgroundColor`a to `clearColor` and adds a shadow to the
 `contentView` layer, as well as implicitly assigning `self` as its
 `component`'s parent.
 
 */
@interface AbstractFormCell : UITableViewCell

@property (nonatomic, weak) id<ParentCellAware> component;

@property (nonatomic, weak) IBOutlet UIView *moveAccessory;

@end
