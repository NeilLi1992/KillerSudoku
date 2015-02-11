//
//  DfsByCell.h
//  KillerSudoku
//
//  Created by 李泳 on 15/1/25.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"
@interface DfsByCell : NSObject
+ (NSArray*)Solve:(GameBoard*)gb;
@end
