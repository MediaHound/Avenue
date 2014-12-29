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
 * @param networkToken A network token which will be associated with this network request.
 *        Use the network token to cancel or re-prioritize this network reqeust.
 * @param priority The network priority to indicate when/how this request should be scheduled
 * @param builder A builder to construct the underlying request operation.
 */
- (PMKPromise*)GET:(NSString*)URLString
        parameters:(NSDictionary*)parameters
      networkToken:(AVENetworkToken*)networkToken
          priority:(AVENetworkPriority*)priority
           builder:(id<AVERequestBuilder>)builder;

/**
 * Executes a POST request.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param builder A builder to construct the underlying request operation
 */
- (PMKPromise*)POST:(NSString*)URLString
         parameters:(NSDictionary*)parameters
            builder:(id<AVERequestBuilder>)builder;

/**
 * Executes a POST request with access to modify the body.
 * @param URLString The URL endpoint
 * @param parameters Any HTTP parameters for the request
 * @param bodyBlock A block to execute to add body data.
 * @param builder A builder to construct the underlying request operation
 */
- (PMKPromise*)POST:(NSString*)URLString
         parameters:(id)parameters
constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
            builder:(id<AVERequestBuilder>)builder;

/**
 * Postpone all GET network requests, except for those that are priorizited as unpostponeable.
 */
- (void)postponeAllGETRequests;

@end
