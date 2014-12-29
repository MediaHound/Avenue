//
//  AVENetworkToken+Internal.h
//  Avenue
//
//  Created by MediaHound on 12/8/14.
//
//

#import "AVENetworkToken.h"

typedef void (^AVECancelHandler)(void);
typedef void (^AVEChangePriorityHandler)(AVENetworkPriority*);


@interface AVENetworkToken (Internal)

- (void)onCancel:(AVECancelHandler)cancelHandler;

- (void)onChangePriority:(AVEChangePriorityHandler)changePriorityHandler;

@end
