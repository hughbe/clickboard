//
//  ViewController.h
//  Test
//
//  Created by Hugh Bellamy on 12/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClickBoardServer.h"
#import "KeyboardTextField.h"
#import "MODropAlertView.h"
#import "NKOColorPickerView.h"
#import "ChooseColorViewController.h"

@interface ViewController : UIViewController <KeyboardTextFieldDelegate, UITextFieldDelegate , UIGestureRecognizerDelegate, MODropAlertViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseColorDelegate, UITableViewDataSource, UITableViewDelegate, ClickBoardServerDataStream>

@property (strong, nonatomic) ClickBoardServer *server;

@property (weak, nonatomic) IBOutlet UIScrollView *widgets;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *portraitView;
@property (weak, nonatomic) IBOutlet UIView *touchpadView;

@end

