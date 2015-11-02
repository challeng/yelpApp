//
//  SegmentedCell.h
//  Yelp
//
//  Created by Jim Challenger on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedCell;

@protocol SegmentedCellDelegate <NSObject>

- (void)segmentedCell:(SegmentedCell *)cell didUpdateValue:(double)value;

@end

@interface SegmentedCell : UITableViewCell
@property (weak, readonly, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) id<SegmentedCellDelegate> delegate;

@end
