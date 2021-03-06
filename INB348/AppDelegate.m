//
//  AppDelegate.m
//  INB348
//
//  Created by nOrJ on 3/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/** Parse key */
#define appID @"hkrprSH9emdT5j21EwL5dIPmw6avj4tPTHRcGwAP"
#define clKey @"BPMeE8klLUm88kooylDPQLjtsYPa98nSXbY7GyeJ"

///** Parse key test */
//#define appID @"DX9lerXNpvbx2Z01bSayqkjg2JkQtKOGnyXWDvwl"
//#define clKey @"dcI2iOiEYmq9LCoBftkSbU07GQYrdDgOEikuDX7i"


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
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
