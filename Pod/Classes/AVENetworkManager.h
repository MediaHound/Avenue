//
//  MHNetworkManager.h
//  Avenue
//
//  Created by MediaHound on 2/20/14.
//  Copyright (c) 2014 Media Hound. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <PromiseKit/PromiseKit.h>

#import "AVENetworkPriority.h"
#import "AVENetworkToken.h"
#import "AVERequestBuilder.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * Use the `AVENetworkManager` to execute network requests.
 * GET and POST requests are supported.
 * Promises allow a requester to handle success or failure responses.
 */
@interface AVENetworkManager : NSObject

/**
 * Returns the shared network manager.
 */
+ (instancetype)sharedManager;

/**
 * Executes a GET request.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param priority The network priority to indicate when/how this request should be scheduled
 * @param networkToken A network token which will be associated with this network request.
 *        Use the network token to cancel or re-prioritize this network reqeust.
 * @param builder A builder to construct the underlying request operation.
 */
- (AnyPromise*)GET:(NSString*)URLString
        parameters:(nullable NSDictionary*)parameters
          priority:(nullable AVENetworkPriority*)priority
      networkToken:(nullable AVENetworkToken*)networkToken
           builder:(id<AVERequestBuilder>)builder;

/**
 * Executes a POST request.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param priority The network priority to indicate when/how this request should be scheduled
 * @param networkToken A network token which will be associated with this network request.
 *        Use the network token to cancel or re-prioritize this network reqeust.
 * @param builder A builder to construct the underlying request operation
 */
- (AnyPromise*)POST:(NSString*)URLString
         parameters:(nullable NSDictionary*)parameters
           priority:(nullable AVENetworkPriority*)priority
       networkToken:(nullable AVENetworkToken*)networkToken
            builder:(id<AVERequestBuilder>)builder;

/**
 * Executes a PUT request.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param priority The network priority to indicate when/how this request should be scheduled
 * @param networkToken A network token which will be associated with this network request.
 *        Use the network token to cancel or re-prioritize this network reqeust.
 * @param builder A builder to construct the underlying request operation.
 */
- (AnyPromise*)PUT:(NSString*)URLString
        parameters:(nullable NSDictionary*)parameters
          priority:(nullable AVENetworkPriority*)priority
      networkToken:(nullable AVENetworkToken*)networkToken
           builder:(id<AVERequestBuilder>)builder;

/**
 * Executes a POST request with access to modify the body.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param bodyBlock A block to execute to add body data.
 * @param priority The network priority to indicate when/how this request should be scheduled
 * @param networkToken A network token which will be associated with this network request.
 *        Use the network token to cancel or re-prioritize this network reqeust.
 * @param builder A builder to construct the underlying request operation
 */
- (AnyPromise*)POST:(NSString*)URLString
         parameters:(nullable id)parameters
constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
           priority:(nullable AVENetworkPriority*)priority
       networkToken:(nullable AVENetworkToken*)networkToken
            builder:(id<AVERequestBuilder>)builder;

/**
 * Postpone all GET network requests, except for those that are priorizited as unpostponeable.
 */
- (void)postponeAllGETRequests;

/**
 * Remove all cached HTTP responses.
 */
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
