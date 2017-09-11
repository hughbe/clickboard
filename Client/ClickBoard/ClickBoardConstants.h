//
//  ClickBoardConstants.h
//  Test
//
//  Created by Hugh Bellamy on 13/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define APPS_USER_DEFAULT_KEY @"APPS_USER_DEFAULTS_KEY"

#define PC_TYPE_USER_DEFAULT_KEY @"PC_TYPE_USER_DEFAULTS_KEY"

#define APPS_RAN_BEFORE_KEY @"APPS_RAN_BEFORE_KEY"

#define USER_BACKGROUND_NAME_KEY @"USER_BACKGROUND_NAME_KEY"

#define USER_MOUSE_OPACITY_KEY @"USER_MOUSE_OPACITY_KEY"

#define USER_FOREGROUND_COLOUR_KEY @"USER_FOREGROUND_COLOUR_KEY"

#define USER_APPS_VIEW_TAG_KEY @"USER_APPS_VIEW_TAG_KEY"

#define APPS_ROTATED_BEFORE_KEY @"APPS_ROTATED_BEFORE_KEY"

typedef NS_ENUM(NSUInteger, PCType) {
    PCTypeWindows,
    PCTypeMac
};

typedef NS_ENUM(NSUInteger, AppsView) {
    AppsView2x1 = 400,
    AppsView3x2 = 401,
    AppsView4x2 = 402,
    AppsView3x4 = 403
    
};

typedef NS_ENUM(NSUInteger, YRotatingState) {
    YRotatingStateNone,
    YRotatingStateDown,
    YRotatingStateUp
};

typedef NS_ENUM(NSUInteger, XRotatingState) {
    XRotatingStateNone,
    XRotatingStateRight,
    XRotatingStateLeft
};

typedef NS_ENUM(NSUInteger, CBSpeed) {
    CBSpeedNone,
    CBSpeedVerySlow,
    CBSpeedSlow,
    CBSpeedMedium,
    CBSpeedFast,
    CBSpeedVeryFast,
    CBSpeedExtremelyFast
};

typedef NS_ENUM(NSUInteger, XMovementState) {
    XMovementStateNone,
    XMovementStateRight,
    XMovementStateLeft
};

typedef NS_ENUM(NSUInteger, YMovementState) {
    YMovementStateNone,
    YMovementStateUp,
    YMovementStateDown
};

@interface ClickBoardConstants : NSObject

+ (PCType)PCType;
+ (void)setPCType:(PCType)PCType;

+ (BOOL)ranBefore;
+ (void)setRanBefore:(BOOL)ranBefore;

+ (BOOL)rotatedBefore;
+ (void)setRotatedBefore:(BOOL)rotatedBefore;

+ (AppsView)appsView;
+ (void)setAppsView:(AppsView)appsView;

+ (NSArray*)apps;
+ (void)setApps:(NSArray*)apps;

+ (NSString*)backgroundImageName;
+ (void)setBackgroundImageName:(NSString*)name;

+ (float)mouseOpacity;
+ (void)setMouseOpacity:(float)opacity;

+ (UIColor*)foregroundColour;
+ (void)setForegroundColour:(UIColor*)colour;

+ (NSString *)appDirectory;
+ (NSString *)hexStringFromColor:(UIColor *)color;

@end

@interface UIColor(MBCategory)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
