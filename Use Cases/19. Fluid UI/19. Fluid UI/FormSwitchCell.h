//
//  FormSwitchCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFormCell.h"
#import "ParentAwareSwitch.h"

static NSString* FormSwitchCellIdentifier = @"FormSwitchCell";

@interface FormSwitchCell : AbstractFormCell

@property (nonatomic, weak) IBOutlet ParentAwareSwitch *component;

@end
