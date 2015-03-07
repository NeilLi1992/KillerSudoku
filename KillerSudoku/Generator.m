//
//  Generator.m
//  KillerSudoku
//
//  Created by 李泳 on 15/1/14.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "Generator.h"
#import "UnionFind.h"
#import "Solver.h"

@implementation Generator

//level: 0-easy, 1-midieum, 2-hard
// Return an array with two objects. 1st is the unsolved GameBoard. 2nd is the solution grid array
+ (NSArray*)generate:(NSInteger)level {
    NSArray* solutionGrid = [Generator generateSolutionGrid];
    NSInteger cageNum = 0;
    NSInteger maxSize = 0;
    
    switch (level) {
        case 0:
            cageNum = arc4random() % 3 + 30;
            maxSize = arc4random() % 2 + 6;
            break;
        case 1:
            cageNum = arc4random() % 3 + 28;
            maxSize = arc4random() % 2 + 7;
            break;
        case 2:
            cageNum = arc4random() % 3 + 26;
            maxSize = arc4random() % 2 + 8;
            break;
        default:
            break;
    }
    
    GameBoard* unsolvedGame = [Generator buildCages:cageNum withMaxSize:maxSize onGrid:solutionGrid];
    
//    GameBoard* solutionBoard = [unsolvedGame copy];
//    for (int i = 0; i < 9; i++) {
//        for (int j = 0; j < 9; j++) {
//            [solutionBoard setNum:[[solutionGrid objectAtIndex:i] objectAtIndex:j] AtRow:i Column:j];
//        }
//    }
//    NSLog(@"Display the solution board.\n%@", [solutionBoard cagesDescription]);
//    
//    
//    NSLog(@"Try to use Solver to solve it.");
//    NSArray* solutions = [Solver solve:unsolvedGame];
//    NSLog(@"Solver found %ld solutions.", [solutions count]);
//    for (GameBoard* solution in solutions) {
//        NSLog(@"%@", [solution cagesDescription]);
//    }
    
    if (unsolvedGame == nil) {
        return nil;
    } else {
        NSArray* result = [NSArray arrayWithObjects:unsolvedGame, solutionGrid, nil];
        return result;
    }
}

