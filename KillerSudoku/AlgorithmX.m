//
//  AlgorithmX.m
//  KillerSudoku
//
//  Created by 李泳 on 14/12/9.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "AlgorithmX.h"

@implementation AlgorithmX

SolverViewController* caller;

+ (void)setCaller:(SolverViewController*)vc {
    caller = vc;
}

+ (NSArray*)Solve:(GameBoard*)unsolvedGame {
    
    // Keep the unsolvedGame intact
    GameBoard* gb = [unsolvedGame copy];
    
    // Build the matrix Y
    NSMutableDictionary* Y = [AlgorithmX buildMatrixYFrom:gb];
    
    // Pre selecting some columns from X (2)
    NSArray* cageIterator = [gb getIteratorForCages];
    Combination* combination = [gb getCombination];
    for (NSArray* cage in cageIterator) {
        NSNumber* cageSize = [NSNumber numberWithInteger:[cage count]];
        NSNumber* cageSum = [gb getCageSumAtIndex:[cage objectAtIndex:0]];
        NSArray* cageCandidates = [combination allNumsOfCageSize:cageSize withSum:cageSum];
        
        for (NSNumber* index in cage) {
            NSInteger row = [index integerValue] / 9;
            NSInteger col = [index integerValue] % 9;
            for (int i = 1; i <= 9; i++) {
                if (![cageCandidates containsObject:[NSNumber numberWithInt:i]]) {
                    NSNumber* rowIndex = [AlgorithmX getRowIndexFromRow:row Col:col Num:i];
                    [Y removeObjectForKey:rowIndex];
                }
            }
        }
    }

    // Build the matrix X
    NSMutableDictionary* X = [AlgorithmX buildMatrixXFrom:Y];
    
    // Pre selecting some columns from X (1)
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            if ([[gb getNumAtRow:i Column:j] integerValue] != 0) {
                NSNumber* cellNum = [gb getNumAtRow:i Column:j];
                NSNumber* rowIndex = [AlgorithmX getRowIndexFromRow:i Col:j Num:[cellNum integerValue]];
                [AlgorithmX selectWith:X and:Y on:rowIndex];
            }
        }
    }
    
    // Solve with Algorithm X
    NSMutableArray* solution = [[NSMutableArray alloc] init];
    NSMutableArray* possible_solutions = [[NSMutableArray alloc] init];
    [AlgorithmX solveWith:X and:Y on:solution with:gb store:possible_solutions];
    
    // Return all possible solutions
    if ([possible_solutions count] == 0) {
        NSLog(@"AlgorithmX no solution.");
    }
    return [NSArray arrayWithArray:possible_solutions];
}

