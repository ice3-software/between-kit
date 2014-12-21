//
//  I3GistData.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I3Gist.h"

@implementation I3Gist

@dynamic formattedCreatedAt;

-(id) initWithGithubId:(NSString *)githubId andDescription:(NSString *)description{
    
    self = [super init];
    
    if(self){
        _githubId = githubId;
        _gistDescription = [description isKindOfClass:[NSNull class]] ? nil : description;
        _state = I3GistStateEmpty;
    }
    
    return self;
}

-(id) copyWithZone:(NSZone *)zone{
    
    I3Gist *copy = [[[self class] alloc] initWithGithubId:_githubId andDescription:_gistDescription];
    
    copy.state = _state;
    copy.ownerUrl = _ownerUrl;
    copy.commentsCount = _commentsCount;
    copy.createdAt = _createdAt;
    
    return copy;
}

-(NSString *)formattedCreatedAt{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss, dd/MM/yyyy"];

    NSLog(@"Formatting %@, into %@", _createdAt, [formatter stringFromDate:_createdAt]);
    
    return [formatter stringFromDate:_createdAt];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@, %@, %@, %@", self.gistDescription, self.formattedCreatedAt, [self.commentsCount stringValue], self.ownerUrl];
}


@end

