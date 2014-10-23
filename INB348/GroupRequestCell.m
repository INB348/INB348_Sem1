//
//  GroupRequestCell.m
//  INB348
//
//  Created by Kristian M Matzen on 23/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupRequestCell.h"

@implementation GroupRequestCell
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)accept:(id)sender {
    [self.groupUser setValue:[NSNumber numberWithBool:YES] forKey:@"accepted"];
    [self.groupUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Group Request Accepted Successfully");
            [self.delegate refresh];
        } else {
            NSLog(@"Group Request Accepted Failed");
        }
    }];
}

- (IBAction)reject:(id)sender {
    [self.groupUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Group Request Denial Successfully");
            [self.delegate refresh];
        } else {
            NSLog(@"Group Request Denial Failed");
        }
    }];
}
@end
