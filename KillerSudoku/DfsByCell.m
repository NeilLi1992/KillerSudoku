//
//  DfsByCell.m
//  KillerSudoku
//
//  Created by 李泳 on 15/1/25.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "DfsByCell.h"

@implementation DfsByCell

+ (NSArray*)Solve:(GameBoard*)gb {
    NSMutableArray* possible_solutions = [[NSMutableArray alloc] init];
    
    // Search for the first position to start
    NSInteger i = 0;
    NSInteger j = 0;
    while (![[gb getNumAtRow:i Column:j] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        if (j < 8) {
            j++;
        }
        else {
            j = 0;
            i ++;
        }
    }
    
    [DfsByCell searchOnGame:gb AtRow:i Col:j Store:possible_solutions];
    
    return [NSArray arrayWithArray:possible_solutions];
}

+ (void)searchOnGame:(GameBoard*)gb AtRow:(NSInteger)row Col:(NSInteger)col Store:(NSMutableArray*)possible_solutions{
    NSMutableSet* candidates = [gb findCandidatesAtRow:row Column:col];
    
    if ([candidates count] == 0) {
        // No available candidates at this position
        return;
    }
    
    while ([candidates count] != 0) {
        // Pop a candidate number for probing from the candidates set
        NSNumber* probeValue = [candidates anyObject];
        [candidates removeObject:probeValue];
        
        // Set this number at this position
        [gb setNum:probeValue AtRow:row Column:col];
        
        // Check is the game is finished
        // Let's just try to locate the next position, if this position is out of board, the game is finished.
        // Otherwise, the next position will be used anyway, this calculaton won't be wasted
        // If nextRow > 8, this means the grid is at least all filled
        NSInteger nextRow = row;
        NSInteger nextCol = col;
        while (nextRow < 9 && ![[gb getNumAtRow:nextRow Column:nextCol] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            if (nextCol < 8) {
                nextCol++;
            } else {
                nextCol = 0;
                nextRow++;
            }
        }
        
        
        // If we test the game's end by detecting next position and see if it goes out of board,
        // there is no need to do the [gb isFinished] test. 40s -> 37s
        if (nextRow > 8) {
            // We find a solution
            [possible_solutions addObject:[gb copy]];
        }
        else {
            // Go to next position for further searching
            [DfsByCell searchOnGame:gb AtRow:nextRow Col:nextCol Store:possible_solutions];
        }
    }
    
    // No more available candidates at this position, clear this position before returning to previous position
    [gb setNum:[NSNumber numberWithInt:0] AtRow:row Column:col];
    return;
}



@end
