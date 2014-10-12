//
//  GroupTabBarController.h
//  INB348
//
//  Created by Kristian M Matzen on 23/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SWRevealViewController.h"

@interface GroupTabBarController : UITabBarController
@property (strong) PFObject *group;
@property (strong) NSArray *groupUsers;
@property (strong) NSArray *expenses;
@end
