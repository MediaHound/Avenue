//
//  AVEViewController.m
//  Avenue
//
//  Created by MediaHound on 12/29/2014.
//  Copyright (c) 2014 MediaHound. All rights reserved.
//

#import "AVEViewController.h"
#import "MyTableViewCell.h"

#import <Avenue/Avenue.h>

@interface AVEViewController ()

@property (strong, nonatomic) NSArray* urls;
@end

@implementation AVEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a list of image URLS, one per cell.
    self.urls = @[
                  @"http://www.getty.edu/art/collections/images/enlarge/00079101.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00075801.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/14042501.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00091801.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00083901.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00093901.JPG",
                  @"http://d2hiq5kf5j4p5h.cloudfront.net/00055401.jpg",
                  @"http://d2hiq5kf5j4p5h.cloudfront.net/00086201.jpg",
                  @"http://d2hiq5kf5j4p5h.cloudfront.net/00091501.jpg",
                  @"http://www.getty.edu/art/collections/images/enlarge/00083001.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00078701.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00087501.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00062201.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/14472101.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00064201.JPG",
                  @"http://www.getty.edu/art/collections/images/enlarge/00054101.JPG",
                  @"http://d2hiq5kf5j4p5h.cloudfront.net/14513501.jpg"
                  ];
    
    // Kick off preemptive image fetches.
    // Each image is fetched with LOW priority.
    // Any high priority image fetch will execute first.
    // This allows us to preemptively fill in cells that are not on screen,
    // while not affecting performance of cells on screen.
    for (NSString* url in self.urls) {
        [[AVEImageFetcher sharedFetcher] fetchImage:url
                                           priority:[AVENetworkPriority priorityWithLevel:AVENetworkPriorityLevelLow] networkToken:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    
    // We save the indexPath on the cell so, later, we can check if the
    // asynchronous image fetch should be applied to the cell, or if the
    // cell has been recycled.
    cell.indexPath = indexPath;
    
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:200];
    
    // Create a network token, so we can cancel this image fetch if the user scrolls
    // the cell out of view.
    AVENetworkToken* token = [[AVENetworkToken alloc] init];
    cell.token = token;
    
    // Asyncronously load the image URL and draw the finished image into the cells'
    // imageView.
    // We will show the 'placeholder' image until it is loaded.
    // A .3 second crossfade will be applied when setting the image. Pass 0 to not cross fade.
    // The `stillValid` block is executed when the image request finishes to check
    // if the cell has been recycled or not.
    [imageView setImageForURL:self.urls[indexPath.row]
                  placeholder:[UIImage imageNamed:@"placeholder"]
            crossFadeDuration:0.3
                   stillValid:^BOOL{
                       return cell.indexPath.row == indexPath.row;
                   }
                     priority:[AVENetworkPriority priorityWithLevel:AVENetworkPriorityLevelHigh]
                 networkToken:token];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // When a cell scrolls out of view, we cancel it's
    // HIGH priority image fetch.
    MyTableViewCell* myCell = (MyTableViewCell*)cell;
    [myCell.token cancel];
}

- (IBAction)clearCacheTapped:(id)sender
{
    [[AVEImageFetcher sharedFetcher] clearCache];
    [[AVENetworkManager sharedManager] clearCache];
}

@end
