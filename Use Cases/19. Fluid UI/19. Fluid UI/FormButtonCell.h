//
//  FormButtonCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* FormButtonCellIdentifier = @"FormButtonCell";

@interface FormButtonCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *button;

@end
