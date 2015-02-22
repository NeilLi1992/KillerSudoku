//
//  cellButton.h
//  KillerSudoku
//
//  Created by 李泳 on 15/2/15.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cellButton : UIButton

@property(nonatomic)BOOL isCrossed;
- (void)clear;
- (void)setNum:(NSNumber*)num;
- (void)incDupCount;
- (void)decDupCount;
- (void)toggleNote:(NSString*)note;
- (void)clearNote;

@end
