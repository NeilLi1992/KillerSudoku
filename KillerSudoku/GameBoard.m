//
//  GameBoard.m
//  KillerSudoku
//
//  Created by 李泳 on 14-10-14.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "GameBoard.h"

@interface GameBoard()

@property(nonatomic, strong)NSMutableArray* cells;  // cells array store all the numbers
@property(nonatomic, strong)NSMutableArray* cages;  // cages array simply serve as an iterator
@property(nonatomic, strong)UnionFind* uf;  // uf object can completely determines the state of the cage
@property(nonatomic, strong)NSMutableDictionary* sums;  //represent the sums of cages, store (key=cageId, value=sum) pair
@property(nonatomic, strong)Combination* combination;   // a combination object for reference the combinations of sum
@end

@implementation GameBoard

#pragma mark Construct methods
// A default initializor which constructs an empty board
-(id)init {
    self = [super init];
    self.cells = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        NSMutableArray* new_row = [[NSMutableArray alloc] init];
        for (int j = 0; j< 9; j++) {
            [new_row addObject:[NSNumber numberWithInt:0]];
        }
        [self.cells addObject:new_row];
    }
    
    return self;
}

/*!
 * This initializor is called in the solver module.
 * We construct an empty grid with a configuration dictionary
 */
-(id)initWithConfiguration:(NSMutableDictionary*)configuration {
    self = [super init];
    // Build an empty board
    self.cells = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        NSMutableArray* new_row = [[NSMutableArray alloc] init];
        for (int j = 0; j< 9; j++) {
            [new_row addObject:[NSNumber numberWithInt:0]];
        }
        [self.cells addObject:new_row];
    }
    
    // Init a combination object for reference
    self.combination = [[Combination alloc] init];
    
    // Convert the configuration into an uf object
    // Also build the sum dictionnary
    [self storeConfiguration:configuration];
    
    return self;
}

// To build an unsolved board, we need uf and sums
-(id)initWithUF:(UnionFind*)uf andSums:(NSMutableDictionary*)sums {
    self = [super init];
    // Build an empty board
    self.cells = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        NSMutableArray* new_row = [[NSMutableArray alloc] init];
        for (int j = 0; j< 9; j++) {
            [new_row addObject:[NSNumber numberWithInt:0]];
        }
        [self.cells addObject:new_row];
    }

    self.uf = [uf copy];
    self.sums = [sums copy];
    self.cages = [[NSMutableArray alloc] init];
    self.combination = [[Combination alloc] init];
    
    NSArray* allCageIDs = [self.uf getAllComponents];
    for (NSNumber* cageID in allCageIDs) {
        NSArray* iterator = [self.uf getIteratorForComponent:[cageID integerValue]];
        [self.cages addObject:iterator];
    }
    
    return self;
}

-(id)initWithCells:(NSArray*)cells {
    self = [super init];
    self.cells = [[NSMutableArray alloc] init];
    for (NSMutableArray* row in cells) {
        [self.cells addObject:[NSMutableArray arrayWithArray:row]];
    }
    
    return self;
}

-(id)initWithIntegerArray:(int[9][9])array {
    self = [super init];
    self.cells = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        NSMutableArray* newRow = [[NSMutableArray alloc] init];
        for (int j = 0; j < 9; j++) {
            [newRow addObject:[NSNumber numberWithInt:array[i][j]]];
        }
        [self.cells addObject:newRow];
    }
    
    self.cages = [[NSMutableArray alloc] init];
    [self buildCages:28 withMaxSize:7];
    
    return self;
}

/*!
 *This method is called during the initialization to build cages division
 *@returns An array of cages objects
 *@param cageNumber The number of cages desired
 *@param maxSize The maximum allowed size(inclusive) a single cage
 */