#pragma -mark Matrix Building Methods
+ (NSMutableDictionary*)buildMatrixYFrom:(GameBoard*)gb {
    NSMutableDictionary* Y = [[NSMutableDictionary alloc] init];
    
    // Build the first 324 colums by adding four normal sudoku constrains
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            for (int n = 1; n <= 9; n++) {
                NSNumber* key = [AlgorithmX getRowIndexFromRow:i Col:j Num:n];
                
                // Calculate the column index for Row-Column Constraints
                NSInteger rc_index = 9 * i + j;
                NSNumber* obj1 = [NSNumber numberWithInteger:rc_index];
                
                // Calculate the column index for Row-Number Constraints
                NSInteger rn_index = 80 + 9 * i + n;
                NSNumber* obj2 = [NSNumber numberWithInteger:rn_index];
                
                // Calculate the column index for Column-Number Constraints
                NSInteger cn_index = 161 + 9 * j + n;
                NSNumber* obj3 = [NSNumber numberWithInteger:cn_index];
                
                // Calcualte the column index for Nonet-Number Constraints
                NSInteger nonet = i / 3 * 3 + j / 3;
                NSInteger nn_index = 242 + 9 * nonet + n;
                NSNumber* obj4 = [NSNumber numberWithInteger:nn_index];

                NSMutableArray* objArray = [NSMutableArray arrayWithObjects:obj1, obj2, obj3, obj4, nil];
                [Y setObject:objArray forKey:key];

            }
        }
    }
    
    // Adding the last 405 columns by analysing cages;
    NSInteger colBase = 0;
    NSArray* cageIterator = [gb getIteratorForCages];
    for (NSArray* cage in cageIterator) {
        NSNumber* cageSize = [NSNumber numberWithInteger:[cage count]];
        NSNumber* cageSum = [gb getCageSumAtIndex:[cage objectAtIndex:0]];
        
        NSMutableDictionary* auxMatrix = [[NSMutableDictionary alloc] init];
        NSInteger posOffset = 0;
        Combination* combination = [gb getCombination]; // Get a combination object for reference
        
        int rolIndexOffset[9] = {-1,-1,-1,-1,-1,-1,-1,-1,-1};    // Used to identify which row to add or modify
        
        for (NSArray* comb in [combination allComsOfCageSize:cageSize withSum:cageSum]) {
            // Calculating a newposition, reset the posOffset
            posOffset = 0;
            for (NSNumber* num in comb) {
                NSMutableArray* numList = [auxMatrix objectForKey:[NSNumber numberWithInteger:posOffset]];
                if (numList) {
                    if (![numList containsObject:num]) {
                        [[auxMatrix objectForKey:[NSNumber numberWithInteger:posOffset]] addObject:num];
                    }
                } else {
                    numList = [NSMutableArray arrayWithObject:num];
                    [auxMatrix setObject:numList forKey:[NSNumber numberWithInteger:posOffset]];
                }
                posOffset += [num integerValue];
            }
        }
        
        // Adjust the rowIndexOffset array
        for (NSNumber* pos in [auxMatrix allKeys]) {
            NSArray* numList = [auxMatrix objectForKey:pos];
            for (NSNumber* num in numList) {
                rolIndexOffset[[num intValue] - 1] ++;
            }
        }
        
        // Now modify or add rows in matrix Y
            // Traverse every num in the auxMatrix
        for (NSNumber* pos in [auxMatrix allKeys]) {
            NSArray* numList = [auxMatrix objectForKey:pos];
            for (NSNumber* num in numList) {
                // Check if we need to modify the original row in Y, or to add a new row
                if (rolIndexOffset[[num intValue] - 1] == 0) {
                    // We can directly modify the existing rowIndex
                    // We need to modify the rows for all possible positions within this cage
                    for (NSNumber* index in cage) {
                        NSInteger row = [index integerValue] / 9;
                        NSInteger col = [index integerValue] % 9;
                        NSNumber* rowIndex = [AlgorithmX getRowIndexFromRow:row Col:col Num:[num integerValue]];    // Calcualte the row Index for this particular position

                        NSMutableArray* matrixRow = [Y objectForKey:rowIndex];
                        for (int i = 0; i < [num intValue]; i++) {
                            // Calculate the column index for adding
                            NSInteger cageConstraint = 324 + colBase + [pos integerValue] + i;
                            [matrixRow addObject:[NSNumber numberWithInteger:cageConstraint]];
                        }
                    }
                } else {
                    // We need to add a new row into Y
                    // We also need to do this for all possible positions
                    for (NSNumber* index in cage) {
                        NSInteger row = [index integerValue] / 9;
                        NSInteger col = [index integerValue] % 9;
                        NSNumber* originalRowIndex = [AlgorithmX getRowIndexFromRow:row Col:col Num:[num integerValue]];
                        NSNumber* newRowIndex = [NSNumber numberWithInteger:([originalRowIndex integerValue] + rolIndexOffset[[num intValue] - 1])];
                        
                        //NSMutableArray* matrixRow = [[Y objectForKey:originalRowIndex] copy];
                        NSMutableArray* matrixRow = [NSMutableArray arrayWithArray:[Y objectForKey:originalRowIndex]];
                        for (int i = 0; i < [num intValue]; i++) {
                            // Calculate the column index for adding
                            NSInteger cageConstraint = 324 + colBase + [pos integerValue] + i;
                            [matrixRow addObject:[NSNumber numberWithInteger:cageConstraint]];
                        }
                        
                        // Add this new row
                        [Y setObject:matrixRow forKey:newRowIndex];
                    }
                    
                    // After doing this for all positions within cage, reduce the rolIndexOffset
                    rolIndexOffset[[num intValue] - 1]--;
                }
            }
        }
        
        // Finish processing one cage, adjust the colBase offset
        colBase += [cageSum integerValue];
    }
    
    return Y;
}

+ (NSMutableDictionary*)buildMatrixXFrom:(NSMutableDictionary*)Y {
    NSMutableDictionary* X = [[NSMutableDictionary alloc] init];
    
    for (NSNumber* rowIndex in Y) {
        for (NSNumber* colIndex in [Y objectForKey:rowIndex]) {
            
            if ([X objectForKey:colIndex]) {
                // This colIndex already exists as a key in X
                [[X objectForKey:colIndex] addObject:[rowIndex copy]];
                
            } else {
                // colIndex doesn't exists as a key in X
                NSMutableArray* objArray = [NSMutableArray arrayWithObject:[rowIndex copy]];
                [X setObject:objArray forKey:colIndex];
            }
        }
    }
    
    return X;
}

