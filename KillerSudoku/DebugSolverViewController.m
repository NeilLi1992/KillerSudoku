//
//  SolverViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 14/11/11.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "DebugSolverViewController.h"
#import "UnionFind.h"
#import "solverCellButton.h"
#import "GameBoard.h"
#import "Solver.h"

@interface DebugSolverViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *solvingPromptLabel;
@property (weak, nonatomic) IBOutlet UITextField *sumTextField;
@property (weak, nonatomic) IBOutlet UILabel *erroLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property(strong, nonatomic)NSMutableArray* selectedCells;  // Store the index NSNumber of each cell during each selection
@property(strong, nonatomic)UIColor* selectColor;
@property(nonatomic, strong)NSMutableDictionary* sums;  //represent the sums of cages, store (key=cageId, value=sum) pair
@property(nonatomic, strong)UnionFind* uf;  // uf object can completely determines the state of the cage
@property(nonatomic, strong)NSArray* solutions;
@property(nonatomic)NSInteger solutionIndex;
@property(nonatomic)BOOL isSolving;
@end

@implementation DebugSolverViewController

CGFloat screenWidth;
CGFloat screenHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.selectColor = [UIColor colorWithRed:191/255.0 green:255/255.0 blue:254/255.0 alpha:1]; // Indicate selection
    self.selectedCells = [[NSMutableArray alloc] init];
    self.sums = [[NSMutableDictionary alloc] init];
    self.uf = [[UnionFind alloc] initWithCapacity: 81];
    self.sumTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(backgroundTouched:)];
    
    [self.view addGestureRecognizer:tap];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    self.spinner.hidden = true;
    self.solvingPromptLabel.hidden = true;
    self.nextBtn.hidden = true;
    self.isSolving = false;
    
    // Draw the board
    [self drawBoard];
}

/*!
 * Draw the board lines
 */
- (void)drawBoard {
    CGFloat boardLength = screenWidth;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat baseY = statusBarHeight + navigationBarHeight;
    CGFloat cellLength = boardLength / 9.0f;
    
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

    // draw board cells
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            // Generate a cellView and set it properly
            solverCellButton* cellBtn = [[solverCellButton alloc] initWithFrame:CGRectMake(j * cellLength, i * cellLength + baseY, cellLength, cellLength)];
            cellBtn.layer.borderColor = [UIColor blackColor].CGColor;
            cellBtn.layer.borderWidth = 0.5f;
            cellBtn.tag = i * 9 + j + 1;

            [self.view addSubview:cellBtn];
            [cellBtn addTarget:self action:@selector(cellTouched:) forControlEvents:UIControlEventTouchDown];
        }
    }
}

#pragma -mark helper methods
/*!
 * Find all the 4-way neighbors' indices for the given cell
 * Indices out of range won't be selected
 */
-(NSMutableArray*)findFourNeighborsForCell:(NSInteger)cellIndex {
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

-(void)drawInnerLines:(NSArray*)cells {
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
        
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[index integerValue] + 1];
        [cell setBorderFlagsLeft:hasLeft Right:hasRight Top:hasTop Below:hasBelow];
        [cell setCornerFlagsLT:lt RT:rt LB:lb RB:rb];
    }
}

-(BOOL)validate {
    // Checking every cell has joined a cage
    for (int index = 0; index < 81; index++) {
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:(index + 1)];
        if (![cell getHasJoined]) {
            // Cell index hasn't joined any cage
            NSLog(@"Cell %d hasn't joined any cage.", index);
            self.erroLabel.text = @"Error: not all cells joined.";
            return false;
        }
    }
    
    // Checking every cage has a sum
    for (NSNumber* cageID in [self.uf getAllComponents]) {
        if ([self.sums objectForKey:cageID] == nil) {
            // No sum set for cageID
            NSLog(@"CageID %d has no sum.", [cageID integerValue]);
            self.erroLabel.text = @"Error: not all cages have sum.";
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
        NSLog(@"Total sum doesn't equal to 405.");
        self.erroLabel.text = @"Error: total sum unequal to 405.";
        return false;
    }

    return true;
}

-(void)clearSelection {
    // Clear current selections
    for (NSNumber* index in self.selectedCells) {
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[index integerValue] + 1];
        cell.backgroundColor = [UIColor clearColor];
    }
    [self.selectedCells removeAllObjects];
}

