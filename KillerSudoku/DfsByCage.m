//
//  DfsByCage.m
//  KillerSudoku
//
//  Created by 李泳 on 15/1/25.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "DfsByCage.h"

@implementation DfsByCage
+ (NSArray*)Solve:(GameBoard*)gb {
    NSMutableArray* possible_solutions= [[NSMutableArray alloc] init];
    
    NSMutableArray* cageOrder = [[NSMutableArray alloc] init];
    
    for (NSSet* cageIndicies in [gb getIteratorForCages]) {
        for (NSNumber* index in cageIndicies) {
            [cageOrder addObject:index];
        }
    }
    
    // We actually need to find the index to start with
    [DfsByCage dfsOnGame:gb ByOrder:cageOrder AtIndex:0 Store:possible_solutions];

    return [NSArray arrayWithArray:possible_solutions];
}

+ (void)dfsOnGame:(GameBoard*)gb ByOrder:(NSArray*)cageOrder AtIndex:(NSInteger)cageOrderIndex Store:(NSMutableArray*)possible_solutions{
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
            [possible_solutions addObject:[gb copy]];
            return;
        }
        else {
            [DfsByCage dfsOnGame:gb ByOrder:cageOrder AtIndex:nextIndex Store:possible_solutions];
        }
    }
    
    // No more available candidates at this position, clear this position before returning to previous position
    [gb setNum:[NSNumber numberWithInteger:0] AtIndex:[cageOrder objectAtIndex:cageOrderIndex]];
    return;
}

@end
