//
//  AVENetworkPriority.m
//  Avenue
//
//  Created by MediaHound on 11/17/14.
//
//

#import "AVENetworkPriority.h"


@interface AVENetworkPriority ()

@property (nonatomic, readwrite) AVENetworkPriorityLevel level;

@property (nonatomic, getter=isPostponeable, readwrite) BOOL postponeable;

@end


@implementation AVENetworkPriority

+ (instancetype)priorityWithLevel:(AVENetworkPriorityLevel)level
{
    return [self priorityWithLevel:level postponeable:YES];
}

+ (instancetype)priorityWithLevel:(AVENetworkPriorityLevel)level postponeable:(BOOL)postponeable
{
    AVENetworkPriority* priority = [[self alloc] init];
    priority.level = level;
    priority.postponeable = postponeable;
    return priority;
}

@end


@implementation AVENetworkPriority (Internal)

- (instancetype)priorityByMergingPriority:(AVENetworkPriority*)priority
{
    if (!priority) {
        return self;
    }
    
    AVENetworkPriority* mergedPriority = [AVENetworkPriority priorityWithLevel:self.level
                                                                  postponeable:self.postponeable && priority.postponeable];
    return mergedPriority;
}

@end