+ (NSArray*)generateSolutionGrid {
    int seeds[3][9][9] = {{
        {5,3,4,6,7,8,9,1,2},
        {6,7,2,1,9,5,3,4,8},
        {1,9,8,3,4,2,5,6,7},
        {8,5,9,7,6,1,4,2,3},
        {4,2,6,8,5,3,7,9,1},
        {7,1,3,9,2,4,8,5,6},
        {9,6,1,5,3,7,2,8,4},
        {2,8,7,4,1,9,6,3,5},
        {3,4,5,2,8,6,1,7,9}},
        {
        {8,6,2,1,7,4,5,3,9},
        {1,4,9,3,2,5,7,6,8},
        {5,7,3,6,8,9,2,1,4},
        {7,2,1,4,3,6,8,9,5},
        {3,8,4,9,5,2,6,7,1},
        {6,9,5,7,1,8,3,4,2},
        {2,1,6,5,4,3,9,8,7},
        {9,5,7,8,6,1,4,2,3},
        {4,3,8,2,9,7,1,5,6}},
        {
        {2,4,7,5,8,6,1,9,3},
        {5,1,8,3,9,4,6,7,2},
        {9,6,3,1,7,2,8,5,4},
        {3,8,4,9,6,1,5,2,7},
        {1,7,9,2,5,3,4,6,8},
        {6,5,2,7,4,8,9,3,1},
        {7,9,1,8,3,5,2,4,6},
        {4,2,5,6,1,7,3,8,9},
        {8,3,6,4,2,9,7,1,5}},
    };
    
    int seed[9][9];
    int seed_number = arc4random() % 3;
    NSLog(@"Using seed_number %ld", seed_number);
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            seed[i][j] = seeds[seed_number][i][j];
        }
    }
    
    // Transform 1: digit exchange
    NSMutableArray* numbers = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i < 10; i++) {
        [numbers addObject:[NSNumber numberWithInt:i]];
    }
    for (int i = 1; i < 10; i++) {
        int j = arc4random() % 9 + 1;
        [numbers exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
        //Begin substituting
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            seed[i][j] = [[numbers objectAtIndex:seed[i][j]] intValue];
        }
    }
    
    // Transform 2: rotation
    int rotationTime = arc4random() % 3 + 1;
    for (int i = 0; i < rotationTime; i++) {
        int new_seed[9][9];
        for (int j = 0; j < 9; j++) {
            for (int k = 0; k < 9; k++) {
                new_seed[8-k][j] = seed[j][k];
            }
        }
        
        for (int j = 0; j < 9; j++) {
            for (int k = 0; k < 9; k++) {
                seed[j][k] = new_seed[j][k];
            }
        }
    }
    
    // Transform 3: row-in-band exchange
    NSMutableArray* threeIndex = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    
    for (int band_index = 0; band_index < 3; band_index++) {
        // Shuffle index mapping for each band exchanging
        for (int i = 0; i < 3; i++) {
            int n = arc4random() % 3;
            [threeIndex exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        
        int threeGroups[3][9];
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 9; j++) {
                threeGroups[[[threeIndex objectAtIndex:i] intValue]][j] = seed[band_index * 3 + i][j];
            }
        }
        
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 9; j++) {
                seed[band_index * 3 + i][j] = threeGroups[i][j];
            }
        }
    }
    
    // Transform 4: column-in-stack exchange
    for (int stack_index = 0; stack_index < 3; stack_index++) {
        // Shuffle index mapping for each band exchanging
        for (int i = 0; i < 3; i++) {
            int n = arc4random() % 3;
            [threeIndex exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        
        int threeGroups[3][9];
        for (int j = 0; j < 3; j++) {
            for (int i = 0; i < 9; i++) {
                threeGroups[i][[[threeIndex objectAtIndex:j] intValue]] = seed[i][stack_index * 3 + j];
            }
        }
        
        for (int j = 0; j < 3; j++) {
            for (int i = 0; i < 9; i++) {
                seed[i][stack_index * 3 + j] = threeGroups[i][j];
            }
        }
    }
    
    // Transform 5: band exchange
    int new_seed[9][9];
    for (int i = 0; i < 3; i++) {
        int n = arc4random() % 3;
        [threeIndex exchangeObjectAtIndex:i withObjectAtIndex:n];
    }

    for (int base_index = 0; base_index < 3; base_index++) {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 9; j++) {
                new_seed[[[threeIndex objectAtIndex:base_index] intValue] * 3 + i][j] = seed[base_index * 3 + i][j];
            }
        }
    }
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            seed[i][j] = new_seed[i][j];
        }
    }
    
    
    // Transform 6: stack exchange
    for (int i = 0; i < 3; i++) {
        int n = arc4random() % 3;
        [threeIndex exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    for (int base_index = 0; base_index < 3; base_index++) {
        for (int j = 0; j < 3; j++) {
            for (int i = 0; i < 9; i++) {
                new_seed[i][[[threeIndex objectAtIndex:base_index] intValue] * 3 + j] = seed[i][base_index * 3 + j];
            }
        }
    }
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            seed[i][j] = new_seed[i][j];
        }
    }

    NSMutableArray* solutionGrid = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        NSMutableArray* row = [[NSMutableArray alloc] init];
        for (int j = 0; j < 9; j++) {
            [row addObject:[NSNumber numberWithInt:seed[i][j]]];
        }
        [solutionGrid addObject:row];
    }
    
    return [NSArray arrayWithArray:solutionGrid];
}

