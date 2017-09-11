//
//  ProgramWindow.h
//  ClickBoard
//
//  Created by Hugh Bellamy on 04/05/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Window : NSObject

@property (strong, nonatomic) NSNumber *pid;
@property (strong, nonatomic) NSString *title;

+ (Window *)windowFromDictionary:(NSDictionary*)dictionary;

@end
