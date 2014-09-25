//
//  GroupsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupsTableViewController.h"

@interface GroupsTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSIndexPath *selection;
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (strong) NSArray *userGroups;
@end

@implementation GroupsTableViewController

- (void)refresh{
    PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
    [query includeKey:@"group"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [query whereKey:@"user" equalTo:currentUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d UserGroups.", objects.count);
                
                // Do something with the found objects
                for (PFObject *object in objects) {
                    //Create object
                    NSEntityDescription *groupEntity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
                    //Initialize Record
                    NSManagedObject *groupRecord = [[NSManagedObject alloc] initWithEntity:groupEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    
                    //Populate Record
                    PFObject *groupObject = object[@"group"];
                    [groupRecord setValue:groupObject[@"name"] forKey:@"name"];
                    [groupRecord setValue:groupObject.objectId forKey:@"objectId"];
                    
                    
                    //Create object
                    NSEntityDescription *groupUserEntity = [NSEntityDescription entityForName:@"UserGroup" inManagedObjectContext:self.managedObjectContext];
                    //Initialize Record
                    NSManagedObject *groupUserRecord = [[NSManagedObject alloc] initWithEntity:groupUserEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    
                    //Populate Record
                    [groupUserRecord setValue:object[@"balance"] forKey:@"balance"];
                    [groupUserRecord setValue:object.objectId forKey:@"objectId"];
                    [groupUserRecord setValue:groupRecord forKey:@"group"];
                }
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
    // Do any additional setup after loading the view, typically from a nib.
    //NSLog(@"%@", self.managedObjectContext);
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserGroup"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    //return 0;
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupListCell *cell = (GroupListCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupListCell" forIndexPath:indexPath];
    
    // Configure Table View Cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(GroupListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Fetch Record
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //Update Cell
    [cell.textLabel setText:[[record valueForKey:@"group"] valueForKey:@"name"]];
    NSNumber *balance =[(NSNumber *)record valueForKey:@"balance"];
    [cell.detailTextLabel setText:[balance stringValue]];
}


#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(GroupListCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGroup"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GroupTabBarController *groupTabBarController = segue.destinationViewController;
        //groupTabBarController.group = self.userGroups[self.selection.row][@"group"];
        groupTabBarController.managedObjectContext = self.managedObjectContext;
        
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (record) {
            [groupTabBarController setRecord:record];
        }
        
        // Reset Selection
        [self setSelection:nil];
    }
}

@end
