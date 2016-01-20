//
//  FormButtonCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFormCell.h"
#import "ParentAwareButton.h"

static NSString* FormButtonCellIdentifier = @"FormButtonCell";

@interface FormButtonCell : AbstractFormCell

@property (nonatomic, weak) IBOutlet ParentAwareButton *component;

@end