-(void)buildCages:(NSInteger)cageNumber withMaxSize:(NSInteger)maxSize {
    
//    UnionFind* uf = [[UnionFind alloc] initWithCapacity: 81];
    self.uf = [[UnionFind alloc] initWithCapacity: 81];
    
    // The number of cages haven't been reduced to our desire
    while ([self.uf count] > cageNumber) {
        // Get the component identifier of a randomly chosen component which under the size limit
        NSInteger randomComponent = [self.uf getRandomComponentUnderSize:maxSize];
        // Calculate the left size for us to union a neighbor component
        NSInteger deltaSize = maxSize - [self.uf sizeOfComponent:randomComponent];
        
        // Try a more random way to find a neighbor component to connect
        
        //Get the iterator which contains all the indices in the randomComponent
        NSMutableArray* iterator = [self.uf getIteratorForComponent:randomComponent];
        
        while ([iterator count] > 0) {
            // From the iterator, pop an index randomly
            NSNumber* index = [iterator objectAtIndex:arc4random_uniform((uint)[iterator count])];
            [iterator removeObject:index];
            
            // Find all the indices for 4-way neighbors of index, indices out of range won't be selected
            NSMutableArray* neighbors = [self findFourNeighborsForCell:[index integerValue]];
            
            while ([neighbors count] > 0) {
                // From the neighbors, pop a neighbor randomly
                NSNumber* neighborIndex = [neighbors objectAtIndex:arc4random_uniform((uint)[neighbors count])];
                [neighbors removeObject:neighborIndex];
                
                // If this neighbor is in a different component, and this component's size is in the size limit, we successfuly find a component to union
                if ([self.uf find:[neighborIndex integerValue]] != randomComponent && [self.uf sizeOfComponent:[self.uf find:[neighborIndex integerValue]]] <= deltaSize) {
                    [self.uf connect:[neighborIndex integerValue] with:randomComponent];
                    goto SatisfiedNeighborComponentFound;
                }
                
            }
        }
        SatisfiedNeighborComponentFound:;
    }
    
    // Now we have completed the connections of UF, we start to construct the cages array
    NSMutableArray* identifiers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 81; i++) {
        if ( [identifiers containsObject:[NSNumber numberWithInteger:[self.uf find:i]]] == false) {
            [identifiers addObject:[NSNumber numberWithInteger:[self.uf find:i]]];
        }
    }
    
    for (NSNumber* identifier in identifiers) {
        [self.cages addObject:[self.uf getIteratorForComponent:[identifier integerValue]]];
    }
}

/*!
 * This method can convert a configuration dictionary into an uf object, and build the cages iterator as well
 */
-(void)storeConfiguration:(NSMutableDictionary*)configuration {
    self.uf = [[UnionFind alloc] initWithCapacity: 81];
    self.sums = [[NSMutableDictionary alloc] init];
    self.cages = [[NSMutableArray alloc] init];
    
    // Iterate the configuration dictionaires to build an uf object, and a sums dict connecting cageId to sum
    for (NSArray* indices in configuration) {
        NSNumber* sum = [configuration objectForKey:indices];
        NSNumber* cageID = [indices objectAtIndex:0];
        
        // Connect each index with the cageID
        for (NSNumber* index in indices) {
            [self.uf connect:[index integerValue] with:[cageID integerValue]];
        }
        
        // Add the iterator for the cage into cages
        [self.cages addObject:[self.uf getIteratorForComponent:[cageID integerValue]]];
        
        // Add the (cageID, sum) pair into the sums dictionary
        [self.sums setObject:sum forKey:cageID];
    }

}

/*!
 * Return a new copy of the game
 */
-(GameBoard*)copy {
    GameBoard* newBoard = [[GameBoard alloc] initWithCells:self.cells];
    newBoard.cages = [NSMutableArray arrayWithArray:self.cages];
    newBoard.uf = [self.uf copy];
    newBoard.sums = [NSMutableDictionary dictionaryWithDictionary:self.sums];
    newBoard.combination = [self.combination copy];
    
    return newBoard;
}

#pragma mark Setter & Getter
// Get an iterator for all cages. Each cage contains the indices of the cells contained within that cage.
-(NSArray*)getIteratorForCages {
    return [NSArray arrayWithArray:self.cages];
}

-(NSArray*)getIteratorForCageID:(NSNumber*)index {
    return  [NSArray arrayWithArray:[self.uf getIteratorForComponent:[index integerValue]]];
}

