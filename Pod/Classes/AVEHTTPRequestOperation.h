//
//  AVEHTTPRequestOperation.h
//  Avenue
//
//  Created by MediaHound on 10/3/14.
//
//

#import <AFNetworking/AFNetworking.h>
#import "AVERequestOperation.h"


/**
 * A simple `AVERequestOperation` that will be used by the `AVEHTTPRequestOperationBuilder`.
 */
@interface AVEHTTPRequestOperation : AFHTTPRequestOperation <AVERequestOperation>

@end
