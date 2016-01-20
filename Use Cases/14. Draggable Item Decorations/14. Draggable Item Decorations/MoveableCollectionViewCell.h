//
//  I3MoveableCollectionViewCell.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MoveableCollectionViewCellIdentifier;

@interface MoveableCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *moveAccessory;

@end
