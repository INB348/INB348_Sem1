//
//  BalanceManagementTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "BalanceManagementTableViewController.h"
#import "SWRevealViewController.h"

@interface BalanceManagementTableViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation BalanceManagementTableViewController
GroupTabBarController *groupTabBarController;
- (NSArray *)getGroupUsers{
    return [(GroupTabBarController *)[(BalanceNavigationController *)[self navigationController] parentViewController] groupUsers];
}

- (PFObject *)getGroup{
    return [(GroupTabBarController *)[(BalanceNavigationController *)[self navigationController] parentViewController] group];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    groupTabBarController = (GroupTabBarController *)[[self navigationController ]parentViewController];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = [[groupTabBarController.record valueForKey:@"group"] valueForKey:@"name"];
    
    // Do any additional setup after loading the view, typically from a nib.
    //NSLog(@"%@", groupTabBarController.managedObjectContext);
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserGroup"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@", [groupTabBarController.record valueForKey:@"group"]];
    [fetchRequest setPredicate:predicate];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:groupTabBarController.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    //[self refresh];
    [self.tableView reloadData];
}

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
    GroupUserCell *cell = (GroupUserCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupUserCell" forIndexPath:indexPath];
    
    // Configure Table View Cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GroupUserCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Fetch Record
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];

    
    //Update Cell
    [cell.textLabel setText:[[record valueForKey:@"user"] valueForKey:@"name"]];
    NSNumber *balance =[(NSNumber *)record valueForKey:@"balance"];
    [cell.detailTextLabel setText:[balance stringValue]];
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewExpenseSegue"]) {
        NewExpenseNavigationController *destNavigationController = segue.destinationViewController;
        destNavigationController.groupUsers = [self getGroupUsers];
        destNavigationController.group = [self getGroup];
    }
}

@end
