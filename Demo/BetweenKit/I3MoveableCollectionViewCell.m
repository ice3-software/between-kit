//
//  I3MoveableCollectionViewCell.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3MoveableCollectionViewCell.h"

NSString *const I3MoveableCollectionViewCellIdentifier = @"I3MoveableCollectionViewCell";

@implementation I3MoveableCollectionViewCell

-(IBAction) glowMoveAccessory:(id) sender{
    self.moveAccessory.backgroundColor = [UIColor lightGrayColor];
}

-(IBAction) darkenMoveAccessory:(id) sender{
    self.moveAccessory.backgroundColor = [UIColor darkGrayColor];
}

@end
