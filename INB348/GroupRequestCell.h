//
//  GroupRequestCell.h
//  INB348
//
//  Created by Kristian M Matzen on 23/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol GroupRequestCell
- (void)refresh;
@end

@interface GroupRequestCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)accept:(id)sender;
- (IBAction)reject:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;
@property (strong) PFObject *groupUser;

@property (nonatomic, assign) id <GroupRequestCell> delegate;
@end
