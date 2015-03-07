//
//  BoardView.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/7.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "BoardView.h"
#import "UIColor+FlatUI.h"

CGFloat innerLineWidth;
CGFloat cellLength;

@implementation BoardView

-(void)setInnerLineWidth:(CGFloat)width {
    innerLineWidth = width;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    cellLength = self.frame.size.width / 9.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor midnightBlueColor].CGColor);
    CGContextSetLineWidth(context, innerLineWidth);
    
    for (int i = 1; i <= 8; i++) {
        if (i == 3 || i == 6) {
            continue;
        }
        CGContextMoveToPoint(context, i * cellLength, 0);
        CGContextAddLineToPoint(context, i * cellLength, self.frame.size.height);
        
        CGContextMoveToPoint(context, 0, i * cellLength);
        CGContextAddLineToPoint(context, self.frame.size.width, i * cellLength);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetLineWidth(context, 2 * innerLineWidth);
    for (int i = 3; i <= 6; i+=3) {
        CGContextMoveToPoint(context, i * cellLength, 0);
        CGContextAddLineToPoint(context, i * cellLength, self.frame.size.height);
        
        CGContextMoveToPoint(context, 0, i * cellLength);
        CGContextAddLineToPoint(context, self.frame.size.width, i * cellLength);
    }
    CGContextDrawPath(context, kCGPathStroke);
}



@end
