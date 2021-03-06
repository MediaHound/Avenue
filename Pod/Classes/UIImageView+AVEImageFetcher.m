//
//  UIImageView+AVEImageFetcher.m
//  Avenue
//
//  Created by MediaHound on 10/31/14.
//
//

#import "UIImageView+AVEImageFetcher.h"
#import "AVEImageFetcher.h"


@implementation UIImageView (AVEImageFetcher)

- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(UIImage*)placeholder
{
    return [self setImageForURL:url
                    placeholder:placeholder
                     stillValid:nil
                   networkToken:nil];
}

- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(UIImage*)placeholder
                   stillValid:(BOOL(^)())stillValid
                 networkToken:(AVENetworkToken*)networkToken
{
    return [self setImageForURL:url
                    placeholder:placeholder
              crossFadeDuration:0
                     stillValid:stillValid
                       priority:nil
                   networkToken:networkToken];
}

- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(UIImage*)placeholder
            crossFadeDuration:(NSTimeInterval)duration
                   stillValid:(BOOL(^)())stillValid
                     priority:(AVENetworkPriority*)priority
                 networkToken:(AVENetworkToken*)networkToken
{
    return [self setImageForURL:url
                    placeholder:placeholder
              crossFadeDuration:duration
                     stillValid:stillValid
                       priority:priority
                   networkToken:networkToken
      usePlaceholderImmediately:YES];
}

- (AnyPromise*)setImageForURL:(NSString*)url
                  placeholder:(nullable UIImage*)placeholder
            crossFadeDuration:(NSTimeInterval)duration
                   stillValid:(nullable BOOL(^)())stillValid
                     priority:(nullable AVENetworkPriority*)priority
                 networkToken:(nullable AVENetworkToken*)networkToken
    usePlaceholderImmediately:(BOOL)usePlaceholderImmediately
{
    if (usePlaceholderImmediately) {
        self.image = placeholder;
    }
    
    if (!url) {
        self.image = placeholder;
        return [AnyPromise promiseWithValue:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    return [[AVEImageFetcher sharedFetcher] fetchImage:url priority:priority networkToken:networkToken].then(^(UIImage* image) {
        if (!image) {
            return image;
        }
        if (stillValid && !stillValid()) {
            return image;
        }
        
        // TODO: If a placeholder was set not a long time ago, then we can assume the view was just brought on the screen and just setting the image would look better rather than doing a crossdissolve.
        if (duration > 0 && weakSelf.window) {
            [UIView transitionWithView:weakSelf.superview
                              duration:duration
                               options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction
                            animations:^{
                                weakSelf.image = image;
                            }
                            completion:nil];
        }
        else {
            weakSelf.image = image;
        }
        return image;
    });
}

@end
