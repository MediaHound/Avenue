//
//  UIImageView+AVEImageFetcher.h
//  Avenue
//
//  Created by MediaHound on 10/31/14.
//
//

#import <UIKit/UIKit.h>
#import <PromiseKit/PromiseKit.h>

#import "AVENetworkPriority.h"
#import "AVENetworkToken.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * UIImageView extension for loading remote images with:
 *   - Placeholders
 *   - Validity checks
 *   - Network priority
 *   - Cancelation
 *   - Reprioritization
 *   - Cross Fades
 */
@interface UIImageView (AVEImageFetcher)

/**
 * Asynchronously set the image view's image to a remote image URL.
 * While the image downloads, shows `placeholder`.
 * If you need to do work after the image is downloaded,
 * attach a `then` handler to the returned promise.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(nullable UIImage*)placeholder;

/**
 * Asynchronously set the image view's image to a remote image URL.
 * While the image downloads, shows `placeholder`.
 * If you are populating a UIImageView contained in a recyclable container (like a UITableView or UICollectionView),
 * use the `stillValid` parameter to specify a block that returns whether the UIImageView has not been recycled and
 * should be loaded with the downloaded image.
 * To cancel or reprioritize, the image network request, pass in a `networkToken`.
 * If you need to do work after the image is downloaded,
 * attach a `then` handler to the returned promise.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(nullable UIImage*)placeholder
                   stillValid:(nullable BOOL(^)())stillValid
                 networkToken:(nullable AVENetworkToken*)networkToken;

/**
 * Asynchronously set the image view's image to a remote image URL.
 * While the image downloads, shows `placeholder`.
 * To have the image view cross-dissolve into the downloaded image, use a non-zero `duration`.
 * If you are populating a UIImageView contained in a recyclable container (like a UITableView or UICollectionView),
 * use the `stillValid` parameter to specify a block that returns whether the UIImageView has not been recycled and
 * should be loaded with the downloaded image.
 * To cancel or reprioritize, the image network request, pass in a `networkToken`.
 * To specify the priority that the image network request should be executed at, pass a `priority`.
 * If you need to do work after the image is downloaded,
 * attach a `then` handler to the returned promise.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(nullable UIImage*)placeholder
            crossFadeDuration:(NSTimeInterval)duration
                   stillValid:(nullable BOOL(^)())stillValid
                     priority:(nullable AVENetworkPriority*)priority
                 networkToken:(nullable AVENetworkToken*)networkToken;

/**
 * Asynchronously set the image view's image to a remote image URL.
 * If `usePlaceholderImmediately` is YES, while the image downloads, the `placeholder` is shown.
 * To have the image view cross-dissolve into the downloaded image, use a non-zero `duration`.
 * If you are populating a UIImageView contained in a recyclable container (like a UITableView or UICollectionView),
 * use the `stillValid` parameter to specify a block that returns whether the UIImageView has not been recycled and
 * should be loaded with the downloaded image.
 * To cancel or reprioritize, the image network request, pass in a `networkToken`.
 * To specify the priority that the image network request should be executed at, pass a `priority`.
 * If you need to do work after the image is downloaded,
 * attach a `then` handler to the returned promise.
 * The returned promise will contain a UIImage*.
 */
- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(nullable UIImage*)placeholder
            crossFadeDuration:(NSTimeInterval)duration
                   stillValid:(nullable BOOL(^)())stillValid
                     priority:(nullable AVENetworkPriority*)priority
                 networkToken:(nullable AVENetworkToken*)networkToken
    usePlaceholderImmediately:(BOOL)usePlaceholderImmediately;

@end

NS_ASSUME_NONNULL_END
