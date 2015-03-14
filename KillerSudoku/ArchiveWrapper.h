//
//  ArchiveWrapper.h
//  KillerSudoku
//
//  Created by 李泳 on 15/3/14.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"

@interface ArchiveWrapper : NSObject <NSCoding>
@property(strong, nonatomic)NSDate* date;
@property(strong, nonatomic)GameBoard* gameBoard;
@property(strong, nonatomic)NSArray* solutionGrid;
@property(nonatomic)NSInteger finishCount;

- (id)initWithGameBoard:(GameBoard*)gameBoard Solution:(NSArray*)solutionGrid FinishCount:(NSInteger)count;
@end


