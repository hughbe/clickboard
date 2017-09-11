//
//  ConnectViewController.h
//  ClickBoard
//
//  Created by Hugh Bellamy on 06/05/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClickBoardServer.h"
#import "MODropAlertView.h"
#import "ZBarSDK.h"

@interface ConnectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ClickBoardServerDelegate, MODropAlertViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, ZBarReaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *instructionsScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *instructionsPageControl;

@property (strong, nonatomic) ClickBoardServer *server;

@end
