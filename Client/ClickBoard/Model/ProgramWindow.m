//
//  ProgramWindow.m
//  ClickBoard
//
//  Created by Hugh Bellamy on 04/05/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "ProgramWindow.h"

@implementation Window

+ (Window *)windowFromDictionary:(NSDictionary *)dictionary {
    if([dictionary isKindOfClass:[NSNull class]] || !dictionary) {
        return nil;
    }
    Window *window = [[Window alloc]init];
    window.pid = dictionary[@"pid"];
    window.title = dictionary[@"title"];
    if([window.pid isKindOfClass:[NSNull class]] || [window.title isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    else {
        return window;
    }
}
@end
