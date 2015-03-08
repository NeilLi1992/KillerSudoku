//
//  PlayCellButton.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/7.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "PlayCellButton.h"
#import "UIColor+FlatUI.h"

@interface PlayCellButton ()
@property(nonatomic)NSInteger dupCount;
@property(strong, nonatomic)NSMutableDictionary* noteNums;

@property(strong, nonatomic)UILabel* sumText;

// Inner line drawing properties
@property(nonatomic)BOOL needsDraw;
@property(nonatomic)BOOL hasLeft;
@property(nonatomic)BOOL hasRight;
@property(nonatomic)BOOL hasTop;
@property(nonatomic)BOOL hasBelow;
@property(nonatomic)BOOL lt;
@property(nonatomic)BOOL rt;
@property(nonatomic)BOOL lb;
@property(nonatomic)BOOL rb;
@end

@implementation PlayCellButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!self.needsDraw) {
        return;
    }
    
    // Drawing code
    CGFloat padding = 2.3f;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.2);
    CGFloat dashes[] = {1,1};
    CGContextSetLineDash(context, 2.0, dashes, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGFloat startX, startY, endX, endY;
    // Left border
    if (!self.hasLeft) {
        startX = padding;
        startY = self.hasTop ? 0 : padding;
        endX = padding;
        endY = self.hasBelow ? height : height - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
    }
    
    // Right border
    if (!self.hasRight) {
        startX = width - padding;
        startY = self.hasTop ? 0 : padding;
        endX = width - padding;
        endY = self.hasBelow ? height : height - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    // Top border
    if (!self.hasTop) {
        startX = self.hasLeft ? 0 : padding;
        startY = padding;
        endX = self.hasRight ? width : width - padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    // Below border
    if (!self.hasBelow) {
        startX = self.hasLeft ? 0 : padding;
        startY = height - padding;
        endX = self.hasRight ? width : width - padding;
        endY = height - padding;
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
        startX = width - padding;
        startY = 0;
        endX = height - padding;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = width - padding;
        startY = padding;
        endX = width;
        endY = padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.lb) {
        startX = 0;
        startY = height - padding;
        endX = padding;
        endY = height - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = padding;
        startY = height - padding;
        endX = padding;
        endY = height;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    if (self.rb) {
        startX = width - padding;
        startY = height - padding;
        endX = width;
        endY = height - padding;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
        
        startX = width - padding;
        startY = height - padding;
        endX = width - padding;
        endY = height;
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddLineToPoint(context, endX, endY);
    }
    
    CGContextStrokePath(context);
}

-(void)clearBorderLines {
    self.needsDraw = false;
    [self setNeedsDisplay];
}

- (void)setNum:(NSNumber*)num {
    if (self.noteNums != nil) {
        for (UILabel* noteLabel in [self.noteNums allValues]) {
            noteLabel.hidden = true;
        }
    }
    
    [self setTitle:[num stringValue] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor midnightBlueColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    
    if (self.dupCount > 0) {
        [self markWrong];
    }
}

- (void)clearNum {
    [self setTitle:@" " forState:UIControlStateNormal];
    
    if (self.noteNums != nil) {
        for (UILabel* noteLabel in [self.noteNums allValues]) {
            noteLabel.hidden = false;
        }
    }
}

- (NSInteger)getNum {
    return [self.titleLabel.text integerValue];
}

- (void)toggleNote:(NSString*)note {
    if (self.noteNums == nil) {
        self.noteNums = [[NSMutableDictionary alloc] init];
    }
    
    UILabel* noteLabel = [self.noteNums objectForKey:note];
    if (noteLabel != nil) {
        if (noteLabel.hidden) {
            noteLabel.hidden = false;
        } else {
            [noteLabel removeFromSuperview];
            [self.noteNums removeObjectForKey:note];
        }
    } else {
        NSInteger num = [note integerValue];
        NSInteger i = (num - 1) / 3;
        NSInteger j = (num - 1) % 3;
        
        CGFloat width = self.frame.size.width / 3.0;
        CGFloat height = self.frame.size.height / 4.0;
        CGFloat x = j * width;
        CGFloat y = height + i * height;
        
        UILabel* noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        noteLabel.text = note;
        [noteLabel setFont:[UIFont systemFontOfSize:7]];
        noteLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:noteLabel];
        [self.noteNums setObject:noteLabel forKey:note];
    }
}

- (void)clearNote {
    for (UILabel* noteLabel in [self.noteNums allValues]) {
        noteLabel.hidden = true;
    }
}

- (void)setSum:(NSInteger)sum {
    if (self.sumText == nil) {
        self.sumText = [[UILabel alloc] initWithFrame:CGRectMake(3, 2, 10, 10)];
        [self.sumText setFont:[UIFont systemFontOfSize:7]];
        [self addSubview:self.sumText];
    }
    
    self.sumText.text = [NSString stringWithFormat:@"%ld", sum];
}

- (void)clearSum {
    if (self.sumText != nil) {
        self.sumText.text = @"";
        [self.sumText removeFromSuperview];
        self.sumText = nil;
    }
}

- (void)markWrong {
    [self setTitleColor:[UIColor pomegranateColor] forState:UIControlStateNormal];
}

- (void)deMarkWrong {
    [self setTitleColor:[UIColor midnightBlueColor] forState:UIControlStateNormal];
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
    self.needsDraw = true;
    [self setNeedsDisplay];
}

-(BOOL)getHasJoined {
    return self.needsDraw;
}

@end
