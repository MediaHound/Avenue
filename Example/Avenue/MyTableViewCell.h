//
//  MyTableViewCell.h
//  Avenue
//
//  Created by Dustin Bachrach on 12/29/14.
//  Copyright (c) 2014 Dustin Bachrach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Avenue/Avenue.h>

@interface MyTableViewCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) AVENetworkToken* token;

@end
