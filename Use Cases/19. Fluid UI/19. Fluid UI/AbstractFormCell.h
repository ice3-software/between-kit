//
//  AbstractFormCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentCellAware.h"

@interface AbstractFormCell : UITableViewCell

@property (nonatomic, weak) IBOutlet id<ParentCellAware> component;

@property (nonatomic, weak) IBOutlet UIView *moveAccessory;

@end
