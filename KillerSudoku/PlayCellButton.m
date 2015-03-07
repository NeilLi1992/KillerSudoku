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
@end

@implementation PlayCellButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
@end
