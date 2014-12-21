//
//  I3GistCollectionViewCell.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const I3GistCollectionViewCellIdentifier;

@interface I3GistCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentsCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *createdAtLabel;

@property (nonatomic, weak) IBOutlet UILabel *ownerUrlLabel;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *downloadingIndicator;

-(void) highlightAsFailed:(void(^)()) animationComplete;

@end
