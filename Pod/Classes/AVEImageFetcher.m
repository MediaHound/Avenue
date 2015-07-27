//
//  AVEImageFetcher.m
//  Avenue
//
//  Created by MediaHound on 10/29/14.
//
//

#import "AVEImageFetcher.h"
#import "AVENetworkManager.h"
#import "AVEHTTPRequestOperationBuilder.h"
#import "AVEError+Internal.h"


static NSString* const kFolderName = @"generic_images_cache";


@interface AVEImageFetcher ()

@property (strong, nonatomic) AVEHTTPRequestOperationBuilder* builder;

@property (strong, nonatomic) NSCache* inMemoryCache;
@property (strong, nonatomic) NSString* cachePath;

@end


@implementation AVEImageFetcher

+ (instancetype)sharedFetcher
{
    static AVEImageFetcher* s_sharedFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedFetcher = [[self alloc] init];
    });
    return s_sharedFetcher;
}

- (instancetype)init
{
    if (self = [super init]) {
        _builder = [[AVEHTTPRequestOperationBuilder alloc] init];
        _builder.requestSerializer = [AFHTTPRequestSerializer serializer];
        _builder.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _inMemoryCache = [[NSCache alloc] init];
        
        _cachePath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0], kFolderName];
        
        // make the cache directory if necessary
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
        }
    }
    return self;
}

- (BOOL)haveImageForURL:(NSString*)url
{
    // Will early exit, and not touch the disk, if it's already in the inMemoryCache
    return ([self.inMemoryCache objectForKey:url]
            || [[NSFileManager defaultManager] fileExistsAtPath:[self cachedPathForURL:url]]);
}

- (UIImage*)imageForURL:(NSString*)url
{
    UIImage* image = [self.inMemoryCache objectForKey:url];
    if (image) {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:[self cachedPathForURL:url]];
    if (!image) {
        return nil;
    }
    
    [self.inMemoryCache setObject:image forKey:url];
    
    return image;
}

- (void)addImage:(UIImage*)image imageData:(NSData*)data forURL:(NSString*)url
{
    [data writeToFile:[self cachedPathForURL:url] atomically:YES];
    [self.inMemoryCache setObject:image forKey:url];
}

- (NSString*)cachedPathForURL:(NSString*)url
{
    return [NSString stringWithFormat:@"%@/%@", self.cachePath, @(url.hash)];
}

- (void)clearCache
{
    [[NSFileManager defaultManager] removeItemAtPath:self.cachePath
                                               error:nil];
    [self.inMemoryCache removeAllObjects];
}

- (AnyPromise*)fetchImage:(NSString*)url
{
    return [self fetchImage:url
                   priority:[AVENetworkPriority priorityWithLevel:AVENetworkPriorityLevelHigh]
               networkToken:nil];
}

- (AnyPromise*)fetchImage:(NSString*)url
                 priority:(AVENetworkPriority*)priority
             networkToken:(AVENetworkToken*)networkToken
{
    __weak typeof(self) weakSelf = self;
    return [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([weakSelf haveImageForURL:url]) {
                UIImage* image = [weakSelf imageForURL:url];
                [weakSelf decompressImage:image];
                resolve(image);
            }
            else {
                AnyPromise* getPromise = [[AVENetworkManager sharedManager] GET:url
                                                                     parameters:nil
                                                                       priority:priority
                                                                   networkToken:networkToken
                                                                        builder:self.builder].thenOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                                                ^id (id response) {
                    UIImage* image = [UIImage imageWithData:response];
                    if (image) {
                        [weakSelf addImage:image imageData:response forURL:url];
                        
                        [weakSelf decompressImage:image];
                        
                        return image;
                    }
                    else {
                        return AVEErrorMake(AVEInvalidImageResponseDataError, @{});
                    }
                });
                resolve(getPromise);
            }

        });
    }];
}

- (void)decompressImage:(UIImage*)image
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    UIGraphicsEndImageContext();
}

@end
