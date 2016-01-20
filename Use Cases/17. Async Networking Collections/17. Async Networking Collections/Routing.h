//
//  I3GistRouting.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2016 stephen fortune. All rights reserved.
//

#ifndef BetweenKit_I3Config_h
#define BetweenKit_I3Config_h

/**
 
 @note I've been a bit lazy and put all the routing code and URL config in
 macros. Ordinarily, I'd may move the constants out to config files and build
 a 'router' class that would handle actually assembling the URLs.
 
 */

#define GISTS_BASE_URL              @"https://api.github.com"
#define GISTS_ENDPOINT_GET_GISTS    @"/gists/public"
#define GISTS_ENDPOINT_GET_GIST     @"/gists/:id"

/**
 
 Simple macro function that constructs the URL for a gist with a specific
 ID from the appropriate routes.
 
 */
#define GISTS_URL_FOR_GIST_WITH_ID(githubId)                    \
    [[NSString stringWithFormat:@"%@%@",                        \
        GISTS_BASE_URL,                                         \
        GISTS_ENDPOINT_GET_GIST]                                \
            stringByReplacingOccurrencesOfString:@":id"         \
            withString:githubId]

/**
 
 Simple macro function that constructs the URL for public gists from the
 appropriate routes
 
 */
#define GISTS_URL_FOR_GISTS()                                   \
    [NSString stringWithFormat:@"%@%@",                         \
        GISTS_BASE_URL,                                         \
        GISTS_ENDPOINT_GET_GISTS]

#endif
