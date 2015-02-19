//
//  crossView.m
//  KillerSudoku
//
//  Created by 李泳 on 15/2/19.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "crossView.h"

@implementation crossView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextMoveToPoint(context, self.frame.size.width, 0.0);
    CGContextAddLineToPoint(context, 0, self.frame.size.height);

    CGContextDrawPath(context, kCGPathStroke);
}


@end
