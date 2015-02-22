//
//  cellButton.m
//  KillerSudoku
//
//  Created by 李泳 on 15/2/15.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "cellButton.h"

@interface cellButton ()
@property(nonatomic)NSInteger dupCount;
@end

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
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    
    if (self.dupCount > 0) {
        [self markWrong];
    }
}

- (void)markWrong {
    self.isCrossed = true;
    [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void)deMarkWrong {
    self.isCrossed = false;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)incDupCount {
    self.dupCount++;
    if (self.dupCount == 1) {
        [self markWrong];
    }
}
- (void)decDupCount {
    self.dupCount--;
    if (self.dupCount == 0) {
        [self deMarkWrong];
    }
}

@end
