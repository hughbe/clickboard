//
//  RFToolbarButton.h
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^eventHandlerBlock)();

@interface RFToolbarButton : UIButton

+ (instancetype)spaceButton;
+ (instancetype)buttonWithTitle:(NSString *)title;

- (void)addEventHandler:(eventHandlerBlock)eventHandler forControlEvents:(UIControlEvents)controlEvent;

- (void)toggleSelected;

@end
