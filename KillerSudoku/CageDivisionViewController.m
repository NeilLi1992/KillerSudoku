//
//  CageDivisionViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 14/11/11.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "CageDivisionViewController.h"
#import "GameBoard.h"
#import "Constant.h"

@interface CageDivisionViewController ()
@property(nonatomic, strong)NSMutableArray* boardCells;
@property(nonatomic, strong)GameBoard* gb;
@property(nonatomic, strong)NSArray* candidateColors;
@end

@implementation CageDivisionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do some initialization
    self.boardCells = [[NSMutableArray alloc] init];
    self.candidateColors = [[NSArray alloc] initWithObjects:
                            [UIColor colorWithRed:255/255.0 green:217/255.0 blue:204/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:242/255.0 blue:204/255.0 alpha:1],
                            [UIColor colorWithRed:184/255.0 green:0/255.0 blue:92/255.0 alpha:1],
                            [UIColor colorWithRed:204/255.0 green:255/255.0 blue:217/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:221/255.0 blue:153/255.0 alpha:1],
                            [UIColor colorWithRed:221/255.0 green:153/255.0 blue:255/255.0 alpha:1], nil];    // Define some candidates color
    //    self.candidateColors = [[NSArray alloc] initWithObjects:
    //                            [UIColor redColor],
    //                            [UIColor greenColor],
    //                            [UIColor orangeColor],
    //                            [UIColor blueColor],
    //                            [UIColor cyanColor],
    //                            [UIColor brownColor], nil];    // Define some candidates color
    
    int GAME1[9][9] = {
        {5,3,4,6,7,8,9,1,2},
        {6,7,2,1,9,5,3,4,8},
        {1,9,8,3,4,2,5,6,7},
        {8,5,9,7,6,1,4,2,3},
        {4,2,6,8,5,3,7,9,1},
        {7,1,3,9,2,4,8,5,6},
        {9,6,1,5,3,7,2,8,4},
        {2,8,7,4,1,9,6,3,5},
        {3,4,5,2,8,6,1,7,9}
    };
    
    int GAME2[9][9] = {
        {5,3,0,0,7,0,0,0,0},
        {6,0,0,1,9,5,0,0,0},
        {0,9,8,0,0,0,0,6,0},
        {8,0,0,0,6,0,0,0,3},
        {4,0,0,8,0,3,0,0,1},
        {7,0,0,0,2,0,0,0,6},
        {0,6,0,0,0,0,2,8,0},
        {0,0,0,4,1,9,0,0,5},
        {0,0,0,0,8,0,0,7,9}
    };
    
        self.gb = [[GameBoard alloc] initWithIntegerArray:GAME1];
        [self drawBoardLines];
        [self drawBoardCells];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Initialization
- (NSArray*)buildColorMatrix {
    NSMutableArray* colorMatrix = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        [colorMatrix addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            [[colorMatrix objectAtIndex:i] addObject:[NSNumber numberWithInt:-1]];
        }
    }
    
    // Iterate all the cages
    for (NSArray* cage in [self.gb getIteratorForCages]) {
        // Build the candidate colors array, which uses numbers to represent all candidate colors
        NSMutableArray* colors = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.candidateColors count]; i++) {
            [colors addObject:[NSNumber numberWithInt:i]];
        }
        
        // Iterate all the indices of all the neighbor cells of this cage
        for (NSNumber* neighborIndex in [self.gb findNeighborCellsForCage:[self.gb getCageIdAtIndex:[cage objectAtIndex:0]]]) {
            NSInteger row = [neighborIndex integerValue] / 9;
            NSInteger col = [neighborIndex integerValue] % 9;
            // Remove all neighbor cages's color from this cage's possible color array
            if ([colors containsObject:[[colorMatrix objectAtIndex:row] objectAtIndex:col]]) {
                [colors removeObject:[[colorMatrix objectAtIndex:row] objectAtIndex:col]];
            }
        }
        
        // Pick a color randomly from the remaining candidates colors
        // Assign this color number to all the cells within this cage
        NSNumber* colorNumber = [colors objectAtIndex:(arc4random_uniform((uint)[colors count]))];
        for (NSNumber* index in cage) {
            NSInteger row = [index integerValue] / 9;
            NSInteger col = [index integerValue] % 9;
            [[colorMatrix objectAtIndex:row] replaceObjectAtIndex:col withObject:colorNumber];
        }
    }
    
    return [NSArray arrayWithArray:colorMatrix];
}


/*!
 * Draw the board lines
 */
- (void)drawBoardLines {

    
    // add horizontal lines
    for (int i = 0; i < 4; i++) {
        UIView* horiLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + i * cellLength * 3 + baseY, self.view.bounds.size.width, 2)];
        horiLineView.backgroundColor = [UIColor blackColor];
        // Set a high z position so it remains above the cells
        horiLineView.layer.zPosition = 10;
        [self.view addSubview:horiLineView];
    }
    
    // add vertical lines
    for (int i = 0; i < 3; i++) {
        UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(i * cellLength * 3, 20 + baseY, 2, self.view.bounds.size.width)];
        vertiLineView.backgroundColor = [UIColor blackColor];
        vertiLineView.layer.zPosition = 10;
        [self.view addSubview:vertiLineView];
    }
    UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(3 * cellLength * 3 - 2, 20 + baseY, 2, self.view.bounds.size.width)];
    vertiLineView.backgroundColor = [UIColor blackColor];
    vertiLineView.layer.zPosition = 10;
    [self.view addSubview:vertiLineView];
    
}


/*!
 * Draw the board cells
 */
- (void)drawBoardCells {
    [self.boardCells removeAllObjects];
    float cellLength = 320.0f / 9;
    // colorMatrix stores the color representatiion for coloring all the cells
    NSArray* colorMatrix = [self buildColorMatrix];
    
    for (int i = 0; i < 9; i++) {
        [self.boardCells addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            // Generate a cellView and set it properly
            UIView* cellView = [[UIView alloc] initWithFrame:CGRectMake(j * cellLength, 20 + i * cellLength + baseY, cellLength, cellLength)];
            cellView.layer.borderColor = [UIColor blackColor].CGColor;
            cellView.layer.borderWidth = 0.5f;
            
            // Add the number label
            UILabel* numLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 3, 30, 30)];
            numLabel.text = [[self.gb getNumAtRow:i Column:j] stringValue];
            [cellView addSubview:numLabel];
            
            // Set the cell's background according to colorMatrix
            cellView.backgroundColor = [self.candidateColors objectAtIndex:[[[colorMatrix objectAtIndex:i] objectAtIndex:j] integerValue]];
            
            // Save it in the boardCells array
            [[self.boardCells objectAtIndex:i] addObject:cellView];
            [self.view addSubview:cellView];
        }
    }
    
}

- (IBAction)generateBtnPressed:(id)sender {
    int new[9][9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            new[i][j] = arc4random_uniform(9);
        }
    }
    
    self.gb = [[GameBoard alloc] initWithIntegerArray:new];
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            [[[self.boardCells objectAtIndex:i] objectAtIndex:j] removeFromSuperview];
            
        }
    }
    
    [self drawBoardCells];
}

@end
