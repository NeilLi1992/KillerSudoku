//
//  UnionFind.h
//  KillerSudoku
//
//  Created by 李泳 on 14/10/21.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnionFind : NSObject

-(id)initWithCapacity:(NSInteger)capacity;
-(void)connect:(NSInteger)p with:(NSInteger)q;
-(NSInteger)find:(NSInteger)p;

-(BOOL)isConnected:(NSInteger)p with:(NSInteger)q;
-(NSInteger)getRandomComponentUnderSize:(NSInteger)sizeLimit;
-(NSInteger)sizeOfComponent:(NSInteger)p;
-(NSArray*)getIteratorForComponent:(NSInteger)p;
-(NSInteger)count;

@end
