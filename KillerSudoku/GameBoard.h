//
//  GameBoard.h
//  KillerSudoku
//
//  Created by 李泳 on 14-10-14.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameBoard : NSObject

-(id)initWithCells:(NSArray*)cells;
-(id)initWithIntegerArray:(int[9][9])array;

-(Boolean)isFinished;
-(NSNumber*)getNumAtRow:(NSInteger)row Column:(NSInteger)col;
-(void)setNum:(NSNumber*)number AtRow:(NSInteger)row Column:(NSInteger)col;
-(NSSet*)findCandidatesAtRow:(NSInteger)row Column:(NSInteger)col;
-(GameBoard*)copy;

@end
