//
//  SolverViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/8.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "SolverViewController.h"
#import "UIColor+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "BoardView.h"
#import "UnionFind.h"
#import "PlayCellButton.h"
#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "GameBoard.h"
#import "Solver.h"
#import "SoundPlayer.h"

@interface SolverViewController () <FUIAlertViewDelegate>
// Model related properties
@property(strong, nonatomic)NSMutableArray* boardCells;
@property(strong, nonatomic)NSMutableArray* selectedCells;
@property(strong, nonatomic)NSMutableDictionary* sums;
@property(strong, nonatomic)UnionFind* uf;
@property(strong, nonatomic)NSArray* solutions;
@property(nonatomic)NSInteger solutionIndex;
@property(strong, nonatomic)NSThread* solvingThread;
@property(nonatomic)BOOL isSolved;
@property(strong, nonatomic)SoundPlayer* soundPlayer;

// View related properties
@property(strong, nonatomic)FUIAlertView* waitView;
@property(strong, nonatomic)BoardView* boardView;
@property(strong, nonatomic)UIColor* selectColor;
@property(strong, nonatomic)UILabel* promptLabel;
@end

@implementation SolverViewController

// Define some UI related parameters
CGFloat boardLength;
CGFloat cellLength;
CGFloat horiPadding;
CGFloat vertPadding;
CGFloat baseY;
CGFloat outerLineWidth;
CGFloat innerLineWidth;
CGFloat itemHeight;
CGFloat itemWidth;
CGFloat itemSep;
CGFloat itemLineSep;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    horiPadding = 6;
    vertPadding = 6;
    boardLength = [UIScreen mainScreen].bounds.size.width - 2 * horiPadding;
    cellLength = boardLength / 9.0f;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    baseY = statusBarHeight + navigationBarHeight;
    outerLineWidth = 2.0;
    innerLineWidth = 1.0;
    itemHeight = cellLength;
    itemWidth = 2 * cellLength;
    itemSep = (boardLength - 3 * itemWidth) / 2.0f;
    itemLineSep = ([UIScreen mainScreen].bounds.size.height - baseY - boardLength - vertPadding - 4 * itemHeight) / 5.0;
    self.boardCells = [[NSMutableArray alloc] init];
    self.selectColor = [UIColor peterRiverColor];
    self.selectedCells = [[NSMutableArray alloc] init];
    self.sums = [[NSMutableDictionary alloc] init];
    self.uf = [[UnionFind alloc] initWithCapacity:81];
    self.isSolved = false;
    self.soundPlayer = [[SoundPlayer alloc] init];
    
    // Do any additional setup after loading the view.
    [self stylize];
    [self drawBoard];
    [self addCellBtns];
    [self drawControlParts];
}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed)];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
}

# pragma mark - Drawing methods
- (void)drawBoard {
    // Draw board view
    self.boardView = [[BoardView alloc] initWithFrame:CGRectMake(horiPadding, vertPadding+baseY, boardLength, boardLength)];
    [self.boardView setInnerLineWidth:innerLineWidth];
    self.boardView.backgroundColor = [UIColor cloudsColor];
    self.boardView.layer.borderColor = [UIColor midnightBlueColor].CGColor;
    self.boardView.layer.borderWidth = outerLineWidth;
    self.boardView.layer.cornerRadius = 6;
    self.boardView.layer.masksToBounds = YES;
    //    boardView.layer.shadowOffset = CGSizeMake(2, 5);
    //    boardView.layer.shadowRadius = 2;
    //    boardView.layer.shadowOpacity = 1;
    //    boardView.layer.shadowColor = [UIColor midnightBlueColor].CGColor;
    [self.view addSubview:self.boardView];
}

