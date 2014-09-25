//
//  GroupTabBarController.h
//  INB348
//
//  Created by Kristian M Matzen on 23/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>

@interface GroupTabBarController : UITabBarController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong,nonatomic) NSManagedObject *record;
@property (strong) PFObject *group;
@property (strong) NSArray *groupUsers;
@property (strong) NSArray *expenses;
@end
