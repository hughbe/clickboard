//
//  AppSettingsViewController.m
//  ClickBoard
//
//  Created by Hugh Bellamy on 11/11/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "ClickBoardConstants.h"

@interface AppSettingsViewController ()

@end

@implementation AppSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView setEditing:YES];
    self.apps = [[ClickBoardConstants apps]mutableCopy];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *app = self.apps[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell.contentView viewWithTag:1];
    textLabel.text = [app firstObject];
    
    /*NPCType type = [ClickBoardConstants PCType];
    
    NSString *name = [app lastObject];
        
    NSString *imageName = name;
    if(type == PCTypeWindows) {
        imageName = [imageName stringByAppendingString:@"_windows.png"];
    }
    else if(type == PCTypeMac) {
        imageName = [imageName stringByAppendingString:@"_mac.png"];
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(-30,0, cell.frame.size.height, cell.frame.size.height)];
    UIImage *image=[UIImage imageNamed:imageName];
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.f);
    } else {
        UIGraphicsBeginImageContext(image.size);
    }
    CGRect rect = CGRectZero;
    rect.size = image.size;
    
    [[UIColor blackColor]set];
    UIRectFill(rect);
    
    [image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imageView.image = image;
    [cell.contentView addSubview:imageView];*/
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSArray *appArray = self.apps[sourceIndexPath.row];
    [self.apps removeObject:appArray];
    [self.apps insertObject:appArray atIndex:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (IBAction)done:(id)sender {
    [ClickBoardConstants setApps:self.apps];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
