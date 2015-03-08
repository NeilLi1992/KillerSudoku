//
//  PlayViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/6.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "PlayViewController.h"
#import "FUIButton.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "BoardView.h"
#import "NSString+Icons.h"
#import "Generator.h"
#import "PlayCellButton.h"

@interface PlayViewController () <FUIAlertViewDelegate>
// Model related properties
@property(strong, nonatomic)GameBoard* unsolvedGame;
@property(strong, nonatomic)NSArray* solutionGrid;
@property(strong, nonatomic)Combination* combination;
@property(strong, nonatomic)NSThread* generatingThread;
@property(strong, nonatomic)NSArray* candidateColors;
@property(strong, nonatomic)NSMutableArray* boardCells;
@property(strong, nonatomic)PlayCellButton* selectedCell;
@property(strong, nonatomic)NSNumber* selectedCage;
@property(nonatomic)BOOL noteMode;
@property(nonatomic)NSInteger finishedCount;

// User preferences
@property(strong, nonatomic)NSString* cellStyle;

// View related properties
@property(strong, nonatomic)FUIAlertView* waitView;
@property(strong, nonatomic)BoardView* boardView;
@property(strong, nonatomic)UILabel* hintSum;
@property(strong, nonatomic)UITextView* hintText;
@end

@implementation PlayViewController

// Define some UI related parameters
CGFloat boardLength;
CGFloat cellLength;
CGFloat horiPadding;
CGFloat vertPadding;
CGFloat baseY;
CGFloat outerLineWidth;
CGFloat innerLineWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    horiPadding = 10;
    vertPadding = 10;
    boardLength = [UIScreen mainScreen].bounds.size.width - 2 * horiPadding;
    cellLength = boardLength / 9.0f;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    baseY = statusBarHeight + navigationBarHeight;
    outerLineWidth = 2.0;
    innerLineWidth = 1.0;
    
    self.isPlaying = true;
    self.boardCells = [[NSMutableArray alloc] init];
    self.noteMode = false;
    self.finishedCount = 80;
    
    
    // Load user preferences
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    self.cellStyle = [preferences stringForKey:@"cellStyle"];
    
    // Stylize and draw board
    [self stylize];
    [self drawBoard];
    [self drawHint];
    [self drawControl];
}

- (void)viewDidAppear:(BOOL)animated {
    // Create a new thread to call the solver
    self.generatingThread = [[NSThread alloc] initWithTarget:self selector:@selector(callGenerator) object:nil];
    
    // Create a alertView to mask the screen
    self.waitView = [[FUIAlertView alloc] initWithTitle:@"Wait" message:@"Game generating, please wait." delegate:self cancelButtonTitle:@"Stop generating" otherButtonTitles:nil];
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
    
    [self.generatingThread start];
}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    self.title = @"Play";
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed)];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    
}
#pragma mark - Drawing methods
- (void)drawBoard {
    // Draw board view
    self.boardView = [[BoardView alloc] initWithFrame:CGRectMake(horiPadding, vertPadding+baseY, boardLength, boardLength)];
    [self.boardView setInnerLineWidth:innerLineWidth];
    self.boardView.backgroundColor = [UIColor silverColor];
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

- (void)drawHint {
    CGFloat hintViewX = horiPadding;
    CGFloat hintViewY = baseY + 2 * vertPadding + boardLength;
    CGFloat hintViewWidth = (boardLength - horiPadding) * 2.0f / 5.0f;
    CGFloat hintViewHeight = [UIScreen mainScreen].bounds.size.height - baseY - boardLength - 3 * vertPadding;
    
    UIView* hintView = [[UIView alloc] initWithFrame:CGRectMake(hintViewX, hintViewY, hintViewWidth, hintViewHeight)];
    hintView.layer.borderColor = [UIColor midnightBlueColor].CGColor;
    hintView.layer.borderWidth = outerLineWidth;
    hintView.layer.cornerRadius = 6;
    hintView.backgroundColor = [UIColor turquoiseColor];
    
    // Add a hint sum view
    CGFloat hintSumHeight = 20;
    CGFloat sepLineWidth = outerLineWidth;
    self.hintSum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, hintView.frame.size.width, hintSumHeight)];
    self.hintSum.font = [UIFont boldFlatFontOfSize:12];
    self.hintSum.textColor = [UIColor whiteColor];
    self.hintSum.text = @"Cage Sum";
    self.hintSum.textAlignment = NSTextAlignmentCenter;
    [hintView addSubview:self.hintSum];
    
    // Add a separate line view
    UIView* sepLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.hintSum.frame.size.height, hintView.frame.size.width, sepLineWidth)];
    sepLineView.backgroundColor = [UIColor midnightBlueColor];
    [hintView addSubview:sepLineView];
    
    // Add a hint text view
    self.hintText = [[UITextView alloc] initWithFrame:CGRectMake(0, self.hintSum.frame.size.height + sepLineWidth, hintView.frame.size.width, hintView.frame.size.height-sepLineWidth-self.hintSum.frame.size.height)];
    self.hintText.backgroundColor = [UIColor clearColor];
    self.hintText.text = @"Possible combinations will be listed here.";
    self.hintText.font = [UIFont boldFlatFontOfSize:10];
    self.hintText.textColor = [UIColor whiteColor];
    self.hintText.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
    self.hintText.scrollEnabled = YES;
    self.hintText.editable = NO;
    self.hintText.selectable = NO;
    [hintView addSubview:self.hintText];
    
    [self.view addSubview:hintView];
}

