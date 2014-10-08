//
//  SummaryCell.m
//  INB348
//
//  Created by Kristian M Matzen on 08/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "SummaryCell.h"

@implementation SummaryCell
@synthesize nameLabel = _nameLabel;
@synthesize oldBalance = _oldBalance;
@synthesize payed = _payed;
@synthesize used = _used;
@synthesize updatedBalance = _updatedBalance;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
