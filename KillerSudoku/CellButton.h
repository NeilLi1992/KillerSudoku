//
//  PlayCellButton.h
//  KillerSudoku
//
//  Created by 李泳 on 15/3/7.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellButton : UIButton
- (void)setNum:(NSNumber*)num;
- (void)clearNum;
- (NSInteger)getNum;

- (void)toggleNote:(NSString*)note;
- (void)clearNote;

- (void)setSum:(NSInteger)sum;
- (void)clearSum;

- (void)incDupCount;
- (void)decDupCount;

-(void)setBorderFlagsLeft:(BOOL)left Right:(BOOL)right Top:(BOOL)top Below:(BOOL)below;
-(void)setCornerFlagsLT:(BOOL)lt RT:(BOOL)rt LB:(BOOL)lb RB:(BOOL)rb;
-(void)clearBorderLines;

-(BOOL)getHasJoined;

@end
