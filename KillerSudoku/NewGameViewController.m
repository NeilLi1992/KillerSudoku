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
@property(strong, nonatomic)NSArray* solutionGrid;
@property(strong, nonatomic)cellButton* selectedCell;
@property(strong, nonatomic)Combination* combination;
@property(strong, nonatomic)NSNumber* selectedCage;
@property(nonatomic)NSInteger finishedCount;
@end

@implementation NewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    NSInteger level = 0;
//    self.candidateColors = [[NSArray alloc] initWithObjects:
//                            [UIColor colorWithRed:255/255.0 green:217/255.0 blue:204/255.0 alpha:1],
//                            [UIColor colorWithRed:255/255.0 green:242/255.0 blue:204/255.0 alpha:1],
//                            [UIColor colorWithRed:184/255.0 green:0/255.0 blue:92/255.0 alpha:1],
//                            [UIColor colorWithRed:204/255.0 green:255/255.0 blue:217/255.0 alpha:1],
//                            [UIColor colorWithRed:255/255.0 green:221/255.0 blue:153/255.0 alpha:1],
//                            [UIColor colorWithRed:221/255.0 green:153/255.0 blue:255/255.0 alpha:1],
//                            [UIColor redColor],
//                            [UIColor purpleColor],nil];
    self.candidateColors = [[NSArray alloc] initWithObjects:
                            [UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1],  // Light coral
//                            [UIColor colorWithRed:238/255.0 green:232/255.0 blue:179/255.0 alpha:1],  // Khaki
                            [UIColor colorWithRed:205/255.0 green:133/255.0 blue:63/255.0 alpha:1],  // Peru
                            [UIColor colorWithRed:154/255.0 green:205/255.0 blue:50/255.0 alpha:1],   // Green yellow
//                            [UIColor colorWithRed:0/255.0 green:255/255.0 blue:127/255.0 alpha:1],    // spring gree
                            [UIColor colorWithRed:72/255.0 green:209/255.0 blue:204/255.0 alpha:1], // Medium turquoise
                            [UIColor colorWithRed:230/255.0 green:230/255.0 blue:250/255.0 alpha:1],  // Lavender
//                            [UIColor colorWithRed:175/255.0 green:238/255.0 blue:238/255.0 alpha:1],  // pale turquoise
                            [UIColor colorWithRed:147/255.0 green:112/255.0 blue:219/255.0 alpha:1],  // Medium purple
                            [UIColor colorWithRed:245/255.0 green:222/255.0 blue:179/255.0 alpha:1] ,nil];  // Wheat

    
    self.boardCells = [[NSMutableArray alloc] init];
    self.selectedCell = nil;
    self.selectedCage = nil;
    self.finishedCount = 0;
    
    // Call generator to generate a game
    NSArray* generationResult = [Generator generate:level];
    self.unsolvedGame = [generationResult objectAtIndex:0];
    self.solutionGrid = [generationResult objectAtIndex:1];
    
//    int GAME2[9][9] = {
//        {5,3,0,0,7,0,0,0,0},
//        {6,0,0,1,9,5,0,0,0},
//        {0,9,8,0,0,0,0,6,0},
//        {8,0,0,0,6,0,0,0,3},
//        {4,0,0,8,0,3,0,0,1},
//        {7,0,0,0,2,0,0,0,6},
//        {0,6,0,0,0,0,2,8,0},
//        {0,0,0,4,1,9,0,0,5},
//        {0,0,0,0,8,0,0,7,9}
//    };
//
//    self.unsolvedGame = [[GameBoard alloc] initWithIntegerArray:GAME2];
    
    NSLog(@"NewGameViewController: get generated game\n%@", [self.unsolvedGame cagesDescription]);
//    NSLog(@"NewGameViewController: print its sums\n%@", [self.unsolvedGame getSum]);
    NSLog(@"NewGameViewController: solution grid\n%@", self.solutionGrid);
    
    // Draw allsubviews
    [self drawBoard];
    [self drawHint];
    [self drawControl];
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
            cellButton* cellBtn = [[cellButton alloc] initWithFrame:CGRectMake(j * cellLength, i * cellLength + baseY, cellLength, cellLength)];
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
    
    UITextView* hintView = [[UITextView alloc] initWithFrame:CGRectMake(0, baseY + boardLength, boardLength * 0.4, height)];
    hintView.editable = false;
    hintView.layer.borderWidth = 2.0f;
    hintView.layer.borderColor = [UIColor blackColor].CGColor;
    hintView.tag = 100;
    hintView.scrollEnabled = YES;
    [self.view addSubview:hintView];
}

