//
//  ArchiveWrapper.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/14.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "ArchiveWrapper.h"

@implementation ArchiveWrapper


#pragma mark - Delegate methods
- (id)initWithGameBoard:(GameBoard*)gameBoard Solution:(NSArray*)solutionGrid FinishCount:(NSInteger)count FilledCount:(NSInteger)count2 Level:(NSInteger)level {
    self = [super init];
    
    self.date = [NSDate date];
    self.gameBoard = gameBoard;
    self.solutionGrid = solutionGrid;
    self.finishCount = count;
    self.filledCount = count2;
    self.level = level;
    
    return self;
}

- (id)initWithCoder: (NSCoder*) coder {
    self.date = [coder decodeObjectForKey:@"date"];
    self.gameBoard = [coder decodeObjectForKey:@"gameboard"];
    self.solutionGrid = [coder decodeObjectForKey:@"solutionGrid"];
    self.finishCount = [coder decodeIntegerForKey:@"finishCount"];
    self.filledCount = [coder decodeIntegerForKey:@"filledCount"];
    self.level = [coder decodeIntegerForKey:@"level"];
    return self;
}

- (void)encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.gameBoard forKey:@"gameboard"];
    [coder encodeObject:self.solutionGrid forKey:@"solutionGrid"];
    [coder encodeInteger:self.finishCount forKey:@"finishCount"];
    [coder encodeInteger:self.filledCount forKey:@"filledCount"];
    [coder encodeInteger:self.level forKey:@"level"];
}

@end
