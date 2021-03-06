//
//  AVEImageFetcher.h
//  Avenue
//
//  Created by MediaHound on 10/29/14.
//
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

#import "AVENetworkPriority.h"
#import "AVENetworkToken.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * Use the `AVEImageFetcher` to asynchronously fetch remote images.
 * Images are cached both on-disk and in memory.
 * Image requests can take an optional priority and network token to allow for greater network control.
 */
@interface AVEImageFetcher : NSObject

/**
 * Returns the shared image fetcher.
 */
+ (instancetype)sharedFetcher;

/**
 * Fetches a remote image.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)fetchImage:(NSString*)url;

/**
 * Fetches a remote image.
 * To cancel or reprioritize, the image network request, pass in a `networkToken`.
 * To specify the priority that the image network request should be executed at, pass a `priority`.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)fetchImage:(NSString*)url
                 priority:(nullable AVENetworkPriority*)priority
             networkToken:(nullable AVENetworkToken*)networkToken;

/**
 * Remove all images from cache.
 */
- (void)clearCache;

/**
 * Returns whether the image at the given url has already been fetched and is in the cache.
 */
- (BOOL)haveImageForURL:(NSString*)url;

@end

NS_ASSUME_NONNULL_END
