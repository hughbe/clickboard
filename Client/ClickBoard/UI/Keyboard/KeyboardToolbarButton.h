//
//  KeyboardToolbarButton.h
//  ClickBoard-iOS
//
//  Created by Hugh Bellamy on 05/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardToolbarButton : UIBarButtonItem

- (void)toggleSelected;

@property (assign, nonatomic) BOOL selected;

@end
