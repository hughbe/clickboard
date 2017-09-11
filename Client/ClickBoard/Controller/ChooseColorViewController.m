//
//  ChooseColorViewController.m
//  Test
//
//  Created by Hugh Bellamy on 18/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "ChooseColorViewController.h"
#import "NKOColorPickerView.h"

@interface ChooseColorViewController ()
@property (weak, nonatomic) IBOutlet NKOColorPickerView *colorPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ChooseColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.colorPicker.color = self.color;
    self.imageView.image = self.image;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    done.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *revert = [[UIBarButtonItem alloc]initWithTitle:@"Revert" style:UIBarButtonItemStylePlain target:self action:@selector(revert:)];
    revert.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItems = @[done, revert];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revert:(id)sender {
    self.colorPicker.color = self.color;
}

- (void)done:(id)sender {
    [self.delegate colorPickerViewController:self didSelectColor:self.colorPicker.color];
}

- (IBAction)cancel:(id)sender {
    [self.delegate colorPickerViewControllerDidCancel:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