- (void)drawControl {
    CGFloat ctlViewX = 2 * horiPadding + (boardLength - horiPadding) * 2.0f / 5.0f;
    CGFloat ctlViewY = baseY + 2 * vertPadding + boardLength;
    CGFloat ctlViewWidth = (boardLength - horiPadding) * 3.0f / 5.0f;
    CGFloat ctlViewHeight = [UIScreen mainScreen].bounds.size.height - baseY - boardLength - 3 * vertPadding;
    
    UIView* ctlView = [[UIView alloc] initWithFrame:CGRectMake(ctlViewX, ctlViewY, ctlViewWidth, ctlViewHeight)];
    
    // Add control buttons
    CGFloat btnPadding = 3.0f;
    CGFloat btnWidth = (ctlViewWidth - 2 * btnPadding) / 3.0f;
    CGFloat btnHeight = (ctlViewHeight - 3 * btnPadding) / 4.0f;
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            CGFloat btnX = j * (btnWidth + btnPadding);
            CGFloat btnY = i * (btnHeight + btnPadding);
            FUIButton* btn = [[FUIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
            btn.buttonColor = [UIColor peterRiverColor];
            btn.shadowColor = [UIColor belizeHoleColor];
            btn.shadowHeight = 3.0f;
            btn.cornerRadius = 6.0f;
            btn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            [btn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
            
            switch (i * 3 + j) {
                case 9:
                    // Check btn
                    [btn setTitle:@"Check" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchDown];
                    break;
                case 10:
                    // Clear btn
                    [btn setTitle:@"-" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(ctlBtnPressed:) forControlEvents:UIControlEventTouchDown];
                    break;
                case 11:
                    // Note btn
                    [btn setTitle:@"Note" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(noteBtnPressed:) forControlEvents:UIControlEventTouchDown];
                    break;
                default:
                    // Num btn
                    [btn setTitle:[[NSNumber numberWithInt:(i * 3 + j + 1)] stringValue] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(ctlBtnPressed:) forControlEvents:UIControlEventTouchDown];
                    break;
            }
            [ctlView addSubview:btn];
        }
    }
    
    [self.view addSubview:ctlView];
}

- (void)addCellBtns {
    // Generation is finished, add cell buttons to board
    BOOL isColorStyle =  [self.cellStyle isEqualToString:@"color"];
    
    
    // Add cell buttons
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
            btn.titleLabel.text = @" ";
            [btn addTarget:self action:@selector(cellBtnPressed:) forControlEvents:UIControlEventTouchDown];
            
            // Save the cell button in boardCells array
            [[self.boardCells objectAtIndex:i] addObject:btn];
            [self.boardView addSubview:btn];
        }
    }
    
    if (isColorStyle) {
        // Use color block style
        [self loadColors];
        NSArray* colorMatrix = [self buildColorMatrix];
        
        // Set the cell's background according to colorMatrix
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                PlayCellButton* btn = [[self.boardCells objectAtIndex:i] objectAtIndex:j];
                btn.backgroundColor = [self.candidateColors objectAtIndex:[[[colorMatrix objectAtIndex:i] objectAtIndex:j] integerValue]];
            }
        }
    } else {
        // Use line style
        for (NSArray* indices in [self.unsolvedGame getIteratorForCages]) {
            [self drawInnerLines:indices];
        }
    }
    
    // Add sum number to each cage
    for (NSArray* indecies in [self.unsolvedGame getIteratorForCages]) {
        NSNumber* firstIndex = [indecies objectAtIndex:0];
        NSNumber* cageId = [self.unsolvedGame getCageIdAtIndex:firstIndex];
        NSInteger row = [firstIndex integerValue] / 9;
        NSInteger col = [firstIndex integerValue] % 9;
        NSNumber* sum = [self.unsolvedGame getCageSumAtIndex:cageId];
        NSInteger x = isColorStyle ? 2 : 3;
        NSInteger y = isColorStyle ? -5 : -4;
        NSInteger width = 20;
        NSInteger height = 20;
        NSInteger fontSize = isColorStyle ? 8 : 7;
        
        UIButton* btn = [[self.boardCells objectAtIndex:row] objectAtIndex:col];
        
        UILabel* sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [sumLabel setFont:[UIFont systemFontOfSize:fontSize]];
        sumLabel.text = [sum stringValue];
        [btn addSubview:sumLabel];
    }
}

