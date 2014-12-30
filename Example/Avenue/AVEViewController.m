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
    NSUInteger row = indexPath.row;
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    cell.indexPath = indexPath;
    
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:200];
    
    AVENetworkToken* token = [[AVENetworkToken alloc] init];
    [imageView setImageForURL:self.urls[row]
                  placeholder:[UIImage imageNamed:@"placeholder"]
                   stillValid:^BOOL{
                       return cell.indexPath.row == indexPath.row;
                   }
                 networkToken:token];
    cell.token = token;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell* myCell = (MyTableViewCell*)cell;
    [myCell.token cancel];
}

- (IBAction)clearCacheTapped:(id)sender
{
    [[AVEImageFetcher sharedFetcher] clearCache];
    [[AVENetworkManager sharedManager] clearCache];
}

@end
