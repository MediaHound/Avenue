//
//  AVENetworkToken.h
//  Avenue
//
//  Created by MediaHound on 5/22/14.
//  Copyright (c) 2014 Media Hound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVENetworkPriority.h"


/**
 * A network token is used to cancel or change the priority of a network request.
 * As the creator of a network request, you can also create an `AVENetworkToken`.
 * Pass this token when creating a network request. You can then call
 * the `-cancel` or `-changePriority:` methods on the network token.
 * If a network request has already completed, calling methods on its associated
 * network token has no effect.
 */
@interface AVENetworkToken : NSObject

/**
 * Cancel the network request that this token is associated with.
 * If a network request has already completed, calling `-cancel` on its associated
 * network token has no effect.
 */
- (void)cancel;

/**
 * Change the priority of the network request that this token is associated with.
 * If a network request has already completed, calling `-changePriority:` on its associated
 * network token has no effect.
 */
- (void)changePriority:(AVENetworkPriority*)priority;

@end