-(void)drawInnerLines:(NSArray*)cells {
    BOOL hasLeft, hasRight, hasTop, hasBelow, lt, rt, lb, rb;
    for (NSNumber* index in cells) {
        NSInteger cellIndex = [index integerValue];
        NSInteger row = [index integerValue] / 9;
        NSInteger col = [index integerValue] % 9;

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
        
        PlayCellButton* cell = [[self.boardCells objectAtIndex:row] objectAtIndex:col];
        [cell setBorderFlagsLeft:hasLeft Right:hasRight Top:hasTop Below:hasBelow];
        [cell setCornerFlagsLT:lt RT:rt LB:lb RB:rb];
    }
}

#pragma mark - Helper methods
- (void)loadColors {
    self.candidateColors = [[NSArray alloc] initWithObjects:
                            [UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1],  // Light coral
                            [UIColor colorWithRed:205/255.0 green:133/255.0 blue:63/255.0 alpha:1],  // Peru
                            [UIColor colorWithRed:154/255.0 green:205/255.0 blue:50/255.0 alpha:1],   // Green yellow
                            [UIColor colorWithRed:72/255.0 green:209/255.0 blue:204/255.0 alpha:1], // Medium turquoise
                            [UIColor colorWithRed:230/255.0 green:230/255.0 blue:250/255.0 alpha:1],  // Lavender
                            [UIColor colorWithRed:147/255.0 green:112/255.0 blue:219/255.0 alpha:1],  // Medium purple
                            [UIColor colorWithRed:245/255.0 green:222/255.0 blue:179/255.0 alpha:1] ,nil];  // Wheat
}

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