- (void)drawControl {
    CGFloat boardLength = [UIScreen mainScreen].bounds.size.width; // Length equals the screen width
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat baseY = statusBarHeight + navigationBarHeight;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - boardLength - baseY;
    
    UIView* controlView = [[UIView alloc] initWithFrame:CGRectMake(boardLength * 0.4 - 1, baseY + boardLength, boardLength * 0.6 + 1, height)];
    controlView.layer.borderWidth = 2.0f;
    controlView.layer.borderColor = [UIColor blackColor].CGColor;
    
    CGFloat btnWidth = controlView.frame.size.width / 3;
    CGFloat btnHeight = controlView.frame.size.height / 4;
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            if (i != 3) {
                // Number button
                UIButton* controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(j * btnWidth, i * btnHeight, btnWidth, btnHeight)];
                controlBtn.layer.borderWidth = 1.0f;    // Set bordre width
                controlBtn.layer.borderColor = [UIColor blackColor].CGColor;    // Set border color
                [controlBtn setTitle:[[NSNumber numberWithInt:(i*3+j+1)] stringValue] forState:UIControlStateNormal];   // Set button title
                [controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];  // Set title color
                [controlBtn setTitleColor:[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0] forState:UIControlStateHighlighted];
                controlBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
                [controlBtn addTarget:self action:@selector(ctlBtnTouched:) forControlEvents:UIControlEventTouchDown ]; // Set button action
                [controlView addSubview:controlBtn];
            } else if (j == 0) {
                // Check button
                UIButton* controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(j * btnWidth, i * btnHeight, btnWidth, btnHeight)];
                controlBtn.layer.borderWidth = 1.0f;
                controlBtn.layer.borderColor = [UIColor blackColor].CGColor;
                [controlBtn setTitle:@"Check" forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0] forState:UIControlStateHighlighted];
                controlBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
                [controlBtn addTarget:self action:@selector(checkWithSolution:) forControlEvents:UIControlEventTouchDown ];
                [controlView addSubview:controlBtn];
            } else if (j == 1) {
                // Clear button
                UIButton* controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(j * btnWidth, i * btnHeight, btnWidth, btnHeight)];
                controlBtn.layer.borderWidth = 1.0f;
                controlBtn.layer.borderColor = [UIColor blackColor].CGColor;
                [controlBtn setTitle:@"-" forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0] forState:UIControlStateHighlighted];
                controlBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
                [controlBtn addTarget:self action:@selector(ctlBtnTouched:) forControlEvents:UIControlEventTouchDown ];
                [controlView addSubview:controlBtn];
            } else if (j == 2) {
                // Note button
                UIButton* controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(j * btnWidth, i * btnHeight, btnWidth, btnHeight)];
                controlBtn.layer.borderWidth = 1.0f;
                controlBtn.layer.borderColor = [UIColor blackColor].CGColor;
                [controlBtn setTitle:@"Note" forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [controlBtn setTitleColor:[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0] forState:UIControlStateHighlighted];
                controlBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
                //                [controlBtn addTarget:self action:@selector(ctlBtnTouched:) forControlEvents:UIControlEventTouchDown ];
                [controlView addSubview:controlBtn];
            }
        }
    }
    
    [self.view addSubview:controlView];
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


- (void)checkWithSolution:(UIButton*)sender {
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            cellButton* cell = [[self.boardCells objectAtIndex:i] objectAtIndex:j];
            NSString* cellLabel = cell.titleLabel.text;
            NSNumber* correctNum = [[self.solutionGrid objectAtIndex:i] objectAtIndex:j];
            if (![cellLabel isEqualToString:@""] && ![cellLabel isEqualToString:[correctNum stringValue]]) {
                // This cell is wrong
                [cell setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
            
        }
    }
}

