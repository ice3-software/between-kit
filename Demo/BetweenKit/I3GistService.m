//
//  I3GistService.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3GistService.h"
#import "I3GistRouting.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>


@interface I3GistService ()

/// @note We should really be injecting this. Instead we're using a shared, static
/// singleton, retrieved in the ctor.

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end

@implementation I3GistService

-(id) init{
    
    self = [super init];
    
    if(self){
        _requestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

-(void) findGistsWithCompleteBlock:(void(^)(NSArray *gists)) complete withFailBlock:(void(^)()) fail{

    NSLog(@"Finding gists... %@", GISTS_URL_FOR_GISTS());
    
    [self.requestManager GET:GISTS_URL_FOR_GISTS() parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Found gists: %@", responseObject);
        
        /// @note So here we map the array of Gist JSON objects to an array of 'empty' gists
        /// We've intentionally thrown away the body of the Gist data so that we can illustrate
        /// making another request later and retrieving the rest of it..
        
        NSArray *gists = responseObject;
        NSMutableArray *emptyGists = [[NSMutableArray alloc] init];
        
        for(NSDictionary *gistJson in gists){
            I3Gist *gist = [[I3Gist alloc] initWithGithubId:gistJson[@"id"] andDescription:gistJson[@"description"]];
            [emptyGists addObject:gist];
        }
        
        NSArray *immutableCopy = [NSArray arrayWithArray:emptyGists];
        complete(immutableCopy);
        
        NSLog(@"Complete: %@", immutableCopy);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail();
        NSLog(@"Failed finding gists!");
    }];
}

-(void) downloadFullGist:(I3Gist *)emptyGist withCompleteBlock:(void(^)()) complete withFailBlock:(void(^)()) fail{

    NSLog(@"Finding gists... %@", GISTS_URL_FOR_GIST_WITH_ID(emptyGist.githubId));

    emptyGist.state = I3GistStateDownloading;
    
    [self.requestManager GET:GISTS_URL_FOR_GIST_WITH_ID(emptyGist.githubId) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *gistDictionary = responseObject;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        emptyGist.ownerUrl = gistDictionary[@"owner"][@"url"];
        emptyGist.commentsCount = gistDictionary[@"comments"];
        emptyGist.createdAt = [formatter dateFromString:gistDictionary[@"created_at"]];
        emptyGist.state = I3GistStateDownloaded;
        
        complete();

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        emptyGist.state = I3GistStateEmpty;
        fail();

    }];
    
}

@end
