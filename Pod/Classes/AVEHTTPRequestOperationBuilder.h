//
//  AVEHTTPRequestOperationBuilder.h
//  Avenue
//
//  Created by MediaHound on 10/31/14.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "AVERequestBuilder.h"


/**
 * A simple AVERequestBuilder that can be configured with a baseURL, request/response serializers,
 * and a security policy.
 * 
 * Typically, you can instantiate and configure a single AVEHTTPRequestOperationBuilder,
 * and reususe it when passing in a builder to `AVENetworkManager` methods.
 */
@interface AVEHTTPRequestOperationBuilder : NSObject <AVERequestBuilder>

/**
 * Creates a builder with a base URL.
 */
- (instancetype)initWithBaseURL:(NSString*)url;

/**
 * The builders' base URL
 * All operations built will use this base URL.
 */
@property (strong, nonatomic, readonly) NSURL* baseURL;

/**
 * The request serializer for all built operations
 */
@property (strong, nonatomic) AFHTTPRequestSerializer<AFURLRequestSerialization>* requestSerializer;

/**
 * The response serializer for all built operations
 */
@property (strong, nonatomic) AFHTTPResponseSerializer<AFURLResponseSerialization>* responseSerializer;

/**
 * The security policy for all built operations
 */
@property (strong, nonatomic) AFSecurityPolicy* securityPolicy;

@end
