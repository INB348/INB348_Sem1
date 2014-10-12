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
- (IBAction)save:(id)sender;

@property (nonatomic, assign) id <NewGroupViewController> delegate;
@end
