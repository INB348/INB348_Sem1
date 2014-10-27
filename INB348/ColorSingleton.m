//
//  ColorSingleton.m
//  INB348
//
//  Created by Kristian M Matzen on 27/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "ColorSingleton.h"
static ColorSingleton *sharedMyColorSingleton = nil;

@implementation ColorSingleton


@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedColorSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyColorSingleton = [[self alloc] init];
    });
    return sharedMyColorSingleton;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (UIColor *)getRedColor{
    return [UIColor colorWithRed:1 green:0.302 blue:0.302 alpha:1];
}

- (UIColor *)getGreenColor{
    return [UIColor colorWithRed:0.2 green:0.678 blue:0.361 alpha:1];
}

- (UIColor *)getWhiteColor{
    return [UIColor whiteColor];
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end