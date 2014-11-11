//
//  UnionFind.m
//  KillerSudoku
//
//  Created by 李泳 on 14/10/21.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//
//  An UF object can solely determine the state of a gameboard's cage division
//
//  The componnet in uf means exactly the same thing as cage in board
//  The components array's indices represent the indices in the board
//  The content number stored in the array's index position, is the parent node to go
//  If the content number equals the index of the position, this is the root of the tree, also considered as the identifer of the component,
//      which is also the cage ID.

#import "UnionFind.h"

@interface UnionFind ()

@property(nonatomic, strong)NSMutableArray* components;
@property(nonatomic, strong)NSMutableArray* componentSizes;
@property(nonatomic, strong)NSNumber* componentNumber;  //Number of components
@end

@implementation UnionFind

#pragma mark Construct methods
/*!
 *Initialize with number of elements as capacity
 *Every element starts as a single component
 */
-(id)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    // Initialize the components array, each component has one index now.
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

#pragma mark Basic UF operations
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
    [self.components replaceObjectAtIndex:pRoot withObject:[[self.components objectAtIndex:qRoot] copy]];
    // Adjust number of components and size of each component
    self.componentNumber = [NSNumber numberWithInteger:([self.componentNumber integerValue] - 1)];
    
    // ComponentSizes array only stores sizes in the root position of each component. Size of other positions within the component will be set to 0 to avoid misuse
    [self.componentSizes replaceObjectAtIndex:qRoot withObject:[NSNumber numberWithInt:([[self.componentSizes objectAtIndex:pRoot] integerValue] + [[self.componentSizes objectAtIndex:qRoot] integerValue])]];
    [self.componentSizes replaceObjectAtIndex:pRoot withObject:[NSNumber numberWithInt:0]];
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
 *Return the number of components in the UF object
 *@Returns Number of components in the UF object
 */
-(NSInteger)count {
    return [self.componentNumber integerValue];
}

#pragma mark Enhanced methods
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
            // Add the root identifier of the satisfied component
            [candidates addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    // Generate a random number to choose a satisfied componetn randomly
    NSInteger randomIndex = arc4random_uniform((uint)[candidates count]);
    
    return [[candidates objectAtIndex:randomIndex] integerValue];
}

/*!
 *Build an array as the iterator which includes all the indices contained in the given component with component identifier
 *@param p The component identifier whose indices will be found out to construct the interator
 *@Returns An array which can be iterated to yield all the indices contained in the given component
 */
-(NSMutableArray*)getIteratorForComponent:(NSInteger)componentIdentifier {
    NSMutableArray* iterator = [[NSMutableArray alloc] init];
    
    // Traverse every index, if it's component identifier equals to the given one, it's in this component
    for (int i = 0; i < [self.components count]; i++) {
        if ([self find:i] == componentIdentifier) {
            [iterator addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return iterator;
}



#pragma mark Description method
- (NSString*)description {
    NSMutableString* str = [[NSMutableString alloc] init];
    [str appendString:@"Index FaIndex\n"];
    
    for (int i = 0; i < [self.components count]; i++) {
        [str appendFormat:@"%d  %ld\n", i, (long)[[self.components objectAtIndex:i] integerValue]];
    }
    
    return [NSString stringWithString:str];
}

@end
