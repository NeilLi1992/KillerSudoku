//
//  Generator.h
//  KillerSudoku
//
//  Created by 李泳 on 15/1/14.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"
@interface Generator : NSObject
+ (GameBoard*)generate:(NSInteger)level;
@end
