//
//  AppSettingsViewController.h
//  ClickBoard
//
//  Created by Hugh Bellamy on 11/11/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *apps;

@end
