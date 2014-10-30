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
            
            PFQuery *listUSersInGroup = [PFQuery queryWithClassName:@"UserGroup"];
            [listUSersInGroup whereKey:@"group" equalTo:self.groupUser[@"group"]];
            [listUSersInGroup findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    
                    NSLog(@"Successfully retrieved %lu Notifications.", (unsigned long)objects.count);
                    
                    for (PFObject *object in objects) {
                        NSString *note = [NSString stringWithFormat: @"'%@' has joined '%@' group.", [PFUser currentUser][@"name"], self.groupUser[@"group"][@"name"]];
                        
                        PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                        [notification setObject:[PFUser currentUser] forKey:@"fromUser"];
                        [notification setObject:object[@"user"] forKey:@"toUser"];
                        [notification setObject:note forKey:@"note"];
                        [notification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
                        [notification saveEventually];

                        // Do something with the found objects
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
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