#pragma -mark action handlers
- (void)cellTouched:(solverCellButton *)sender {
    // Add all the cells within the same cage of this pressed cell into selectedCells array
    NSArray* indices = [self.uf getIteratorForComponent:[self.uf find:sender.tag - 1]]; // Do the minus 1 bias on sender.tag
    
    if ([self.selectedCells containsObject:[NSNumber numberWithInteger:sender.tag - 1]]) {
        // Already selected, remove
        for (NSNumber* index in indices) {
            [self.selectedCells removeObject:index];
            [self.view viewWithTag:[index integerValue] + 1].backgroundColor = [UIColor clearColor];
        }
    } else {
        // Not selected, add
        for (NSNumber* index in indices) {
            [self.selectedCells addObject:index];
            [self.view viewWithTag:[index integerValue] + 1].backgroundColor = self.selectColor;
        }
    }
}

- (IBAction)joinBtnPressed:(id)sender {
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
                    // Deal with sum
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
                            solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[firstCell integerValue] + 1];
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
                        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[firstCell integerValue] + 1];
                        [cell setSum:totalSum];
                    }
                }
            }
            
            for (NSNumber* index in toUnion) {  // Clear the selection color of the unioned cells
                [self.view viewWithTag:[index integerValue] + 1].backgroundColor = [UIColor clearColor];
            }
        }
    }
}

- (IBAction)deleteBtnPressed:(id)sender {
    // Delete component in uf
    NSMutableArray* toResotre = [[NSMutableArray alloc] init];
    
    // Clear selection
    NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
    for (NSNumber* index in self.selectedCells) {
        // Clear the selection background color for every cell
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[index integerValue] + 1];
        cell.backgroundColor = [UIColor clearColor];
        
        // If the cell has joined a cage, remove it
        if ([cell getHasJoined]) {
            // Identify different cages
            NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
            if (![cageIDs containsObject:cageID]) {
                // The first time this cage is seen
                // This cell is the first cell within the cage, it has the sumtext on it, remove it
                [cageIDs addObject:cageID];
                [cell clearSum];
                [self.sums removeObjectForKey:cageID];
            }
            
            // If this cell is not the cageID cell, add it to restore
            if ([index integerValue] != [cageID integerValue]) {
                [toResotre addObject:index];
            }
            
            // Clear the border lines for this cell
            [cell clearBorderLines];
        }
    }
    
    [self.uf restore:toResotre];
    [self.selectedCells removeAllObjects];
}

- (IBAction)enterBtnPressed:(id)sender {
    NSInteger sum = [self.sumTextField.text integerValue];
    [self.sumTextField resignFirstResponder];
    if (1 <= sum && sum <= 45) {
        // Find all different cageIDs
        NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
        for (NSNumber* index in self.selectedCells) {
            solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[index integerValue] + 1];
            if ([cell getHasJoined]) {
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
            solverCellButton* cellToAdd = (solverCellButton*)[self.view viewWithTag:[firstCell integerValue] + 1];
            [cellToAdd setSum:sum];
        }
    }
    
    // Clear sum text, clear selection
    self.sumTextField.text = @"";
    [self clearSelection];
}

// When clear is pressed, delete sums from selected cages, but keep the cages
- (IBAction)clearBtnPressed:(id)sender {
    NSLog(@"Clear is pressed");
    
    NSMutableArray* cageIDs = [[NSMutableArray alloc] init];
    for (NSNumber* index in self.selectedCells) {
        // Clear the selection background color for every cell
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[index integerValue] + 1];
        cell.backgroundColor = [UIColor clearColor];
        
        if ([cell getHasJoined]) {
            NSNumber* cageID = [NSNumber numberWithInteger:[self.uf find:[index integerValue]]];
            if (![cageIDs containsObject:cageID]) {
                [cageIDs addObject:cageID];
                [cell clearSum];
                [self.sums removeObjectForKey:cageID];
            }
        }
    }
    
    [self.selectedCells removeAllObjects];
}

- (IBAction)solveBtnPressed:(id)sender {
    self.erroLabel.text = @"";
    self.solutionIndex = 0;
    self.nextBtn.hidden = true;
    
    // Do basic check to ensure the entered game is valid
    if ([self validate]) {
        NSLog(@"Validated, OK to solve.");
        // Build up the unsolved game
        GameBoard* unsolvedGame = [[GameBoard alloc] initWithUF:self.uf andSums:self.sums];
        
        // Show spinner and solving prompt label
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        self.solvingPromptLabel.hidden = false;
        self.isSolving = true;
        
        self.view.userInteractionEnabled = false;
        
        // Create a new thread to call the solver, in order not to block the UI
        NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(callSolver:) object:unsolvedGame];
        [thread start];
    }
}

