//
//  I3TodoCell.h
//
//  Created by Stephen Fortune on 13/12/2013.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIInsetLabel.h"

@interface I3TodoCell : UITableViewCell

@property (nonatomic, strong) UIColor* cellColour;
@property (nonatomic, readonly, strong) UIInsetLabel* label;

@end
