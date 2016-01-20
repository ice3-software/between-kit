//
//  GistService.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gist.h"

@interface GistService : NSObject

-(void) findGistsWithCompleteBlock:(void(^)(NSArray *gists)) complete withFailBlock:(void(^)()) fail;

-(void) findGistByGithubId:(NSString *)githubId withCompleteBlock:(void(^)(Gist *)) complete withFailBlock:(void(^)()) fail;

@end
