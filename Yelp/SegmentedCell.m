//
//  SegmentedCell.m
//  Yelp
//
//  Created by Jim Challenger on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "SegmentedCell.h"

@interface SegmentedCell()
@property (weak, readwrite, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)valueChanged:(id)sender;

@end

@implementation SegmentedCell

- (IBAction)valueChanged:(id)sender {
    double value = 0;
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            value = 482.803;
            break;
        case 1:
            value = 1609.34;
            break;
        case 2:
            value = 8046.72;
            break;
        case 3:
            value = 24140.2;
            break;
        case 4:
            value = 32186.9;
            break;
        default:
            break;
    }
    
    [self.delegate segmentedCell:self didUpdateValue:value];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