// Get cage identifier of a given position. Cage identifier is the root index in the uf of each cage
-(NSNumber*)getCageIdAtRow:(NSInteger)row Column:(NSInteger)col {
    NSInteger index = row * 9 + col;
    return  [NSNumber numberWithInteger:[self.uf find:index]];
}

-(NSNumber*)getCageIdAtIndex:(NSNumber*)index {
    return  [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
}

// Get cage sum for a given position.
-(NSNumber*)getCageSumAtRow:(NSInteger)row Column:(NSInteger)col {
    NSInteger index = row * 9 + col;
    return [self getCageSumAtIndex:[NSNumber numberWithInteger:index]];
}

// Get cage sum for a given position.
-(NSNumber*)getCageSumAtIndex:(NSNumber*)index {
    return [self.sums objectForKey:[self getCageIdAtIndex:index]];
}

// Get the number of a given position.
-(NSNumber*)getNumAtRow:(NSInteger)row Column:(NSInteger)col {
    return [[self.cells objectAtIndex:row] objectAtIndex:col];
    
}

-(NSNumber*)getNumAtIndex:(NSNumber*)index {
    NSInteger row = [index integerValue] / 9;
    NSInteger col = [index integerValue] % 9;
    return [[self.cells objectAtIndex:row] objectAtIndex:col];
}

// Get the combination object for reference purpose.
-(Combination*)getCombination {
    return self.combination;
}

-(NSArray*)getCombsForCage:(NSNumber*)cageID {
    NSNumber* cageSum = [self getCageSumAtIndex:cageID];
    NSNumber* cageSize = [NSNumber numberWithInteger:[self.uf sizeOfComponent:[cageID integerValue]]];
    return [self.combination allComsOfCageSize:cageSize withSum:cageSum];
}



// Set the number of a given position.
-(void)setNum:(NSNumber*)number AtRow:(NSInteger)row Column:(NSInteger)col {
    [[self.cells objectAtIndex:row] replaceObjectAtIndex:col withObject:number];
}

-(void)setNum:(NSNumber *)number AtIndex:(NSNumber*)index {
    NSInteger row = [index integerValue] / 9;
    NSInteger col = [index integerValue] % 9;
    [[self.cells objectAtIndex:row] replaceObjectAtIndex:col withObject:number];
}

-(UnionFind*)getUF {
    return self.uf;
}

-(NSMutableDictionary*)getSum {
    return self.sums;
}

-(NSMutableArray*)getCells {
    return self.cells;
}

#pragma mark Helper methods
/*!
 * Find all the candidate numbers at a given position, according to the normal sudoku rules
 */
-(NSMutableSet*)findCandidatesAtIndex:(NSNumber*)index {
    NSInteger row = [index integerValue] / 9;
    NSInteger col = [index integerValue] % 9;
    return [self findCandidatesAtRow:row Column:col];
}

-(NSMutableSet*)findCandidatesAtRow:(NSInteger)row Column:(NSInteger)col {
    NSMutableSet* candidates = [[NSMutableSet alloc] init];
    
    //  If the cell is already filled, return the empty set directly
    if ([[[self.cells objectAtIndex:row] objectAtIndex:col] intValue] == 0) {
        // Otherwise, add 9 numbers into it by default
        for (int i = 1; i <= 9; i++) {
            [candidates addObject:[NSNumber numberWithInt:i]];
        }
        
        // Apply normal sudoku rules
            // Check the row for duplicate
        NSMutableArray* checkingRow = [self.cells objectAtIndex:row];
        [candidates minusSet:[NSSet setWithArray:checkingRow]];
        
            // Check the column for duplicate
        for (int i = 0; i < 9; i++) {
            if ([candidates containsObject:[[self.cells objectAtIndex:i] objectAtIndex:col]]) {
                [candidates removeObject:[[self.cells objectAtIndex:i] objectAtIndex:col]];
            }
        }
        
        if ([candidates count] == 0) {
            // All 9 numbers excluded, no need for further checking
            return candidates;
        }
        
            // Check the nonet for duplicate
        NSInteger nonet = row / 3 * 3 + col / 3;
        NSInteger i = nonet / 3 * 3;
        NSInteger j = nonet % 3 * 3;
        for (int delta_i = 0; delta_i < 3; delta_i++) {
            for (int delta_j = 0; delta_j < 3; delta_j++) {
                if ([candidates containsObject:[[self.cells objectAtIndex:(i + delta_i)] objectAtIndex:(j + delta_j)]]) {
                    [candidates removeObject:[[self.cells objectAtIndex:(i + delta_i)] objectAtIndex:(j + delta_j)]];
                }
            }
        }
        
        if ([candidates count] == 0) {
            // All 9 numbers excluded, no need for further checking
            return candidates;
        }
        
        // Consider cages
        NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:(row * 9 + col)]];
        NSInteger cageSize = [self.uf sizeOfComponent:[cageID integerValue]];
        NSInteger cageSum = [[self.sums objectForKey:cageID] integerValue];
            // Get the iterator for this cage
        NSArray* cageCells = [self.uf getIteratorForComponent:[cageID integerValue]];
        for (NSNumber* cellIndex in cageCells) {
            NSNumber* cellNumber = [self getNumAtIndex:cellIndex];
            if ([cellNumber integerValue] != 0) {
                cageSize--;
                cageSum -= [cellNumber integerValue];
            }
        }
        
        NSArray* remainingCageCandidates = [self.combination allNumsOfCageSize:[NSNumber numberWithInteger:cageSize] withSum:[NSNumber numberWithInteger:cageSum]];
        [candidates intersectSet:[NSSet setWithArray:remainingCageCandidates]];
        
    }
    else {
        //NSLog(@"This cell is alreay filled, no candidates.");
    }
    return candidates;
}


