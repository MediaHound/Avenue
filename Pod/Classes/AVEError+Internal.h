//
//  AVEError+Internal.h
//  Avenue
//
//  Created by Dustin Bachrach on 2/10/15.
//
//

#import "AVEError.h"

static inline NSError* AVEErrorMake(NSInteger code, NSDictionary* userInfo)
{
    return [[NSError alloc] initWithDomain:AVEErrorDomain
                                      code:code
                                  userInfo:userInfo];
}
