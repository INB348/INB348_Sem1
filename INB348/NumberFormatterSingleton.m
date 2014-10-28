//
//  NumberFormatterSingleton.m
//  INB348
//
//  Created by Kristian M Matzen on 28/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NumberFormatterSingleton.h"
static NumberFormatterSingleton *sharedMyNumberFormatterSingleton = nil;

@implementation NumberFormatterSingleton
+ (id)sharedMyNumberFormatterSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyNumberFormatterSingleton = [[self alloc] init];
    });
    return sharedMyNumberFormatterSingleton;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSNumberFormatter *)getCurrencyNumberFormatter
{
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setFormatterBehavior: NSNumberFormatterBehavior10_4 ];
    [fmt setCurrencySymbol:@"$"];
    [fmt setNumberStyle: NSNumberFormatterCurrencyStyle ];
    return fmt;
}

- (NSNumberFormatter *)getNumberFormatter
{
    NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
    fmt.positiveFormat = @"0.##";
    return fmt;
}


@end
