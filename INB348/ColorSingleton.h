//
//  ColorSingleton.h
//  INB348
//
//  Created by Kristian M Matzen on 27/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorSingleton : NSObject

+ (id)sharedColorSingleton;
- (UIColor *)getRedColor;
- (UIColor *)getRedBackgroundColor;
- (UIColor *)getLightGreyColor;
- (UIColor *)getGreenColor;
- (UIColor *)getWhiteColor;
- (UIColor *)getBlueColor;

@end
