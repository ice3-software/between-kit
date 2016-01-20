//
//  FormTextFieldCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFormCell.h"
#import "ParentAwareTextField.h"

static NSString* FormTextFieldCellIdentifier = @"FormTextFieldCell";

@interface FormTextFieldCell : AbstractFormCell

@property (nonatomic, weak) IBOutlet ParentAwareTextField *component;

@end
