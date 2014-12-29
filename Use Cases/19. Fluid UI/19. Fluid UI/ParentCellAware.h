
//
//  TableViewCellAware.h
//  19. Fluid UI
//
//  Created by Stephen Fortune on 29/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

@protocol ParentCellAware <NSObject>

@required

@property (nonatomic, weak) UITableViewCell *parentCell;

@end