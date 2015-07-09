//
//  AVENetworkManager.m
//  Avenue
//
//  Created by MediaHound on 2/20/14.
//  Copyright (c) 2014 Media Hound. All rights reserved.
//

#import "AVENetworkManager.h"
#import "AVENetworkToken+Internal.h"
#import "AVENetworkPriority+Internal.h"
#import "AVERequestOperation.h"

//#import <AgnosticLogger/AgnosticLogger.h>
#import <KVOController/FBKVOController.h>


@interface AVENetworkManager ()

@property (strong, nonatomic) NSOperationQueue* fastRequestQueue;
@property (strong, nonatomic) NSOperationQueue* slowRequestQueue;
@property (strong, nonatomic) NSOperationQueue* postponedRequestQueue;

@property (strong, nonatomic) NSLock* lock;

@end


@implementation AVENetworkManager

+ (instancetype)sharedManager
{
    static AVENetworkManager* s_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedManager = [[self alloc] init];
    });
    return s_sharedManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _lock = [[NSLock alloc] init];
        
        _fastRequestQueue = [[NSOperationQueue alloc] init];
        _fastRequestQueue.maxConcurrentOperationCount = 4;
        
        _slowRequestQueue = [[NSOperationQueue alloc] init];
        _slowRequestQueue.maxConcurrentOperationCount = 2;
        
        _postponedRequestQueue = [[NSOperationQueue alloc] init];
        _postponedRequestQueue.maxConcurrentOperationCount = 2;
        
        __weak typeof(self) weakSelf = self;
        void (^suspendPostponedQueueIfNecesarry)() = ^{
            const BOOL previousSuspendedState = weakSelf.postponedRequestQueue.suspended;
            const BOOL newSuspendedState = !(weakSelf.slowRequestQueue.operationCount == 0 && weakSelf.fastRequestQueue.operationCount == 0);
            
            weakSelf.postponedRequestQueue.suspended = newSuspendedState;
            
            if (previousSuspendedState != newSuspendedState) {
                if (newSuspendedState) {
//                    AGLLogVerbose(@"[AVENetworkManager] Stopping Postponed Queue");
                    for (AFURLConnectionOperation<AVERequestOperation>* op in weakSelf.postponedRequestQueue.operations) {
                        if (op.isExecuting) {
//                            AGLLogInfo(@"Stopping executing postpned task and putting back in postponed queue: %@ ,", op.url);
                            [weakSelf postponeTask:op];
                        }
                    }
                }
                else {
//                    AGLLogVerbose(@"[AVENetworkManager] Starting Postponed Queue");
                }
            }
        };
        
        // suspend slowQueue while fastQueue is active
        [self.KVOController observe:self.fastRequestQueue
                            keyPath:@"operationCount"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary* change) {
                                  weakSelf.slowRequestQueue.suspended = !!weakSelf.fastRequestQueue.operationCount;
                                  
                                  suspendPostponedQueueIfNecesarry();
                              }];
        [self.KVOController observe:self.slowRequestQueue
                            keyPath:@"operationCount"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary* change) {
                                  suspendPostponedQueueIfNecesarry();
                              }];
        
        [self prepareCache];
    }
    return self;
}

