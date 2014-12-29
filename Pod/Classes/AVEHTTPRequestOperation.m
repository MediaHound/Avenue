//
//  AVEHTTPRequestOperation.m
//  Avenue
//
//  Created by MediaHound on 10/3/14.
//
//

#import "AVEHTTPRequestOperation.h"
#import "AVENetworkPriority.h"

//#import <AgnosticLogger/AgnosticLogger.h>


@interface AVEHTTPRequestOperation ()

@property (strong, nonatomic) NSMutableArray* internalCompletions;

@end


@implementation AVEHTTPRequestOperation

@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize method = _method;
@synthesize priority = _priority;
@synthesize builder = _builder;
@synthesize completions = _completions;

- (instancetype)init
{
    if (self = [super init]) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest*)urlRequest
{
    if (self = [super initWithRequest:urlRequest]) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    _internalCompletions = [NSMutableArray array];
}

- (void)addCompletion:(void(^)(id))completion
{
    if (completion) {
        @synchronized (self) {
            [self.internalCompletions addObject:completion];
        }
    }
}

- (void)addCompletions:(NSArray*)completions
{
    if (completions.count) {
        @synchronized (self) {
            [self.internalCompletions addObjectsFromArray:completions];
        }
    }
}

- (void)removeAllCompletions
{
    @synchronized (self) {
        [self.internalCompletions removeAllObjects];
    }
}

- (NSArray*)completions
{
    @synchronized (self) {
        return self.internalCompletions.copy;
    }
}

- (void)fireCompletionsWith:(id)obj
{
    NSArray* completionsCopy = self.completions;
    for (void(^completion)(id) in completionsCopy) {
        completion(obj);
    }
}

- (NSString*)priorityDescription
{
    NSString* priorityName = nil;
    switch (self.priority.level) {
        case AVENetworkPriorityLevelHigh: priorityName = @"High"; break;
        case AVENetworkPriorityLevelLow: priorityName = @"Low"; break;
        case AVENetworkPriorityLevelPostponed: priorityName = @"Postponed"; break;
    }
    return priorityName;
}

- (void)start
{
    if (!self.isCancelled) {
//        NSString* priorityName = [self priorityDescription];
//        AGLLogInfo(@"HTTPReqOp started: %@ (q %@)", self.url, priorityName);
        
        __weak typeof(self) weakSelf = self;
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
//            AGLLogInfo(@"HTTPReqOp succesfull: %@ (q %@)(c %d)", self.url, priorityName, self.completions.count);
            [weakSelf fireCompletionsWith:responseObject];
        }
                                    failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                        [weakSelf fireCompletionsWith:error];
                                    }];
    }
    
    [super start];
}

@end
