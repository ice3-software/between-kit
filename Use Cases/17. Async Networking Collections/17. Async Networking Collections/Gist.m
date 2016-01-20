//
//  Gist.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#import "Gist.h"


@implementation Gist

@dynamic formattedCreatedAt;

-(id) initWithGithubId:(NSString *)githubId{

    self = [super init];
    
    if(self){
        _githubId = githubId;
    }
    
    return self;
}

-(id) copyWithZone:(NSZone *)zone{
    
    Gist *copy = [[[self class] alloc] initWithGithubId:_githubId];
    
    copy.ownerUrl = _ownerUrl;
    copy.commentsCount = _commentsCount;
    copy.createdAt = _createdAt;
    
    return copy;
}

-(NSString *)formattedCreatedAt{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss, dd/MM/yyyy"];

    return [formatter stringFromDate:_createdAt];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@, %@, %@, %@", self.gistDescription, self.formattedCreatedAt, [self.commentsCount stringValue], self.ownerUrl];
}

@end


@implementation GistDescriptor

-(id) copyWithZone:(NSZone *)zone{
    
    GistDescriptor *copy = [[[self class] alloc] init];
    
    copy.githubId = _githubId;
    copy.gistDescription = _gistDescription;
    copy.hasFailed = _hasFailed;
    
    return copy;
}

@end