- (void)checkDuplicate:(PlayCellButton*)cell From:(NSString*)ori To:(NSString*)now {
    NSInteger index = (NSInteger)cell.tag;
    NSInteger row = index / 9;
    NSInteger col = index % 9;
    
    NSMutableSet* cellsToCheck = [[NSMutableSet alloc] init];
    // Check for row
    NSMutableArray* checkingRow = [self.boardCells objectAtIndex:row];
    for (PlayCellButton* cell in checkingRow) {
        if (cell.tag != index) {
            [cellsToCheck addObject:cell];
        }
    }
    
    // Check for column
    for (int i = 0; i < 9; i++) {
        PlayCellButton* cell = [[self.boardCells objectAtIndex:i] objectAtIndex:col];
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
            PlayCellButton* cell = [[self.boardCells objectAtIndex:(i + delta_i)] objectAtIndex:(j + delta_j)];
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
    
    // Do check now
    for (PlayCellButton* checkingCell in cellsToCheck) {
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

- (void)finishGame {
    // Disable user interaction
    self.view.userInteractionEnabled = NO;
    FUIAlertView* finishAlertView = [[FUIAlertView alloc] initWithTitle:@"Finish" message:@"Congradulations!\nYou finished the game! " delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
    
    // Stylize the alert view
    finishAlertView.titleLabel.textColor = [UIColor cloudsColor];
    finishAlertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    finishAlertView.messageLabel.textColor = [UIColor cloudsColor];
    finishAlertView.messageLabel.font = [UIFont flatFontOfSize:14];
    finishAlertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    finishAlertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    finishAlertView.alertContainer.layer.cornerRadius = 3;
    finishAlertView.alertContainer.layer.masksToBounds = YES;
    finishAlertView.defaultButtonColor = [UIColor cloudsColor];
    finishAlertView.defaultButtonShadowColor = [UIColor asbestosColor];
    finishAlertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    finishAlertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    [finishAlertView show];

}


#pragma mark - Action methods
- (void)backBtnPressed {
    // Check if the game is ongoing
    if (self.view.userInteractionEnabled) {
        // Build the alert view for play choice
        FUIAlertView* alertView = [[FUIAlertView alloc] initWithTitle:@"Sure"
                                                              message:@"Game unfinished, sure to exit?"
                                                             delegate:self cancelButtonTitle:@"Continue"
                                                    otherButtonTitles:@"Exit now",@"Save game",nil];
        // Stylize the alert view
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        alertView.alertContainer.layer.cornerRadius = 3;
        alertView.alertContainer.layer.masksToBounds = YES;
        alertView.defaultButtonColor = [UIColor turquoiseColor];
        alertView.defaultButtonShadowColor = [UIColor greenSeaColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor whiteColor];
        
        FUIButton* cancelBtn = (FUIButton*)[alertView.buttons objectAtIndex:alertView.cancelButtonIndex];
        cancelBtn.buttonColor = [UIColor cloudsColor];
        cancelBtn.shadowColor = [UIColor asbestosColor];
        cancelBtn.tintColor = [UIColor asbestosColor];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
        
        // Show the alert view
        [alertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cellBtnPressed:(PlayCellButton*)sender {
    // Don't do anything
    if (self.selectedCell == sender) {
        return;
    }
    
    if (self.selectedCell != nil) {
        // Remove the select border
        self.selectedCell.layer.borderColor = 0;
        self.selectedCell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    self.selectedCell = sender;
    sender.layer.borderWidth = 2.0f;
    sender.layer.borderColor = [UIColor belizeHoleColor].CGColor;
    sender.clipsToBounds = YES;
    
    // Modify the hint view if necessary
    NSNumber* index = [NSNumber numberWithInteger:sender.tag];
    NSNumber* cageID = [self.unsolvedGame getCageIdAtIndex:index];
    
    if (self.selectedCage != cageID) {
        // Need to change the hint
        self.selectedCage = cageID;
        
        self.hintSum.text = [[self.unsolvedGame getCageSumAtIndex:cageID] stringValue];
        
        NSMutableArray* combStrList = [[NSMutableArray alloc] init];
        
        for (NSArray* comb in [self.unsolvedGame getCombsForCage:cageID]) {
            NSString* combString = [comb componentsJoinedByString:@"+"];
            [combStrList addObject:combString];
        }
        NSString* hintString = [combStrList componentsJoinedByString:@"\n"];
        
        self.hintText.text = hintString;
    }
    
}

- (void)ctlBtnPressed:(UIButton*)sender {
    NSString* btnLabel = sender.titleLabel.text;
    
    if (self.selectedCell == nil) {
        // No cell selected yet, do nothing
        return;
    }
    
    if (self.noteMode && [self.selectedCell.titleLabel.text isEqualToString:@" "]) {
        // Can set note
        if ([btnLabel isEqualToString:@"-"]) {
            [self.selectedCell clearNote];
        } else {
            [self.selectedCell toggleNote:btnLabel];
        }
    }
    
    if (!self.noteMode) {
        // Write number
        NSInteger row = self.selectedCell.tag / 9;
        NSInteger col = self.selectedCell.tag % 9;
        NSNumber* correctNum = [[self.solutionGrid objectAtIndex:row] objectAtIndex:col];
        if ([btnLabel isEqualToString:@"-"]) {
            // Clear number
            if ([self.selectedCell.titleLabel.text isEqualToString:[correctNum stringValue]]) {
                self.finishedCount--;
            }
            [self checkDuplicate:self.selectedCell From:self.selectedCell.titleLabel.text To:@" "];
            [self.selectedCell clearNum];
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
                [self finishGame];
            }
        }
    }
}

- (void)checkBtnPressed:(UIButton*)sender {
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            PlayCellButton* cell = [[self.boardCells objectAtIndex:i] objectAtIndex:j];
            NSString* cellLabel = cell.titleLabel.text;
            NSNumber* correctNum = [[self.solutionGrid objectAtIndex:i] objectAtIndex:j];
            if (![cellLabel isEqualToString:@""] && ![cellLabel isEqualToString:[correctNum stringValue]]) {
                // This cell is wrong
                [cell setTitleColor:[UIColor pomegranateColor] forState:UIControlStateNormal];
            }
            
        }
    }
}

- (void)noteBtnPressed:(FUIButton*)sender {
    self.noteMode = !self.noteMode;
    if (self.noteMode) {
        // Change to activated style
        sender.buttonColor = [UIColor orangeColor];
        sender.shadowColor = [UIColor pomegranateColor];
        
    } else {
        // Return to normal style
        sender.buttonColor = [UIColor peterRiverColor];
        sender.shadowColor = [UIColor belizeHoleColor];
    }
}

#pragma mark - Delegate methods
-(void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Sure"]) {
        // Back pressed confirm alertView
        switch (buttonIndex) {
            case 1:
                // Exit now
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 2:
                // Save game
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 0:
                // Continue
                return;
            default:
                break;
        }
    } else if ([alertView.title isEqualToString:@"Wait"]) {
        // Generating wait prompt view
        switch (buttonIndex) {
            case 0:
                // Stop generating
                [self.generatingThread cancel];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    } else if ([alertView.title isEqualToString:@"Finish"]) {
        // Game finish alert view
        switch (buttonIndex) {
            case 0:
                // Exit
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
    
    
}

#pragma mark - Thread related methods
-(void)callGenerator {
    // Call generator to generate a new game
    NSArray* generationResult = [Generator generate:self.level];
    
    if (generationResult != nil) {
        self.unsolvedGame = [generationResult objectAtIndex:0];
        self.solutionGrid = [generationResult objectAtIndex:1];
    } else {
        NSLog(@"Didn't get generated game due to cancelled thread.");
    }
    
    [self performSelectorOnMainThread:@selector(finishGenerating) withObject:nil waitUntilDone:YES];
}

-(void)finishGenerating {
    // Dismiss the wait alertView
    [self.waitView dismissWithClickedButtonIndex: self.waitView.cancelButtonIndex
                                          animated: YES];
    [self addCellBtns];
    NSLog(@"Generation finished.");
    NSLog(@"%@", self.solutionGrid);
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