/*!
 * Find indices for all the neighboring cells for the given cage,
 * which is represented by the cage id in the cagesLookup array
 */
-(NSMutableArray*)findNeighborCellsForCage:(NSNumber*)cageId {
    NSMutableArray* neighborCells = [[NSMutableArray alloc] init];
    
    // Get all the indices within the given cage
    NSArray* indices = [self.uf getIteratorForComponent:[cageId integerValue]];
    
    for (NSNumber* index in indices) {
        // Find all the indices for 4-way neighbors of idnex
        NSMutableArray* neighbors = [self findFourNeighborsForCell:[index integerValue]];
        
        for (NSNumber* neighborIndex in neighbors) {
            if ([[self getCageIdAtIndex:neighborIndex] integerValue] != [cageId integerValue]) {
                [neighborCells addObject:neighborIndex];
            }
        }
    }
    
    return neighborCells;
}



/*!
 * Test if the game is finished, only according to the normal sudoku rules now.
 */
-(Boolean)isFinished {
    // Build an array containing all the possible values 1 ~ 9
    NSMutableArray* values = [[NSMutableArray alloc] init];
    for (int i = 1; i < 10; i++) {
        [values addObject:[NSNumber numberWithInt:i]];
    }
    
    // Check each row
    for (NSMutableArray* row in self.cells) {
        for (NSNumber* number in values) {
            if([row containsObject:number] == false) {
                return false;
            }
        }
    }
    
    // Check each column
    for (int j = 0; j < 9; j++) {
        NSMutableArray* checkedValues = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            NSNumber* value = [[self.cells objectAtIndex:i] objectAtIndex:j];
            // If this vlaue is invalid, or already in the checkedValues array, then the game is not valid finished
            if ([values containsObject:value] == false || [checkedValues containsObject:value]) {
                return false;
            }
            else {
                [checkedValues addObject:value];
            }
        }
    }
    
    // Check each nonet
    for (int nonet = 0; nonet < 9; nonet++) {
        NSMutableArray* checkedValues = [[NSMutableArray alloc] init];
        // Calculate the start position for current nonet
        int i = nonet / 3 * 3;
        int j = nonet % 3 * 3;
        
        for (int delta_i = 0; delta_i < 3; delta_i++) {
            for (int delta_j = 0; delta_j < 3; delta_j++) {
                NSNumber* value = [[self.cells objectAtIndex:(i + delta_i)] objectAtIndex:(j + delta_j)];
                if ([values containsObject:value] == false || [checkedValues containsObject:value]) {
                    return false;
                }
                else {
                    [checkedValues addObject:value];
                }
            }
        }
    }
    
    return true;
}

