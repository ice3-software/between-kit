//
//  I3GistData.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 The states that the Gist model can be in:
 
 - I3GistStateEmpty: empty, containing only its githubId and description. In
   this state, brief information about the gist can be rendered to screen, but
   the juicy info about the gist must be retrieved from the API
 - I3GistStateDownloading: the juicy info about the Gist is currently being 
   downloaded
 - I3GistStateDownloaded: all the juicy info for this gist has been downloaded
   and the object has been hydrated with it.
 
 */
typedef NS_ENUM(NSInteger, I3GistState) {
    I3GistStateEmpty,
    I3GistStateDownloading,
    I3GistStateDownloaded,
    I3GistStateFailed,
};


@interface I3Gist : NSObject <NSCopying>

@property (nonatomic) I3GistState state;

@property (nonatomic, readonly, copy) NSString *githubId;

@property (nonatomic, readonly, copy) NSString *gistDescription;

@property (nonatomic, copy) NSString *ownerUrl;

@property (nonatomic, copy) NSNumber *commentsCount;

@property (nonatomic, copy) NSDate *createdAt;

@property (nonatomic, copy, readonly) NSString *formattedCreatedAt;

-(id) initWithGithubId:(NSString *)githubId andDescription:(NSString *)description;

@end
