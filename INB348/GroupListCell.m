//
//  GroupListCell.m
//  INB348
//
//  Created by Kristian Matzen on 25/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupListCell.h"

@implementation GroupListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
