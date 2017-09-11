//
//  ChooseColorViewController.h
//  Test
//
//  Created by Hugh Bellamy on 18/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseColorDelegate;

@interface ChooseColorViewController : UIViewController

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) id<ChooseColorDelegate> delegate;

@end

@protocol ChooseColorDelegate <NSObject>

- (void)colorPickerViewController:(ChooseColorViewController*)colorPicker didSelectColor:(UIColor*)color;

- (void)colorPickerViewControllerDidCancel:(ChooseColorViewController*)colorPicker;

@end