//
//  ClickBoardConstants.m
//  Test
//
//  Created by Hugh Bellamy on 13/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "ClickBoardConstants.h"


@implementation ClickBoardConstants

+ (PCType)PCType {
    return [[[NSUserDefaults standardUserDefaults]objectForKey:PC_TYPE_USER_DEFAULT_KEY] unsignedIntegerValue];
}

+ (void)setPCType:(PCType)PCType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(PCType) forKey:PC_TYPE_USER_DEFAULT_KEY];
    [userDefaults synchronize];
}

+ (BOOL)ranBefore {
    return [[NSUserDefaults standardUserDefaults]boolForKey:APPS_RAN_BEFORE_KEY];
}

+ (void)setRanBefore:(BOOL)ranBefore {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:ranBefore forKey:APPS_RAN_BEFORE_KEY];
    [userDefaults synchronize];
}

+ (BOOL)rotatedBefore {
    return [[NSUserDefaults standardUserDefaults]boolForKey:APPS_ROTATED_BEFORE_KEY];
}

+ (void)setRotatedBefore:(BOOL)rotatedBefore {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:rotatedBefore forKey:APPS_ROTATED_BEFORE_KEY];
    [userDefaults synchronize];
}

+ (AppsView)appsView {
    AppsView appsView =  [[[NSUserDefaults standardUserDefaults]objectForKey:USER_APPS_VIEW_TAG_KEY] unsignedIntegerValue];
    if(!appsView) {
        appsView = AppsView3x4;
    }
    return appsView;
}

+ (void)setAppsView:(AppsView)appsView {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(appsView) forKey:USER_APPS_VIEW_TAG_KEY];
    [userDefaults synchronize];
}

+ (NSArray*)apps {
    return [[NSUserDefaults standardUserDefaults]objectForKey:APPS_USER_DEFAULT_KEY];
}

+ (void)setApps:(NSArray*)apps {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:apps forKey:APPS_USER_DEFAULT_KEY];
    [userDefaults synchronize];
}

+ (NSString*)backgroundImageName {
    return [[NSUserDefaults standardUserDefaults]objectForKey:USER_BACKGROUND_NAME_KEY];
}

+ (void)setBackgroundImageName:(NSString*)name {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:name forKey:USER_BACKGROUND_NAME_KEY];
    [userDefaults synchronize];
}

+ (NSString *)appDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (float)mouseOpacity {
    return [[[NSUserDefaults standardUserDefaults]objectForKey:USER_MOUSE_OPACITY_KEY] floatValue];
}

+ (void)setMouseOpacity:(float)opacity {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(opacity) forKey:USER_MOUSE_OPACITY_KEY];
    [userDefaults synchronize];
}

+ (UIColor *)foregroundColour {
    NSString *foregroundColour = [[NSUserDefaults standardUserDefaults]objectForKey:USER_FOREGROUND_COLOUR_KEY];
    if(!foregroundColour) {
        foregroundColour = @"#000000";
        [ClickBoardConstants setForegroundColour:[UIColor whiteColor]];
    }
    
    return [UIColor colorWithHexString:foregroundColour];
}

+ (void)setForegroundColour:(UIColor *)colour {
    NSString *foreground;
    if([colour isEqual:[UIColor whiteColor]]) {
        foreground = @"#FFFFFF";
    }
    else {
        foreground = [ClickBoardConstants hexStringFromColor:colour];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:foreground forKey:USER_FOREGROUND_COLOUR_KEY];
    [userDefaults synchronize];
}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end

@implementation UIColor(MBCategory)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 x = (UInt32)strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end