- (void)prepareCache
{
    NSURLCache* URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

- (void)clearCache
{
    NSString* cacheFolderPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    [[NSFileManager defaultManager] removeItemAtPath:cacheFolderPath error:nil];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (AFURLConnectionOperation<AVERequestOperation>*)taskForMethod:(NSString*)method
                                                            URL:(NSString*)URLString
                                                     parameters:(NSDictionary*)parameters
                                      constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
                                                       priority:(AVENetworkPriority*)priority
                                                   networkToken:(AVENetworkToken*)networkToken
                                                        builder:(id<AVERequestBuilder>)builder
{
    AFURLConnectionOperation<AVERequestOperation>* operation = [builder build:method
                                                                         path:URLString
                                                                   parameters:parameters
                                                    constructingBodyWithBlock:bodyBlock];
    operation.method = method;
    operation.url = URLString;
    operation.parameters = parameters;
    operation.priority = priority;
    operation.builder = builder;
    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __weak typeof(operation) weakOp = operation;
    [networkToken onCancel:^{
        if (!weakOp.isCancelled && !weakOp.isFinished) {
//            AGLLogInfo(@"[MHNetworkManager] Cancelled request");
            [weakOp cancel];
        }
    }];
    
    
    __weak typeof(self) weakSelf = self;
    [networkToken onChangePriority:^(AVENetworkPriority* priority) {
        if (priority.level == AVENetworkPriorityLevelHigh) {
//            AGLLogWarn(@"Changing to a High network priority is not supported");
        }
        else if (priority.level == AVENetworkPriorityLevelLow) {
            [weakSelf.lock lock];
            
            AFURLConnectionOperation<AVERequestOperation>* fastTask = [weakSelf existingFastQueueTaskFor:URLString parameters:parameters];
            
            if (fastTask) {
                NSArray* completions = fastTask.completions;
                [fastTask removeAllCompletions];
                [fastTask cancel];
                
                AFURLConnectionOperation<AVERequestOperation>* slowTask = [weakSelf existingSlowQueueTaskFor:URLString parameters:parameters];
                
                priority = [priority priorityByMergingPriority:fastTask.priority];
                
                if (slowTask) { // reuse an executing slow task
//                    AGLLogInfo(@"Changing priority of %@ to LOW, and attaching to existing slowTask", URLString);
                    [slowTask addCompletions:completions];
                    
                    priority = [priority priorityByMergingPriority:slowTask.priority];
                    slowTask.priority = priority;
                }
                else { // add a fresh task to slow queue
//                    AGLLogInfo(@"Changing priority of %@ to LOW, and creating new slowTask", URLString);
                    AFURLConnectionOperation<AVERequestOperation>* task = [weakSelf taskForMethod:method
                                                                                              URL:URLString
                                                                                       parameters:parameters
                                                                        constructingBodyWithBlock:bodyBlock
                                                                                         priority:priority
                                                                                     networkToken:networkToken
                                                                                          builder:builder];
                    [task addCompletions:completions];
                }
            }
            
            [weakSelf.lock unlock];
        }
    }];
    
    NSOperationQueue* queue = nil;
    if (priority.level == AVENetworkPriorityLevelHigh) {
        queue = self.fastRequestQueue;
    }
    else if (priority.level == AVENetworkPriorityLevelLow) {
        queue = self.slowRequestQueue;
    }
    else if (priority.level == AVENetworkPriorityLevelPostponed) {
        queue = self.postponedRequestQueue;
    }
    
    [queue addOperation:operation];
    
    return operation;
}

- (PMKPromise*)GET:(NSString*)URLString
        parameters:(NSDictionary*)parameters
          priority:(AVENetworkPriority*)priority
      networkToken:(AVENetworkToken*)networkToken
           builder:(id<AVERequestBuilder>)builder
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.lock lock];
            
            void (^completion)(id) = ^(id result) {
                if ([result isKindOfClass:NSError.class]) {
                    rejecter(result);
                }
                else {
                    fulfiller(result);
                }
            };
            
            AFURLConnectionOperation<AVERequestOperation>* slowTask = [self existingSlowQueueTaskFor:URLString parameters:parameters];
            AFURLConnectionOperation<AVERequestOperation>* fastTask = [self existingFastQueueTaskFor:URLString parameters:parameters];
            AFURLConnectionOperation<AVERequestOperation>* postponedTask = [self existingPostponedQueueTaskFor:URLString parameters:parameters];
            
            AVENetworkPriority* newPriority = priority;
            if (slowTask) {
                newPriority = [newPriority priorityByMergingPriority:slowTask.priority];
            }
            if (fastTask) {
                newPriority = [newPriority priorityByMergingPriority:fastTask.priority];
            }
            if (postponedTask) {
                newPriority = [newPriority priorityByMergingPriority:postponedTask.priority];
            }
            
            if (priority.level == AVENetworkPriorityLevelLow) {
                if (fastTask && !slowTask.isExecuting) { // reuse existing fast task
                    NSArray* completions = slowTask.completions;
                    [slowTask removeAllCompletions];
                    [slowTask cancel];
                    
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    [fastTask addCompletion:completion];
                    [fastTask addCompletions:completions];
                    [fastTask addCompletions:postponedCompletions];
                    
                    fastTask.priority = newPriority;
                }
                else if (slowTask) { // reuse existing slow task
                    NSArray* completions = fastTask.completions;
                    [fastTask removeAllCompletions];
                    [fastTask cancel];
                    
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    [slowTask addCompletion:completion];
                    [slowTask addCompletions:completions];
                    [slowTask addCompletions:postponedCompletions];
                    
                    slowTask.priority = newPriority;
                }
                else { // add a fresh task to slow queue
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    AFURLConnectionOperation<AVERequestOperation>* task = [self taskForMethod:@"GET"
                                                                                          URL:URLString
                                                                                   parameters:parameters
                                                                    constructingBodyWithBlock:nil
                                                                                     priority:newPriority
                                                                                 networkToken:networkToken
                                                                                      builder:builder];
                    [task addCompletion:completion];
                    [task addCompletions:postponedCompletions];
                }
            }
            else {
                if (slowTask.isExecuting) {
                    NSArray* completions = fastTask.completions;
                    [fastTask removeAllCompletions];
                    [fastTask cancel];
                    
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    [slowTask addCompletion:completion];
                    [slowTask addCompletions:completions];
                    [slowTask addCompletions:postponedCompletions];
                    
                    slowTask.priority = newPriority;
                }
                else if (fastTask) {
                    NSArray* completions = slowTask.completions;
                    [slowTask removeAllCompletions];
                    [slowTask cancel];
                    
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    [fastTask addCompletion:completion];
                    [fastTask addCompletions:completions];
                    [fastTask addCompletions:postponedCompletions];
                    
                    fastTask.priority = newPriority;
                }
                else {
                    NSArray* completions = slowTask.completions;
                    [slowTask removeAllCompletions];
                    [slowTask cancel];
                    
                    NSArray* postponedCompletions = postponedTask.completions;
                    [postponedTask removeAllCompletions];
                    [postponedTask cancel];
                    
                    AFURLConnectionOperation<AVERequestOperation>* task = [self taskForMethod:@"GET"
                                                                                          URL:URLString
                                                                                   parameters:parameters
                                                                    constructingBodyWithBlock:nil
                                                                                     priority:newPriority
                                                                                 networkToken:networkToken
                                                                                      builder:builder];
                    [task addCompletion:completion];
                    [task addCompletions:completions];
                    [task addCompletions:postponedCompletions];
                }
            }
            
            [self.lock unlock];
        });
    }];
}

