//
//  cellButton.m
//  KillerSudoku
//
//  Created by 李泳 on 15/2/15.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "cellButton.h"

@implementation cellButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)clear {
    [self setTitle:@" " forState:UIControlStateNormal];
}

- (void)setNum:(NSNumber*)num {
    [self setTitle:[num stringValue] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self drawCross];
    [self clearCross];
}

- (void)drawCross {
    self.isCrossed = true;
    crossView* subview = [[crossView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [subview setBackgroundColor:[UIColor clearColor]];
    subview.tag = 10;
    [self addSubview:subview];
}

- (void)clearCross {
    self.isCrossed = false;
    [[self viewWithTag:10] removeFromSuperview];
}

@end
