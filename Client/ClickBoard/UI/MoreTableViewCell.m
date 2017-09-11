//
//  MoreTableViewCell.m
//  ClickBoard
//
//  Created by Hugh Bellamy on 07/05/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "MoreTableViewCell.h"

@implementation MoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 10.0;
    self.contentView.layer.masksToBounds = NO;
}

@end
