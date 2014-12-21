//
//  I3GistData.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface I3Gist : NSObject <NSCopying>

@property (nonatomic) BOOL hasFailed;

@property (nonatomic, copy) NSString *githubId;

@property (nonatomic, copy) NSString *gistDescription;

@property (nonatomic, copy) NSString *ownerUrl;

@property (nonatomic, copy) NSNumber *commentsCount;

@property (nonatomic, copy) NSDate *createdAt;

@property (nonatomic, copy, readonly) NSString *formattedCreatedAt;

-(id) initWithGithubId:(NSString *)githubId;

@end
