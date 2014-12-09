//
//  GameBoard.h
//  KillerSudoku
//
//  Created by 李泳 on 14-10-14.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameBoard : NSObject

// Construct methods
-(id)initWithConfiguration:(NSMutableDictionary*)configuration;
-(id)initWithCells:(NSArray*)cells;
-(id)initWithIntegerArray:(int[9][9])array;
-(GameBoard*)copy;

// Setter & Getter
-(NSArray*)getIteratorForCages;

-(NSNumber*)getCageIdAtRow:(NSInteger)row Column:(NSInteger)col;
-(NSNumber*)getCageIdAtIndex:(NSNumber*)index;

-(NSNumber*)getNumAtRow:(NSInteger)row Column:(NSInteger)col;
-(NSNumber*)getNumAtIndex:(NSNumber*)index;

-(void)setNum:(NSNumber*)number AtRow:(NSInteger)row Column:(NSInteger)col;
-(void)setNum:(NSNumber *)number AtIndex:(NSNumber*)index;

// Helper methods
-(NSMutableSet*)findCandidatesAtRow:(NSInteger)row Column:(NSInteger)col;
-(NSMutableSet*)findCandidatesAtIndex:(NSNumber*)index;
-(NSArray*)findNeighborCellsForCage:(NSNumber*)cageID;
-(Boolean)isFinished;


// Description methods
-(NSString*)cagesDescription;
-(NSString*)cagesLookupDescription;
-(NSString*)cagesArrayDescription;

@end