/*!
 * Find all the 4-way neighbors' indices for the given cell
 * Indices out of range won't be selected
 */
-(NSMutableArray*)findFourNeighborsForCell:(NSInteger)cellIndex {
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


#pragma mark Description methods


/*!
 *Description of the gameBoard with cage divisions
 */
-(NSString*)cagesDescription {
    
    NSMutableString* description = [[NSMutableString alloc] init];
    [description appendString:@"\n"];
    
    
    for (int i = 0 ; i < 9; i++) {
        NSMutableString* betweenLine = [[NSMutableString alloc] init];
        for (int j = 0; j < 9; j++) {
            // We only probe the cell right to it, and below it
            if (j + 1 < 9 && ([self.uf find:(9 * i + j)] != [self.uf find:(9 * i + j + 1)])) {
                // We need to add a split to cell's right side
                [description appendFormat:@"%ld | ", (long)[[[self.cells objectAtIndex:i] objectAtIndex:j] integerValue]];
            }
            else {
                // We doesn't need a split
                [description appendFormat:@"%ld   ", (long)[[[self.cells objectAtIndex:i] objectAtIndex:j] integerValue]];
            }
            
            
            
            if (i + 1 < 9 && ([self.uf find:(9 * i + j)] != [self.uf find:(9 * (i + 1) + j)])) {
                // We need to add a split below the cell
                [betweenLine appendString:@"--  "];
            }
            else {
                [betweenLine appendString:@"    "];
            }
        }
        // Need a line breaker
        [description appendString:@"\n"];
        [betweenLine appendString:@"\n"];
        [description appendString:betweenLine];
    }
    
    
    
    return [NSString stringWithString:description];
}

/*!
 *Description of the gameBoard with only numbers
 */

- (NSString*)description {
    NSMutableString* description = [[NSMutableString alloc] init];
    [description appendString:@"\n    0 1 2   3 4 5   6 7 8\n    - - - - - - - - - - - \n"];
    for (int i = 0; i < 9; i++) {
        [description appendString:[NSString stringWithFormat:@"%d | ",i,nil]];
        for (int j = 0; j < 9; j++) {
            [description appendString:[[[self.cells objectAtIndex:i] objectAtIndex:j] stringValue]];
            [description appendString:@" "];
            if (j == 2 || j == 5) {
                [description appendString:@"| "];
            }
        }
        [description appendString:@"\n"];
        if (i == 2 || i == 5) {
            [description appendString:@"    - - - - - - - - - - -\n"];
        }
    }
    [description appendString:@"\n"];
    return [NSString stringWithString:description];
}

/*!
 * Return the description of cages lookup matrix. In each cell the number is the cage identifier
 */
- (NSString*)cagesLookupDescription {
    NSMutableString* description = [[NSMutableString alloc] init];
    [description appendString:@"\n    0  1  2    3  4  5    6  7  8 \n    - - - - - - - - - - - - - - - \n"];
    for (int i = 0; i < 9; i++) {
        [description appendString:[NSString stringWithFormat:@"%d | ",i,nil]];
        for (int j = 0; j < 9; j++) {
            [description appendFormat:@"%ld", (long)[self.uf find:(9 * i + j)]];
            [description appendString:@" "];
            if ([self.uf find:(9 * i + j)] < 10) {
                [description appendString:@" "];
            }
            if (j == 2 || j == 5) {
                [description appendString:@"| "];
            }
        }
        [description appendString:@"\n"];
        if (i == 2 || i == 5) {
            [description appendString:@"    - - - - - - - - - - - - - - -\n"];
        }
    }
    
    [description appendString:@"\n"];
    return [NSString stringWithString:description];
}

/*!
 * Return the content stored in the cage array
 */
- (NSString*)cagesArrayDescription {
    return [self.cages description];
}

@end
