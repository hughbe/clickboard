//
//  ScrollSlider.m
//  ClickBoard
//
//  Created by Hugh Bellamy on 10/11/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//

#import "ScrollSlider.h"

@implementation ScrollSlider

// get the location of the thumb
- (CGRect)thumbRect
{
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds
                                      trackRect:trackRect
                                          value:self.value];
    return thumbRect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect thumbFrame = [self thumbRect];
    
    UIScrollView *superView = (UIScrollView*)self.superview.superview;
    if([self.superview.superview isKindOfClass:[UIScrollView class]]) {
        // check if the point is within the thumb
        if (CGRectContainsPoint(thumbFrame, point))
        {
            // if so trigger the method of the super class
            superView.scrollEnabled = NO;
            return [super hitTest:point withEvent:event];
        }
        else
        {
            // if not just pass the event on to your superview
            superView.scrollEnabled = YES;
            return [[self superview] hitTest:point withEvent:event];
        }
    }
    
    return [[self superview] hitTest:point withEvent:event];
}

@end
