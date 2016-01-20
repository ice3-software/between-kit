//
//  AvailableGistCollectionViewCell.h
//  BetweenKit
//
//  Created by Stephen Fortune on 21/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const AvailableGistCollectionViewCellIdentifier;

@interface AvailableGistCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end
