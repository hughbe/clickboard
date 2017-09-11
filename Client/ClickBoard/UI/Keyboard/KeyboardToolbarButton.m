//
//  KeyboardToolbarButton.m
//  ClickBoard-iOS
//
//  Created by Hugh Bellamy on 05/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "KeyboardToolbarButton.h"

@implementation KeyboardToolbarButton

- (void)toggleSelected {
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if(selected) {
        //Select
        self.tintColor = [UIColor redColor];
    }
    else {
        //Deselect
        self.tintColor = [UIColor blackColor];
    }
}

@end
