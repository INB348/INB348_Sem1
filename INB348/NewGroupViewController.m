//
//  NewGroupViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 17/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewGroupViewController.h"

@interface NewGroupViewController ()

@end

@implementation NewGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
 
    // Create a new Group and set name
    PFObject *group= [PFObject objectWithClassName:@"Group"];
    [group setValue:self.nameTextField.text forKey:@"name"];
    [group save];
    
    // Create a new UserGroup relation
    PFObject *userGroup= [PFObject objectWithClassName:@"UserGroup"];
    [userGroup setObject:[PFUser currentUser] forKey:@"user"];
    [userGroup setObject:group forKey:@"group"];
    
    //Set default balance of 0
    userGroup[@"balance"] = @0;
    
    //Save
    [userGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
           [self.delegate refresh];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
