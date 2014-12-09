//
//  Solver.m
//  KillerSudoku
//
//  Created by 李泳 on 14/11/18.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "Solver.h"


@implementation Solver

+ (GameBoard*)solve:(NSMutableDictionary*)configuration {
    NSString* searchMode = @"dfsByCageOrder";
    
    GameBoard* gb = [[GameBoard alloc] initWithConfiguration:configuration];
    
    // Time the solving process
    startTime = [[NSDate date] timeIntervalSinceReferenceDate];
    
    // Apply preprocessing techniques
    [Solver singleCageTechniqueOn:gb with:configuration];
    
    if ([gb isFinished]) {
        NSLog(@"The game is solved by pre techniques.");
        return nil;
    }
    
    // Start solving
    if ([searchMode isEqualToString:@"dfs"]) {
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
        
        [Solver dfsOnGame:gb AtRow:i Col:j];

        return nil;
    }
    else if ([searchMode isEqualToString:@"dfsByCageOrder"]) {
        NSLog(@"%@", configuration);
        NSMutableArray* cageOrder = [[NSMutableArray alloc] init];
        for (NSSet* cageIndicies in configuration) {
            for (NSNumber* index in cageIndicies) {
                [cageOrder addObject:index];
            }
        }
        
        // We actually need to find the index to start with
        [Solver dfsOnGame:gb ByOrder:cageOrder AtIndex:0];
        return nil;
    }
    else    return nil;
}

# pragma mark Different Solving Methods
+ (void)dfsOnGame:(GameBoard*)gb AtRow:(NSInteger)row Col:(NSInteger)col {
//    NSLog(@"Enter searching position (%ld,%ld)", row, col);
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
            // Voila, we find a solution
            NSLog(@"A soluton is found.\n%@", gb);
//            return;
            
            // Print the run time
            endTime = [[NSDate date] timeIntervalSinceReferenceDate];
            double elapsedTime = endTime - startTime;
            NSLog(@"time: %f", elapsedTime);

            exit(0);
        }
        else {
            // Go to next position for further searching
            [Solver dfsOnGame:gb AtRow:nextRow Col:nextCol];
        }
    }
    
    // No more available candidates at this position, clear this position before returning to previous position
    [gb setNum:[NSNumber numberWithInt:0] AtRow:row Column:col];
    return;
}

+ (void)dfsOnGame:(GameBoard*)gb ByOrder:(NSArray*)cageOrder AtIndex:(NSInteger)cageOrderIndex {
//    NSLog(@"Enter searching index %ld\n", (long)cageOrderIndex);
    NSMutableSet* candidates = [gb findCandidatesAtIndex:[cageOrder objectAtIndex:cageOrderIndex]];

    if ([candidates count] == 0) {
        // No available candidates at this position
        return;
    }
    
    while ([candidates count] != 0) {
        // Pop a candidate number for probing from the candidates set
        NSNumber* probeValue = [candidates anyObject];
        [candidates removeObject:probeValue];
        
        // Set this number at this position
        [gb setNum:probeValue AtIndex:[cageOrder objectAtIndex:cageOrderIndex]];
        
        // Game end test
        NSInteger nextIndex = cageOrderIndex;
        while (nextIndex < [cageOrder count] && ![[gb getNumAtIndex:[cageOrder objectAtIndex:nextIndex]] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
            nextIndex++;
        }
        
        if (nextIndex == [cageOrder count]) {
            // Voila, we find a solution
            NSLog(@"A soluton is found.\n%@", gb);
            //            return;
            
            // Print the run time
            endTime = [[NSDate date] timeIntervalSinceReferenceDate];
            double elapsedTime = endTime - startTime;
            NSLog(@"time: %f", elapsedTime);
            
            exit(0);

        }
        else {
            [Solver dfsOnGame:gb ByOrder:cageOrder AtIndex:nextIndex];
        }
    }
    
    // No more available candidates at this position, clear this position before returning to previous position
    [gb setNum:[NSNumber numberWithInteger:0] AtIndex:[cageOrder objectAtIndex:cageOrderIndex]];
    return;
}


#pragma mark Preprocessing techniques performed before doing dfs
/*!
 * If one cage has only a single number, we can immediately fill this number
 */
+ (void)singleCageTechniqueOn:(GameBoard*)gb with:(NSMutableDictionary*)configuration {
    NSMutableArray* removableSet = [[NSMutableArray alloc] init];
    for (NSMutableArray* indicesSet in configuration) {
        if ([indicesSet count] == 1) {
            NSNumber* sum = [configuration objectForKey:indicesSet];
            [gb setNum:sum AtIndex:[indicesSet objectAtIndex:0]];
            [removableSet addObject:indicesSet];
        }
    }
    
    // These single cages are done, can be removed from configuration dictionnary.
    for (NSMutableArray* toRemove in removableSet) {
        [configuration removeObjectForKey:toRemove];
    }
}

@end
