//
//  ColorSingleton.h
//  INB348
//
//  Created by Kristian M Matzen on 27/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorSingleton : NSObject

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedColorSingleton;
- (UIColor *)getRedColor;
- (UIColor *)getRedBackgroundColor;
- (UIColor *)getGreenColor;
- (UIColor *)getWhiteColor;
- (UIColor *)getBlueColor;

@end
