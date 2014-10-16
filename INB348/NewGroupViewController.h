//
//  NewGroupViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 17/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol NewGroupViewController
- (void)refresh;
@end

@interface NewGroupViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *img_Profile;
@property (nonatomic, assign) id <NewGroupViewController> delegate;

- (IBAction)selectPhoto:(UIButton *)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
