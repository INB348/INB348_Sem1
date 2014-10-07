//
//  GroupTabBarController.m
//  INB348
//
//  Created by Kristian M Matzen on 23/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupTabBarController.h"

@interface GroupTabBarController ()

@end

@implementation GroupTabBarController

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
    [self refresh];
}

- (void)refresh{
    //Retrieving GroupUser list
    PFQuery *groupUsersQuery = [PFQuery queryWithClassName:@"UserGroup"];
    [groupUsersQuery includeKey:@"user"];
    NSString *groupObjectId = [[self.record valueForKey:@"group"] valueForKey:@"objectId"];
    [groupUsersQuery whereKey:@"group" equalTo:[PFObject objectWithoutDataWithClassName:@"Group" objectId:groupObjectId]];
    [groupUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d UserGroups.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                //User
                NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
                NSManagedObject *userRecord = [[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:self.managedObjectContext];
                PFUser *userObject = object[@"user"];
                [userObject fetchIfNeeded];
                [userRecord setValue:userObject[@"name"] forKey:@"name"];
                [userRecord setValue:userObject.objectId forKey:@"objectId"];
                NSLog(@"%@", userObject);
                //UserGroup
                NSEntityDescription *groupUserEntity = [NSEntityDescription entityForName:@"UserGroup" inManagedObjectContext:self.managedObjectContext];
                NSManagedObject *groupUserRecord = [[NSManagedObject alloc] initWithEntity:groupUserEntity insertIntoManagedObjectContext:self.managedObjectContext];
                [groupUserRecord setValue:object[@"balance"] forKey:@"balance"];
                [groupUserRecord setValue:object.objectId forKey:@"objectId"];
                [groupUserRecord setValue:userRecord forKey:@"user"];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