- (PMKPromise*)POST:(NSString*)URLString
         parameters:(NSDictionary*)parameters
           priority:(AVENetworkPriority*)priority
       networkToken:(AVENetworkToken*)networkToken
            builder:(id<AVERequestBuilder>)builder
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.lock lock];
            
            AFURLConnectionOperation<AVERequestOperation>* task = [self taskForMethod:@"POST"
                                                                                  URL:URLString
                                                                           parameters:parameters
                                                            constructingBodyWithBlock:nil
                                                                             priority:priority
                                                                         networkToken:networkToken
                                                                              builder:builder];
            [task addCompletion:^(id result) {
                if ([result isKindOfClass:NSError.class]) {
                    rejecter(result);
                }
                else {
                    fulfiller(result);
                }
            }];
            
            [self.lock unlock];
        });
    }];
}

- (PMKPromise*)PUT:(NSString*)URLString
        parameters:(NSDictionary*)parameters
          priority:(AVENetworkPriority*)priority
      networkToken:(AVENetworkToken*)networkToken
           builder:(id<AVERequestBuilder>)builder
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.lock lock];
            
            AFURLConnectionOperation<AVERequestOperation>* task = [self taskForMethod:@"PUT"
                                                                                  URL:URLString
                                                                           parameters:parameters
                                                            constructingBodyWithBlock:nil
                                                                             priority:priority
                                                                         networkToken:networkToken
                                                                              builder:builder];
            [task addCompletion:^(id result) {
                if ([result isKindOfClass:NSError.class]) {
                    rejecter(result);
                }
                else {
                    fulfiller(result);
                }
            }];
            
            [self.lock unlock];
        });
    }];
}

