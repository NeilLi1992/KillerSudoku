//
//  solverCellButton.m
//  KillerSudoku
//
//  Created by 李泳 on 15/2/26.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "solverCellButton.h"
@interface solverCellButton()
@property(nonatomic)BOOL needDraw;
@property(nonatomic)BOOL hasLeft;
@property(nonatomic)BOOL hasRight;
@property(nonatomic)BOOL hasTop;
@property(nonatomic)BOOL hasBelow;
@property(nonatomic)BOOL lt;
@property(nonatomic)BOOL rt;
@property(nonatomic)BOOL lb;
@property(nonatomic)BOOL rb;
@end

@implementation solverCellButton
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!self.needDraw) {
        return;
    }
    
    // Drawing code
    CGFloat padding = 5.0f;
    CGFloat length = self.frame.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGFloat dashes[] = {1,1};
    CGContextSetLineDash(context, 2.0, dashes, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGFloat startX, startY, endX, endY;
    // Left border
    if (!self.hasLeft) {
        startX = padding;
        startY = self.hasTop ? 0 : padding;
        endX = padding;
        endY = self.hasBelow ? length : length - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);

    }
    
    // Right border
    if (!self.hasRight) {
        startX = length - padding;
        startY = self.hasTop ? 0 : padding;
        endX = length - padding;
        endY = self.hasBelow ? length : length - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    // Top border
    if (!self.hasTop) {
        startX = self.hasLeft ? 0 : padding;
        startY = padding;
        endX = self.hasRight ? length : length - padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    // Below border
    if (!self.hasBelow) {
        startX = self.hasLeft ? 0 : padding;
        startY = length - padding;
        endX = self.hasRight ? length : length - padding;
        endY = length - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.lt) {
        startX = 0;
        startY = padding;
        endX = padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = padding;
        startY = 0;
        endX = padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.rt) {
        startX = length - padding;
        startY = 0;
        endX = length - padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = length - padding;
        startY = padding;
        endX = length;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.lb) {
        startX = 0;
        startY = length - padding;
        endX = padding;
        endY = length - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = padding;
        startY = length - padding;
        endX = padding;
        endY = length;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.rb) {
        startX = length - padding;
        startY = length - padding;
        endX = length;
        endY = length - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = length - padding;
        startY = length - padding;
        endX = length - padding;
        endY = length;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    CGContextStrokePath(context);
}

-(void)setBorderFlagsLeft:(BOOL)left Right:(BOOL)right Top:(BOOL)top Below:(BOOL)below {
    self.hasLeft = left;
    self.hasRight = right;
    self.hasBelow = below;
    self.hasTop = top;
}

-(void)setCornerFlagsLT:(BOOL)lt RT:(BOOL)rt LB:(BOOL)lb RB:(BOOL)rb {
    self.lt = lt;
    self.rt = rt;
    self.lb = lb;
    self.rb = rb;
    self.needDraw = true;
    [self setNeedsDisplay];
}

@end
