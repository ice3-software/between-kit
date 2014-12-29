//
//  FormTextFieldCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCellAwareTextField.h"

static NSString* FormTextFieldCellIdentifier = @"FormTextFieldCell";

@interface FormTextFieldCell : UITableViewCell

@property (nonatomic, weak) IBOutlet TableViewCellAwareTextField *textField;

@property (nonatomic, weak) IBOutlet UIView *moveAccessory;

@end