- (void)checkDuplicate:(cellButton*)cell From:(NSString*)ori To:(NSString*)now{
    NSInteger index = (NSInteger)cell.tag;
    NSInteger row = index / 9;
    NSInteger col = index % 9;
    
    NSMutableSet* cellsToCheck = [[NSMutableSet alloc] init];

    // Check for row
    NSMutableArray* checkingRow = [self.boardCells objectAtIndex:row];
    for (cellButton* cell in checkingRow) {
        if (cell.tag != index) {
            [cellsToCheck addObject:cell];
        }
    }
    
    // Check for column
    for (int i = 0; i < 9; i++) {
        cellButton* cell = [[self.boardCells objectAtIndex:i] objectAtIndex:col];
        if (cell.tag != index) {
            [cellsToCheck addObject:cell];
        }
    }

    // Check for nonet
    NSInteger nonet = row / 3 * 3 + col / 3;
    NSInteger i = nonet / 3 * 3;
    NSInteger j = nonet % 3 * 3;
    for (int delta_i = 0; delta_i < 3; delta_i++) {
        for (int delta_j = 0; delta_j < 3; delta_j++) {
            cellButton* cell = [[self.boardCells objectAtIndex:(i + delta_i)] objectAtIndex:(j + delta_j)];
            if (cell.tag != index) {
                [cellsToCheck addObject:cell];
            }
        }
    }
    
    // Check for cage
    for (NSNumber* cellIndex in [self.unsolvedGame getIteratorForCageID:[self.unsolvedGame getCageIdAtIndex:[NSNumber numberWithInteger:index]]]) {
        if ([cellIndex integerValue] != index) {
            NSInteger i = [cellIndex integerValue] / 9;
            NSInteger j = [cellIndex integerValue] % 9;
            [cellsToCheck addObject:[[self.boardCells objectAtIndex:i] objectAtIndex:j]];
        }
    }
    
    for (cellButton* checkingCell in cellsToCheck) {
        if (![checkingCell.titleLabel.text isEqualToString:@" "] && [checkingCell.titleLabel.text isEqualToString:now]) {
            [checkingCell incDupCount];
            [cell incDupCount];
        }
        
        if (![checkingCell.titleLabel.text isEqualToString:@" "] && [checkingCell.titleLabel.text isEqualToString:ori]) {
            [checkingCell decDupCount];
            [cell decDupCount];
        }
    }
}

- (void)gameFinish {
    [self performSegueWithIdentifier:@"finish" sender:self];
}

#pragma -mark action handlers

- (void)cellTouched:(cellButton *)sender {
    if (self.selectedCell != nil) {
        [[self.selectedCell viewWithTag:101] removeFromSuperview];
    }
    self.selectedCell = sender;
    
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
    NSNumber* index = [NSNumber numberWithInteger:sender.tag];
    NSNumber* cageID = [self.unsolvedGame getCageIdAtIndex:index];
    
    
    if (self.selectedCage != cageID) {
        self.selectedCage = cageID;
        
        NSMutableArray* comStrList = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@ =", [self.unsolvedGame getCageSumAtIndex:cageID]], nil];
        
        for (NSArray* comb in [self.unsolvedGame getCombsForCage:cageID]) {
            NSString* combString = [comb componentsJoinedByString:@"+"];
            [comStrList addObject:combString];
        }
        NSString* hintString = [comStrList componentsJoinedByString:@"\n"];

        hintView.text = hintString;
    }
}

- (void)ctlBtnTouched:(UIButton*)sender {
    NSString* btnLabel = sender.titleLabel.text;
    if (self.selectedCell != nil) {
        NSInteger row = self.selectedCell.tag / 9;
        NSInteger col = self.selectedCell.tag % 9;
        NSNumber* correctNum = [[self.solutionGrid objectAtIndex:row] objectAtIndex:col];
        if ([btnLabel isEqualToString:@"-"]) {
            if ([self.selectedCell.titleLabel.text isEqualToString:[correctNum stringValue]]) {
                self.finishedCount--;
            }
            [self checkDuplicate:self.selectedCell From:self.selectedCell.titleLabel.text To:@" "];
            [self.selectedCell clear];
        } else if (![self.selectedCell.titleLabel.text isEqualToString:btnLabel]) {
            if (![self.selectedCell.titleLabel.text isEqualToString:[correctNum stringValue]] && [btnLabel isEqualToString:[correctNum stringValue]]) {
                self.finishedCount++;
            }
            
            if ([self.selectedCell.titleLabel.text isEqualToString:[correctNum stringValue]] && ![btnLabel isEqualToString:[correctNum stringValue]]) {
                self.finishedCount--;
            }
            
            [self checkDuplicate:self.selectedCell From:self.selectedCell.titleLabel.text To:btnLabel];
            [self.selectedCell setNum:[NSNumber numberWithInteger:[btnLabel integerValue]]];
            if (self.finishedCount == 81) {
                [self gameFinish];
            }
        }
        
    }
}

@end
