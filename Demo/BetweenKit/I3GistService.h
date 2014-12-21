//
//  I3GistService.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I3Gist.h"

@interface I3GistService : NSObject

-(void) findGistsWithCompleteBlock:(void(^)(NSArray *gists)) complete withFailBlock:(void(^)()) fail;

-(void) downloadFullGist:(I3Gist *)emptyGist withCompleteBlock:(void(^)()) complete withFailBlock:(void(^)()) fail;

@end
