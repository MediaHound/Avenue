//
//  AVERequestOperation.h
//  Avenue
//
//  Created by MediaHound on 12/10/14.
//
//

@protocol AVERequestBuilder;
@class AVENetworkPriority;

NS_ASSUME_NONNULL_BEGIN


/**
 * All operations that are built by a `AVERequestBuilder` must inherit from AFURLConnectionOperation
 * and also implement the `AVERequestOperation` protocol.
 * `AVERequestOperation` requires properties for storing request information and dealing with completion handlers.
 *
 * Typically, you can use the concrete `AVEHTTPRequestoperation`, which implements `AVERequestOperation` for you.
 */
@protocol AVERequestOperation <NSObject>

@required

/**
 * The request's URL.
 */
@property (strong, nonatomic) NSString* url;

/**
 * Any parameters to include with the request.
 */
@property (strong, nullable, nonatomic) NSDictionary* parameters;

/**
 * The HTTP request method.
 */
@property (strong, nonatomic) NSString* method;

/**
 * The network priority for the request.
 */
@property (strong, nonatomic) AVENetworkPriority* priority;

/**
 * A reference to the Request Builder that created this operation.
 */
@property (weak, nonatomic) id<AVERequestBuilder> builder;

/**
 * All completion handlers that will be executed when the request completes.
 */
@property (strong, nonatomic, readonly) NSArray* completions;

/**
 * Add a completion handler.
 */
- (void)addCompletion:(void(^)(id))completion;

/**
 * Add multiple completion handlers.
 */
- (void)addCompletions:(NSArray*)completions;

/**
 * Remove all completion handlers.
 */
- (void)removeAllCompletions;

@end

NS_ASSUME_NONNULL_END