+ (GameBoard*)buildCages:(NSInteger)cageNumber withMaxSize:(NSInteger)maxSize onGrid:(NSArray*)solutionGrid{
    // Initialize a UF and a sums
    UnionFind* uf = [[UnionFind alloc] initWithCapacity:81];
    NSMutableDictionary* sums = [[NSMutableDictionary alloc] init];
    for (int index = 0; index < 81; index++) {
        NSInteger row = index / 9;
        NSInteger col = index % 9;
        [sums setObject:[[solutionGrid objectAtIndex:row] objectAtIndex:col] forKey:[NSNumber numberWithInt:index]];
    }
    
    int ite1 = 0;
    // Repeat until we get our desired number of cages
    while ([uf count] > cageNumber) {
        if ([[NSThread currentThread] isCancelled]) {
            NSLog(@"Generator thread is cancelled!");
            return nil;
        }
        // Randomly choose a cage
        NSInteger randomCageID = [uf getRandomComponentUnderSize:maxSize];
        // Calculate the left size for us to union a neighbor component
        NSInteger deltaSize = maxSize - [uf sizeOfComponent:randomCageID];
        
        if (deltaSize <= 0) {
            continue;
        }
        
        // Get the iterator containing all the indices in the randomCageID
        NSMutableArray* iterator = [uf getIteratorForComponent:randomCageID];
        
        // Find all the cageIDs around this cage, which are potentially uninonable
        NSMutableSet* possibleNeighborCageIDs = [[NSMutableSet alloc] init];
        for (NSNumber* cellIndex in iterator) {
            // Find all the 4-way neighbors of this cell. Indices out of range won't be selected
            NSMutableArray* neighbors = [Generator findFourNeighborsForCell:[cellIndex integerValue]];
            for (NSNumber* neighborIndex in neighbors) {
                //NSNumber* neighborCageID = [NSNumber numberWithInteger:[uf find:[neighborIndex integerValue]]];
                NSInteger neighborCageID = [uf find:[neighborIndex integerValue]];
                if (neighborCageID != randomCageID && [uf sizeOfComponent:neighborCageID] <= deltaSize) {
                    [possibleNeighborCageIDs addObject:[NSNumber numberWithInteger:neighborCageID]];
                }
            }
        }
        
        if ([possibleNeighborCageIDs count] == 0) {
            continue;
        }
        
        // Record all the numbers in the randomly selected cage
        NSMutableArray* allCageNumbers = [[NSMutableArray alloc] init];
        for (NSNumber* index in iterator) {
            NSInteger row = [index integerValue] / 9;
            NSInteger col = [index integerValue] % 9;
            [allCageNumbers addObject:[[solutionGrid objectAtIndex:row] objectAtIndex:col]];
        }
        
        int ite2 = 0;
        
        // Try to find a neighbor cage which is OK to union
        for (NSNumber* neighborCageID in possibleNeighborCageIDs) {
//            NSLog(@"ite2=%d", ite2++);
            // Check if duplicate numbers exist
            NSMutableArray* neighborIterator = [uf getIteratorForComponent:[neighborCageID integerValue]];
            BOOL findDuplicate = false;
            for (NSNumber* neighborIndex in neighborIterator) {
                if (findDuplicate) {
                    break;
                }
                NSInteger row = [neighborIndex integerValue] / 9;
                NSInteger col = [neighborIndex integerValue] % 9;
                if ([allCageNumbers containsObject:[[solutionGrid objectAtIndex:row] objectAtIndex:col]]) {
                    // Find duplicate numbers
                    findDuplicate = true;
                }
            }
            if (findDuplicate) {
                // Try next cage
                continue;
            }
            
            // Check if solution is unique after uninon
            UnionFind* test_uf = [uf copy];
            NSMutableDictionary* test_sums = [NSMutableDictionary dictionaryWithDictionary:sums];
            
            [test_uf connect:randomCageID with:[neighborCageID integerValue]];
            NSInteger sum1 = [[test_sums objectForKey:[NSNumber numberWithInteger:randomCageID]] integerValue];
            NSInteger sum2 = [[test_sums objectForKey:neighborCageID] integerValue];
            
            [test_sums removeObjectForKey:neighborCageID];
            [test_sums removeObjectForKey:[NSNumber numberWithInteger:randomCageID]];
            [test_sums setObject:[NSNumber numberWithInteger:(sum1 + sum2)] forKey:[NSNumber numberWithInteger:[test_uf find:randomCageID]]];
            
            GameBoard* test_gb = [[GameBoard alloc] initWithUF:test_uf andSums:test_sums];
            
//            NSLog(@"Into solver.");
            NSArray* solutions = [Solver solve:test_gb];
//            NSLog(@"Out of solver.");
            if ([solutions count] == 1) {
                // Ok to union
                uf = test_uf;
                sums = test_sums;
                break;
            } else {
                NSLog(@"Multiple solutions, discarded.");
//                NSLog(@"randomCageID=%d, neighbor=%d", randomCageID, [neighborCageID integerValue]);
//                NSLog(@"Original board:\n%@", [[[GameBoard alloc] initWithUF:uf andSums:sums] cagesDescription]);
//                
//                for (GameBoard* solution in solutions) {
//                    NSLog(@"%@", [solution cagesDescription]);
//                }
//                
//                exit(0);
                // Try next neighbor cage
                continue;
            }
        }
    }
    
    // Now the division of cages has completed. We should have valid UF and sums
    GameBoard* unsolvedGame = [[GameBoard alloc] initWithUF:uf andSums:sums];
    NSLog(@"Generation finished.");
    return unsolvedGame;
}

+ (NSMutableArray*)findFourNeighborsForCell:(NSInteger)cellIndex {
    NSMutableArray* neighbors = [[NSMutableArray alloc] init];
    if ((cellIndex + 1) % 9 != 0) {
        [neighbors addObject:[NSNumber numberWithInteger: cellIndex + 1]];
    }
    
    if (cellIndex % 9 != 0) {
        [neighbors addObject:[NSNumber numberWithInteger: cellIndex - 1]];
    }
    
    if (cellIndex + 9 < 81) {
        [neighbors addObject:[NSNumber numberWithInteger:cellIndex + 9]];
    }
    
    if (cellIndex - 9 >= 0) {
        [neighbors addObject:[NSNumber numberWithInteger:cellIndex - 9]];
    }
    return neighbors;
}

@end
