//
//  FormTextFieldCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* FormTextFieldCellIdentifier = @"FormTextFieldCell";

@interface FormTextFieldCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end
