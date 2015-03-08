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

@interface SolverViewController ()
// Model related properties
@property(strong, nonatomic)NSMutableArray* boardCells;
@property(strong, nonatomic)NSMutableArray* selectedCells;
@property(strong, nonatomic)NSMutableDictionary* sums;
@property(strong, nonatomic)UnionFind* uf;
@property(strong, nonatomic)NSArray* solutions;
@property(nonatomic)NSInteger solutionIndex;

// View related properties
@property(strong, nonatomic)BoardView* boardView;
@property(strong, nonatomic)UIColor* selectColor;
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
    
    // Do any additional setup after loading the view.
    [self stylize];
    [self drawBoard];
    [self addCellBtns];
}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

# pragma mark - Drawing methods
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
        }
    }
}

# pragma mark - Action methods
- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
