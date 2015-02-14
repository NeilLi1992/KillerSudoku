//
//  NewGameViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/2/10.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "NewGameViewController.h"

@interface NewGameViewController ()
@property(strong, nonatomic)NSArray* candidateColors;
@property(strong, nonatomic)UIView* boardView;
@property(strong, nonatomic)UIView* hintView;
@property(strong, nonatomic)UIView* controlView;
@property(strong, nonatomic)NSMutableArray* boardCells;
@property(strong, nonatomic)GameBoard* unsolvedGame;
@property(strong, nonatomic)UIButton* selectedCell;
@property(strong, nonatomic)Combination* combination;
@property(strong, nonatomic)NSNumber* selectedCageID;
@end

@implementation NewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    NSInteger level = 1;
    self.candidateColors = [[NSArray alloc] initWithObjects:
                            [UIColor colorWithRed:255/255.0 green:217/255.0 blue:204/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:242/255.0 blue:204/255.0 alpha:1],
                            [UIColor colorWithRed:184/255.0 green:0/255.0 blue:92/255.0 alpha:1],
                            [UIColor colorWithRed:204/255.0 green:255/255.0 blue:217/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:221/255.0 blue:153/255.0 alpha:1],
                            [UIColor colorWithRed:221/255.0 green:153/255.0 blue:255/255.0 alpha:1],
                            [UIColor whiteColor],
                            [UIColor redColor],
                            [UIColor purpleColor],nil];
    self.boardCells = [[NSMutableArray alloc] init];
    self.selectedCell = nil;
    self.selectedCageID = nil;
    
    // Call generator to generate a game
    self.unsolvedGame = [Generator generate:level];
    self.combination = [self.unsolvedGame getCombination];
    
    
    NSLog(@"NewGameViewController: get generated game\n%@", [self.unsolvedGame cagesDescription]);
    NSLog(@"NewGameViewController: print its sums\n%@", [self.unsolvedGame getSum]);
    
    // Draw allsubviews
    [self drawBoard];
    [self drawHint];
}

#pragma -mark drawing methods
- (void)drawBoard {
    CGFloat boardLength = [UIScreen mainScreen].bounds.size.width; // Length equals the screen width
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat baseY = statusBarHeight + navigationBarHeight;
    CGFloat cellLength = boardLength / 9;

    // draw horizontal board lines
    for (int i = 0; i < 4; i++) {
        UIView* horiLineView = [[UIView alloc] initWithFrame:CGRectMake(0, i * cellLength * 3 + baseY, boardLength, 2)];
        horiLineView.backgroundColor = [UIColor blackColor];
        // Set a high z position so it remains above the cells
        horiLineView.layer.zPosition = 10;
        [self.view addSubview:horiLineView];
    }
    
    // draw vertical board lines
    for (int i = 0; i < 3; i++) {
        UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(i * cellLength * 3, baseY, 2, self.view.bounds.size.width)];
        vertiLineView.backgroundColor = [UIColor blackColor];
        vertiLineView.layer.zPosition = 10;
        [self.view addSubview:vertiLineView];
    }
    UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(3 * cellLength * 3 - 2, baseY, 2, self.view.bounds.size.width)];
    vertiLineView.backgroundColor = [UIColor blackColor];
    vertiLineView.layer.zPosition = 10;
    [self.view addSubview:vertiLineView];
    
    // color board cells
    NSArray* colorMatrix = [self buildColorMatrix]; // Get color representation for all cells
    for (int i = 0; i < 9; i++) {
        [self.boardCells addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            // Generate a cellBtn and set it properly
            UIButton* cellBtn = [[UIButton alloc] initWithFrame:CGRectMake(j * cellLength, i * cellLength + baseY, cellLength, cellLength)];
            cellBtn.tag = i * 9 + j;
            cellBtn.layer.borderColor = [UIColor blackColor].CGColor;
            cellBtn.layer.borderWidth = 0.5f;
            
            // Set the cell's background according to colorMatrix
            cellBtn.backgroundColor = [self.candidateColors objectAtIndex:[[[colorMatrix objectAtIndex:i] objectAtIndex:j] integerValue]];
            
            // Save it in the boardCells array
            [[self.boardCells objectAtIndex:i] addObject:cellBtn];
            [self.view addSubview:cellBtn];
            [cellBtn addTarget:self action:@selector(cellTouched:) forControlEvents:UIControlEventTouchDown ];
        }
    }
    
    // add sum number to each cage
