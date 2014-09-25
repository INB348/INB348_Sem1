//
//  AppDelegate.m
//  INB348
//
//  Created by nOrJ on 3/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/** Parse key */
#define appID @"hkrprSH9emdT5j21EwL5dIPmw6avj4tPTHRcGwAP"
#define clKey @"BPMeE8klLUm88kooylDPQLjtsYPa98nSXbY7GyeJ"

///** Parse key test */
//#define appID @"DX9lerXNpvbx2Z01bSayqkjg2JkQtKOGnyXWDvwl"
//#define clKey @"dcI2iOiEYmq9LCoBftkSbU07GQYrdDgOEikuDX7i"

@interface AppDelegate()
@property(strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Author: nOrJ
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x3d5593)];
    [self.window setTintColor:[UIColor whiteColor]];
    
    /** PARSE setup */
    [Parse setApplicationId:appID
                  clientKey:clKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    /** Test Database
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    NSDictionary *dimensions = @{
                                 // What type of news is this?
                                 @"category": @"politics",
                                 // Is it a weekday or the weekend?
                                 @"dayType": @"weekday",
                                 };
    // Send the dimensions to Parse along with the 'read' event
    
    [PFAnalytics trackEvent:@"read" dimensions:dimensions];
    */
    
    // Fetch Main Storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    // Instantiate Root Navigation Controller
    UINavigationController *rootNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"rootNavigationController"];
    // Configure View Controller
    LogInViewController *uiTableViewController = (LogInViewController *)[rootNavigationController topViewController];
    if ([uiTableViewController isKindOfClass:[LogInViewController class]]) {
        [uiTableViewController setManagedObjectContext:self.managedObjectContext];
    }
    // Configure Window
    [self.window setRootViewController:rootNavigationController];
    
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc]init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (void)saveManagedObjectContext {
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        if (error) {
            NSLog(@"Unable to save changes.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}



@end