- (void)addCellBtns {
    for (int i = 0; i < 9; i++) {
        [self.boardCells addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            CGFloat btnX = j * cellLength + innerLineWidth / 2;
            CGFloat btnY = i * cellLength + innerLineWidth / 2;
            CGFloat btnWidth = cellLength - innerLineWidth;
            CGFloat btnHeight = cellLength - innerLineWidth;
            
            // Adjust x, y, width, height to avoid covering thick lines
            switch (j) {
                case 0:
                    btnWidth -= 1.5 * innerLineWidth;
                    btnX += 1.5 * innerLineWidth;
                    break;
                case 2: // Thick line right to cell
                case 5:
                    btnWidth -= innerLineWidth / 2;
                    break;
                case 3: // Thick line left to cell
                case 6:
                    btnWidth -= innerLineWidth / 2;
                    btnX += innerLineWidth / 2;
                    break;
                case 8:
                    btnWidth -= 1.5 * innerLineWidth;
                    break;
                default:
                    break;
            }
            
            switch (i) {
                case 0:
                    btnHeight -= 1.5 * innerLineWidth;
                    btnY += 1.5 * innerLineWidth;
                    break;
                case 2: // Thick line below cell
                case 5:
                    btnHeight -= innerLineWidth / 2;
                    break;
                case 3: // Thick line above cell
                case 6:
                    btnHeight -= innerLineWidth / 2;
                    btnY += innerLineWidth / 2;
                    break;
                case 8:
                    btnHeight -= 1.5 * innerLineWidth;
                default:
                    break;
            }
            
            PlayCellButton* btn = [[PlayCellButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
            btn.tag = i * 9 + j;
            [btn addTarget:self action:@selector(cellBtnPressed:) forControlEvents:UIControlEventTouchDown];
            
            // Save the button in boardCells array
            [[self.boardCells objectAtIndex:i] addObject:btn];
            [self.boardView addSubview:btn];
        }
    }
}

- (void)drawControlParts {
    CGFloat ctlViewX = horiPadding;
    CGFloat ctlViewY = baseY + boardLength + 3 * vertPadding;
    CGFloat ctlViewWidth = boardLength;
    CGFloat ctlViewHeight = [UIScreen mainScreen].bounds.size.height - baseY - boardLength - 3 * vertPadding;
    UIView* controlView = [[UIView alloc] initWithFrame:CGRectMake(ctlViewX, ctlViewY, ctlViewWidth, ctlViewHeight)];
    
    // Add prompt label
    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, boardLength, itemHeight)];
    self.promptLabel.layer.borderColor = [UIColor midnightBlueColor].CGColor;
    self.promptLabel.layer.borderWidth = outerLineWidth;
    self.promptLabel.layer.cornerRadius = 6.0f;
    self.promptLabel.layer.masksToBounds = YES;
    self.promptLabel.backgroundColor = [UIColor amethystColor];
    self.promptLabel.font = [UIFont boldFlatFontOfSize:14];
    [self.promptLabel setTextColor:[UIColor cloudsColor]];
    [controlView addSubview:self.promptLabel];
    
    // Add cage realted control parts
    FUIButton* cageTextBtn = [[FUIButton alloc] initWithFrame:CGRectMake(0, itemHeight + itemLineSep, itemWidth, itemHeight)];
    cageTextBtn.buttonColor = [UIColor peterRiverColor];
    cageTextBtn.cornerRadius = 6.0f;
    cageTextBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [cageTextBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [cageTextBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [cageTextBtn setTitle:@"Cage" forState:UIControlStateNormal];
    cageTextBtn.enabled = NO;
    [controlView addSubview:cageTextBtn];
    
    FUIButton* joinBtn = [[FUIButton alloc] initWithFrame:CGRectMake(itemWidth + itemSep, itemHeight + itemLineSep, itemWidth, itemHeight)];
    joinBtn.buttonColor = [UIColor turquoiseColor];
    joinBtn.shadowColor = [UIColor greenSeaColor];
    joinBtn.shadowHeight = 3.0f;
    joinBtn.cornerRadius = 6.0f;
    joinBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [joinBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [joinBtn setTitle:@"Join" forState:UIControlStateNormal];
    [joinBtn addTarget:self action:@selector(joinBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:joinBtn];
    
    FUIButton* deleteBtn = [[FUIButton alloc] initWithFrame:CGRectMake((itemWidth + itemSep) * 2, itemHeight + itemLineSep, itemWidth, itemHeight)];
    deleteBtn.buttonColor = [UIColor turquoiseColor];
    deleteBtn.shadowColor = [UIColor greenSeaColor];
    deleteBtn.shadowHeight = 3.0f;
    deleteBtn.cornerRadius = 6.0f;
    deleteBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [deleteBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:deleteBtn];
    
    // Add sum related control parts
    FUIButton* sumTextBtn = [[FUIButton alloc] initWithFrame:CGRectMake(0, (itemHeight + itemLineSep) * 2, itemWidth, itemHeight)];
    sumTextBtn.buttonColor = [UIColor peterRiverColor];
    sumTextBtn.cornerRadius = 6.0f;
    sumTextBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [sumTextBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [sumTextBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [sumTextBtn setTitle:@"Sum" forState:UIControlStateNormal];
    sumTextBtn.enabled = NO;
    [controlView addSubview:sumTextBtn];
    
    FUIButton* setBtn = [[FUIButton alloc] initWithFrame:CGRectMake(itemWidth + itemSep, (itemHeight + itemLineSep) * 2, itemWidth, itemHeight)];
    setBtn.buttonColor = [UIColor turquoiseColor];
    setBtn.shadowColor = [UIColor greenSeaColor];
    setBtn.shadowHeight = 3.0f;
    setBtn.cornerRadius = 6.0f;
    setBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [setBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [setBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [setBtn setTitle:@"Set" forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(setBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:setBtn];
    
    FUIButton* clearBtn = [[FUIButton alloc] initWithFrame:CGRectMake((itemWidth + itemSep) * 2, (itemHeight + itemLineSep) * 2, itemWidth, itemHeight)];
    clearBtn.buttonColor = [UIColor turquoiseColor];
    clearBtn.shadowColor = [UIColor greenSeaColor];
    clearBtn.shadowHeight = 3.0f;
    clearBtn.cornerRadius = 6.0f;
    clearBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [clearBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:clearBtn];
    
    // Add solve related control parts
    CGFloat longItemWidth = 1.4 * itemWidth;
    
    FUIButton* solveBtn = [[FUIButton alloc] initWithFrame:CGRectMake(boardLength - longItemWidth - itemWidth - itemSep, (itemHeight + itemLineSep) * 3, longItemWidth, itemHeight)];
    solveBtn.buttonColor = [UIColor sunflowerColor];
    solveBtn.shadowColor = [UIColor orangeColor];
    solveBtn.shadowHeight = 3.0f;
    solveBtn.cornerRadius = 6.0f;
    solveBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [solveBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [solveBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [solveBtn setTitle:@"Solve" forState:UIControlStateNormal];
    [solveBtn addTarget:self action:@selector(solveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:solveBtn];
    
    FUIButton* resetBtn = [[FUIButton alloc] initWithFrame:CGRectMake(boardLength - longItemWidth, (itemHeight + itemLineSep) * 3, longItemWidth, itemHeight)];
    resetBtn.buttonColor = [UIColor silverColor];
    resetBtn.shadowColor = [UIColor asbestosColor];
    resetBtn.shadowHeight = 3.0f;
    resetBtn.cornerRadius = 6.0f;
    resetBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [resetBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:resetBtn];
    
    // Add a debug button
    FUIButton* debugBtn = [[FUIButton alloc] initWithFrame:CGRectMake(0, (itemHeight + itemLineSep) * 3, 0.8 * itemWidth, itemHeight)];
    debugBtn.buttonColor = [UIColor alizarinColor];
    debugBtn.shadowColor = [UIColor pomegranateColor];
    debugBtn.shadowHeight = 3.0f;
    debugBtn.cornerRadius = 6.0f;
    debugBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [debugBtn setTitle:@"Demo" forState:UIControlStateNormal];
    [debugBtn addTarget:self action:@selector(debugBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:debugBtn];
    
    [self.view addSubview:controlView];
}

# pragma mark - Helper methods
- (NSMutableArray*)findFourNeighborsForCell:(NSInteger)cellIndex {
    NSMutableArray* neighbors = [[NSMutableArray alloc] init];
    if (cellIndex - 9 >= 0) {
        [neighbors addObject:[NSNumber numberWithInteger:cellIndex - 9]];
    }
    
    if (cellIndex % 9 != 0) {
        [neighbors addObject:[NSNumber numberWithInteger: cellIndex - 1]];
    }
    
    if ((cellIndex + 1) % 9 != 0) {
        [neighbors addObject:[NSNumber numberWithInteger: cellIndex + 1]];
    }
    
    if (cellIndex + 9 < 81) {
        [neighbors addObject:[NSNumber numberWithInteger:cellIndex + 9]];
    }
    
    return neighbors;
}

- (void)drawInnerLines:(NSArray*)cells {
    BOOL hasLeft, hasRight, hasTop, hasBelow, lt, rt, lb, rb;
    for (NSNumber* index in cells) {
        NSInteger cellIndex = [index integerValue];
        hasLeft = false;
        hasRight = false;
        hasTop = false;
        hasBelow = false;
        lt = false;
        rt = false;
        lb = false;
        rb = false;
        
        NSNumber* left = [NSNumber numberWithInteger:(cellIndex - 1)];
        NSNumber* right = [NSNumber numberWithInteger:(cellIndex + 1)];
        NSNumber* top = [NSNumber numberWithInteger:(cellIndex - 9)];
        NSNumber* below = [NSNumber numberWithInteger:(cellIndex + 9)];
        NSNumber* leftTop = [NSNumber numberWithInteger:(cellIndex - 1 - 9)];
        NSNumber* rightTop = [NSNumber numberWithInteger:(cellIndex + 1 - 9)];
        NSNumber* leftBelow = [NSNumber numberWithInteger:(cellIndex - 1 + 9)];
        NSNumber* rightBelow = [NSNumber numberWithInteger:(cellIndex + 1+ 9)];
        
        // Has right
        if ([cells containsObject:right]) {
            hasRight = true;
        }
        // Has left
        if ([cells containsObject:left]) {
            hasLeft = true;
        }
        // Has below
        if ([cells containsObject:below]) {
            hasBelow = true;
        }
        // Has top
        if ([cells containsObject:top]) {
            hasTop = true;
        }
        
        // Left top corner
        if ([cells containsObject:left] && [cells containsObject:top] && ![cells containsObject:leftTop]) {
            lt = true;
        }
        
        // Right top corner
        if ([cells containsObject:right] && [cells containsObject:top] && ![cells containsObject:rightTop]) {
            rt = true;
        }
        
        // Left below corner
        if ([cells containsObject:left] && [cells containsObject:below] && ![cells containsObject:leftBelow]) {
            lb = true;
        }
        
        // Right below corner
        if ([cells containsObject:right] && [cells containsObject:below] && ![cells containsObject:rightBelow]) {
            rb = true;
        }
        
        PlayCellButton* cell = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
        [cell setBorderFlagsLeft:hasLeft Right:hasRight Top:hasTop Below:hasBelow];
        [cell setCornerFlagsLT:lt RT:rt LB:lb RB:rb];
    }
}

- (BOOL)validate {
    // Checking every cell has joined a cage
    for (int index = 0; index < 81; index++) {
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:(index / 9)] objectAtIndex:(index % 9)];

        if (![cellBtn getHasJoined]) {
            // Cell index hasn't joined any cage
            self.promptLabel.text = @"  Error: not all cells joined.";
            return false;
        }
    }
    
    // Checking every cage has a sum
    for (NSNumber* cageID in [self.uf getAllComponents]) {
        if ([self.sums objectForKey:cageID] == nil) {
            // No sum set for cageID
            self.promptLabel.text = @"  Error: not all cages have sum.";
            return false;
        }
    }
    
    // Checking total sum equals 405
    NSInteger totalSum = 0;
    for (NSNumber* sum in [self.sums allValues]) {
        totalSum += [sum integerValue];
    }
    if (totalSum != 405) {
        // Total sum not equal to 405
        self.promptLabel.text = @"  Error: total sum unequal to 405.";
        return false;
    }

    return true;
}

- (void)clearSelection {
    // Clear current selections;
    for (NSNumber* index in self.selectedCells) {
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
        cellBtn.backgroundColor = [UIColor clearColor];
    }
    [self.selectedCells removeAllObjects];
}

# pragma mark - Action methods
- (void)backBtnPressed {
    [self.soundPlayer playButtonSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cellBtnPressed:(PlayCellButton*)sender {
    // Add all the cells within the same cage of this pressed cell into selectedCells array
    NSArray* indices = [self.uf getIteratorForComponent:[self.uf find:sender.tag]];
    if ([self.selectedCells containsObject:[NSNumber numberWithInteger:sender.tag]]) {
        // Already selected, remove
        [self.soundPlayer playDeselectSound];
        for (NSNumber* index in indices) {
            [self.selectedCells removeObject:index];
            UIButton* cellBtn = (UIButton*)[[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
            cellBtn.backgroundColor = [UIColor clearColor];
        }
    } else {
        // Not selected, add
        [self.soundPlayer playSelectSound];
        for (NSNumber* index in indices) {
            [self.selectedCells addObject:index];
            UIButton* cellBtn = (UIButton*)[[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
            cellBtn.backgroundColor = self.selectColor;
        }
    }
}

- (void)joinBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    if (self.isSolved) {
        self.promptLabel.text = @"  Reset before modify.";
        return;
    }
    
    if ([self.selectedCells count] != 0) {
        while ([self.selectedCells count] != 0) {
            NSNumber* oneCell = [self.selectedCells objectAtIndex:0];   // Take any cell
            [self.selectedCells removeObject:oneCell];
            
            NSMutableArray* toCheck = [[NSMutableArray alloc] initWithObjects:oneCell, nil];
            NSMutableArray* toUnion = [[NSMutableArray alloc] init];
            
            while ([toCheck count] != 0) {
                // Take one cell from the toCheck array
                NSNumber* checkCell = [toCheck objectAtIndex:0];
                [toCheck removeObject:checkCell];
                
                // Get all possible 4-way neibor indices
                NSArray* neighbors = [self findFourNeighborsForCell:[checkCell integerValue]];
                for (NSNumber* neighborIndex in neighbors) {
                    if ([self.selectedCells containsObject:neighborIndex]) {
                        [self.selectedCells removeObject:neighborIndex];
                        [toCheck addObject:neighborIndex];
                    }
                }
                
                // Add this checked cell to toUnion array
                [toUnion addObject:checkCell];
            }
            ////////////////////////
            // Join case 1: only one cell
            if ([toUnion count] == 1) {
                [self drawInnerLines:toUnion];  // Single-cell cage, no need to deal with the UF model
            }
            // Join case 2: multiple cages
            else if ([toUnion count] <= 9) {
                NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
                for (NSNumber* index in toUnion) {  // Identify different cageIDs
                    NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
                    if (![cageIDs containsObject:cageID]) {
                        [cageIDs addObject:cageID];
                    }
                }
                
                if ([cageIDs count] > 1) {  // Only join more than one cages
                    // Set the total sum text for the first cell in the joined whole cage, if not 0
                    NSInteger totalSum = 0;
                    for (NSNumber* cageID in cageIDs) {
                        if ([self.sums objectForKey:cageID] != nil) {   // Sum already set for this cage
                            // Add to total sum
                            totalSum += [[self.sums objectForKey:cageID] integerValue];
                            // Remove the sum from self.sums
                            [self.sums removeObjectForKey:cageID];
                            // Remove sum text for this cage
                            NSNumber* firstCell = [[self.uf getIteratorForComponent:[cageID integerValue]] objectAtIndex:0];
                            PlayCellButton* cell = [[self.boardCells objectAtIndex:([firstCell integerValue] / 9)] objectAtIndex:([firstCell integerValue] % 9)];
                            [cell clearSum];
                        }
                    }
                    
                    // Join in UF model, connect all other cages with the first cage
                    for (int i = 1; i < [cageIDs count]; i++) {
                        [self.uf connect:[[cageIDs objectAtIndex:i] integerValue] with:[[cageIDs objectAtIndex:0] integerValue]];
                    }
                    
                    // Join in view
                    [self drawInnerLines:toUnion];
                    
                    // Set the total sum for joined whole cage, if not 0
                    if (totalSum != 0) {
                        NSNumber* wholeCageID = [cageIDs objectAtIndex:0];
                        [self.sums setObject:[NSNumber numberWithInteger:totalSum] forKey:wholeCageID];
                        NSNumber* firstCell = [[self.uf getIteratorForComponent:[wholeCageID integerValue]] objectAtIndex:0];
                        PlayCellButton* cell = [[self.boardCells objectAtIndex:([firstCell integerValue] / 9)] objectAtIndex:([firstCell integerValue] % 9)];
                        [cell setSum:totalSum];
                    }
                }
            }
            
            for (NSNumber* index in toUnion) {  // Clear the selection color of the unioned cells
                PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
                cellBtn.backgroundColor = [UIColor clearColor];
            }
        }
    }
}

- (void)deleteBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    if (self.isSolved) {
        self.promptLabel.text = @"  Reset before modify.";
        return;
    }
    
    // Delete component in uf
    NSMutableArray* toResotre = [[NSMutableArray alloc] init];
    
    // Clear selection
    NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
    for (NSNumber* index in self.selectedCells) {
        // Clear the selection background color for every cell
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
        cellBtn.backgroundColor = [UIColor clearColor];
        
        // If the cell has joined a cage, remove it
        if ([cellBtn getHasJoined]) {
            // Identify different cages
            NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
            if (![cageIDs containsObject:cageID]) {
                // The first time this cage is seen
                // This cell is the first cell within the cage, it has the sumtext on it, remove it
                [cageIDs addObject:cageID];
                [cellBtn clearSum];
                [self.sums removeObjectForKey:cageID];
            }
            
            // If this cell is not the cageID cell, add it to restore
            if ([index integerValue] != [cageID integerValue]) {
                [toResotre addObject:index];
            }
            
            // Clear the border lines for this cell
            [cellBtn clearBorderLines];
        }
    }
    
    [self.uf restore:toResotre];
    [self.selectedCells removeAllObjects];
}

- (void)setBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    if (self.isSolved) {
        self.promptLabel.text = @"  Reset before modify.";
        return;
    }
    
    BOOL hasNoCage = true;
    for (NSNumber* index in self.selectedCells) {
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
        if ([cellBtn getHasJoined]) {
            hasNoCage = false;
            break;
        }
    }
    
    if (hasNoCage) {
        // Prompt no cage selected
        self.promptLabel.text = @"  No joined cage selected.";
        return;
    }
    
    // Build an input alert view to get the sum
    self.promptLabel.text = @"  ";
    FUIAlertView* sumAlertView = [[FUIAlertView alloc] initWithTitle:@"Sum" message:@"Input sum for selected cages." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Enter", nil];
    sumAlertView.alertViewStyle = FUIAlertViewStylePlainTextInput;
    
    FUITextField* textField = [sumAlertView textFieldAtIndex:0];
    [textField setTextFieldColor:[UIColor cloudsColor]];
    [textField setBorderColor:[UIColor asbestosColor]];
    [textField setCornerRadius:4];
    [textField setFont:[UIFont flatFontOfSize:14]];
    [textField setTextColor:[UIColor midnightBlueColor]];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    
    sumAlertView.titleLabel.textColor = [UIColor cloudsColor];
    sumAlertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    sumAlertView.messageLabel.textColor = [UIColor cloudsColor];
    sumAlertView.messageLabel.font = [UIFont flatFontOfSize:14];
    sumAlertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    sumAlertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    sumAlertView.defaultButtonColor = [UIColor peterRiverColor];
    sumAlertView.defaultButtonShadowColor = [UIColor belizeHoleColor];
    sumAlertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    sumAlertView.defaultButtonTitleColor = [UIColor cloudsColor];
    sumAlertView.alertContainer.layer.cornerRadius = 3;
    sumAlertView.alertContainer.layer.masksToBounds = YES;
    
    FUIButton* cancelBtn = (FUIButton*)[sumAlertView.buttons objectAtIndex:sumAlertView.cancelButtonIndex];
    cancelBtn.buttonColor = [UIColor cloudsColor];
    cancelBtn.shadowColor = [UIColor asbestosColor];
    cancelBtn.tintColor = [UIColor asbestosColor];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
    
    [sumAlertView show];
}

- (void)clearBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    if (self.isSolved) {
        self.promptLabel.text = @"  Reset before modify.";
        return;
    }
    
    NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
    for (NSNumber* index in self.selectedCells) {
        // Clear the selection background color for every cell
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
        cellBtn.backgroundColor = [UIColor clearColor];
        
        if ([cellBtn getHasJoined]) {
            NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
            if (![cageIDs containsObject:cageID]) {
                [cageIDs addObject:cageID];
                [cellBtn clearSum];
                [self.sums removeObjectForKey:cageID];
            }
        }
    }
    
    [self.selectedCells removeAllObjects];
}

- (void)resetBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    FUIAlertView* confirmAlertView = [[FUIAlertView alloc] initWithTitle:@"Reset" message:@"Are you sure to reset your input puzzle?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    confirmAlertView.titleLabel.textColor = [UIColor cloudsColor];
    confirmAlertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    confirmAlertView.messageLabel.textColor = [UIColor cloudsColor];
    confirmAlertView.messageLabel.font = [UIFont flatFontOfSize:14];
    confirmAlertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    confirmAlertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    confirmAlertView.alertContainer.layer.cornerRadius = 3;
    confirmAlertView.alertContainer.layer.masksToBounds = YES;
    confirmAlertView.defaultButtonColor = [UIColor peterRiverColor];
    confirmAlertView.defaultButtonShadowColor = [UIColor belizeHoleColor];
    confirmAlertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    confirmAlertView.defaultButtonTitleColor = [UIColor cloudsColor];
    
    FUIButton* cancelBtn = (FUIButton*)[confirmAlertView.buttons objectAtIndex:confirmAlertView.cancelButtonIndex];
    cancelBtn.buttonColor = [UIColor cloudsColor];
    cancelBtn.shadowColor = [UIColor asbestosColor];
    cancelBtn.tintColor = [UIColor asbestosColor];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
    
    [confirmAlertView show];
}

- (void)solveBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    if (self.solutions != nil && [self.solutions count] == 1) {
        self.promptLabel.text = @"  Already solved. Reset firstly.";
        return;
    }
    
    if (self.solutions != nil && [self.solutions count] > 1) {
        self.solutionIndex++;
        if (self.solutionIndex == [self.solutions count]) {
            self.solutionIndex = 0;
        }
        
        // Modify cell numbers
        GameBoard* nextSolution = [self.solutions objectAtIndex:self.solutionIndex];
        for (int index = 0; index < 81; index++) {
            PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:(index / 9)] objectAtIndex:(index % 9)];
            NSNumber* num = [nextSolution getNumAtIndex:[NSNumber numberWithInteger:index]];
            
            if ([cellBtn getNum] != [num integerValue]) {
                [cellBtn setNum:num];
            }
        }
        
        self.promptLabel.text = [NSString stringWithFormat:@"  %ld solutions, display sol %ld. Press Solve to see more.", [self.solutions count], self.solutionIndex + 1];
        return;
    }
    
    // Do basic check to ensure the entered game is valid
    if ([self validate]) {
        // Build up the unsolved game
        GameBoard* unsolvedGame = [[GameBoard alloc] initWithUF:self.uf andSums:self.sums];
        
        
        // Create a new thread to call the solver, in order not to block the UI
        self.solvingThread = [[NSThread alloc] initWithTarget:self selector:@selector(callSolver:) object:unsolvedGame];
        
        // Create an alertView to mask the screen
        self.waitView = [[FUIAlertView alloc] initWithTitle:@"Wait" message:@"Solving, please wait." delegate:self cancelButtonTitle:@"Stop solving" otherButtonTitles:nil];
        self.waitView.titleLabel.textColor = [UIColor cloudsColor];
        self.waitView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        self.waitView.messageLabel.textColor = [UIColor cloudsColor];
        self.waitView.messageLabel.font = [UIFont flatFontOfSize:14];
        self.waitView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        self.waitView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        self.waitView.alertContainer.layer.cornerRadius = 3;
        self.waitView.alertContainer.layer.masksToBounds = YES;
        self.waitView.defaultButtonColor = [UIColor cloudsColor];
        self.waitView.defaultButtonShadowColor = [UIColor asbestosColor];
        self.waitView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        self.waitView.defaultButtonTitleColor = [UIColor asbestosColor];
        [self.waitView show];

        [self.solvingThread start];
    }
}

- (void)debugBtnPressed:(FUIButton*)sender {
    [self.soundPlayer playButtonSound];
    
    [self clearSelection];
    NSMutableDictionary* configuration = [[NSMutableDictionary alloc] init];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"multiple_solutions" ofType:@""];
    NSString* file_content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // Do the following process block on each line
    [file_content enumerateLinesUsingBlock:^(NSString* line, BOOL *stop){
        NSArray* components = [line componentsSeparatedByString:@":"];
        NSArray* indices = [[components objectAtIndex:0] componentsSeparatedByString:@","];
        NSMutableArray* indicesSet = [[NSMutableArray alloc] init];
        // Extract each index number and store in a set
        for (NSString* indexStr in indices) {
            NSNumber* index = [NSNumber numberWithInteger:[indexStr integerValue]];
            [indicesSet addObject:index];
        }
        // Extraact the cage sum number
        NSNumber* sum = [NSNumber numberWithInteger:[[components objectAtIndex:1] integerValue]];
        
        // Add the indices-sum pair into the dictionary
        [configuration setObject:sum forKey:indicesSet];
    }];
    
    // Construct an empty, unsolved game, and obtain an array of solutions.
    // In valid situations, there should be only one solution
    GameBoard* unsolvedGame = [[GameBoard alloc] initWithConfiguration:configuration];
    
    // Apply this game directly in the board
    UnionFind* testUF = [unsolvedGame getUF];
    NSDictionary* testSums = [unsolvedGame getSum];
    self.sums = [NSMutableDictionary dictionaryWithDictionary:testSums];
    self.uf = testUF;
    
    for (NSNumber* cageID in [self.uf getAllComponents]) {
        NSArray* cageCells = [self.uf getIteratorForComponent:[cageID integerValue]];
        [self drawInnerLines:cageCells];    // Draw inner border lines for each cage
        NSNumber* firstCell = [cageCells objectAtIndex:0];
        
        PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([firstCell integerValue] / 9)] objectAtIndex:([firstCell integerValue] %9)];

        NSNumber* sum = [self.sums objectForKey:cageID];
        [cellBtn setSum:[sum integerValue]];   // Set sum text for first cell of each cage
    }
}

#pragma mark - Thread related methods
- (void)callSolver:(GameBoard*)unsolvedGame {
    // Call solver to solve the game
    [Solver setCaller:self];
    NSArray* solutions = [Solver solve:unsolvedGame];
    
    // Update UI in main thread
    [self performSelectorOnMainThread:@selector(finishSolving:) withObject:solutions waitUntilDone:YES];
}

- (void)finishSolving:(NSArray*) solutions {
    self.solutions = solutions;
    
    if (self.solutions != nil && [self.solutions count] != 0) {
        // Has solutions
        self.isSolved = true;
        if ([self.solutions count] == 1) {
            self.promptLabel.text = @"  One solution found!";
        } else {
            self.promptLabel.text = [NSString stringWithFormat:@"  %ld solutions, display sol 1. Press Solve to see more.", [self.solutions count]];
        }
        // Fill the first solution into the board
        GameBoard* firstSolution = [self.solutions objectAtIndex:0];
        for (int index = 0; index < 81; index++) {
            PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:(index / 9)] objectAtIndex:(index % 9)];
            [cellBtn setNum:[firstSolution getNumAtIndex:[NSNumber numberWithInt:index]]];
        }
    } else if ([self.solvingThread isCancelled]) {
        NSLog(@"cancelled");
        self.promptLabel.text = @"  Solving is stopped.";
    } else {
        self.promptLabel.text = @"  No solution found!";
    }
    
    [self.waitView dismissWithClickedButtonIndex:self.waitView.cancelButtonIndex animated:YES];
}

- (void)findSolution:(NSNumber*)count {
    if ([count integerValue] == 1) {
        [self.waitView.messageLabel setText:@"Found 1 solution."];
    } else if ([count integerValue] > 1) {
        [self.waitView.messageLabel setText:[NSString stringWithFormat:@"Found %ld solutions.", [count integerValue]]];
    }
}

#pragma mark - Delegate methods
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.soundPlayer playButtonSound];
    
    if ([alertView.title isEqualToString:@"Sum"]) {
        if (buttonIndex == 1) {
            // Enter
            NSInteger sum = [[alertView textFieldAtIndex:0].text integerValue];
            
            if (1 <= sum && sum <= 45) {
                // Find all different cageIDs
                NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
                for (NSNumber* index in self.selectedCells) {
                    PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:([index integerValue] / 9)] objectAtIndex:([index integerValue] % 9)];
                    
                    if ([cellBtn getHasJoined]) {
                        NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
                        if (![cageIDs containsObject:cageID]) {
                            [cageIDs addObject:cageID];
                        }
                    }
                }
                
                
                for (NSNumber* cageID in cageIDs) {
                    // Set sum in the sums dictionary
                    [self.sums setObject:[NSNumber numberWithInteger:sum] forKey:cageID];
                    
                    // Set sum in the view
                    NSNumber* firstCell = [[self.uf getIteratorForComponent:[cageID integerValue]] objectAtIndex:0];
                    PlayCellButton* cellToAdd = [[self.boardCells objectAtIndex:([firstCell integerValue] / 9)] objectAtIndex:([firstCell integerValue] % 9)];
                    
                    [cellToAdd setSum:sum];
                }
            }
            
            // Clear selection
            [self clearSelection];
        }
    } else if ([alertView.title isEqualToString:@"Wait"]) {
        // Stop solving
        [self.solvingThread cancel];
    } else if ([alertView.title isEqualToString:@"Reset"]) {
        if (buttonIndex == 1) {
            // Yes
            self.uf = [[UnionFind alloc] initWithCapacity:81];
            [self.sums removeAllObjects];
            [self clearSelection];
            self.solutionIndex = 0;
            self.promptLabel.text = @" ";
            self.isSolved = false;
            if (self.solutions != nil) {
                self.solutions = nil;
            }
            
            for (int index = 0; index < 81; index++) {
                PlayCellButton* cellBtn = [[self.boardCells objectAtIndex:(index / 9)] objectAtIndex:(index % 9)];
                [cellBtn clearBorderLines];
                [cellBtn clearSum];
                [cellBtn clearNum];
            }
        }
    }
}

- (void)didPresentAlertView:(FUIAlertView *)alertView {
    // Show keyboard and focust on the text field after showing alert view
    if ([alertView.title isEqualToString:@"Sum"]) {
        [[alertView textFieldAtIndex:0] becomeFirstResponder];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