//    NSMutableDictionary* sums = [self.unsolvedGame getSum];
//    NSLog(@"%@", sums);
//    
//    NSLog(@"%@", [self.unsolvedGame cagesDescription]);
//    
//    NSArray* solutions = [Solver solve:self.unsolvedGame];
//    NSLog(@"%@", [solutions objectAtIndex:0]);
    
    for (NSArray* indecies in [self.unsolvedGame getIteratorForCages]) {
        NSNumber* firstIndex = [indecies objectAtIndex:0];
        NSNumber* cageId = [self.unsolvedGame getCageIdAtIndex:firstIndex];
        NSInteger row = [firstIndex integerValue] / 9;
        NSInteger col = [firstIndex integerValue] % 9;
        NSNumber* sum = [self.unsolvedGame getCageSumAtIndex:cageId];
        
        UIButton* cellBtn = [[self.boardCells objectAtIndex:row] objectAtIndex:col];
        UILabel* sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, -2, 20, 20)];
        [sumLabel setFont:[UIFont systemFontOfSize:8]];
        sumLabel.text = [sum stringValue];
        [cellBtn addSubview:sumLabel];
    }
    
}

- (void)drawHint {
    CGFloat boardLength = [UIScreen mainScreen].bounds.size.width; // Length equals the screen width
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat baseY = statusBarHeight + navigationBarHeight;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - boardLength - baseY;
    
    UITextView* hintView = [[UITextView alloc] initWithFrame:CGRectMake(0, baseY + boardLength, boardLength / 2, height)];
    hintView.editable = false;
    hintView.layer.borderWidth = 2.0f;
    hintView.layer.borderColor = [UIColor blackColor].CGColor;
    hintView.tag = 100;
    
    [self.view addSubview:hintView];
}

#pragma -mark helper methods
- (NSArray*)buildColorMatrix {
    NSMutableArray* colorMatrix = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        [colorMatrix addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            [[colorMatrix objectAtIndex:i] addObject:[NSNumber numberWithInt:-1]];
        }
    }
    
    // Iterate all the cages
    for (NSArray* cage in [self.unsolvedGame getIteratorForCages]) {
        // Build the candidate colors array, which uses numbers to represent all candidate colors
        NSMutableArray* colors = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.candidateColors count]; i++) {
            [colors addObject:[NSNumber numberWithInt:i]];
        }
        
        // Iterate all the indices of all the neighbor cells of this cage
        for (NSNumber* neighborIndex in [self.unsolvedGame findNeighborCellsForCage:[self.unsolvedGame getCageIdAtIndex:[cage objectAtIndex:0]]]) {
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

#pragma -mark action handlers

- (void)cellTouched:(UIButton *)sender {
    if (self.selectedCell != nil) {
        [[self.selectedCell viewWithTag:101] removeFromSuperview];
    }
    self.selectedCell = sender;
    
    NSLog(@"get action");
    UIView* insideBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height)];
    insideBorderView.backgroundColor = [UIColor clearColor];
    insideBorderView.layer.borderWidth = 2.0f;
    insideBorderView.layer.borderColor = [UIColor blueColor].CGColor;
    insideBorderView.tag = 101;
    insideBorderView.clipsToBounds = YES;
    insideBorderView.layer.zPosition = 100;
    [sender addSubview:insideBorderView];
    
    // Modify the textView if necessary
    UITextView* hintView = (UITextView*)[self.view viewWithTag:100];
    NSNumber* cageID = [NSNumber numberWithInteger:sender.tag];
    
    if (self.selectedCageID != cageID) {
        self.selectedCageID = cageID;
        
    }
}



@end
