//
//  AlgorithmX.h
//  KillerSudoku
//
//  Created by 李泳 on 14/12/9.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"
#import "SolverViewController.h"
@interface AlgorithmX : NSObject
+ (void)setCaller:(SolverViewController*)vc;
+ (NSArray*)Solve:(GameBoard*)gb;
@end
