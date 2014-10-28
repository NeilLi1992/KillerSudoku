//
//  UnionFind.m
//  KillerSudoku
//
//  Created by 李泳 on 14/10/21.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "UnionFind.h"

@interface UnionFind ()

@property(nonatomic, strong)NSMutableArray* components;
@property(nonatomic, strong)NSMutableArray* componentSizes;
@property(nonatomic, strong)NSNumber* componentNumber;
@end

@implementation UnionFind

/*!
 *Initialize with number of elements as capacity
 *Every element starts as a single component
 */
-(id)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    // Initialize the components array, each component has one identifier now.
    // Initialize the componentSizes array, each component has size 1 now.
    self.components = [[NSMutableArray alloc] init];
    self.componentSizes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < capacity; i++) {
        [self.components addObject:[NSNumber numberWithInt:i]];
        [self.componentSizes addObject:[NSNumber numberWithInt:1]];
    }
    
    self.componentNumber = [NSNumber numberWithInteger:capacity];
    return self;
}

/*!
 *Quick union
 */
-(void)connect:(NSInteger)p with:(NSInteger)q {
    NSInteger pRoot = [self find:p];
    NSInteger qRoot = [self find:q];
    
    if (pRoot == qRoot) {
        return;
    }
    
    // The unioned component will have the identifier of component q
    [self.components replaceObjectAtIndex:p withObject:[NSNumber numberWithInt:[[self.components objectAtIndex:q] intValue]]];

    // Adjust number of components and size of each component
    self.componentNumber = [NSNumber numberWithInteger:([self.componentNumber intValue] - 1)];
    
    // ComponentSizes array only stores sizes in the root position of each component. Size of other positions within the componetn will be cleared to avoid misuse
    [self.componentSizes replaceObjectAtIndex:q withObject:[NSNumber numberWithInt:([[self.componentSizes objectAtIndex:p] intValue] + [[self.componentSizes objectAtIndex:q] intValue])]];
    [self.componentSizes replaceObjectAtIndex:p withObject:[NSNumber numberWithInt:0]];
}

/*!
 *Find the identifier of the component including p
 */
-(NSInteger)find:(NSInteger)p {
    while (p != [[self.components objectAtIndex:p] integerValue]) {
        p = [[self.components objectAtIndex:p] integerValue];
    }
    
    return p;
}

/*!
 *Test if p and q are connected
 */
-(BOOL)isConnected:(NSInteger)p with:(NSInteger)q {
    return [self find:p] == [self find:q];
}

/*!
 *Get the size of component
 *@Returns The size of component
 */
-(NSInteger)sizeOfComponent:(NSInteger)componentIdentifier {
    return [[self.componentSizes objectAtIndex:componentIdentifier] integerValue];
}


/*!
 *Return the identifier of a randomly chosen component, whose size is smaller than the sizeLimit
 *@Returns Identifier of a satisfied component based on random selection
 */
-(NSInteger)getRandomComponentUnderSize:(NSInteger)sizeLimit {
    NSMutableArray* candidates = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.componentSizes count]; i++) {
        NSInteger size = [[self.componentSizes objectAtIndex:i] integerValue];
        if (size != 0 && size < sizeLimit) {
            // Add the identifier into candidates
            [candidates addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    NSInteger randomComponent = arc4random_uniform((uint)[candidates count]);
    
    return randomComponent;
}

/*!
 *Build an array as the iterator which includes all the indices contained in the given component
 *@param p The component identifier whose indices will be found out to construct the interator
 *@Returns An array which can be iterated to yield all the indices contained in the given component
 */
-(NSArray*)getIteratorForComponent:(NSInteger)p {
    NSMutableArray* iterator = [[NSMutableArray alloc] init];
    
    NSInteger  pRoot = [self find:p];
    
    for (int i = 0; i < [self.components count]; i++) {
        if ([[self.components objectAtIndex:i] integerValue] == pRoot) {
            [iterator addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return [NSArray arrayWithArray:iterator];
}

/*!
 *Return the number of components in the UF object
 *@Returns Number of components in the UF object
 */
-(NSInteger)count {
    return [self.componentNumber integerValue];
}

- (NSString*)description {
    return [self.components description];
}

@end
