//
//  solverCellButton.h
//  KillerSudoku
//
//  Created by 李泳 on 15/2/26.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface solverCellButton : UIButton
-(void)setBorderFlagsLeft:(BOOL)left Right:(BOOL)right Top:(BOOL)top Below:(BOOL)below;
-(void)setCornerFlagsLT:(BOOL)lt RT:(BOOL)rt LB:(BOOL)lb RB:(BOOL)rb;
-(void)clearBorderLines;
-(BOOL)getHasJoined;
-(void)setSum:(NSInteger)sum;
-(void)clearSum;
-(void)setNum:(NSNumber*)number;
-(NSInteger)getNum;
-(void)clearNum;
@end
