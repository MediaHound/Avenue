//
//  AVENetworkPriority+Internal.h
//  Avenue
//
//  Created by MediaHound on 11/18/14.
//
//

#import "AVENetworkPriority.h"


@interface AVENetworkPriority (Internal)

- (instancetype)priorityByMergingPriority:(AVENetworkPriority*)priority;

@end