#pragma  -mark Algorithm X Core Methods
+ (void)solveWith:(NSMutableDictionary*)X and:(NSMutableDictionary*)Y on:(NSMutableArray*)solution with:(GameBoard*)gb store:(NSMutableArray*)possible_solutions {
    if ([[NSThread currentThread] isCancelled]) {
        NSLog(@"Solving thread cancelled in Algorithm X");
        NSLog(@"Already found solution number: %ld", [possible_solutions count]);
        return;
    }
    
    if ([X count] == 0) {
        for (NSNumber* rowIndex in solution) {
            NSInteger n = [rowIndex integerValue] / 10 % 9 + 1;
            NSInteger c = [rowIndex integerValue] / 10 / 9 % 9;
            NSInteger r = [rowIndex integerValue] / 10 / 81;
            
            [gb setNum:[NSNumber numberWithInteger:n] AtRow:r Column:c];
        }
        
        // Store the found solution in an array
        [possible_solutions addObject:[gb copy]];
        
        // Inform the solver on main thread a solution is found
        if (caller != nil) {
            [caller performSelectorOnMainThread:@selector(findSolution:) withObject:[NSNumber numberWithInteger:[possible_solutions count]] waitUntilDone:NO];
        }

    } else {
        // Find the column col, corresponding to least number of rows
        NSNumber* col;
        NSInteger numOfRows = INFINITY;
        for (NSNumber* colIndex in [X allKeys]) {
            if ([[X objectForKey:colIndex] count] < numOfRows) {
                numOfRows = [[X objectForKey:colIndex] count];
                col = colIndex;
            }
        }
        
        // Rpeat on each corresponding row of the chosen col
        for (NSNumber* row in [[X objectForKey:col] copy]) {
            // Add this row as a partial solution
            [solution addObject:row];
            NSMutableArray* columns = [AlgorithmX selectWith:X and:Y on:row];   // Select columns
            [AlgorithmX solveWith:X and:Y on:solution with:gb store:possible_solutions]; // ?????
            
            [AlgorithmX deselectWith:X and:Y on:row from:columns];  // Deselect columns and recover the mtrix
            [solution removeLastObject];
        }
    }
}

+ (NSMutableArray*)selectWith:(NSMutableDictionary*)X and:(NSMutableDictionary*)Y on:(NSNumber*)row {
    NSMutableArray* cols = [[NSMutableArray alloc] init];
    
    for (NSNumber* j in [Y objectForKey:row]) {
        for (NSNumber* i in [X objectForKey:j]) {
            for (NSNumber* k in [Y objectForKey:i]) {
                if ([k integerValue] != [j integerValue]) {
                    [[X objectForKey:k] removeObject:i];
                }
            }
        }
        [cols addObject:[X objectForKey:j]];
        [X removeObjectForKey:j];
    }
    return  cols;
}

+ (void)deselectWith:(NSMutableDictionary*)X and:(NSMutableDictionary*)Y on:(NSNumber*)row from:(NSMutableArray*)cols {
    NSArray* colIndices = [Y objectForKey:row];
    for (int dummy_j = (int)([colIndices count] - 1); dummy_j >=0 ; dummy_j--) {  // Traverse Y[row] in a reversed order
        // X[j] = cols.pop()
        NSNumber* j = [colIndices objectAtIndex:dummy_j];
        NSNumber* col = [cols lastObject];
        [cols removeLastObject];
        [X setObject:col forKey:j];
        
        for (NSNumber* i in [X objectForKey:j]) {
            for (NSNumber* k in [Y objectForKey:i]) {
                if ([k integerValue] != [j integerValue]) {
                    [[X objectForKey:k] addObject:i];
                }
            }
        }
    }
}

#pragma -mark Helper Methods
//Row~(0,8), Col~(0,8), Num~(1,9)
+ (NSNumber*)getRowIndexFromRow:(NSUInteger)r Col:(NSUInteger)c Num:(NSUInteger)n {
    NSInteger index = r * 81 + c * 9 + (n - 1);
    index *= 10;
    return  [NSNumber numberWithInteger:index];
}

+ (NSArray*)getRowColNumFromIndex:(NSNumber*)index {
    NSNumber* n = [NSNumber numberWithInteger:[index integerValue] % 9 + 1];
    NSNumber* c = [NSNumber numberWithInteger:[index integerValue] / 9];
    NSNumber* r = [NSNumber numberWithInteger:[index integerValue] / 81];
    
    return [NSArray arrayWithObjects:n, c, r, nil];
}

@end
