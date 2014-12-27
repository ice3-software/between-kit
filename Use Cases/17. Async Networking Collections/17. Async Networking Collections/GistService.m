//
//  GistService.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "GistService.h"
#import "Routing.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>


#define BAD_GIST_DATA @{@"id": @"___", @"description": @"I will fail"}
#define BAD_GIST_UPPER_BOUND 12
#define BAD_GIST_LOWER_BOUND 5
#define FAKE_NETWORK_LATENCY_SEC 2


@interface GistService ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end

@implementation GistService

-(id) init{
    
    self = [super init];
    
    if(self){
        _requestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

-(NSArray *) polutedGistArray:(NSArray *)gists{

    NSInteger badGistFrequency = arc4random() % BAD_GIST_UPPER_BOUND + BAD_GIST_LOWER_BOUND;
    NSMutableArray *polutedGists = [[NSMutableArray alloc] init];
    
    for(NSInteger i = 0; i < gists.count; ++i){
        if(!(i % badGistFrequency)){
            [polutedGists addObject:BAD_GIST_DATA];
        }
        [polutedGists addObject:gists[i]];
    }

    return polutedGists;
}

-(void) findGistsWithCompleteBlock:(void(^)(NSArray *gists)) complete withFailBlock:(void(^)()) fail{
    
    [self.requestManager GET:GISTS_URL_FOR_GISTS() parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        /// @note So here we map the array of Gist JSON objects to an array of 'empty' gists
        /// We've intentionally thrown away the body of the Gist data so that we can illustrate
        /// making another request later and retrieving the rest of it..
        /// We also intentionally polute the array with erroneous data so that we can test
        /// how to UI reacts to failing requests.
        
        NSArray *gists = [self polutedGistArray:responseObject];
        NSMutableArray *emptyGists = [[NSMutableArray alloc] init];
        
        for(NSDictionary *gistJson in gists){
            
            GistDescriptor *gistDescriptor = [[GistDescriptor alloc] init];
            
            gistDescriptor.githubId = gistJson[@"id"];
            gistDescriptor.gistDescription = gistJson[@"description"];
            
            [emptyGists addObject:gistDescriptor];
        }
        
        NSArray *immutableCopy = [NSArray arrayWithArray:emptyGists];
        complete(immutableCopy);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed.. %@", error);
        fail();

    }];
}

-(void) findGistByGithubId:(NSString *)githubId withCompleteBlock:(void(^)(Gist *)) complete withFailBlock:(void(^)()) fail{

    
    [self.requestManager GET:GISTS_URL_FOR_GIST_WITH_ID(githubId) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *gistDictionary = responseObject;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        Gist *gist = [[Gist alloc] initWithGithubId:githubId];
        
        gist.gistDescription = gistDictionary[@"description"];
        gist.ownerUrl = gistDictionary[@"owner"][@"url"];
        gist.commentsCount = gistDictionary[@"comments"];
        gist.createdAt = [formatter dateFromString:gistDictionary[@"created_at"]];
        
        /// @note Itentionally fake network latency so that we can test how the UI responds

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FAKE_NETWORK_LATENCY_SEC*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            complete(gist);
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
        /// @note Itentionally fake network latency so that we can test how the UI responds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FAKE_NETWORK_LATENCY_SEC*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fail();
        });

    }];
    
}

@end
