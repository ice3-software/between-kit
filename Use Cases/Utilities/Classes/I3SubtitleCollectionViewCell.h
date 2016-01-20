//
//  I3SubtitleCollectionViewCell.h
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const I3SubtitleCollectionViewCellIdentifier;

@interface I3SubtitleCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;

@property (nonatomic, weak) IBOutlet UITextView *subtitle;

@end
