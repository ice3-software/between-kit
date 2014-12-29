//
//  FormTextAreaCell.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 28/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCellAwareTextView.h"

static NSString* FormTextAreaCellIdentifier = @"FormTextAreaCell";

@interface FormTextAreaCell : UITableViewCell

@property (nonatomic, weak) IBOutlet TableViewCellAwareTextView *textArea;

@property (nonatomic, weak) IBOutlet UIView *moveAccessory;

@end
