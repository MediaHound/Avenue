//
//  AVERequestBuilder.h
//  Avenue
//
//  Created by MediaHound on 12/10/14.
//
//

#import <AFNetworking/AFNetworking.h>

@protocol AVERequestOperation;

NS_ASSUME_NONNULL_BEGIN


/**
 * A Request Builder is responsible for building Request Operations.
 * A builder must implement the -build:path:parameters:constructingBodyWithBlock: method, 
 * which must return an AFURLConnectionOperation that also implements the AVERequestOperation protocol.
 * For most use cases, the `AVEHTTPRequestOperationBuilder` can be instantiated and used
 * as the builder.
 */
@protocol AVERequestBuilder <NSObject>

@required

/**
 * Builds a request operation that will be submitted to the Network Manager's network request queues.
 * @param method The HTTP method
 * @param path The URL path
 * @param parameters Any parameters to include in the request
 * @param bodyBlock An optional body-constructing block for multipart POST requests
 */
- (AFURLConnectionOperation<AVERequestOperation>*)build:(NSString*)method
                                                   path:(NSString*)path
                                             parameters:(nullable NSDictionary*)parameters
                              constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock;

@end

NS_ASSUME_NONNULL_END