- (IBAction)nextBtnPressed:(id)sender {
    // Change solutionIndex
    self.solutionIndex++;
    if (self.solutionIndex == [self.solutions count]) {
        self.solutionIndex = 0;
    }
    
    // Modify cell numbers
    GameBoard* nextSolution = [self.solutions objectAtIndex:self.solutionIndex];
    for (int index = 0; index < 81; index++) {
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:(index + 1)];
        NSNumber* num = [nextSolution getNumAtIndex:[NSNumber numberWithInteger:index]];
        if ([cell getNum] != [num integerValue]) {
            [cell setNum:num];
        }
    }
    
    self.erroLabel.text = [NSString stringWithFormat:@"%d solutions, display sol %d.", [self.solutions count], self.solutionIndex + 1];
}

// Resign sumTextField as first responder when background touched
-(void)backgroundTouched:(id)sender {
    // Hide keyboard for sumtext field
    [self.sumTextField resignFirstResponder];
    self.sumTextField.text = @"";
    
    // Clear current selections
    [self clearSelection];
}

- (IBAction)resetBtnPressed:(id)sender {
    self.uf = [[UnionFind alloc] initWithCapacity:81];
    [self.sums removeAllObjects];
    [self clearSelection];
    self.nextBtn.hidden = true;
    self.erroLabel.text = @"";
    if (self.solutions != nil) {
        self.solutions = nil;
    }
    
    for (int index = 0; index < 81; index++) {
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:(index + 1)];
        [cell clearBorderLines];
        [cell clearSum];
        [cell clearNum];
    }
}

- (IBAction)debugBtnPressed:(id)sender {
    [self clearSelection];
    NSMutableDictionary* configuration = [[NSMutableDictionary alloc] init];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"game3" ofType:@""];
    NSString* file_content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
//    NSMutableString* game_file = [NSMutableString stringWithString:@"/Users/neilli1992/Y3S1/Final Year Project/Code/KillerSudoku/KillerSudoku/"];
//    NSString* game_name = @"game3";
//    [game_file appendString:game_name];
    
//    NSString* file_content = [[NSString alloc] initWithContentsOfFile:game_file encoding:NSUTF8StringEncoding error:nil];
    
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
        solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:[firstCell integerValue] + 1];
        NSNumber* sum = [self.sums objectForKey:cageID];
        [cell setSum:[sum integerValue]];   // Set sum text for first cell of each cage
    }
}

#pragma mark thead related methods
- (void)callSolver:(GameBoard*)unsolvedGame {
    // Calling solver to solve the game
    NSArray* solutions = [Solver solve:unsolvedGame];
    NSLog(@"Solving completed!");
    for (GameBoard* solution in solutions) {
        NSLog(@"%@", solution);
    }
    
    // Update UI in main thread
    [self performSelectorOnMainThread:@selector(finishSolving:) withObject:solutions waitUntilDone:YES];
}

- (void)finishSolving:(NSArray*) solutions {
    // Hide spinner and solving prompt label
    [self.spinner stopAnimating];
    self.spinner.hidden = true;
    self.solvingPromptLabel.hidden = true;

    self.solutions = solutions;
    
    // Fill the board with solved solutions
    if ([self.solutions count] == 0) {
        NSLog(@"No solution.");
        self.erroLabel.text = @"No solution found!";
        for (int index = 0; index < 81; index++) {
            solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:(index + 1)];
            [cell clearNum];
        }
    } else {
        // Has solutions
        if ([self.solutions count] == 1) {
            self.erroLabel.text = @"Unique solution found!";
        } else {
            self.erroLabel.text = [NSString stringWithFormat:@"%d solutions, display sol 1.", [self.solutions count]];
            // Provide a way to show more solutions
            self.nextBtn.hidden = false;
        }
        // Fill the first solution into the board
        GameBoard* firstSolution = [self.solutions objectAtIndex:0];
        for (int index = 0; index < 81; index++) {
            solverCellButton* cell = (solverCellButton*)[self.view viewWithTag:(index + 1)];
            [cell setNum:[firstSolution getNumAtIndex:[NSNumber numberWithInt:index]]];
        }
    }
    
    self.view.userInteractionEnabled = true;
}


#pragma mark delegate methods
-(void)showKeyboard:(NSNotification*)notification {
    NSDictionary* info = notification.userInfo;
    NSValue* value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - keyboardFrame.size.height), self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void)hideKeyboard:(NSNotification*)notification {
    NSDictionary* info = notification.userInfo;
    NSValue* value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + keyboardFrame.size.height), self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}


@end
