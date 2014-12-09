//
//  Combination.h
//  KillerSudoku
//
//  Created by 李泳 on 14/11/18.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Combination : NSObject

- (NSArray*)allComsOfCageSize:(NSNumber*)size withSum:(NSNumber*)sum;
- (NSArray*)allNumsOfCageSize:(NSNumber*)size withSum:(NSNumber*)sum;
- (NSDictionary*)probabilityDistributionOfCageSize:(NSNumber*)size withSum:(NSNumber*)sum;

@end
