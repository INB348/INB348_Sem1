//
//  NotificationsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NotificationsTableViewController.h"
#import "SWRevealViewController.h"

@interface NotificationsTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation NotificationsTableViewController

- (void)refresh{
    PFQuery *notification = [PFQuery queryWithClassName:@"Notifications"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [notification includeKey:@"fromUser"];
        [notification whereKey:@"toUser" equalTo:currentUser];
        [notification orderByDescending:@"createdAt"];
        [notification findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu Notifications.", (unsigned long)objects.count);
                // Do something with the found objects
                self.listOfNotifications = [objects mutableCopy];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    [self refresh];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.listOfNotifications.count;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *notificationTableIdentifier = @"NotificationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:notificationTableIdentifier];
    }
    
    PFObject *notification = self.listOfNotifications[indexPath.row];
    NSString *note = notification[@"note"];
    NSDate *createdAt = notification.createdAt;
    BOOL read = [notification[@"read"] boolValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-YYYY HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:createdAt];
    
    if (read) {
        cell.textLabel.textColor = [UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]; // color
        cell.textLabel.font = [UIFont boldSystemFontOfSize:(15)]; // font size
        cell.detailTextLabel.textColor = [UIColor colorWithRed:109.0/255 green:109.0/255 blue:109.0/255 alpha:1];
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    } else {
        cell.textLabel.textColor = [UIColor whiteColor]; // color
        cell.textLabel.font = [UIFont boldSystemFontOfSize:(15)]; // font size
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        [cell setBackgroundColor:[UIColor colorWithRed:91.0/255 green:111.0/255 blue:165.0/255 alpha:1]];
    }
    
    cell.textLabel.numberOfLines = 3; // multiline
    
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", note]];
    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", dateString]];
    
    
    PFFile *thumbnail = notification[@"fromUser"][@"profilePic"];
    cell.imageView.image = [UIImage imageNamed:@"person_grey.jpg"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            cell.imageView.image = [UIImage imageWithData:data];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"pill.png"];
        }
        
        /* Profile Image Format */
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.layer.borderWidth = 3.0f;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        /* */
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFQuery *editNotificationStatus = [PFQuery queryWithClassName:@"Notifications"];
    PFObject *currentNotification = self.listOfNotifications[indexPath.row];
    // Retrieve the object by id
    [editNotificationStatus getObjectInBackgroundWithId:currentNotification.objectId block:^(PFObject *object, NSError *error) {
        object[@"read"] = @YES;
        [object saveInBackground];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]; // color
        cell.textLabel.font = [UIFont boldSystemFontOfSize:(15)]; // font size
        cell.detailTextLabel.textColor = [UIColor colorWithRed:109.0/255 green:109.0/255 blue:109.0/255 alpha:1];
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
