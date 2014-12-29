//
//  AVENetworkToken.m
//  Avenue
//
//  Created by MediaHound on 5/22/14.
//  Copyright (c) 2014 Media Hound. All rights reserved.
//

#import "AVENetworkToken.h"
#import "AVENetworkToken+Internal.h"

typedef NS_ENUM(NSInteger, AVECancelTokenState)
{
    AVECancelTokenStateReady,
    AVECancelTokenStateCancelled
};


@interface AVENetworkToken ()

@property (strong, nonatomic) NSMutableArray* cancelHandlers;
@property (strong, nonatomic) NSMutableArray* changePriorityHandlers;
@property (nonatomic) AVECancelTokenState cancelState;

@end


@implementation AVENetworkToken

- (instancetype)init
{
    if (self = [super init]) {
        _cancelHandlers = [NSMutableArray array];
        _changePriorityHandlers = [NSMutableArray array];
        _cancelState = AVECancelTokenStateReady;
    }
    return self;
}

- (void)cancel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* cancelHandlersSnapshot = nil;
        @synchronized(self) {
            if (self.cancelState != AVECancelTokenStateReady) {
                return;
            }
            
            self.cancelState = AVECancelTokenStateCancelled;
            
            cancelHandlersSnapshot = self.cancelHandlers.copy;
            self.cancelHandlers = nil;
        }
        
        for (AVECancelHandler handler in cancelHandlersSnapshot) {
            handler();
        }
    });
}

- (void)changePriority:(AVENetworkPriority*)priority
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* changePriorityHandlers = nil;
        @synchronized (self) {
            changePriorityHandlers = self.changePriorityHandlers.copy;
        }
        for (AVEChangePriorityHandler handler in changePriorityHandlers) {
            handler(priority);
        }
    });
}

@end


@implementation AVENetworkToken (Internal)

- (void)onCancel:(AVECancelHandler)cancelHandler
{
    @synchronized(self) {
        if (self.cancelState == AVECancelTokenStateReady) {
            [self.cancelHandlers addObject:cancelHandler];
            return;
        }
    }
    
    cancelHandler();
}

- (void)onChangePriority:(AVEChangePriorityHandler)changePriorityHandler
{
    @synchronized(self) {
        [self.changePriorityHandlers addObject:changePriorityHandler];
    }
}

@end