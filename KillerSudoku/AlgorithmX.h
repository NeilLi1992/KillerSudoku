//
//  AlgorithmX.h
//  KillerSudoku
//
//  Created by 李泳 on 14/12/9.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"

@interface AlgorithmX : NSObject
+ (NSArray*)Solve:(GameBoard*)gb;
@end
