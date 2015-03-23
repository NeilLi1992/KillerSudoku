//
//  Solver.m
//  KillerSudoku
//
//  Created by 李泳 on 14/11/18.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "Solver.h"
#import "AlgorithmX.h"
#import "DfsByCell.h"
#import "DfsByCage.h"

@implementation Solver

SolverViewController* caller;

+ (void)setCaller:(SolverViewController*)vc {
    caller = vc;
}

+ (NSArray*)solve:(GameBoard*)unsolvedGame {
    NSString* algorithm = @"AlgorithmX";
//    NSString* algorithm = @"DfsByCell";
//    NSString* algorithm = @"DfsByCage";
    
//    // Apply preprocessing techniques
//    [Solver singleCageTechniqueOn:gb with:configuration];
//    
//    if ([gb isFinished]) {
//        //NSLog(@"The game is solved by pre techniques.");
//        return nil;
//    }
    
    NSArray* possible_solutions;
    
    // Time the solving process
    startTime = [[NSDate date] timeIntervalSinceReferenceDate];
    
    if ([algorithm isEqualToString:@"AlgorithmX"]) {
        [AlgorithmX setCaller:caller];
        possible_solutions = [AlgorithmX Solve:unsolvedGame];
    } else if ([algorithm isEqualToString:@"DfsByCell"]) {
        possible_solutions = [DfsByCell Solve:unsolvedGame];
    } else if ([algorithm isEqualToString:@"DfsByCage"]) {
        possible_solutions = [DfsByCage Solve:unsolvedGame];
    }
    
    // Print running time
    endTime = [[NSDate date] timeIntervalSinceReferenceDate];
    double elapsedTime = endTime - startTime;
//    NSLog(@"Total solving time: %f", elapsedTime);
    
    return possible_solutions;
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
