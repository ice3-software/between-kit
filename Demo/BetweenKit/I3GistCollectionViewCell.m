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

-(void) setIsEmptyGist:(BOOL) isEmptyGist{
    
    if(isEmptyGist){
        
        self.descriptionLabel.alpha = 1;
        self.commentsCountLabel.alpha = 0;
        self.createdAtLabel.alpha = 0;
        self.ownerUrlLabel.alpha = 0;

    }
    else{
    
        self.descriptionLabel.alpha = 1;
        self.commentsCountLabel.alpha = 1;
        self.createdAtLabel.alpha = 1;
        self.ownerUrlLabel.alpha = 1;

    }
    
    _isEmptyGist = isEmptyGist;
}

-(void) startDownloadingIndicator{

    [self.downloadingIndicator startAnimating];
    self.descriptionLabel.alpha = 0.2;
    
}

-(void) highlightAsFailed:(void(^)()) animationComplete{

    [UIView animateWithDuration:0.2 animations:^{
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
