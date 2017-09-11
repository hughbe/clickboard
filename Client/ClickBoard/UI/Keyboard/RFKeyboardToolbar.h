//
//  RFKeyboardToolbar.h
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFKeyboardToolbar : UIView

@property (nonatomic, strong) NSArray *buttons;

+ (instancetype)toolbarViewWithButtons:(NSArray *)buttons;

- (void)setButtons:(NSArray *)buttons animated:(BOOL)animated;

@end
