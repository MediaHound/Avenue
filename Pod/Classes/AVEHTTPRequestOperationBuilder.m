//
//  AVEHTTPRequestOperationBuilder.m
//  Avenue
//
//  Created by MediaHound on 10/31/14.
//
//

#import "AVEHTTPRequestOperationBuilder.h"
#import "AVEHTTPRequestOperation.h"


@implementation AVEHTTPRequestOperationBuilder

- (instancetype)init
{
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL*)url
{
    if (self = [super init]) {
        // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
        if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
            url = [url URLByAppendingPathComponent:@""];
        }
        
        self.baseURL = url;
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    return self;
}

- (AFURLConnectionOperation<AVERequestOperation>*)build:(NSString*)method
                                                   path:(NSString*)path
                                             parameters:(NSDictionary*)parameters
                              constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
{
    NSString* urlString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    NSMutableURLRequest* request = nil;
    if (bodyBlock) {
        request = [self.requestSerializer multipartFormRequestWithMethod:method
                                                               URLString:urlString
                                                              parameters:parameters
                                               constructingBodyWithBlock:bodyBlock
                                                                   error:nil];
    }
    else {
        request = [self.requestSerializer requestWithMethod:method
                                                  URLString:urlString
                                                 parameters:parameters
                                                      error:nil];
    }
    
    AVEHTTPRequestOperation* operation = [[AVEHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.securityPolicy = self.securityPolicy;
    
    return operation;
}

@end
