//
//  I3GistCollectionViewCell.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3GistCollectionViewCell.h"

NSString *const I3GistCollectionViewCellIdentifier = @"I3GistCollectionViewCell";

@implementation I3GistCollectionViewCell

-(void) highlightAsFailed:(void(^)()) animationComplete{

    [self.downloadingIndicator stopAnimating];
    
    [UIView animateWithDuration:0.75 animations:^{
        self.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:3 animations:^{
            self.alpha = 0.2;
        } completion:^(BOOL finished) {
            animationComplete();
        }];
    }];
    
}

@end
