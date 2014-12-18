//
//  I3Logging.h
//  BetweenKit
//
//  Created by Stephen Fortune on 14/09/2014.
//  Copyright (c) 2013 IceCube Software Ltd. All rights reserved.
//


/** 
 
 Environment-specific logging macro. Should be used in place of NSLog.
 
 */

#ifndef DND_LOG
    #ifdef DEBUG
        #define DND_LOG(s, ...) NSLog(@"%@ %@", NSStringFromSelector(_cmd), [NSString stringWithFormat:s, ##__VA_ARGS__])
    #else
        #define DND_LOG(s, ...) {}
        #warning "DND_LOG supressed."
    #endif
#endif
