//
//  Solver.h
//  KillerSudoku
//
//  Created by 李泳 on 14/11/18.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"
#import "Constant.h"
#import "SolverViewController.h"
static NSTimeInterval startTime;
static NSTimeInterval endTime;

@interface Solver : NSObject
+ (void)setCaller:(SolverViewController*)vc;
+ (NSArray*)solve:(GameBoard*)unsolvedGame;
@end
