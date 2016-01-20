//
//  TableViewCellAwareButton.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2016 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentCellAware.h"

@interface ParentAwareButton : UIButton <ParentCellAware>

@property (nonatomic, weak) UITableViewCell *parentCell;

@end
