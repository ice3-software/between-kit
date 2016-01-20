//
//  Gist.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 
 Simple class that contains metadata about a gist. Used as a placeholder containing data to
 render on the screen in the meantime, the actual githubId of the Gist so that 
 we can make a subsequent request later on to retrieve the full Gist, and a boolean
 flag indicating the state of an associated full Gist download.
 
 */
@interface GistDescriptor : NSObject<NSCopying>

@property (nonatomic) BOOL hasFailed;

@property (nonatomic, copy) NSString *githubId;

@property (nonatomic, copy) NSString *gistDescription;

@end


/**
 
 The full Gist. Must be retrieved with a githubId.
 
 */
@interface Gist : NSObject <NSCopying>

@property (nonatomic, copy) NSString *githubId;

@property (nonatomic, copy) NSString *gistDescription;

@property (nonatomic, copy) NSString *ownerUrl;

@property (nonatomic, copy) NSNumber *commentsCount;

@property (nonatomic, copy) NSDate *createdAt;

@property (nonatomic, copy, readonly) NSString *formattedCreatedAt;

-(id) initWithGithubId:(NSString *)githubId;

@end
