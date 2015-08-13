//
//  AVENetworkPriority.h
//  Avenue
//
//  Created by MediaHound on 10/3/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Priority Levels describe how/when a network request is fulfilled compared to other existing network requests.
 */
typedef NS_ENUM(NSInteger, AVENetworkPriorityLevel)
{
    /**
     * Execute as soon as possible.
     * Network requests that populate on screen UI elements should be `High`.
     */
    AVENetworkPriorityLevelHigh,
    
    /**
     * Execute as when all `High` priority requests complete.`
     * Network requests that populate on screen UI elements should be `High`.
     */
    AVENetworkPriorityLevelLow,
    
    /// Private
    AVENetworkPriorityLevelPostponed
};


/**
 * Network priority is described by two properties: *priority level* and *postponeability*.
 * Priority Levels describe how/when a network request is fulfilled compared to other existing network requests.
 * Postponeability indicates whether a the network request can be temporarily postponed, and executed at a later time.
 */
@interface AVENetworkPriority : NSObject

/**
 * Create a priority by specifying a priority level.
 * This request will be postponeable.
 */
+ (instancetype)priorityWithLevel:(AVENetworkPriorityLevel)level;

/** Creates a priority by specifying a priority level and whether it's postponeable.
 */
+ (instancetype)priorityWithLevel:(AVENetworkPriorityLevel)level postponeable:(BOOL)postponeable;

/// The priority level
@property (nonatomic, readonly) AVENetworkPriorityLevel level;

/// Whether the associated network request can be postponed.
@property (nonatomic, getter=isPostponeable, readonly) BOOL postponeable;

@end

NS_ASSUME_NONNULL_END