- (PMKPromise*)POST:(NSString*)URLString
         parameters:(id)parameters
constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
           priority:(AVENetworkPriority*)priority
       networkToken:(AVENetworkToken*)networkToken
            builder:(id<AVERequestBuilder>)builder
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.lock lock];
            
            AFURLConnectionOperation<AVERequestOperation>* task = [self taskForMethod:@"POST"
                                                                                  URL:URLString
                                                                           parameters:parameters
                                                            constructingBodyWithBlock:bodyBlock
                                                                             priority:priority
                                                                         networkToken:networkToken
                                                                              builder:builder];
            [task addCompletion:^(id result) {
                if ([result isKindOfClass:NSError.class]) {
                    rejecter(result);
                }
                else {
                    fulfiller(result);
                }
            }];
            
            [self.lock unlock];
        });
    }];
}

- (AFURLConnectionOperation<AVERequestOperation>*)existingFastQueueTaskFor:(NSString*)url
                                                                parameters:(NSDictionary*)parameters
{
    return [self existingTaskFor:url parameters:parameters inQueue:self.fastRequestQueue];
}

- (AFURLConnectionOperation<AVERequestOperation>*)existingSlowQueueTaskFor:(NSString*)url
                                                                parameters:(NSDictionary*)parameters
{
    return [self existingTaskFor:url parameters:parameters inQueue:self.slowRequestQueue];
}

- (AFURLConnectionOperation<AVERequestOperation>*)existingPostponedQueueTaskFor:(NSString*)url
                                                                     parameters:(NSDictionary*)parameters
{
    return [self existingTaskFor:url parameters:parameters inQueue:self.postponedRequestQueue];
}

- (AFURLConnectionOperation<AVERequestOperation>*)existingTaskFor:(NSString*)url
                                                       parameters:(NSDictionary*)parameters
                                                          inQueue:(NSOperationQueue*)queue
{
    for (AFURLConnectionOperation<AVERequestOperation>* task in queue.operations) {
        if ((task.isReady || task.isExecuting)
            &&
            !task.isCancelled
            &&
            [task.url isEqualToString:url]
            &&
            ((task.parameters && [task.parameters isEqualToDictionary:parameters])
             ||
             ((!task.parameters) && !parameters))) {
            return task;
        }
    }
    return nil;
}

- (void)postponeAllGETRequests
{
    [self.lock lock];
    
//    AGLLogVerbose(@"Postponing all GET requests");
    
    self.fastRequestQueue.suspended = YES;
    const BOOL initialSlowQueueSuspended = self.slowRequestQueue.suspended;
    self.slowRequestQueue.suspended = YES;
    
    for (AFURLConnectionOperation<AVERequestOperation>* fastTask in self.fastRequestQueue.operations.copy) {
        if (fastTask.priority.isPostponeable) {
            [self postponeTask:fastTask];
        }
    }
    
    for (AFURLConnectionOperation<AVERequestOperation>* slowTask in self.slowRequestQueue.operations.copy) {
        if (slowTask.priority.isPostponeable) {
            [self postponeTask:slowTask];
        }
    }
    
    self.fastRequestQueue.suspended = NO;
    self.slowRequestQueue.suspended = initialSlowQueueSuspended;
    
    [self.lock unlock];
}

- (void)postponeTask:(AFURLConnectionOperation<AVERequestOperation>*)task
{
    NSArray* completions = task.completions;
    [task removeAllCompletions];
    [task cancel];
    
    // add a fresh task to postponed queue
//    AGLLogInfo(@"[AVENetworkManager] Moving task to postponed queue: %@", task.url);
    AFURLConnectionOperation<AVERequestOperation>* newTask = [self taskForMethod:task.method
                                                                             URL:task.url
                                                                      parameters:task.parameters
                                                       constructingBodyWithBlock:nil
                                                                        priority:[[AVENetworkPriority priorityWithLevel:AVENetworkPriorityLevelPostponed] priorityByMergingPriority:task.priority]
                                                                    networkToken:nil
                                                                         builder:task.builder];
    [newTask addCompletions:completions];
}

@end
