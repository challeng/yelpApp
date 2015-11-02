//
//  BusinessCell.h
//  Yelp
//
//  Created by Jim Challenger on 10/31/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YelpBusiness.h"

@interface BusinessCell : UITableViewCell

@property (nonatomic, strong) YelpBusiness * business;

@end
